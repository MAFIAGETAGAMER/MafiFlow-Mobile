import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const MafiFlowApp()); }
const green = Color(0xFF168657);
const expenseRed = Color(0xFFE76F6F);
const defaults = <String, dynamic>{
  'monthly_income': 0.0, 'rent': 0.0, 'savings_goal': 0.0,
  'income_frequency': 'monthly', 'income_start_date': '', 'income_processed_dates': [],
  'monthly_savings': 0.0, 'savings_saved': 0.0, 'savings_processed_months': [],
  'transactions': [], 'monthly_payments': [], 'processed_months': [],
  'custom_categories': [], 'hidden_categories': [], 'ai_provider': 'OpenAI', 'ai_api_key': '',
  'ai_model': '', 'ai_base_url': '', 'ai_history': [], 'setup_completed': false, 'currency': 'USD', 'opening_balance': 0.0,
  'language': 'es', 'theme': 'light'
};
const labels = <String, Map<String,String>>{
  'es': {'home':'Inicio','moves':'Movimientos','monthly':'Pagos','stats':'Estadísticas','ai':'Consejero IA','settings':'Ajustes','balance':'Disponible','income':'Ingresos','expenses':'Gastos','savings':'Meta de ahorro','add':'Agregar','delete':'Eliminar','save':'Guardar','category':'Categoría','amount':'Cantidad','note':'Nota','name':'Nombre','send':'Enviar','wait':'La IA está preparando tu respuesta','providerWait':'Esperando respuesta del proveedor','noData':'Todavía no hay datos','monthIncome':'Ingreso mensual automático','provider':'Proveedor de IA','model':'Modelo','key':'Clave API','import':'Importar JSON desde portapapeles','export':'Copiar copia de seguridad JSON','confirm':'¿Reemplazar todos los datos de este dispositivo?','yes':'Reemplazar','cancel':'Cancelar','settingsSaved':'Ajustes guardados','invalid':'Cantidad o formato no válido','type':'Tipo','extra':'Ingreso extra','expense':'Gasto','payment':'Pago mensual','active':'Activo','paused':'Pausado','language':'Idioma','theme':'Tema','dark':'Oscuro','light':'Claro','newPayment':'Nuevo pago mensual','noKey':'Configura tu clave API en Ajustes.','custom':'URL personalizada','goal':'Ahorro objetivo','error':'Error','loading':'Conectando','backup':'Copia de seguridad copiada (sin clave API)','imported':'Datos importados','recents':'Últimos movimientos','calculator':'Calculadora'},
  'en': {'home':'Home','moves':'Transactions','monthly':'Payments','stats':'Statistics','ai':'AI Advisor','settings':'Settings','balance':'Available','income':'Income','expenses':'Expenses','savings':'Savings goal','add':'Add','delete':'Delete','save':'Save','category':'Category','amount':'Amount','note':'Note','name':'Name','send':'Send','wait':'AI is preparing your response','providerWait':'Waiting for provider response','noData':'No data yet','monthIncome':'Automatic monthly income','provider':'AI provider','model':'Model','key':'API key','import':'Import JSON from clipboard','export':'Copy JSON backup','confirm':'Replace all data on this device?','yes':'Replace','cancel':'Cancel','settingsSaved':'Settings saved','invalid':'Invalid amount or format','type':'Type','extra':'Extra income','expense':'Expense','payment':'Monthly payment','active':'Active','paused':'Paused','language':'Language','theme':'Theme','dark':'Dark','light':'Light','newPayment':'New monthly payment','noKey':'Configure your API key in Settings.','custom':'Custom URL','goal':'Savings goal','error':'Error','loading':'Connecting','backup':'Backup copied (without API key)','imported':'Data imported','recents':'Recent transactions','calculator':'Calculator'}
};
const additionalLabels=<String,Map<String,String>>{
'fr':{'home':'Accueil','moves':'Mouvements','monthly':'Paiements','stats':'Statistiques','ai':'Conseiller IA','settings':'Paramètres','balance':'Disponible','income':'Revenus','expenses':'Dépenses','savings':'Objectif d’épargne','add':'Ajouter','delete':'Supprimer','save':'Enregistrer','category':'Catégorie','amount':'Montant','note':'Note','name':'Nom','send':'Envoyer','wait':'L’IA prépare votre réponse','providerWait':'En attente du fournisseur','noData':'Aucune donnée','monthIncome':'Revenu mensuel automatique','provider':'Fournisseur IA','model':'Modèle','key':'Clé API','import':'Importer JSON','export':'Copier la sauvegarde JSON','confirm':'Remplacer toutes les données ?','yes':'Remplacer','cancel':'Annuler','settingsSaved':'Paramètres enregistrés','invalid':'Montant invalide','type':'Type','extra':'Revenu supplémentaire','expense':'Dépense','payment':'Paiement mensuel','active':'Actif','paused':'Suspendu','language':'Langue','theme':'Thème','dark':'Sombre','light':'Clair','newPayment':'Nouveau paiement mensuel','noKey':'Configurez la clé API dans les paramètres.','custom':'URL personnalisée','goal':'Objectif d’épargne','error':'Erreur','loading':'Connexion','backup':'Sauvegarde copiée','imported':'Données importées','recents':'Dernières opérations'},
'de':{'home':'Start','moves':'Buchungen','monthly':'Zahlungen','stats':'Statistiken','ai':'KI-Berater','settings':'Einstellungen','balance':'Verfügbar','income':'Einnahmen','expenses':'Ausgaben','savings':'Sparziel','add':'Hinzufügen','delete':'Löschen','save':'Speichern','category':'Kategorie','amount':'Betrag','note':'Notiz','name':'Name','send':'Senden','wait':'KI bereitet die Antwort vor','providerWait':'Warte auf Anbieter','noData':'Noch keine Daten','monthIncome':'Automatisches Monatseinkommen','provider':'KI-Anbieter','model':'Modell','key':'API-Schlüssel','import':'JSON importieren','export':'JSON-Sicherung kopieren','confirm':'Alle Daten ersetzen?','yes':'Ersetzen','cancel':'Abbrechen','settingsSaved':'Gespeichert','invalid':'Ungültiger Betrag','type':'Typ','extra':'Zusätzliches Einkommen','expense':'Ausgabe','payment':'Monatszahlung','active':'Aktiv','paused':'Pausiert','language':'Sprache','theme':'Design','dark':'Dunkel','light':'Hell','newPayment':'Neue Monatszahlung','noKey':'API-Schlüssel in Einstellungen eintragen.','custom':'Eigene URL','goal':'Sparziel','error':'Fehler','loading':'Verbinden','backup':'Sicherung kopiert','imported':'Daten importiert','recents':'Letzte Buchungen'},
'bn':{'home':'হোম','moves':'লেনদেন','monthly':'মাসিক পেমেন্ট','stats':'পরিসংখ্যান','ai':'এআই পরামর্শক','settings':'সেটিংস','balance':'অবশিষ্ট','income':'আয়','expenses':'খরচ','savings':'সঞ্চয়ের লক্ষ্য','add':'যোগ করুন','delete':'মুছুন','save':'সংরক্ষণ','category':'বিভাগ','amount':'পরিমাণ','note':'নোট','name':'নাম','send':'পাঠান','wait':'এআই উত্তর প্রস্তুত করছে','providerWait':'সেবাদাতার উত্তরের অপেক্ষায়','noData':'কোনো তথ্য নেই','monthIncome':'মাসিক আয়','provider':'এআই প্রদানকারী','model':'মডেল','key':'এপিআই কী','import':'JSON আমদানি','export':'JSON ব্যাকআপ কপি','confirm':'সব তথ্য বদলাবেন?','yes':'বদলান','cancel':'বাতিল','settingsSaved':'সেটিংস সংরক্ষিত','invalid':'ভুল পরিমাণ','type':'ধরন','extra':'অতিরিক্ত আয়','expense':'খরচ','payment':'মাসিক পেমেন্ট','active':'সক্রিয়','paused':'বন্ধ','language':'ভাষা','theme':'থিম','dark':'ডার্ক','light':'লাইট','newPayment':'নতুন মাসিক পেমেন্ট','noKey':'সেটিংসে এপিআই কী দিন।','custom':'কাস্টম URL','goal':'সঞ্চয়ের লক্ষ্য','error':'ত্রুটি','loading':'সংযোগ','backup':'ব্যাকআপ কপি হয়েছে','imported':'তথ্য আমদানি হয়েছে','recents':'সাম্প্রতিক লেনদেন'}
};
const improvedLabels = <String,Map<String,String>>{
'es': {'opening':'Saldo inicial','currency':'Moneda','manageCategories':'Administrar categorías','newCategory':'Nueva categoría','categoriesHint':'Elige una categoría','categoryName':'Nombre de categoría','removeCategory':'Eliminar categoría','restoreCategories':'Restablecer categorías','categoryInUse':'Esta categoría se usa en movimientos anteriores; los registros no se borrarán.','chartType':'Tipo de gráfica','distribution':'Distribución de gastos','monthlyTrend':'Comparación mensual','categoryShares':'Gastos por categoría','monthComparison':'Comparación con el mes anterior','previousMonth':'Mes anterior','currentMonth':'Mes actual','spendingChange':'Variación de gastos','incomeChange':'Variación de ingresos','noPrevious':'Sin datos del mes anterior','barChart':'Barras','pieChart':'Circular','lineChart':'Líneas','share':'del gasto','expenseCategories':'Categorías de gastos','editCategories':'Editar categorías'},
'en': {'opening':'Opening balance','currency':'Currency','manageCategories':'Manage categories','newCategory':'New category','categoriesHint':'Choose a category','categoryName':'Category name','removeCategory':'Remove category','restoreCategories':'Restore categories','categoryInUse':'Past transactions using this category will be preserved.','chartType':'Chart type','distribution':'Expense distribution','monthlyTrend':'Monthly comparison','categoryShares':'Expenses by category','monthComparison':'Compared with previous month','previousMonth':'Previous month','currentMonth':'Current month','spendingChange':'Expense change','incomeChange':'Income change','noPrevious':'No data for previous month','barChart':'Bars','pieChart':'Pie','lineChart':'Line','share':'of expenses','expenseCategories':'Expense categories','editCategories':'Edit categories'},
'fr': {'opening':'Solde initial','currency':'Devise','manageCategories':'Gérer les catégories','newCategory':'Nouvelle catégorie','categoriesHint':'Choisir une catégorie','categoryName':'Nom de catégorie','removeCategory':'Supprimer la catégorie','restoreCategories':'Réinitialiser les catégories','categoryInUse':'Les anciennes opérations seront conservées.','chartType':'Type de graphique','distribution':'Répartition des dépenses','monthlyTrend':'Comparaison mensuelle','categoryShares':'Dépenses par catégorie','monthComparison':'Par rapport au mois précédent','previousMonth':'Mois précédent','currentMonth':'Mois actuel','spendingChange':'Variation des dépenses','incomeChange':'Variation des revenus','noPrevious':'Aucune donnée du mois précédent','barChart':'Barres','pieChart':'Camembert','lineChart':'Courbe','share':'des dépenses','expenseCategories':'Catégories de dépenses','editCategories':'Modifier les catégories','calculator':'Calculatrice'},
'de': {'opening':'Anfangssaldo','currency':'Währung','manageCategories':'Kategorien verwalten','newCategory':'Neue Kategorie','categoriesHint':'Kategorie auswählen','categoryName':'Kategoriename','removeCategory':'Kategorie entfernen','restoreCategories':'Kategorien zurücksetzen','categoryInUse':'Frühere Buchungen bleiben erhalten.','chartType':'Diagrammtyp','distribution':'Ausgabenverteilung','monthlyTrend':'Monatsvergleich','categoryShares':'Ausgaben nach Kategorie','monthComparison':'Vergleich zum Vormonat','previousMonth':'Vormonat','currentMonth':'Aktueller Monat','spendingChange':'Ausgabenänderung','incomeChange':'Einnahmenänderung','noPrevious':'Keine Daten im Vormonat','barChart':'Balken','pieChart':'Kreis','lineChart':'Linie','share':'der Ausgaben','expenseCategories':'Ausgabenkategorien','editCategories':'Kategorien bearbeiten','calculator':'Rechner'},
'bn': {'opening':'প্রারম্ভিক ব্যালেন্স','currency':'মুদ্রা','manageCategories':'বিভাগ পরিচালনা','newCategory':'নতুন বিভাগ','categoriesHint':'বিভাগ বেছে নিন','categoryName':'বিভাগের নাম','removeCategory':'বিভাগ মুছুন','restoreCategories':'বিভাগ পুনরুদ্ধার','categoryInUse':'আগের লেনদেনগুলো সংরক্ষিত থাকবে।','chartType':'চার্টের ধরন','distribution':'খরচের বিভাজন','monthlyTrend':'মাসিক তুলনা','categoryShares':'বিভাগভিত্তিক খরচ','monthComparison':'আগের মাসের তুলনায়','previousMonth':'আগের মাস','currentMonth':'চলতি মাস','spendingChange':'খরচের পরিবর্তন','incomeChange':'আয়ের পরিবর্তন','noPrevious':'আগের মাসের তথ্য নেই','barChart':'বার','pieChart':'পাই','lineChart':'লাইন','share':'খরচের','expenseCategories':'খরচের বিভাগ','editCategories':'বিভাগ সম্পাদনা','calculator':'ক্যালকুলেটর'}
};
const categoryTranslations = <String,Map<String,String>>{
'Comida':{'es':'Comida','en':'Food','fr':'Alimentation','de':'Lebensmittel','bn':'খাবার'},
'Transporte':{'es':'Transporte','en':'Transport','fr':'Transport','de':'Transport','bn':'পরিবহন'},
'Vivienda':{'es':'Vivienda','en':'Housing','fr':'Logement','de':'Wohnen','bn':'বাসস্থান'},
'Servicios':{'es':'Servicios','en':'Utilities','fr':'Services','de':'Nebenkosten','bn':'ইউটিলিটি'},
'Salud':{'es':'Salud','en':'Health','fr':'Santé','de':'Gesundheit','bn':'স্বাস্থ্য'},
'Entretenimiento':{'es':'Entretenimiento','en':'Entertainment','fr':'Loisirs','de':'Unterhaltung','bn':'বিনোদন'},
'Compras':{'es':'Compras','en':'Shopping','fr':'Achats','de':'Einkäufe','bn':'কেনাকাটা'},
'Educación':{'es':'Educación','en':'Education','fr':'Éducation','de':'Bildung','bn':'শিক্ষা'},
'Otro':{'es':'Otro','en':'Other','fr':'Autre','de':'Sonstiges','bn':'অন্যান্য'},
'Ingreso mensual':{'es':'Ingreso mensual','en':'Monthly income','fr':'Revenu mensuel','de':'Monatseinkommen','bn':'মাসিক আয়'},
'Pago mensual':{'es':'Pago mensual','en':'Monthly payment','fr':'Paiement mensuel','de':'Monatszahlung','bn':'মাসিক পেমেন্ট'}
};
const defaultCategories=['Comida','Transporte','Vivienda','Servicios','Salud','Entretenimiento','Compras','Educación','Otro'];

String monthNow() { final d=DateTime.now(); return '${d.year}-${d.month.toString().padLeft(2,'0')}'; }
String stampNow() => DateTime.now().toIso8601String().replaceFirst('T',' ').substring(0,19);
double number(dynamic n) => n is num ? n.toDouble() : double.tryParse('$n') ?? 0;
String activeCurrency='USD';
String money(num v) => '${{'USD':'\$','CAD':'CA\$','EUR':'€','GBP':'£','BDT':'৳'}[activeCurrency]??'\$'}${v.toStringAsFixed(2)}';
List<Map<String,dynamic>> records(dynamic v) => v is List ? v.whereType<Map>().map((x)=>Map<String,dynamic>.from(x)).toList() : [];

class MafiFlowApp extends StatefulWidget { const MafiFlowApp({super.key}); @override State<MafiFlowApp> createState()=>_MafiFlowAppState(); }
class _MafiFlowAppState extends State<MafiFlowApp> {
  final navKey=GlobalKey<NavigatorState>();
  final messengerKey=GlobalKey<ScaffoldMessengerState>();
  BuildContext get dialogContext => navKey.currentState!.context;

  Map<String,dynamic> data=Map<String,dynamic>.from(defaults);
  bool ready=false; int tab=0;
  String t(String key)=> improvedLabels['${data['language']}']?[key] ?? (additionalLabels[data['language']] ?? labels[data['language']] ?? labels['es']!)[key] ?? labels['en']![key] ?? key;
  String catName(String category)=>categoryTranslations[category]?['${data['language']}']??category;
  List<String> get categories {final hidden=(data['hidden_categories'] as List? ?? []).map((e)=>'$e').toSet();final custom=(data['custom_categories'] as List? ?? []).map((e)=>'$e').where((e)=>e.trim().isNotEmpty);return {...defaultCategories,...custom}.where((e)=>!hidden.contains(e)).toList();}
  String chartMode='pie';
  List<Map<String,dynamic>> get tx=>records(data['transactions']);
  List<Map<String,dynamic>> get payments=>records(data['monthly_payments']);
  bool get dark=>data['theme']=='dark';
  @override void initState(){super.initState();load();}
  Future<void> load() async {final p=await SharedPreferences.getInstance(); final raw=p.getString('mafiflow_data'); if(raw!=null){try{final obj=jsonDecode(raw); if(obj is Map){data={...defaults,...Map<String,dynamic>.from(obj)}; if(!obj.containsKey('setup_completed') || (obj['setup_completed']==true && (records(obj['transactions']).isNotEmpty || number(obj['monthly_income'])>0 || records(obj['monthly_payments']).isNotEmpty))) data['setup_completed']=true;}}catch(_){}} if(data['setup_completed']==true){applyMonthly();applySavingsMonthly();} if(mounted)setState(()=>ready=true);}
  Future<void> persistWithoutRebuild() async {final p=await SharedPreferences.getInstance(); await p.setString('mafiflow_data',jsonEncode(data));}
  void refreshAfterDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }
  Future<void> save() async {
    await persistWithoutRebuild();
    if (mounted) refreshAfterDialog();
  }
  // Register income on its actual payday, independently of opening balance.
  // Monthly legacy data keeps its existing first-of-month behavior.
  void applyIncomeSchedule(){
    final amount=number(data['monthly_income']);
    if(amount<=0)return;
    final now=DateTime.now();
    final today=DateTime(now.year,now.month,now.day);
    final freq='${data['income_frequency']??'monthly'}';
    final raw='${data['income_start_date']??''}';
    DateTime start=DateTime(now.year,now.month,1);
    if(raw.isNotEmpty){
      final parsed=DateTime.tryParse(raw);
      if(parsed!=null)start=DateTime(parsed.year,parsed.month,parsed.day);
    }
    if(start.isAfter(today))return;
    final done=List<String>.from((data['income_processed_dates'] as List?)??[]);
    final seen=done.toSet();
    final list=tx;
    // Do not duplicate income from the old monthly processing system.
    final existing=list.where((x)=>x['type']=='Ingreso mensual' && x['auto_month']!=null).map((x)=>'${x['auto_month']}-01').toSet();
    DateTime cursor=start;
    int count=0;
    while(!cursor.isAfter(today) && count<3660){
      final key='${cursor.year}-${cursor.month.toString().padLeft(2,'0')}-${cursor.day.toString().padLeft(2,'0')}';
      if(!seen.contains(key) && !existing.contains(key)){
        list.add({'date':'$key 09:00:00','type':'Ingreso mensual','category':'Ingreso mensual','amount':amount,'note':'Ingreso automático ($freq)','auto_income_date':key});
        done.add(key);seen.add(key);
      }
      count++;
      if(freq=='daily'){cursor=cursor.add(const Duration(days:1));}
      else if(freq=='weekly'){cursor=cursor.add(const Duration(days:7));}
      else if(freq=='biweekly'){cursor=cursor.add(const Duration(days:14));}
      else {
        final nextMonth=DateTime(cursor.year,cursor.month+1,1);
        final lastDay=DateTime(nextMonth.year,nextMonth.month+1,0).day;
        cursor=DateTime(nextMonth.year,nextMonth.month,start.day>lastDay?lastDay:start.day);
      }
    }
    data['transactions']=list;
    data['income_processed_dates']=done;
  }
  void applyMonthly(){
    final month=monthNow();
    final done=List<String>.from((data['processed_months'] as List?)??[]);
    if(!done.contains(month)){
      final list=tx;
      final stamp='$month-01 09:00:00';
      for(final p in payments){
        if(p['active']==false)continue;
        final v=number(p['amount']);
        if(v>0)list.add({'date':stamp,'type':'Pago mensual','category':'Pago mensual','amount':v,'note':'${p['name']??''}','auto_month':month});
      }
      done.add(month);data['transactions']=list;data['processed_months']=done;
    }
    applyIncomeSchedule();
    save();
  }
  // Reserve savings once per calendar month, without exceeding the target.
  // This is a budgeting reserve, not a real bank transfer.
  void applySavingsMonthly(){
    final month=monthNow();
    final done=List<String>.from((data['savings_processed_months'] as List?)??[]);
    if(done.contains(month))return;
    final goal=number(data['savings_goal']);
    final saved=number(data['savings_saved']);
    final monthly=number(data['monthly_savings']);
    if(goal<=0||monthly<=0||saved>=goal)return;
    final amount=min(monthly,goal-saved);
    data['savings_saved']=saved+amount;
    data['savings_last_amount']=amount;
    data['savings_last_month']=month;
    done.add(month);
    data['savings_processed_months']=done;
    save();
  }
  double savingsForMonth(String month)=>data['savings_last_month']==month?number(data['savings_last_amount']):0;
  ({double income,double spent,double balance}) totals([String? month]) {final list=tx.where((e)=>'${e['date']??''}'.startsWith(month??monthNow()));double inc=0,spent=0;
    for(final e in list){final v=number(e['amount']);if(e['type']=='Ingreso extra'||e['type']=='Ingreso mensual'){inc+=v;}else if(e['type']=='Gasto'||e['type']=='Pago mensual'){spent+=v;}}
    // The opening balance is the real amount already owned at setup.
    // It is never an income transaction. Available balance is cumulative,
    // while income and expenses above are month-specific for statistics.
    final all=tx;
    final totalIncome=all.where((e)=>e['type']=='Ingreso mensual'||e['type']=='Ingreso extra').fold<double>(0,(sum,e)=>sum+number(e['amount']));
    final totalSpent=all.where((e)=>e['type']=='Gasto'||e['type']=='Pago mensual').fold<double>(0,(sum,e)=>sum+number(e['amount']));
    return (income:inc,spent:spent,balance:number(data['opening_balance'])+totalIncome-totalSpent-number(data['savings_saved'])); }
  void notice(String text){messengerKey.currentState?.showSnackBar(SnackBar(content:Text(text)));}
  Widget card(Widget child)=>Card(margin:const EdgeInsets.symmetric(vertical:7),child:Padding(padding:const EdgeInsets.all(16),child:child));
  Widget heading(String text)=>Padding(padding:const EdgeInsets.only(top:12,bottom:8),child:Text(text,style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:dark?Colors.white:Colors.black87)));
  @override Widget build(BuildContext context){final lang='${data['language']}';activeCurrency='${data['currency']??'USD'}';return MaterialApp(navigatorKey:navKey,scaffoldMessengerKey:messengerKey,debugShowCheckedModeBanner:false,title:'MafiFlow Mobile',theme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:green),useMaterial3:true),darkTheme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:green,brightness:Brightness.dark),useMaterial3:true),themeMode:dark?ThemeMode.dark:ThemeMode.light,home:!ready?const Scaffold(body:Center(child:CircularProgressIndicator())):data['setup_completed']!=true?WelcomeWizard(onComplete:(v) async {data.addAll(v);data['setup_completed']=true;applyMonthly();applySavingsMonthly();await save();}):Builder(builder:(shellContext)=>Scaffold(appBar:AppBar(title:Row(children:[Image.asset('assets/logo.png',height:34),const SizedBox(width:10),const Text('MafiFlow Mobile')]),actions:[IconButton(tooltip:t('calculator'),icon:const Icon(Icons.calculate_outlined),onPressed:()=>showDialog(context:dialogContext,builder:(_)=>const CalculatorDialog())),IconButton(icon:const Icon(Icons.settings),onPressed:()=>setState(()=>tab=5))]),body:SafeArea(child:LayoutBuilder(builder:(ctx,box){final content=IndexedStack(index:tab,children:[home(),transactions(),monthly(),stats(),Advisor(data:data,lang:lang,onSave:save),settings()]);return content;})),bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),labelBehavior:NavigationDestinationLabelBehavior.onlyShowSelected,destinations:[NavigationDestination(icon:const Icon(Icons.home_outlined),label:t('home')),NavigationDestination(icon:const Icon(Icons.receipt_long),label:t('moves')),NavigationDestination(icon:const Icon(Icons.event_repeat),label:t('monthly')),NavigationDestination(icon:const Icon(Icons.pie_chart_outline),label:t('stats')),NavigationDestination(icon:const Icon(Icons.smart_toy_outlined),label:t('ai')),NavigationDestination(icon:const Icon(Icons.settings_outlined),label:t('settings'))]))));}
  Widget scroll(List<Widget> widgets)=>ListView(padding:const EdgeInsets.all(16),children:widgets);
  Widget stat(String label,double value,IconData icon,Color color)=>card(Row(children:[Icon(icon,color:color),const SizedBox(width:14),Expanded(child:Text(label)),Text(money(value),style:TextStyle(fontWeight:FontWeight.bold,fontSize:19,color:color))]));
  Widget home(){final v=totals();return scroll([heading(t('home')),stat(t('balance'),v.balance,Icons.account_balance_wallet,v.balance<0?expenseRed:green),stat(t('income'),v.income,Icons.trending_up,green),stat(t('expenses'),v.spent,Icons.trending_down,expenseRed),stat(t('savings'),number(data['savings_saved']),Icons.savings,Colors.blue),card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${t('savings')}: ${money(number(data['savings_saved']))} / ${money(number(data['savings_goal']))}'),const SizedBox(height:8),LinearProgressIndicator(value:number(data['savings_goal'])>0?(number(data['savings_saved'])/number(data['savings_goal'])).clamp(0.0,1.0):0)])),heading(t('recents')),...tx.reversed.take(7).map(tile)]);}
  Widget tile(Map<String,dynamic> x,{VoidCallback? onDelete}) {final plus=x['type']=='Ingreso mensual'||x['type']=='Ingreso extra';return card(ListTile(contentPadding:EdgeInsets.zero,title:Text(catName('${x['category']??x['type']}')),subtitle:Text('${x['date']??''}\n${x['note']??''}'),isThreeLine:true,trailing:Row(mainAxisSize:MainAxisSize.min,children:[Text('${plus?'+':'−'}${money(number(x['amount']))}',style:TextStyle(color:plus?green:expenseRed,fontWeight:FontWeight.bold)),if(onDelete!=null)IconButton(onPressed:onDelete,icon:const Icon(Icons.delete_outline))])));}
  Future<void> addTransaction() async {
    String type='Gasto';
    String category=categories.isEmpty?'Otro':categories.first;
    final amount=TextEditingController(),note=TextEditingController();
    bool transactionAdded=false;
    await showDialog(context:dialogContext,builder:(c)=>StatefulBuilder(builder:(c,update)=>AlertDialog(
      title:Text(t('add')),
      content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        DropdownButtonFormField<String>(initialValue:type,items:['Gasto','Ingreso extra'].map((e)=>DropdownMenuItem(value:e,child:Text(e=='Gasto'?t('expense'):t('extra')))).toList(),onChanged:(v)=>update(()=>type=v!)),
        if(type=='Gasto') DropdownButtonFormField<String>(key:ValueKey(category),initialValue:categories.contains(category)?category:null,decoration:InputDecoration(labelText:t('category')),isExpanded:true,items:categories.map((e)=>DropdownMenuItem(value:e,child:Text(catName(e)))).toList(),onChanged:(v)=>update(()=>category=v??'Otro')),
        TextButton.icon(onPressed:()async{await manageCategories();if(c.mounted)update((){if(!categories.contains(category))category=categories.isEmpty?'Otro':categories.first;});},icon:const Icon(Icons.tune),label:Text(t('editCategories'))),
        TextField(controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:t('amount'))),
        TextField(controller:note,decoration:InputDecoration(labelText:t('note')))
      ])),
      actions:[TextButton(onPressed:()=>Navigator.pop(c),child:Text(t('cancel'))),FilledButton(onPressed:(){
        final n=double.tryParse(amount.text.replaceAll(',','.'));
        if(n==null||n<=0||!n.isFinite){notice(t('invalid'));return;}
        data['transactions']=[...tx,{'date':stampNow(),'type':type,'category':type=='Gasto'?category:'Ingreso extra','amount':n,'note':note.text}];
        transactionAdded=true;
        Navigator.pop(c);
      },child:Text(t('save')))]
    )));
    if(transactionAdded) await save();
    else refreshAfterDialog();
    WidgetsBinding.instance.addPostFrameCallback((_){amount.dispose();note.dispose();});
  }
  Future<void> manageCategories() async {
    final controller=TextEditingController();
    await showDialog(context:dialogContext,builder:(ctx)=>StatefulBuilder(builder:(ctx,update)=>AlertDialog(
      title:Text(t('manageCategories')),
      content:SizedBox(width:380,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:controller,decoration:InputDecoration(labelText:t('categoryName'))),
        const SizedBox(height:8),
        FilledButton.icon(onPressed:(){final name=controller.text.trim();if(name.isEmpty)return;final hidden=(data['hidden_categories'] as List? ?? []).map((e)=>'$e').toList();hidden.remove(name);data['hidden_categories']=hidden;if(!defaultCategories.contains(name)){data['custom_categories']={...(data['custom_categories'] as List? ?? []).map((e)=>'$e'),name}.toList();}controller.clear();update((){});persistWithoutRebuild();},icon:const Icon(Icons.add),label:Text(t('newCategory'))),
        ...categories.map((name)=>ListTile(dense:true,title:Text(catName(name)),trailing:IconButton(tooltip:t('removeCategory'),icon:const Icon(Icons.delete_outline),onPressed:(){if(defaultCategories.contains(name)){data['hidden_categories']={...(data['hidden_categories'] as List? ?? []).map((e)=>'$e'),name}.toList();}else{data['custom_categories']=(data['custom_categories'] as List? ?? []).where((e)=>'$e'!=name).toList();}update((){});persistWithoutRebuild();}))),
        TextButton.icon(onPressed:(){data['hidden_categories']=[];update((){});persistWithoutRebuild();},icon:const Icon(Icons.restore),label:Text(t('restoreCategories'))),
        Text(t('categoryInUse'),style:const TextStyle(fontSize:12))
      ]))),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:Text(t('save')))]
    )));
    WidgetsBinding.instance.addPostFrameCallback((_){controller.dispose();});
    refreshAfterDialog();
  }
  Widget transactions()=>scroll([heading(t('moves')),FilledButton.icon(onPressed:addTransaction,icon:const Icon(Icons.add),label:Text(t('add'))),...tx.reversed.map((x)=>tile(x,onDelete:(){final list=tx;// compare values as records() creates copies
    final i=list.indexWhere((v)=>v['date']==x['date']&&v['amount']==x['amount']&&v['type']==x['type']&&v['note']==x['note']);if(i>=0)list.removeAt(i);data['transactions']=list;save();}))]);
  Future<void> addPayment()async {final name=TextEditingController(),amount=TextEditingController();await showDialog(context:dialogContext,builder:(c)=>AlertDialog(title:Text(t('newPayment')),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:name,decoration:InputDecoration(labelText:t('name'))),TextField(controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:t('amount')))]),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:Text(t('cancel'))),FilledButton(onPressed:(){final n=double.tryParse(amount.text.replaceAll(',','.'));if(n==null||n<=0||!n.isFinite||name.text.trim().isEmpty){notice(t('invalid'));return;}data['monthly_payments']=[...payments,{'name':name.text.trim(),'amount':n,'active':true}];Navigator.pop(c);save();},child:Text(t('save')))]));}
  Widget monthly()=>scroll([heading(t('monthly')),FilledButton.icon(onPressed:addPayment,icon:const Icon(Icons.add),label:Text(t('newPayment'))),...payments.asMap().entries.map((e)=>card(ListTile(title:Text('${e.value['name']}'),subtitle:Text(money(number(e.value['amount']))),leading:Switch(value:e.value['active']!=false,onChanged:(v){final list=payments;list[e.key]['active']=v;data['monthly_payments']=list;save();}),trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:(){final list=payments;list.removeAt(e.key);data['monthly_payments']=list;save();})) ))]);
  String previousMonth(){final now=DateTime.now();final prev=DateTime(now.year,now.month-1,1);return '${prev.year}-${prev.month.toString().padLeft(2,'0')}';}
  String monthAt(int offset){final d=DateTime.now();final x=DateTime(d.year,d.month+offset,1);return '${x.year}-${x.month.toString().padLeft(2,'0')}';}
  String percentChange(double now,double prev){if(prev==0)return now==0?'0%':'—';final change=(now-prev)/prev*100;return '${change>=0?'+':''}${change.toStringAsFixed(1)}%';}
  Widget stats(){
    final v=totals(),prior=totals(previousMonth());
    final income=max(0.0,v.income),spent=max(0.0,v.spent),sum=income+spent;
    final byCategory=<String,double>{};
    for(final x in tx.where((e)=>'${e['date']}'.startsWith(monthNow())&&(e['type']=='Gasto'||e['type']=='Pago mensual'))){
      final n=max(0.0,number(x['amount']));if(n>0)byCategory.update('${x['category']}',(old)=>old+n,ifAbsent:()=>n);
    }
    final colors=[green,expenseRed,Colors.blue,Colors.orange,Colors.purple,Colors.teal,Colors.pink,Colors.amber,Colors.indigo];
    final items=byCategory.entries.toList()..sort((a,b)=>b.value.compareTo(a.value));
    final expenseTotal=items.fold<double>(0,(v,e)=>v+e.value);
    final lastMonths=List.generate(6,(i)=>monthAt(i-5));
    final series=lastMonths.map((m)=>totals(m)).toList();
    final maxValue=max(1.0,series.fold<double>(0,(v,e)=>max(v,max(e.income,e.spent))))*1.2;
    return scroll([
      heading(t('stats')),
      stat(t('income'),v.income,Icons.arrow_upward,green),
      stat(t('expenses'),v.spent,Icons.arrow_downward,expenseRed),
      card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(t('monthComparison'),style:Theme.of(dialogContext).textTheme.titleMedium),const SizedBox(height:12),
        Row(children:[Expanded(child:Text(t('spendingChange'))),Text(percentChange(v.spent,prior.spent),style:TextStyle(color:v.spent>prior.spent?expenseRed:green,fontWeight:FontWeight.bold))]),
        const SizedBox(height:8),Row(children:[Expanded(child:Text(t('incomeChange'))),Text(percentChange(v.income,prior.income),style:const TextStyle(fontWeight:FontWeight.bold))]),
        if(prior.spent==0&&prior.income==0)Padding(padding:const EdgeInsets.only(top:8),child:Text(t('noPrevious'),style:Theme.of(dialogContext).textTheme.bodySmall))
      ])),
      card(Column(children:[
        Text(t('distribution'),style:Theme.of(dialogContext).textTheme.titleMedium),const SizedBox(height:12),
        SizedBox(height:200,child:sum<=0?Center(child:Text(t('noData'))):PieChart(PieChartData(sections:[
          if(income>0)PieChartSectionData(value:income,color:green,title:'${(100*income/sum).round()}%',radius:72),
          if(spent>0)PieChartSectionData(value:spent,color:expenseRed,title:'${(100*spent/sum).round()}%',radius:72)
        ],sectionsSpace:2,centerSpaceRadius:30)))
      ])),
      card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(t('monthlyTrend'),style:Theme.of(dialogContext).textTheme.titleMedium),const SizedBox(height:8),
        SegmentedButton<String>(showSelectedIcon:false,segments:[ButtonSegment(value:'bar',label:Text(t('barChart'))),ButtonSegment(value:'line',label:Text(t('lineChart')))],selected:{chartMode=='line'?'line':'bar'},onSelectionChanged:(v)=>setState(()=>chartMode=v.first)),
        const SizedBox(height:18),
        SizedBox(height:230,child:chartMode=='line'?LineChart(LineChartData(
          minY:0,maxY:maxValue,
          lineBarsData:[LineChartBarData(spots:List.generate(6,(i)=>FlSpot(i.toDouble(),series[i].income)),color:green,isCurved:true,barWidth:3,dotData:const FlDotData(show:true)),LineChartBarData(spots:List.generate(6,(i)=>FlSpot(i.toDouble(),series[i].spent)),color:expenseRed,isCurved:true,barWidth:3,dotData:const FlDotData(show:true))],
          titlesData:FlTitlesData(topTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),rightTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),leftTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),bottomTitles:AxisTitles(sideTitles:SideTitles(showTitles:true,reservedSize:30,getTitlesWidget:(value,meta){final i=value.toInt();return i>=0&&i<6?Text(lastMonths[i].substring(5),style:const TextStyle(fontSize:10)):const SizedBox.shrink();})))
        )):BarChart(BarChartData(
          maxY:maxValue,alignment:BarChartAlignment.spaceAround,
          barGroups:List.generate(6,(i)=>BarChartGroupData(x:i,barRods:[BarChartRodData(toY:series[i].income,color:green,width:9),BarChartRodData(toY:series[i].spent,color:expenseRed,width:9)])),
          titlesData:FlTitlesData(topTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),rightTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),leftTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),bottomTitles:AxisTitles(sideTitles:SideTitles(showTitles:true,reservedSize:30,getTitlesWidget:(value,meta){final i=value.toInt();return i>=0&&i<6?Text(lastMonths[i].substring(5),style:const TextStyle(fontSize:10)):const SizedBox.shrink();})))
        ))),
        Row(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.circle,color:green,size:12),const SizedBox(width:4),Text(t('income')),const SizedBox(width:18),Icon(Icons.circle,color:expenseRed,size:12),const SizedBox(width:4),Text(t('expenses'))])
      ])),
      heading(t('categoryShares')),
      if(items.isEmpty)card(Text(t('noData'))) else card(Column(children:[
        SizedBox(height:220,child:PieChart(PieChartData(centerSpaceRadius:28,sectionsSpace:2,sections:List.generate(items.length,(i)=>PieChartSectionData(value:items[i].value,color:colors[i%colors.length],radius:76,title:'${(100*items[i].value/expenseTotal).round()}%'))))),
        ...List.generate(items.length,(i)=>Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Row(children:[Icon(Icons.circle,color:colors[i%colors.length],size:13),const SizedBox(width:8),Expanded(child:Text(catName(items[i].key))),Text('${(100*items[i].value/expenseTotal).toStringAsFixed(1)}%  ·  ${money(items[i].value)}')]))),
      ]))
    ]);
  }
  Widget settings(){final opening=TextEditingController(text:'${data['opening_balance']??0}');String currency='${data['currency']??'USD'}';final income=TextEditingController(text:'${data['monthly_income']}'),goal=TextEditingController(text:'${data['savings_goal']}'),monthlySavings=TextEditingController(text:'${data['monthly_savings']??0}'),api=TextEditingController(text:'${data['ai_api_key']}'),model=TextEditingController(text:'${data['ai_model']}'),url=TextEditingController(text:'${data['ai_base_url']}');String incomeFrequency='${data['income_frequency']??'monthly'}';String provider='${data['ai_provider']}';String lang='${data['language']}';String theme='${data['theme']}';return StatefulBuilder(builder:(c,update)=>scroll([heading(t('settings')),card(Column(children:[TextField(controller:income,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Cantidad que recibes por pago')),DropdownButtonFormField<String>(value:['daily','weekly','biweekly','monthly'].contains(incomeFrequency)?incomeFrequency:'monthly',decoration:const InputDecoration(labelText:'¿Cada cuánto cobras?'),items:const [DropdownMenuItem(value:'daily',child:Text('Diariamente')),DropdownMenuItem(value:'weekly',child:Text('Semanalmente')),DropdownMenuItem(value:'biweekly',child:Text('Cada 2 semanas')),DropdownMenuItem(value:'monthly',child:Text('Mensualmente'))],onChanged:(v)=>update(()=>incomeFrequency=v??'monthly')),TextField(controller:goal,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:t('goal'))),TextField(controller:monthlySavings,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Ahorro mensual / Monthly savings')),const Text('Cada mes se reservará automáticamente esta cantidad del dinero disponible, hasta alcanzar la meta.'),TextField(controller:opening,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:t('opening'))),DropdownButtonFormField<String>(initialValue:currency,decoration:InputDecoration(labelText:t('currency')),items:['USD','CAD','EUR','GBP','BDT'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v)=>update(()=>currency=v??'USD')),DropdownButtonFormField<String>(value:['OpenAI','NVIDIA','Custom'].contains(provider)?provider:'OpenAI',decoration:InputDecoration(labelText:t('provider')),items:['OpenAI','NVIDIA','Custom'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>update(()=>provider=v!)),TextField(controller:api,obscureText:true,decoration:InputDecoration(labelText:t('key'))),TextField(controller:model,decoration:InputDecoration(labelText:t('model'))),TextField(controller:url,decoration:InputDecoration(labelText:t('custom'))),DropdownButtonFormField<String>(value:const ['es','en','fr','de','bn'].contains(lang)?lang:'es',decoration:InputDecoration(labelText:t('language')),items:const [DropdownMenuItem(value:'es',child:Text('Español')),DropdownMenuItem(value:'en',child:Text('English')),DropdownMenuItem(value:'fr',child:Text('Français')),DropdownMenuItem(value:'de',child:Text('Deutsch')),DropdownMenuItem(value:'bn',child:Text('বাংলা'))],onChanged:(v)=>update(()=>lang=v!)),DropdownButtonFormField<String>(value:theme,decoration:InputDecoration(labelText:t('theme')),items:[DropdownMenuItem(value:'light',child:Text(t('light'))),DropdownMenuItem(value:'dark',child:Text(t('dark')))],onChanged:(v)=>update(()=>theme=v!)),const SizedBox(height:12),FilledButton(onPressed:(){final inc=double.tryParse(income.text.replaceAll(',','.'));final sav=double.tryParse(goal.text.replaceAll(',','.'));final monthlySav=double.tryParse(monthlySavings.text.replaceAll(',','.'));if(inc==null||sav==null||monthlySav==null||monthlySav<0||!monthlySav.isFinite||double.tryParse(opening.text.replaceAll(',','.'))==null||!inc.isFinite||!sav.isFinite||inc<0||sav<0){notice(t('invalid'));return;}data.addAll({'monthly_income':inc,'income_frequency':incomeFrequency,'income_start_date':incomeFrequency=='${data['income_frequency']??'monthly'}'?data['income_start_date']:DateTime.now().toIso8601String().substring(0,10),'savings_goal':sav,'monthly_savings':monthlySav,'opening_balance':double.parse(opening.text.replaceAll(',','.')),'currency':currency,'ai_provider':provider,'ai_api_key':api.text.trim(),'ai_model':model.text.trim(),'ai_base_url':url.text.trim(),'language':lang,'theme':theme});applySavingsMonthly();save();notice(t('settingsSaved'));},child:Text(t('save')))])),card(Column(children:[ListTile(leading:const Icon(Icons.category_outlined),title:Text(t('manageCategories')),onTap:manageCategories),ListTile(leading:const Icon(Icons.copy),title:Text(t('export')),onTap:()async{final copy=Map<String,dynamic>.from(data)..['ai_api_key']='';await Clipboard.setData(ClipboardData(text:const JsonEncoder.withIndent('  ').convert(copy)));notice(t('backup'));}),ListTile(leading:const Icon(Icons.download),title:Text(t('import')),onTap:()async{final clipboard=await Clipboard.getData('text/plain');try{final obj=jsonDecode(clipboard?.text??'');if(obj is! Map||obj['transactions'] is! List)throw const FormatException();if(!mounted)return;final ok=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(title:Text(t('import')),content:Text(t('confirm')),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:Text(t('cancel'))),FilledButton(onPressed:()=>Navigator.pop(d,true),child:Text(t('yes')))]));if(ok==true){data={...defaults,...Map<String,dynamic>.from(obj)};await save();notice(t('imported'));}}catch(_){notice(t('invalid'));}})]))]));}
}

class Advisor extends StatefulWidget {final Map<String,dynamic> data;final String lang;final Future<void> Function() onSave;const Advisor({super.key,required this.data,required this.lang,required this.onSave});@override State<Advisor> createState()=>_AdvisorState();}
class _AdvisorState extends State<Advisor> {
  final input=TextEditingController();final scroll=ScrollController();bool busy=false;String response='';String status='';http.Client? client;Timer? waitTimer;
  String get wait=>({'es':'La IA está preparando tu respuesta','en':'AI is preparing your response','fr':'L’IA prépare votre réponse','de':'KI bereitet die Antwort vor','bn':'এআই উত্তর প্রস্তুত করছে'}[widget.lang]??'AI is preparing your response');
  String get providerWait=>({'es':'Esperando respuesta del proveedor','en':'Waiting for provider response','fr':'En attente du fournisseur','de':'Warte auf Anbieter','bn':'সেবাদাতার উত্তরের অপেক্ষায়'}[widget.lang]??'Waiting for provider response');
  @override void dispose(){waitTimer?.cancel();client?.close();input.dispose();scroll.dispose();super.dispose();}
  void bottom(){WidgetsBinding.instance.addPostFrameCallback((_){if(scroll.hasClients)scroll.animateTo(scroll.position.maxScrollExtent,duration:const Duration(milliseconds:180),curve:Curves.easeOut);});}
  Future<void> send()async {final question=input.text.trim();if(question.isEmpty||busy)return;final key='${widget.data['ai_api_key']??''}'.trim();if(key.isEmpty){setState(()=>status=widget.lang=='es'?'Configura tu clave API en Ajustes.':'Configure your API key in Settings.');return;}
    input.clear();final history=records(widget.data['ai_history']);history.add({'role':'user','content':question});widget.data['ai_history']=history;await widget.onSave();setState((){busy=true;response='';status='$wait…';});bottom();
    var dots=0;waitTimer=Timer.periodic(const Duration(milliseconds:450),(_){if(mounted&&busy&&response.isEmpty){setState(()=>status='${status.startsWith(providerWait)?providerWait:wait}${'.'*(++dots%4)}');}});
    final provider='${widget.data['ai_provider']??'OpenAI'}';String base=provider=='NVIDIA'?'https://integrate.api.nvidia.com/v1':provider=='Custom'?'${widget.data['ai_base_url']??''}':'https://api.openai.com/v1';base=base.replaceAll(RegExp(r'/$'),'');final model='${widget.data['ai_model']??''}'.trim().isNotEmpty?'${widget.data['ai_model']}':provider=='NVIDIA'?'meta/llama-3.1-8b-instruct':'gpt-4o-mini';
    try{final totals=<String,double>{'income':0,'expenses':0};final m=monthNow();for(final tx in records(widget.data['transactions'])){if(!'${tx['date']??''}'.startsWith(m))continue;final v=number(tx['amount']);if(tx['type']=='Ingreso extra'||tx['type']=='Ingreso mensual'){totals['income']=totals['income']!+v;}else if(tx['type']=='Gasto'||tx['type']=='Pago mensual'){totals['expenses']=totals['expenses']!+v;}}
      final messages=[{'role':'system','content':'You are a helpful financial budgeting assistant. Respond in ${{'es':'Spanish','en':'English','fr':'French','de':'German','bn':'Bengali'}[widget.lang]??'English'}. Current month income ${totals['income']}, expenses ${totals['expenses']}, savings goal ${widget.data['savings_goal']}. Be concise and avoid pretending to know missing information.'},...history.take(20).map((e)=>{'role':e['role'],'content':e['content']})];
      client=http.Client();final req=http.Request('POST',Uri.parse('$base/chat/completions'));req.headers.addAll({'Authorization':'Bearer $key','Content-Type':'application/json','Accept':'text/event-stream'});req.body=jsonEncode({'model':model,'messages':messages,'stream':true,'max_tokens':1000});final res=await client!.send(req).timeout(const Duration(seconds:35));if(res.statusCode<200||res.statusCode>=300){final err=await res.stream.bytesToString();throw Exception('HTTP ${res.statusCode}: ${err.length>240?err.substring(0,240):err}');}
      if(mounted)setState(()=>status='$providerWait…');
      await for(final line in res.stream.transform(utf8.decoder).transform(const LineSplitter())){if(!line.startsWith('data:'))continue;final raw=line.substring(5).trim();if(raw=='[DONE]')break;try{final decoded=jsonDecode(raw);final choices=decoded['choices'];if(choices is List&&choices.isNotEmpty){final delta=choices[0]['delta'];final piece=delta is Map?delta['content']:null;if(piece is String&&piece.isNotEmpty&&mounted){setState((){response+=piece;status='';});bottom();}}}catch(_){}}
      if(response.trim().isEmpty)throw Exception(widget.lang=='es'?'El proveedor no envió texto.':'Provider returned no text.');history.add({'role':'assistant','content':response});widget.data['ai_history']=history;await widget.onSave();
    }catch(e){if(mounted)setState(()=>status='${widget.lang=='es'?'Error':'Error'}: $e');}finally{waitTimer?.cancel();client?.close();client=null;if(mounted)setState(()=>busy=false);bottom();}
  }
  @override Widget build(BuildContext context){final history=records(widget.data['ai_history']);return Column(children:[Expanded(child:ListView(controller:scroll,padding:const EdgeInsets.all(16),children:[for(final msg in history)Align(alignment:msg['role']=='user'?Alignment.centerRight:Alignment.centerLeft,child:Card(color:msg['role']=='user'?Theme.of(context).colorScheme.primaryContainer:null,child:Padding(padding:const EdgeInsets.all(12),child:Text('${msg['content']??''}')))),if(busy||status.isNotEmpty)Align(alignment:Alignment.centerLeft,child:Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[if(response.isNotEmpty)Text(response),if(status.isNotEmpty)Row(mainAxisSize:MainAxisSize.min,children:[if(busy)const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)),const SizedBox(width:8),Flexible(child:Text(status))])]))))])),Padding(padding:const EdgeInsets.all(12),child:Row(children:[Expanded(child:TextField(controller:input,enabled:!busy,maxLines:3,minLines:1,decoration:InputDecoration(hintText:widget.lang=='es'?'Escríbele a tu consejero':'Ask your advisor',border:const OutlineInputBorder()))),const SizedBox(width:8),IconButton.filled(onPressed:busy?null:send,icon:const Icon(Icons.send))]))]);}
}


// Onboarding is shown only on fresh installations, before the first monthly entry.
class WelcomeWizard extends StatefulWidget {
  final Future<void> Function(Map<String,dynamic>) onComplete;
  const WelcomeWizard({super.key,required this.onComplete});
  @override State<WelcomeWizard> createState()=>_WelcomeWizardState();
}
class _WelcomeWizardState extends State<WelcomeWizard> {
  int step=0;String language='es',currency='USD',incomeFrequency='monthly';DateTime payday=DateTime(DateTime.now().year,DateTime.now().month+1,1);
  final income=TextEditingController(text:'0'),opening=TextEditingController(text:'0'),goal=TextEditingController(text:'0'),monthlySavings=TextEditingController(text:'0');
  final name=TextEditingController(),payment=TextEditingController();
  final List<Map<String,dynamic>> bills=[];
  @override void dispose(){income.dispose();opening.dispose();goal.dispose();monthlySavings.dispose();name.dispose();payment.dispose();super.dispose();}
  String word(String es,String en,String fr,String de,String bn)=>{'es':es,'en':en,'fr':fr,'de':de,'bn':bn}[language]??es;
  double? parse(String v){final x=double.tryParse(v.trim().replaceAll(',','.'));return x!=null&&x.isFinite&&x>=0?x:null;}
  void next(){
    if((step==1&&(parse(income.text)==null||parse(opening.text)==null)) ||
       (step==2&&(parse(goal.text)==null||parse(monthlySavings.text)==null))){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(word('Introduce cantidades válidas','Enter valid amounts','Montants invalides','Ungültige Beträge','সঠিক পরিমাণ দিন'))));
      return;
    }
    if(step<3){setState(()=>step++);return;}
    // Save the payment being typed even when the user skips Add payment.
    final pendingName=name.text.trim();
    final pendingAmount=parse(payment.text);
    if(pendingName.isNotEmpty||payment.text.trim().isNotEmpty){
      if(pendingName.isEmpty||pendingAmount==null||pendingAmount<=0){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(word('Completa el nombre y el importe del pago, o deja ambos vacíos.','Complete the payment name and amount, or leave both blank.','Complétez le paiement ou laissez les deux champs vides.','Zahlung vervollständigen oder beide Felder leer lassen.','পেমেন্টের তথ্য পূরণ করুন বা ফাঁকা রাখুন।'))));
        return;
      }
      bills.add({'name':pendingName,'amount':pendingAmount,'active':true});
      name.clear();payment.clear();
    }
    widget.onComplete({'language':language,'currency':currency,'monthly_income':parse(income.text)??0,'income_frequency':incomeFrequency,'income_start_date':payday.toIso8601String().substring(0,10),'opening_balance':parse(opening.text)??0,'savings_goal':parse(goal.text)??0,'monthly_savings':parse(monthlySavings.text)??0,'monthly_payments':bills});
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('MafiFlow Mobile')),body:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:540),child:ListView(padding:const EdgeInsets.all(24),children:[LinearProgressIndicator(value:(step+1)/4),const SizedBox(height:28),Text(word('¡Bienvenido a MafiFlow!','Welcome to MafiFlow!','Bienvenue sur MafiFlow !','Willkommen bei MafiFlow!','MafiFlow-তে স্বাগতম!'),style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:22),
    if(step==0)...[Text(word('Elige idioma y moneda','Choose language and currency','Choisissez langue et devise','Sprache und Währung wählen','ভাষা ও মুদ্রা নির্বাচন করুন')),DropdownButtonFormField<String>(initialValue:language,items:const [DropdownMenuItem(value:'es',child:Text('Español')),DropdownMenuItem(value:'en',child:Text('English')),DropdownMenuItem(value:'fr',child:Text('Français')),DropdownMenuItem(value:'de',child:Text('Deutsch')),DropdownMenuItem(value:'bn',child:Text('বাংলা'))],onChanged:(v)=>setState(()=>language=v??'es')),DropdownButtonFormField<String>(initialValue:currency,items:['USD','CAD','EUR','GBP','BDT'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v)=>setState(()=>currency=v??'USD'))],
    if(step==1)...[Text(word('Configura tus finanzas iniciales','Set up your starting finances','Configurez vos finances','Finanzen einrichten','প্রাথমিক অর্থ সেট করুন')),TextField(controller:income,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:word('Cantidad que recibes por pago','Amount per payday','Montant par paie','Betrag pro Zahlung','প্রতি বেতনের পরিমাণ'))),DropdownButtonFormField<String>(value:incomeFrequency,decoration:InputDecoration(labelText:word('¿Cada cuánto cobras?','How often are you paid?','À quelle fréquence êtes-vous payé ?','Wie oft wirst du bezahlt?','কত ঘন ঘন বেতন পান?')),items:[DropdownMenuItem(value:'daily',child:Text(word('Diariamente','Daily','Chaque jour','Täglich','প্রতিদিন'))),DropdownMenuItem(value:'weekly',child:Text(word('Semanalmente','Weekly','Chaque semaine','Wöchentlich','প্রতি সপ্তাহে'))),DropdownMenuItem(value:'biweekly',child:Text(word('Cada 2 semanas','Every 2 weeks','Toutes les 2 semaines','Alle 2 Wochen','প্রতি ২ সপ্তাহে'))),DropdownMenuItem(value:'monthly',child:Text(word('Mensualmente','Monthly','Chaque mois','Monatlich','প্রতি মাসে')))],onChanged:(v)=>setState(()=>incomeFrequency=v??'monthly')),const SizedBox(height:8),ListTile(contentPadding:EdgeInsets.zero,title:Text(word('Fecha del próximo cobro','Next payday','Date du premier paiement','Erster Zahltag','প্রথম বেতনের তারিখ')),subtitle:Text('${payday.year}-${payday.month.toString().padLeft(2,'0')}-${payday.day.toString().padLeft(2,'0')}'),trailing:const Icon(Icons.calendar_today),onTap:()async{final chosen=await showDatePicker(context:context,initialDate:payday,firstDate:DateTime(2020),lastDate:DateTime(2100));if(chosen!=null)setState(()=>payday=chosen);}),TextField(controller:opening,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:word('Saldo disponible ahora (no se suma al salario)','Available balance now (not added to salary)','Solde actuel (pas un revenu)','Aktueller Kontostand (kein Einkommen)','বর্তমান ব্যালেন্স')))],
    if(step==2)...[TextField(controller:monthlySavings,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:word('¿Cuánto quieres ahorrar al mes?','How much to save monthly?','Combien épargner par mois ?','Monatlicher Sparbetrag','মাসিক সঞ্চয়'))),TextField(controller:goal,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:word('¿Cuál es tu objetivo total de ahorro?','Total savings target','Objectif total d’épargne','Gesamtsparziel','মোট সঞ্চয়ের লক্ষ্য'))),const SizedBox(height:12),Text(word('Mensualmente este dinero se descontará automáticamente del dinero disponible hasta llegar a tu objetivo.','Each month this amount will automatically be deducted from available money until you reach your goal.','Chaque mois, ce montant sera déduit de votre solde disponible jusqu’à votre objectif.','Jeden Monat wird dieser Betrag vom verfügbaren Geld abgezogen, bis das Ziel erreicht ist.','লক্ষ্য পূরণ না হওয়া পর্যন্ত প্রতি মাসে উপলব্ধ অর্থ থেকে এই পরিমাণ বাদ যাবে।'))],
    if(step==3)...[Text(word('Agrega tus gastos fijos (opcional)','Add recurring expenses (optional)','Ajoutez les dépenses récurrentes','Wiederkehrende Ausgaben','নিয়মিত খরচ যোগ করুন')),TextField(controller:name,decoration:InputDecoration(labelText:word('Nombre del gasto','Expense name','Nom de la dépense','Ausgabenname','খরচের নাম'))),TextField(controller:payment,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:word('Cantidad mensual','Monthly amount','Montant mensuel','Monatlicher Betrag','মাসিক পরিমাণ'))),TextButton.icon(onPressed:(){final n=parse(payment.text);if(name.text.trim().isEmpty||n==null||n<=0)return;setState((){bills.add({'name':name.text.trim(),'amount':n,'active':true});name.clear();payment.clear();});},icon:const Icon(Icons.add),label:Text(word('Agregar pago','Add payment','Ajouter','Hinzufügen','যোগ করুন'))),...bills.map((b)=>ListTile(title:Text('${b['name']}'),trailing:Text('${b['amount']}')))],
    const SizedBox(height:30),Row(children:[if(step>0)TextButton(onPressed:()=>setState(()=>step--),child:Text(word('Atrás','Back','Retour','Zurück','পেছনে'))),const Spacer(),FilledButton(onPressed:next,child:Text(step==3?word('Empezar','Get started','Commencer','Starten','শুরু করুন'):word('Continuar','Continue','Continuer','Weiter','চালিয়ে যান')))])]))));
}

class CalculatorDialog extends StatefulWidget {const CalculatorDialog({super.key});@override State<CalculatorDialog> createState()=>_CalculatorDialogState();}
class _CalculatorDialogState extends State<CalculatorDialog> {
  String display='0',operator='',previous='';bool resetNext=false;
  void press(String key){setState((){if(key=='C'){display='0';operator='';previous='';resetNext=false;return;}if(key=='⌫'){display=display.length>1?display.substring(0,display.length-1):'0';return;}if(key=='+'||key=='−'||key=='×'||key=='÷'){previous=display;operator=key;resetNext=true;return;}if(key=='='){final a=double.tryParse(previous),b=double.tryParse(display);if(a==null||b==null||operator.isEmpty)return;final v=switch(operator){'+'=>a+b,'−'=>a-b,'×'=>a*b,'÷'=>b==0?double.nan:a/b,_=>b};display=v.isFinite?(v==v.roundToDouble()?v.toInt().toString():v.toStringAsFixed(6).replaceFirst(RegExp(r'0+$'),'').replaceFirst(RegExp(r'\.$'),'')):'Error';operator='';resetNext=true;return;}if(resetNext||display=='0'||display=='Error'){display=key=='.'?'0.':key;resetNext=false;}else if(key!='.'||!display.contains('.')){display+=key;}});}
  @override Widget build(BuildContext context)=>AlertDialog(title:const Text('Calculadora'),content:SizedBox(width:300,child:Column(mainAxisSize:MainAxisSize.min,children:[Align(alignment:Alignment.centerRight,child:SelectableText(display,style:Theme.of(context).textTheme.headlineMedium)),const SizedBox(height:14),for(final row in [['7','8','9','÷'],['4','5','6','×'],['1','2','3','−'],['C','0','.','+'],['⌫','=']])Row(children:[for(final key in row)Expanded(child:Padding(padding:const EdgeInsets.all(3),child:FilledButton.tonal(onPressed:()=>press(key),child:Text(key))))])])),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('OK'))]);
}
