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
  'monthly_savings': 0.0, 'savings_saved': 0.0, 'savings_processed_months': [], 'savings_history': [],
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
const featureLabels = <String,Map<String,String>>{
  'es': {'automaticSavings': 'Ahorro mensual automático', 'chargeDay': 'Día de cobro mensual', 'chargeDayHint': 'Se descontará automáticamente en ese día de cada mes.', 'chargeDaySubtitle': 'Día {day} de cada mes', 'changeDay': 'Cambiar día', 'payAmount': 'Cantidad que recibes por pago', 'payFrequency': '¿Cada cuánto cobras?', 'freqDaily': 'Diariamente', 'freqWeekly': 'Semanalmente', 'freqBiweekly': 'Cada 2 semanas', 'freqMonthly': 'Mensualmente', 'monthlySavings': 'Ahorro mensual', 'monthlySavingsHint': 'Cada mes se reservará automáticamente esta cantidad del dinero disponible, hasta alcanzar la meta.', 'pasteJsonHint': 'Pega aquí tu copia de seguridad JSON', 'pasteClipboard': 'Pegar desde portapapeles', 'invalidBackup': 'El JSON no es válido o no contiene datos de MafiFlow.', 'importBackup': 'Importar copia de seguridad'},
  'en': {'automaticSavings': 'Automatic monthly savings', 'chargeDay': 'Monthly charge day', 'chargeDayHint': 'The payment will be deducted automatically on this day each month.', 'chargeDaySubtitle': 'Day {day} of each month', 'changeDay': 'Change day', 'payAmount': 'Amount received per payday', 'payFrequency': 'How often are you paid?', 'freqDaily': 'Daily', 'freqWeekly': 'Weekly', 'freqBiweekly': 'Every 2 weeks', 'freqMonthly': 'Monthly', 'monthlySavings': 'Monthly savings', 'monthlySavingsHint': 'Each month, this amount will automatically be reserved from your available balance until you reach your goal.', 'pasteJsonHint': 'Paste your JSON backup here', 'pasteClipboard': 'Paste from clipboard', 'invalidBackup': 'Invalid JSON or not a MafiFlow backup.', 'importBackup': 'Import backup'},
  'fr': {'automaticSavings': 'Épargne mensuelle automatique', 'chargeDay': 'Jour du prélèvement mensuel', 'chargeDayHint': 'Le paiement sera prélevé automatiquement ce jour-là chaque mois.', 'chargeDaySubtitle': 'Jour {day} de chaque mois', 'changeDay': 'Modifier le jour', 'payAmount': 'Montant reçu par paie', 'payFrequency': 'À quelle fréquence êtes-vous payé ?', 'freqDaily': 'Chaque jour', 'freqWeekly': 'Chaque semaine', 'freqBiweekly': 'Toutes les 2 semaines', 'freqMonthly': 'Chaque mois', 'monthlySavings': 'Épargne mensuelle', 'monthlySavingsHint': 'Chaque mois, ce montant sera automatiquement réservé sur votre solde disponible jusqu’à atteindre votre objectif.', 'pasteJsonHint': 'Collez votre sauvegarde JSON ici', 'pasteClipboard': 'Coller depuis le presse-papiers', 'invalidBackup': 'JSON invalide ou sauvegarde MafiFlow non reconnue.', 'importBackup': 'Importer la sauvegarde'},
  'de': {'automaticSavings': 'Automatisches monatliches Sparen', 'chargeDay': 'Monatlicher Abbuchungstag', 'chargeDayHint': 'Die Zahlung wird jeden Monat automatisch an diesem Tag abgebucht.', 'chargeDaySubtitle': 'Tag {day} jedes Monats', 'changeDay': 'Tag ändern', 'payAmount': 'Betrag pro Gehaltszahlung', 'payFrequency': 'Wie oft wirst du bezahlt?', 'freqDaily': 'Täglich', 'freqWeekly': 'Wöchentlich', 'freqBiweekly': 'Alle 2 Wochen', 'freqMonthly': 'Monatlich', 'monthlySavings': 'Monatlicher Sparbetrag', 'monthlySavingsHint': 'Jeden Monat wird dieser Betrag automatisch vom verfügbaren Guthaben zurückgelegt, bis das Sparziel erreicht ist.', 'pasteJsonHint': 'JSON-Sicherung hier einfügen', 'pasteClipboard': 'Aus Zwischenablage einfügen', 'invalidBackup': 'Ungültiges JSON oder keine MafiFlow-Sicherung.', 'importBackup': 'Sicherung importieren'},
  'bn': {'automaticSavings': 'স্বয়ংক্রিয় মাসিক সঞ্চয়', 'chargeDay': 'মাসিক টাকা কাটার দিন', 'chargeDayHint': 'প্রতি মাসে এই দিনে স্বয়ংক্রিয়ভাবে টাকা কাটা হবে।', 'chargeDaySubtitle': 'প্রতি মাসের {day} তারিখ', 'changeDay': 'দিন পরিবর্তন', 'payAmount': 'প্রতি বেতনে প্রাপ্ত অর্থ', 'payFrequency': 'কত ঘন ঘন বেতন পান?', 'freqDaily': 'প্রতিদিন', 'freqWeekly': 'প্রতি সপ্তাহে', 'freqBiweekly': 'প্রতি ২ সপ্তাহে', 'freqMonthly': 'প্রতি মাসে', 'monthlySavings': 'মাসিক সঞ্চয়', 'monthlySavingsHint': 'লক্ষ্য পূরণ না হওয়া পর্যন্ত প্রতি মাসে উপলব্ধ ব্যালেন্স থেকে এই পরিমাণ স্বয়ংক্রিয়ভাবে সঞ্চয় করা হবে।', 'pasteJsonHint': 'এখানে JSON ব্যাকআপ পেস্ট করুন', 'pasteClipboard': 'ক্লিপবোর্ড থেকে পেস্ট করুন', 'invalidBackup': 'অবৈধ JSON বা MafiFlow ব্যাকআপ নয়।', 'importBackup': 'ব্যাকআপ আমদানি করুন'}
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
// Helpers for the statistics screen.
String monthAt(int offset) {
  final now = DateTime.now();
  final target = DateTime(now.year, now.month + offset, 1);
  return '${target.year}-${target.month.toString().padLeft(2, '0')}';
}
String previousMonth() => monthAt(-1);
String percentChange(double current, double previous) {
  if (previous == 0) return current == 0 ? '0%' : '—';
  final change = ((current - previous) / previous) * 100;
  return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';
}

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
  String t(String key)=> featureLabels['${data['language']}']?[key] ?? improvedLabels['${data['language']}']?[key] ?? (additionalLabels[data['language']] ?? labels[data['language']] ?? labels['es']!)[key] ?? labels['en']![key] ?? key;
  String catName(String category)=>categoryTranslations[category]?['${data['language']}']??category;
  String transactionTitle(Map<String,dynamic> x) {
    final category='${x['category']??x['type']??''}';
    final type='${x['type']??''}';
    if(type=='Ingreso extra' && (category=='Ingreso extra'||category.isEmpty))return t('extra');
    if(type=='Ingreso mensual' && (category=='Ingreso mensual'||category.isEmpty))return t('monthIncome');
    if(type=='Pago mensual' && (category=='Pago mensual'||category.isEmpty))return t('payment');
    if(type=='Gasto' && (category=='Gasto'||category.isEmpty))return t('expense');
    return catName(category);
  }
  String transactionNote(Map<String,dynamic> x) {
    final note='${x['note']??''}';
    if(note.startsWith('Ingreso automático (') && note.endsWith(')')){
      final frequency=note.substring('Ingreso automático ('.length,note.length-1);
      final label= <String,String>{'daily':'incomeFrequencyDaily','weekly':'incomeFrequencyWeekly','biweekly':'incomeFrequencyBiweekly','monthly':'incomeFrequencyMonthly'}[frequency];
      final lang='${data['language']??'es'}';
      const translations={
        'es':['Ingreso automático','Diariamente','Semanalmente','Cada 2 semanas','Mensualmente'],
        'en':['Automatic income','Daily','Weekly','Every 2 weeks','Monthly'],
        'fr':['Revenu automatique','Chaque jour','Chaque semaine','Toutes les 2 semaines','Chaque mois'],
        'de':['Automatische Einnahme','Täglich','Wöchentlich','Alle 2 Wochen','Monatlich'],
        'bn':['স্বয়ংক্রিয় আয়','প্রতিদিন','প্রতি সপ্তাহে','প্রতি ২ সপ্তাহে','প্রতি মাসে']
      };
      final words=translations[lang]??translations['es']!;
      final index={'daily':1,'weekly':2,'biweekly':3,'monthly':4}[frequency];
      return '${words[0]} (${index==null?frequency:words[index]})';
    }
    if(note=='Ingreso mensual automático')return t('monthIncome');
    return note;
  }
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
  // Each recurring bill is charged on its own selected day.
  // A payment created today starts no earlier than today, avoiding retroactive charges.
  void applyMonthly(){
    final now=DateTime.now();
    final today=DateTime(now.year,now.month,now.day);
    final list=tx;
    final bills=payments;
    bool changed=false;
    for(int i=0;i<bills.length;i++){
      final p=bills[i];
      // Stable ID is necessary to prevent duplicates when bills share a name.
      if(p['id']==null){p['id']='bill_${DateTime.now().microsecondsSinceEpoch}_$i';changed=true;}
      final id='${p['id']}';
      final rawDay=(number(p['day']).toInt());
      final day=rawDay.clamp(1,31);
      if(p['day']!=day){p['day']=day;changed=true;}
      if(p['start_date']==null){
        // Old bills were already charged on the 1st by the legacy system.
        // Preserve that history; begin the new schedule today.
        p['start_date']='${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
        changed=true;
      }
      if(p['active']==false)continue;
      final amount=number(p['amount']);
      if(amount<=0)continue;
      final start=DateTime.tryParse('${p['start_date']}');
      if(start==null)continue;
      final first=DateTime(start.year,start.month,1);
      for(int offset=0;offset<1200;offset++){
        final month=DateTime(first.year,first.month+offset,1);
        if(month.isAfter(today))break;
        final lastDay=DateTime(month.year,month.month+1,0).day;
        final due=DateTime(month.year,month.month,day>lastDay?lastDay:day);
        if(due.isBefore(DateTime(start.year,start.month,start.day))||due.isAfter(today))continue;
        final monthKey='${month.year}-${month.month.toString().padLeft(2,'0')}';
        final dueKey='${due.year}-${due.month.toString().padLeft(2,'0')}-${due.day.toString().padLeft(2,'0')}';
        final exists=list.any((x)=>x['type']=='Pago mensual' &&
          (x['auto_bill_id']==id && x['auto_month']==monthKey ||
          // Prevent a second charge when migrating legacy monthly bills.
          (x['auto_bill_id']==null && x['auto_month']==monthKey && x['note']=='${p['name']??''}')));
        if(!exists){
          list.add({'date':'$dueKey 09:00:00','type':'Pago mensual',
            'category':'Pago mensual','amount':amount,'note':'${p['name']??''}',
            'auto_month':monthKey,'auto_bill_id':id});
          changed=true;
        }
      }
    }
    if(changed){data['monthly_payments']=bills;data['transactions']=list;}
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
    final history=records(data['savings_history']);
    if(!history.any((e)=>e['month']==month)){
      history.add({'month':month,'date':'$month-01','amount':amount});
      data['savings_history']=history;
    }
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
  @override Widget build(BuildContext context){final lang='${data['language']}';activeCurrency='${data['currency']??'USD'}';return MaterialApp(navigatorKey:navKey,scaffoldMessengerKey:messengerKey,debugShowCheckedModeBanner:false,title:'MafiFlow Mobile',theme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:green),useMaterial3:true),darkTheme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:green,brightness:Brightness.dark),useMaterial3:true),themeMode:dark?ThemeMode.dark:ThemeMode.light,home:!ready?const Scaffold(body:Center(child:CircularProgressIndicator())):data['setup_completed']!=true?WelcomeWizard(onComplete:(v) async {data.addAll(v);data['setup_completed']=true;applyMonthly();applySavingsMonthly();await save();}):Builder(builder:(shellContext)=>Scaffold(appBar:AppBar(title:Row(children:[Image.asset('assets/logo.png',height:34),const SizedBox(width:10),const Text('MafiFlow Mobile')]),actions:[IconButton(tooltip:t('calculator'),icon:const Icon(Icons.calculate_outlined),onPressed:()=>showDialog(context:dialogContext,builder:(_)=>CalculatorDialog(title:t('calculator')))),IconButton(icon:const Icon(Icons.settings),onPressed:()=>setState(()=>tab=5))]),body:SafeArea(child:LayoutBuilder(builder:(ctx,box){final content=IndexedStack(index:tab,children:[home(),transactions(),monthly(),stats(),Advisor(data:data,lang:lang,onSave:save),settings()]);return content;})),bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),labelBehavior:NavigationDestinationLabelBehavior.onlyShowSelected,destinations:[NavigationDestination(icon:const Icon(Icons.home_outlined),label:t('home')),NavigationDestination(icon:const Icon(Icons.receipt_long),label:t('moves')),NavigationDestination(icon:const Icon(Icons.event_repeat),label:t('monthly')),NavigationDestination(icon:const Icon(Icons.pie_chart_outline),label:t('stats')),NavigationDestination(icon:const Icon(Icons.smart_toy_outlined),label:t('ai')),NavigationDestination(icon:const Icon(Icons.settings_outlined),label:t('settings'))]))));}
  Widget scroll(List<Widget> widgets)=>ListView(padding:const EdgeInsets.all(16),children:widgets);
  Widget stat(String label,double value,IconData icon,Color color)=>card(Row(children:[Icon(icon,color:color),const SizedBox(width:14),Expanded(child:Text(label)),Text(money(value),style:TextStyle(fontWeight:FontWeight.bold,fontSize:19,color:color))]));
  Widget home(){
    final v=totals();
    final saved=number(data['savings_saved']);
    final goal=number(data['savings_goal']);
    final monthlySaving=number(data['monthly_savings']);
    final progress=goal>0?(saved/goal).clamp(0.0,1.0).toDouble():0.0;
    return scroll([
      heading(t('home')),
      stat(t('balance'),v.balance,Icons.account_balance_wallet,v.balance<0?expenseRed:green),
      stat(t('income'),v.income,Icons.trending_up,green),
      stat(t('expenses'),v.spent,Icons.trending_down,expenseRed),
      card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[
          const Icon(Icons.savings,color:Colors.blue),
          const SizedBox(width:14),
          Expanded(child:Text(t('savings'))),
          Text(money(goal),style:const TextStyle(fontWeight:FontWeight.bold,fontSize:19,color:Colors.blue)),
        ]),
        const SizedBox(height:12),
        Text('${money(saved)} / ${money(goal)}'),
        const SizedBox(height:8),
        LinearProgressIndicator(value:progress),
      ])),
      card(Row(children:[
        const Icon(Icons.calendar_month_outlined,color:Colors.blue),
        const SizedBox(width:14),
        Expanded(child:Text(t('automaticSavings'))),
        Text(money(monthlySaving),style:const TextStyle(fontWeight:FontWeight.bold,fontSize:19,color:Colors.blue)),
      ])),
      heading(t('recents')),
      ...tx.reversed.take(7).map(tile),
    ]);
  }
  Widget tile(Map<String,dynamic> x,{VoidCallback? onDelete}) {final plus=x['type']=='Ingreso mensual'||x['type']=='Ingreso extra';return card(ListTile(contentPadding:EdgeInsets.zero,title:Text(transactionTitle(x)),subtitle:Text('${x['date']??''}\n${transactionNote(x)}'),isThreeLine:true,trailing:Row(mainAxisSize:MainAxisSize.min,children:[Text('${plus?'+':'−'}${money(number(x['amount']))}',style:TextStyle(color:plus?green:expenseRed,fontWeight:FontWeight.bold)),if(onDelete!=null)IconButton(onPressed:onDelete,icon:const Icon(Icons.delete_outline))])));}
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
    if (transactionAdded) {
      await save();
    } else {
      refreshAfterDialog();
    }
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
  Future<void> addPayment()async {
    final name=TextEditingController(),amount=TextEditingController();
    int selectedDay=DateTime.now().day;
    await showDialog(context:dialogContext,builder:(c)=>StatefulBuilder(builder:(context,setDialogState)=>AlertDialog(
      title:Text(t('newPayment')),
      content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:name,decoration:InputDecoration(labelText:t('name'))),
        TextField(controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:t('amount'))),
        DropdownButtonFormField<int>(initialValue:selectedDay,
          decoration:InputDecoration(labelText:t('chargeDay')),
          items:List.generate(31,(i)=>DropdownMenuItem(value:i+1,child:Text('${i+1}'))),
          onChanged:(v)=>setDialogState(()=>selectedDay=v??1)),
        const SizedBox(height:8),
        Text(t('chargeDayHint'),style:Theme.of(context).textTheme.bodySmall),
      ])),
      actions:[TextButton(onPressed:()=>Navigator.pop(c),child:Text(t('cancel'))),
        FilledButton(onPressed:(){final n=double.tryParse(amount.text.replaceAll(',','.'));
          if(n==null||n<=0||!n.isFinite||name.text.trim().isEmpty){notice(t('invalid'));return;}
          final today=DateTime.now().toIso8601String().substring(0,10);
          data['monthly_payments']=[...payments,{'name':name.text.trim(),'amount':n,'active':true,'day':selectedDay,'start_date':today}];
          Navigator.pop(c);applyMonthly();
        },child:Text(t('save')))])));
    name.dispose();amount.dispose();
  }
  Widget monthly()=>scroll([heading(t('monthly')),
    FilledButton.icon(onPressed:addPayment,icon:const Icon(Icons.add),label:Text(t('newPayment'))),
    ...payments.asMap().entries.map((e)=>card(ListTile(
      title:Text('${e.value['name']}'),
      subtitle:Text("${money(number(e.value['amount']))} · ${t('chargeDaySubtitle').replaceAll('{day}', '${number(e.value['day']).toInt().clamp(1,31)}')}"),
      leading:Switch(value:e.value['active']!=false,onChanged:(v){final list=payments;list[e.key]['active']=v;if(v)list[e.key]['start_date']=DateTime.now().toIso8601String().substring(0,10);data['monthly_payments']=list;applyMonthly();}),
      trailing:Row(mainAxisSize:MainAxisSize.min,children:[
        IconButton(tooltip:t('changeDay'),icon:const Icon(Icons.edit_calendar_outlined),onPressed:()async{
          int selectedDay=number(e.value['day']).toInt().clamp(1,31);
          await showDialog(context:dialogContext,builder:(c)=>StatefulBuilder(builder:(context,setDialogState)=>AlertDialog(
            title:Text(t('chargeDay')),
            content:DropdownButtonFormField<int>(initialValue:selectedDay,items:List.generate(31,(i)=>DropdownMenuItem(value:i+1,child:Text('${i+1}'))),onChanged:(v)=>setDialogState(()=>selectedDay=v??1)),
            actions:[TextButton(onPressed:()=>Navigator.pop(c),child:Text(t('cancel'))),FilledButton(onPressed:(){
              final list=payments;list[e.key]['day']=selectedDay;
              // A changed day takes effect from today, without replaying past months.
              list[e.key]['start_date']=DateTime.now().toIso8601String().substring(0,10);
              data['monthly_payments']=list;Navigator.pop(c);applyMonthly();
            },child:Text(t('save')))])));
        }),
        IconButton(icon:const Icon(Icons.delete_outline),onPressed:(){final list=payments;list.removeAt(e.key);data['monthly_payments']=list;save();})
      ]))))]);
  String statsPeriod='monthly';
  DateTime _periodStart(DateTime date, String period) {
    final d=DateTime(date.year,date.month,date.day);
    if(period=='daily')return d;
    if(period=='weekly')return d.subtract(Duration(days:d.weekday-1));
    if(period=='yearly')return DateTime(d.year);
    return DateTime(d.year,d.month);
  }
  DateTime _periodShift(DateTime date,int shift,String period) {
    if(period=='daily')return DateTime(date.year,date.month,date.day+shift);
    if(period=='weekly')return DateTime(date.year,date.month,date.day+7*shift);
    if(period=='yearly')return DateTime(date.year+shift);
    return DateTime(date.year,date.month+shift);
  }
  String _periodLabel(DateTime d,String period) {
    if(period=='daily')return '${d.day}/${d.month}';
    if(period=='weekly')return '${d.day}/${d.month}';
    if(period=='yearly')return '${d.year}';
    return '${d.month}/${d.year%100}';
  }
  ({double income,double spent,double savings}) _periodTotals(DateTime start,DateTime end) {
    double income=0,spent=0,savings=0;
    for(final item in tx){
      final raw='${item['date']??''}';
      final date=DateTime.tryParse(raw);
      if(date==null||date.isBefore(start)||!date.isBefore(end))continue;
      final amount=number(item['amount']);
      switch('${item['type']}'){
        case 'Ingreso mensual':
        case 'Ingreso extra': income+=amount;break;
        case 'Gasto':
        case 'Pago mensual': spent+=amount;break;
      }
    }
    for(final entry in records(data['savings_history'])){
      final date=DateTime.tryParse('${entry['date']??''}');
      if(date!=null&&!date.isBefore(start)&&date.isBefore(end)){
        savings+=number(entry['amount']);
      }
    }
    return (income:income,spent:spent,savings:savings);
  }
  String _analyticsText(String key){
    final lang='${data['language']??'es'}';
    const dictionary=<String,Map<String,String>>{
      'es':{'overview':'Resumen del período','savings':'Ahorro reservado','available':'Saldo disponible','balanceTrend':'Evolución del saldo','savingsTrend':'Ahorro acumulado','recurring':'Pagos recurrentes realizados','ordinary':'Otros gastos','net':'Resultado del período','savingsGoal':'Progreso de la meta','legacy':'El ahorro anterior a esta versión no tiene fechas individuales; se incluye en el total, no en las barras históricas.','noHistory':'Todavía no hay reservas de ahorro fechadas.'},
      'en':{'overview':'Period summary','savings':'Reserved savings','available':'Available balance','balanceTrend':'Balance over time','savingsTrend':'Accumulated savings','recurring':'Recurring payments made','ordinary':'Other expenses','net':'Period net','savingsGoal':'Savings goal progress','legacy':'Older savings have no individual dates; they are included in the total but not historical bars.','noHistory':'No dated savings deposits yet.'},
      'fr':{'overview':'Résumé de la période','savings':'Épargne réservée','available':'Solde disponible','balanceTrend':'Évolution du solde','savingsTrend':'Épargne cumulée','recurring':'Paiements récurrents effectués','ordinary':'Autres dépenses','net':'Résultat de la période','savingsGoal':'Progression de l’objectif','legacy':'L’épargne ancienne ne possède pas de dates individuelles.','noHistory':'Pas encore d’épargne datée.'},
      'de':{'overview':'Zeitraumübersicht','savings':'Zurückgelegtes Spargeld','available':'Verfügbares Guthaben','balanceTrend':'Kontostandverlauf','savingsTrend':'Angespartes Guthaben','recurring':'Ausgeführte Dauerzahlungen','ordinary':'Sonstige Ausgaben','net':'Ergebnis des Zeitraums','savingsGoal':'Sparziel-Fortschritt','legacy':'Ältere Ersparnisse haben keine einzelnen Datumsangaben.','noHistory':'Noch keine datierten Sparbeträge.'},
      'bn':{'overview':'সময়ের সারাংশ','savings':'সঞ্চিত অর্থ','available':'উপলব্ধ ব্যালেন্স','balanceTrend':'ব্যালেন্সের পরিবর্তন','savingsTrend':'মোট সঞ্চয়','recurring':'নিয়মিত পেমেন্ট','ordinary':'অন্যান্য খরচ','net':'সময়ের ফলাফল','savingsGoal':'সঞ্চয় লক্ষ্যের অগ্রগতি','legacy':'পুরোনো সঞ্চয়ের পৃথক তারিখ নেই।','noHistory':'এখনো তারিখসহ সঞ্চয় নেই।'}
    };
    return dictionary[lang]?[key]??dictionary['es']![key]??key;
  }
  double _balanceAt(DateTime exclusiveEnd){
    double balance=number(data['opening_balance']);
    for(final item in tx){
      final date=DateTime.tryParse('${item['date']??''}');
      if(date==null||!date.isBefore(exclusiveEnd))continue;
      final amount=number(item['amount']);
      if(item['type']=='Ingreso mensual'||item['type']=='Ingreso extra')balance+=amount;
      if(item['type']=='Gasto'||item['type']=='Pago mensual')balance-=amount;
    }
    // Older reserved savings are undated; treat them as an opening adjustment,
    // without inventing historical deposits or counting them as expenses.
    final history=records(data['savings_history']);
    final dated=history.fold<double>(0,(v,e)=>v+number(e['amount']));
    balance-=max(0.0,number(data['savings_saved'])-dated);
    for(final entry in history){
      final date=DateTime.tryParse('${entry['date']??''}');
      if(date!=null&&date.isBefore(exclusiveEnd))balance-=number(entry['amount']);
    }
    return balance;
  }
  double _savingsAt(DateTime exclusiveEnd){
    final history=records(data['savings_history']);
    final dated=history.fold<double>(0,(v,e)=>v+number(e['amount']));
    double value=max(0.0,number(data['savings_saved'])-dated);
    for(final entry in history){
      final date=DateTime.tryParse('${entry['date']??''}');
      if(date!=null&&date.isBefore(exclusiveEnd))value+=number(entry['amount']);
    }
    return value;
  }
  Widget stats(){
    final now=DateTime.now();
    final current=_periodStart(now,statsPeriod);
    final priorStart=_periodShift(current,-1,statsPeriod);
    final v=_periodTotals(current,_periodShift(current,1,statsPeriod));
    final prior=_periodTotals(priorStart,current);
    final income=max(0.0,v.income),spent=max(0.0,v.spent),sum=income+spent;
    final byCategory=<String,double>{};
    for(final x in tx){
      final date=DateTime.tryParse('${x['date']??''}');
      if(date==null||date.isBefore(current)||!date.isBefore(_periodShift(current,1,statsPeriod)))continue;
      if(x['type']!='Gasto'&&x['type']!='Pago mensual')continue;
      final n=max(0.0,number(x['amount']));
      if(n>0)byCategory.update('${x['category']??'Otro'}',(old)=>old+n,ifAbsent:()=>n);
    }
    final colors=[green,expenseRed,Colors.blue,Colors.orange,Colors.purple,Colors.teal,Colors.pink,Colors.amber,Colors.indigo];
    final items=byCategory.entries.toList()..sort((a,b)=>b.value.compareTo(a.value));
    final expenseTotal=items.fold<double>(0,(v,e)=>v+e.value);
    final count=statsPeriod=='daily'?7:statsPeriod=='weekly'?8:6;
    final periods=List.generate(count,(i)=>_periodShift(current,i-count+1,statsPeriod));
    final series=periods.map((p)=>_periodTotals(p,_periodShift(p,1,statsPeriod))).toList();
    final maxValue=max(1.0,series.fold<double>(0,(v,e)=>max(v,max(e.income,e.spent))))*1.2;
    final periodEnd=_periodShift(current,1,statsPeriod);
    double recurring=0,ordinary=0;
    for(final item in tx){
      final date=DateTime.tryParse('${item['date']??''}');
      if(date==null||date.isBefore(current)||!date.isBefore(periodEnd))continue;
      if(item['type']=='Pago mensual')recurring+=number(item['amount']);
      if(item['type']=='Gasto')ordinary+=number(item['amount']);
    }
    final goal=number(data['savings_goal']);
    final saved=number(data['savings_saved']);
    final savingsRatio=goal>0?(saved/goal).clamp(0.0,1.0).toDouble():0.0;
    final balanceSeries=periods.map((p)=>_balanceAt(_periodShift(p,1,statsPeriod))).toList();
    final savingSeries=periods.map((p)=>_savingsAt(_periodShift(p,1,statsPeriod))).toList();
    final hasSavingsHistory=records(data['savings_history']).isNotEmpty;
    final language='${data['language']??'es'}';
    final names=<String,List<String>>{
      'es':['Diario','Semanal','Mensual','Anual'],
      'en':['Daily','Weekly','Monthly','Yearly'],
      'fr':['Jour','Semaine','Mois','Année'],
      'de':['Tag','Woche','Monat','Jahr'],
      'bn':['দৈনিক','সাপ্তাহিক','মাসিক','বার্ষিক']
    };
    final periodNames=names[language]??names['es']!;
    return scroll([
      heading(t('stats')),
      card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(language=='es'?'Ver estadísticas por':language=='en'?'View statistics by':'Periodo / Period',style:Theme.of(dialogContext).textTheme.titleMedium),
        const SizedBox(height:10),
        Wrap(spacing:6,runSpacing:6,children:List.generate(4,(i){
          final key=['daily','weekly','monthly','yearly'][i];
          return ChoiceChip(label:Text(periodNames[i]),selected:statsPeriod==key,onSelected:(_)=>setState(()=>statsPeriod=key));
        }))
      ])),
      stat(t('income'),v.income,Icons.arrow_upward,green),
      stat(t('expenses'),v.spent,Icons.arrow_downward,expenseRed),
      heading(_analyticsText('overview')),
      stat(_analyticsText('available'),_balanceAt(periodEnd),Icons.account_balance_wallet,green),
      stat(_analyticsText('savings'),v.savings,Icons.savings,Colors.blue),
      stat(_analyticsText('recurring'),recurring,Icons.event_repeat,Colors.orange),
      stat(_analyticsText('ordinary'),ordinary,Icons.shopping_cart_outlined,expenseRed),
      stat(_analyticsText('net'),v.income-v.spent-v.savings,Icons.account_balance,Colors.teal),
      card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(_analyticsText('savingsGoal'),style:Theme.of(dialogContext).textTheme.titleMedium),
        const SizedBox(height:10),
        Text('${money(saved)} / ${money(goal)}'),
        const SizedBox(height:8),LinearProgressIndicator(value:savingsRatio),
        const SizedBox(height:8),Text('${(savingsRatio*100).toStringAsFixed(1)}%'),
      ])),
      card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(_analyticsText('balanceTrend'),style:Theme.of(dialogContext).textTheme.titleMedium),
        const SizedBox(height:16),
        SizedBox(height:190,child:LineChart(LineChartData(
          minY:min(0.0,balanceSeries.reduce(min))*1.1,
          maxY:max(1.0,balanceSeries.reduce(max))*1.1,
          lineBarsData:[LineChartBarData(spots:List.generate(count,(i)=>FlSpot(i.toDouble(),balanceSeries[i])),color:green,barWidth:3,isCurved:false,dotData:const FlDotData(show:true))],
          titlesData:FlTitlesData(topTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),rightTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),leftTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),bottomTitles:AxisTitles(sideTitles:SideTitles(showTitles:true,reservedSize:30,interval:1,getTitlesWidget:(value,meta){final i=value.toInt();return i>=0&&i<count&&value==i.toDouble()?Text(_periodLabel(periods[i],statsPeriod),style:const TextStyle(fontSize:9)):const SizedBox.shrink();})))
        ))),
      ])),
      card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(_analyticsText('savingsTrend'),style:Theme.of(dialogContext).textTheme.titleMedium),
        const SizedBox(height:12),
        if(!hasSavingsHistory)Text(_analyticsText('noHistory')) else SizedBox(height:190,child:LineChart(LineChartData(
          minY:0,maxY:max(1.0,savingSeries.reduce(max))*1.2,
          lineBarsData:[LineChartBarData(spots:List.generate(count,(i)=>FlSpot(i.toDouble(),savingSeries[i])),color:Colors.blue,barWidth:3,isCurved:false,dotData:const FlDotData(show:true))],
          titlesData:FlTitlesData(topTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),rightTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),leftTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),bottomTitles:AxisTitles(sideTitles:SideTitles(showTitles:true,reservedSize:30,interval:1,getTitlesWidget:(value,meta){final i=value.toInt();return i>=0&&i<count&&value==i.toDouble()?Text(_periodLabel(periods[i],statsPeriod),style:const TextStyle(fontSize:9)):const SizedBox.shrink();})))
        ))),
        if(number(data['savings_saved'])>records(data['savings_history']).fold<double>(0,(a,e)=>a+number(e['amount']))+0.001)
          Padding(padding:const EdgeInsets.only(top:8),child:Text(_analyticsText('legacy'),style:Theme.of(dialogContext).textTheme.bodySmall)),
      ])),

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
          lineBarsData:[LineChartBarData(spots:List.generate(count,(i)=>FlSpot(i.toDouble(),series[i].income)),color:green,isCurved:false,barWidth:3,dotData:const FlDotData(show:true)),LineChartBarData(spots:List.generate(count,(i)=>FlSpot(i.toDouble(),series[i].spent)),color:expenseRed,isCurved:false,barWidth:3,dotData:const FlDotData(show:true))],
          titlesData:FlTitlesData(topTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),rightTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),leftTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),bottomTitles:AxisTitles(sideTitles:SideTitles(showTitles:true,reservedSize:30,interval:1,getTitlesWidget:(value,meta){final i=value.toInt();return i>=0&&i<count&&value==i.toDouble()?Text(_periodLabel(periods[i],statsPeriod),style:const TextStyle(fontSize:9)):const SizedBox.shrink();})))
        )):BarChart(BarChartData(
          maxY:maxValue,alignment:BarChartAlignment.spaceAround,
          barGroups:List.generate(count,(i)=>BarChartGroupData(x:i,barRods:[BarChartRodData(toY:series[i].income,color:green,width:statsPeriod=='weekly'?7:9),BarChartRodData(toY:series[i].spent,color:expenseRed,width:statsPeriod=='weekly'?7:9)])),
          titlesData:FlTitlesData(topTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),rightTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),leftTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),bottomTitles:AxisTitles(sideTitles:SideTitles(showTitles:true,reservedSize:30,interval:1,getTitlesWidget:(value,meta){final i=value.toInt();return i>=0&&i<count&&value==i.toDouble()?Text(_periodLabel(periods[i],statsPeriod),style:const TextStyle(fontSize:9)):const SizedBox.shrink();})))
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

  Future<void> importBackup() async {
    final editor=TextEditingController();
    try {
      final clipboard=await Clipboard.getData('text/plain');
      if(clipboard?.text!=null)editor.text=clipboard!.text!;
    } catch (_) {}
    if(!mounted){editor.dispose();return;}
    final raw=await showDialog<String>(context:dialogContext,builder:(c)=>AlertDialog(
      title:Text(t('importBackup')),
      content:SizedBox(width:500,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:editor,maxLines:9,minLines:4,decoration:InputDecoration(hintText:t('pasteJsonHint'),border:const OutlineInputBorder())),
        TextButton.icon(onPressed:()async{final clip=await Clipboard.getData('text/plain');if(clip?.text!=null)editor.text=clip!.text!;},icon:const Icon(Icons.paste),label:Text(t('pasteClipboard')))
      ]))),
      actions:[TextButton(onPressed:()=>Navigator.pop(c),child:Text(t('cancel'))),FilledButton(onPressed:()=>Navigator.pop(c,editor.text),child:Text(t('import')))]));
    editor.dispose();
    if(raw==null||raw.trim().isEmpty)return;
    try {
      var clean=raw.trim().replaceFirst('\uFEFF','');
      if(clean.startsWith('```')){
        clean=clean.replaceFirst(RegExp(r'^```(?:json)?\s*',caseSensitive:false),'').replaceFirst(RegExp(r'\s*```$'),'').trim();
      }
      final decoded=jsonDecode(clean);
      if(decoded is! Map)throw const FormatException('Expected object');
      final obj=Map<String,dynamic>.from(decoded);
      // Accept old backups that omit transactions, but reject arbitrary JSON.
      const fields=['transactions','monthly_payments','monthly_income','opening_balance','savings_goal','monthly_savings','currency','language','setup_completed'];
      if(!fields.any(obj.containsKey))throw const FormatException('Not a MafiFlow backup');
      for(final key in ['transactions','monthly_payments','savings_history']){
        if(obj.containsKey(key)&&obj[key] is! List)throw const FormatException('Invalid list');
      }
      if(!mounted)return;
      final ok=await showDialog<bool>(context:dialogContext,builder:(c)=>AlertDialog(title:Text(t('importBackup')),content:Text(t('confirm')),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:Text(t('cancel'))),FilledButton(onPressed:()=>Navigator.pop(c,true),child:Text(t('yes')))]));
      if(ok!=true||!mounted)return;
      final replacement={...defaults,...obj};
      // Do not run scheduled charges on imported data before saving it.
      setState(()=>data=replacement);
      await save();
      notice(t('imported'));
    } catch (_) {if(mounted)notice(t('invalidBackup'));}
  }
  Widget settings()=>SettingsPanel(
    active:tab==5, data:data, t:t, scrollBuilder:scroll, cardBuilder:card, headingBuilder:heading,
    onManageCategories:manageCategories, onImportBackup:importBackup,
    onExportBackup:() async {
      final copy=Map<String,dynamic>.from(data)..['ai_api_key']='';
      await Clipboard.setData(ClipboardData(text:const JsonEncoder.withIndent('  ').convert(copy)));
      notice(t('backup'));
    },
    onSave:(values) async {
      data.addAll(values);
      applySavingsMonthly();
      await save();
      notice(t('settingsSaved'));
    },
    onInvalid:()=>notice(t('invalid')),
  );

}


// Keep the form state alive while other tabs rebuild. Never recreate text
// controllers during build: doing so discarded edits when a field lost focus.
class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key,required this.active,required this.data,required this.t,
    required this.scrollBuilder,required this.cardBuilder,required this.headingBuilder,
    required this.onManageCategories,required this.onImportBackup,
    required this.onExportBackup,required this.onSave,required this.onInvalid});
  final bool active;
  final Map<String,dynamic> data;
  final String Function(String) t;
  final Widget Function(List<Widget>) scrollBuilder;
  final Widget Function(Widget) cardBuilder;
  final Widget Function(String) headingBuilder;
  final VoidCallback onManageCategories;
  final Future<void> Function() onImportBackup;
  final Future<void> Function() onExportBackup;
  final Future<void> Function(Map<String,dynamic>) onSave;
  final VoidCallback onInvalid;
  @override State<SettingsPanel> createState()=>_SettingsPanelState();
}
class _SettingsPanelState extends State<SettingsPanel> {
  late final TextEditingController income,goal,monthlySavings,api,model,url;
  late String currency,incomeFrequency,provider,lang,theme;
  @override void initState(){
    super.initState();
    income=TextEditingController();
    goal=TextEditingController();
    monthlySavings=TextEditingController();
    api=TextEditingController();
    model=TextEditingController();
    url=TextEditingController();
    restoreSavedSettings();
  }
  // Load the last committed values, discarding any unsaved draft.
  // Only call when leaving/re-entering Settings, not during typing.
  void restoreSavedSettings(){
    final d=widget.data;
    income.text='${d['monthly_income']??0}';
    goal.text='${d['savings_goal']??0}';
    monthlySavings.text='${d['monthly_savings']??0}';
    api.text='${d['ai_api_key']??''}';
    model.text='${d['ai_model']??''}';
    url.text='${d['ai_base_url']??''}';
    currency='${d['currency']??'USD'}';
    incomeFrequency='${d['income_frequency']??'monthly'}';
    provider='${d['ai_provider']??'OpenAI'}';
    lang='${d['language']??'es'}';
    theme='${d['theme']??'light'}';
  }
  @override void didUpdateWidget(covariant SettingsPanel oldWidget){
    super.didUpdateWidget(oldWidget);
    // IndexedStack keeps Settings alive while another tab is selected.
    // When the tab changes, reload only committed data, never drafts.
    if(oldWidget.active != widget.active || !identical(oldWidget.data,widget.data)){
      restoreSavedSettings();
    }
  }
  @override void dispose(){for(final c in [income,goal,monthlySavings,api,model,url]){c.dispose();}super.dispose();}
  double? amount(String raw){final v=double.tryParse(raw.trim().replaceAll(',','.'));return v!=null&&v.isFinite&&v>=0?v:null;}
  Future<void> submit() async {
    final inc=amount(income.text),sav=amount(goal.text),monthly=amount(monthlySavings.text);
    if(inc==null||sav==null||monthly==null){widget.onInvalid();return;}
    await widget.onSave({
      'monthly_income':inc,'income_frequency':incomeFrequency,
      'income_start_date':incomeFrequency=='${widget.data['income_frequency']??'monthly'}'
        ?widget.data['income_start_date']:DateTime.now().toIso8601String().substring(0,10),
      'savings_goal':sav,'monthly_savings':monthly,'currency':currency,
      'ai_provider':provider,'ai_api_key':api.text.trim(),
      'ai_model':model.text.trim(),'ai_base_url':url.text.trim(),
      'language':lang,'theme':theme,
    });
  }
  @override Widget build(BuildContext context){
    String t(String k)=>widget.t(k);
    return widget.scrollBuilder([
      widget.headingBuilder(t('settings')),
      widget.cardBuilder(Column(children:[
        TextField(controller:income,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:t('payAmount'))),
        DropdownButtonFormField<String>(key:ValueKey('frequency-$incomeFrequency'),initialValue:['daily','weekly','biweekly','monthly'].contains(incomeFrequency)?incomeFrequency:'monthly',decoration:InputDecoration(labelText:t('payFrequency')),items:[DropdownMenuItem(value:'daily',child:Text(t('freqDaily'))),DropdownMenuItem(value:'weekly',child:Text(t('freqWeekly'))),DropdownMenuItem(value:'biweekly',child:Text(t('freqBiweekly'))),DropdownMenuItem(value:'monthly',child:Text(t('freqMonthly')))],onChanged:(v)=>setState(()=>incomeFrequency=v??'monthly')),
        TextField(controller:goal,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:t('goal'))),
        TextField(controller:monthlySavings,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:t('monthlySavings'))),
        Text(t('monthlySavingsHint')),
        // Opening balance is set only in the onboarding wizard. Do not edit it here.
        DropdownButtonFormField<String>(key:ValueKey('currency-$currency'),initialValue:currency,decoration:InputDecoration(labelText:t('currency')),items:['USD','CAD','EUR','GBP','BDT'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v)=>setState(()=>currency=v??'USD')),
        DropdownButtonFormField<String>(key:ValueKey('provider-$provider'),initialValue:['OpenAI','NVIDIA','Custom'].contains(provider)?provider:'OpenAI',decoration:InputDecoration(labelText:t('provider')),items:['OpenAI','NVIDIA','Custom'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>provider=v??'OpenAI')),
        TextField(controller:api,obscureText:true,decoration:InputDecoration(labelText:t('key'))),
        TextField(controller:model,decoration:InputDecoration(labelText:t('model'))),
        TextField(controller:url,decoration:InputDecoration(labelText:t('custom'))),
        DropdownButtonFormField<String>(key:ValueKey('language-$lang'),initialValue:const ['es','en','fr','de','bn'].contains(lang)?lang:'es',decoration:InputDecoration(labelText:t('language')),items:const [DropdownMenuItem(value:'es',child:Text('Español')),DropdownMenuItem(value:'en',child:Text('English')),DropdownMenuItem(value:'fr',child:Text('Français')),DropdownMenuItem(value:'de',child:Text('Deutsch')),DropdownMenuItem(value:'bn',child:Text('বাংলা'))],onChanged:(v)=>setState(()=>lang=v??'es')),
        DropdownButtonFormField<String>(key:ValueKey('theme-$theme'),initialValue:theme,decoration:InputDecoration(labelText:t('theme')),items:[DropdownMenuItem(value:'light',child:Text(t('light'))),DropdownMenuItem(value:'dark',child:Text(t('dark')))],onChanged:(v)=>setState(()=>theme=v??'light')),
        const SizedBox(height:12),FilledButton(onPressed:submit,child:Text(t('save')))
      ])),
      widget.cardBuilder(Column(children:[
        ListTile(leading:const Icon(Icons.category_outlined),title:Text(t('manageCategories')),onTap:widget.onManageCategories),
        ListTile(leading:const Icon(Icons.copy),title:Text(t('export')),onTap:widget.onExportBackup),
        ListTile(leading:const Icon(Icons.download),title:Text(t('import')),onTap:widget.onImportBackup),
      ])),
    ]);
  }
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
  @override Widget build(BuildContext context){final history=records(widget.data['ai_history']);return Column(children:[Expanded(child:ListView(controller:scroll,padding:const EdgeInsets.all(16),children:[for(final msg in history)Align(alignment:msg['role']=='user'?Alignment.centerRight:Alignment.centerLeft,child:Card(color:msg['role']=='user'?Theme.of(context).colorScheme.primaryContainer:null,child:Padding(padding:const EdgeInsets.all(12),child:Text('${msg['content']??''}')))),if(busy||status.isNotEmpty)Align(alignment:Alignment.centerLeft,child:Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[if(response.isNotEmpty)Text(response),if(status.isNotEmpty)Row(mainAxisSize:MainAxisSize.min,children:[if(busy)const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)),const SizedBox(width:8),Flexible(child:Text(status))])]))))])),Padding(padding:const EdgeInsets.all(12),child:Row(children:[Expanded(child:TextField(controller:input,enabled:!busy,maxLines:3,minLines:1,decoration:InputDecoration(hintText:{'es':'Escríbele a tu consejero','en':'Ask your advisor','fr':'Écrivez à votre conseiller','de':'Frage deinen Finanzberater','bn':'আপনার পরামর্শককে জিজ্ঞাসা করুন'}[widget.lang]??'Ask your advisor',border:const OutlineInputBorder()))),const SizedBox(width:8),IconButton.filled(onPressed:busy?null:send,icon:const Icon(Icons.send))]))]);}
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
  final Set<TextEditingController> selectedOnFirstFocus={};
  void selectInitialZero(TextEditingController controller){
    if(selectedOnFirstFocus.add(controller)&&controller.text=='0'){
      controller.selection=TextSelection(baseOffset:0,extentOffset:controller.text.length);
    }
  }
  int paymentDay=DateTime.now().day;
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
      bills.add({'name':pendingName,'amount':pendingAmount,'active':true,'day':paymentDay,'start_date':DateTime.now().toIso8601String().substring(0,10)});
      name.clear();payment.clear();paymentDay=DateTime.now().day;
    }
    widget.onComplete({'language':language,'currency':currency,'monthly_income':parse(income.text)??0,'income_frequency':incomeFrequency,'income_start_date':payday.toIso8601String().substring(0,10),'opening_balance':parse(opening.text)??0,'savings_goal':parse(goal.text)??0,'monthly_savings':parse(monthlySavings.text)??0,'monthly_payments':bills});
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('MafiFlow Mobile')),body:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:540),child:ListView(padding:const EdgeInsets.all(24),children:[LinearProgressIndicator(value:(step+1)/4),const SizedBox(height:28),Text(word('¡Bienvenido a MafiFlow!','Welcome to MafiFlow!','Bienvenue sur MafiFlow !','Willkommen bei MafiFlow!','MafiFlow-তে স্বাগতম!'),style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:22),
    if(step==0)...[Text(word('Elige idioma y moneda','Choose language and currency','Choisissez langue et devise','Sprache und Währung wählen','ভাষা ও মুদ্রা নির্বাচন করুন')),DropdownButtonFormField<String>(initialValue:language,items:const [DropdownMenuItem(value:'es',child:Text('Español')),DropdownMenuItem(value:'en',child:Text('English')),DropdownMenuItem(value:'fr',child:Text('Français')),DropdownMenuItem(value:'de',child:Text('Deutsch')),DropdownMenuItem(value:'bn',child:Text('বাংলা'))],onChanged:(v)=>setState(()=>language=v??'es')),DropdownButtonFormField<String>(initialValue:currency,items:['USD','CAD','EUR','GBP','BDT'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v)=>setState(()=>currency=v??'USD'))],
    if(step==1)...[Text(word('Configura tus finanzas iniciales','Set up your starting finances','Configurez vos finances','Finanzen einrichten','প্রাথমিক অর্থ সেট করুন')),TextField(controller:income,onTap:()=>selectInitialZero(income),keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:word('Cantidad que recibes por pago','Amount per payday','Montant par paie','Betrag pro Zahlung','প্রতি বেতনের পরিমাণ'))),DropdownButtonFormField<String>(initialValue:incomeFrequency,decoration:InputDecoration(labelText:word('¿Cada cuánto cobras?','How often are you paid?','À quelle fréquence êtes-vous payé ?','Wie oft wirst du bezahlt?','কত ঘন ঘন বেতন পান?')),items:[DropdownMenuItem(value:'daily',child:Text(word('Diariamente','Daily','Chaque jour','Täglich','প্রতিদিন'))),DropdownMenuItem(value:'weekly',child:Text(word('Semanalmente','Weekly','Chaque semaine','Wöchentlich','প্রতি সপ্তাহে'))),DropdownMenuItem(value:'biweekly',child:Text(word('Cada 2 semanas','Every 2 weeks','Toutes les 2 semaines','Alle 2 Wochen','প্রতি ২ সপ্তাহে'))),DropdownMenuItem(value:'monthly',child:Text(word('Mensualmente','Monthly','Chaque mois','Monatlich','প্রতি মাসে')))],onChanged:(v)=>setState(()=>incomeFrequency=v??'monthly')),const SizedBox(height:8),ListTile(contentPadding:EdgeInsets.zero,title:Text(word('Fecha del próximo cobro','Next payday','Date du premier paiement','Erster Zahltag','প্রথম বেতনের তারিখ')),subtitle:Text('${payday.year}-${payday.month.toString().padLeft(2,'0')}-${payday.day.toString().padLeft(2,'0')}'),trailing:const Icon(Icons.calendar_today),onTap:()async{final chosen=await showDatePicker(context:context,initialDate:payday,firstDate:DateTime(2020),lastDate:DateTime(2100));if(chosen!=null)setState(()=>payday=chosen);}),TextField(controller:opening,onTap:()=>selectInitialZero(opening),keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:word('Saldo disponible ahora (no se suma al salario)','Available balance now (not added to salary)','Solde actuel (pas un revenu)','Aktueller Kontostand (kein Einkommen)','বর্তমান ব্যালেন্স')))],
    if(step==2)...[TextField(controller:monthlySavings,onTap:()=>selectInitialZero(monthlySavings),keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:word('¿Cuánto quieres ahorrar al mes?','How much to save monthly?','Combien épargner par mois ?','Monatlicher Sparbetrag','মাসিক সঞ্চয়'))),TextField(controller:goal,onTap:()=>selectInitialZero(goal),keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:word('¿Cuál es tu objetivo total de ahorro?','Total savings target','Objectif total d’épargne','Gesamtsparziel','মোট সঞ্চয়ের লক্ষ্য'))),const SizedBox(height:12),Text(word('Mensualmente este dinero se descontará automáticamente del dinero disponible hasta llegar a tu objetivo.','Each month this amount will automatically be deducted from available money until you reach your goal.','Chaque mois, ce montant sera déduit de votre solde disponible jusqu’à votre objectif.','Jeden Monat wird dieser Betrag vom verfügbaren Geld abgezogen, bis das Ziel erreicht ist.','লক্ষ্য পূরণ না হওয়া পর্যন্ত প্রতি মাসে উপলব্ধ অর্থ থেকে এই পরিমাণ বাদ যাবে।'))],
    if(step==3)...[Text(word('Agrega tus gastos fijos (opcional)','Add recurring expenses (optional)','Ajoutez les dépenses récurrentes','Wiederkehrende Ausgaben','নিয়মিত খরচ যোগ করুন')),TextField(controller:name,decoration:InputDecoration(labelText:word('Nombre del gasto','Expense name','Nom de la dépense','Ausgabenname','খরচের নাম'))),TextField(controller:payment,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:word('Cantidad mensual','Monthly amount','Montant mensuel','Monatlicher Betrag','মাসিক পরিমাণ'))),DropdownButtonFormField<int>(initialValue:paymentDay,decoration:InputDecoration(labelText:word('Día de cobro mensual','Monthly charge day','Jour du prélèvement','Monatlicher Abbuchungstag','মাসিক পেমেন্টের দিন')),items:List.generate(31,(i)=>DropdownMenuItem(value:i+1,child:Text('${i+1}'))),onChanged:(v)=>setState(()=>paymentDay=v??1)),const SizedBox(height:8),TextButton.icon(onPressed:(){final n=parse(payment.text);if(name.text.trim().isEmpty||n==null||n<=0)return;setState((){bills.add({'name':name.text.trim(),'amount':n,'active':true,'day':paymentDay,'start_date':DateTime.now().toIso8601String().substring(0,10)});name.clear();payment.clear();paymentDay=DateTime.now().day;});},icon:const Icon(Icons.add),label:Text(word('Agregar pago','Add payment','Ajouter','Hinzufügen','যোগ করুন'))),...bills.map((b)=>ListTile(title:Text('${b['name']}'),trailing:Text('${b['amount']}')))],
    const SizedBox(height:30),Row(children:[if(step>0)TextButton(onPressed:()=>setState(()=>step--),child:Text(word('Atrás','Back','Retour','Zurück','পেছনে'))),const Spacer(),FilledButton(onPressed:next,child:Text(step==3?word('Empezar','Get started','Commencer','Starten','শুরু করুন'):word('Continuar','Continue','Continuer','Weiter','চালিয়ে যান')))])]))));
}

class CalculatorDialog extends StatefulWidget {const CalculatorDialog({super.key,required this.title});final String title;@override State<CalculatorDialog> createState()=>_CalculatorDialogState();}
class _CalculatorDialogState extends State<CalculatorDialog> {
  String display='0',operator='',previous='';bool resetNext=false;
  String format(double value)=>value.isFinite
      ?(value==value.roundToDouble()?value.toInt().toString():value.toStringAsFixed(6).replaceFirst(RegExp(r'0+$'),'').replaceFirst(RegExp(r'\.$'),''))
      :'Error';
  double evaluate(double a,double b,String op)=>switch(op){
    '+'=>a+b,'−'=>a-b,'×'=>a*b,'÷'=>b==0?double.nan:a/b,_=>b,
  };
  void press(String key){setState((){
    if(key=='C'){display='0';operator='';previous='';resetNext=false;return;}
    if(key=='⌫'){
      if(resetNext){resetNext=false;return;}
      display=display.length>1?display.substring(0,display.length-1):'0';
      if(display=='-'||display.isEmpty)display='0';
      return;
    }
    if(['+','−','×','÷'].contains(key)){
      if(operator.isNotEmpty&&!resetNext){
        final a=double.tryParse(previous),b=double.tryParse(display);
        if(a!=null&&b!=null)display=format(evaluate(a,b,operator));
      }
      if(display=='Error'){operator='';previous='';resetNext=true;return;}
      previous=display;operator=key;resetNext=true;return;
    }
    if(key=='='){
      final a=double.tryParse(previous),b=double.tryParse(display);
      if(a==null||b==null||operator.isEmpty)return;
      display=format(evaluate(a,b,operator));
      operator='';previous='';resetNext=true;return;
    }
    if(resetNext||display=='0'||display=='Error'){
      display=key=='.'?'0.':key;resetNext=false;
    }else if(key!='.'||!display.contains('.')){display+=key;}
  });}
  @override Widget build(BuildContext context)=>AlertDialog(title:Text(widget.title),content:SizedBox(width:300,child:Column(mainAxisSize:MainAxisSize.min,children:[Align(alignment:Alignment.centerRight,child:SelectableText(display,style:Theme.of(context).textTheme.headlineMedium)),const SizedBox(height:14),for(final row in [['7','8','9','÷'],['4','5','6','×'],['1','2','3','−'],['C','0','.','+'],['⌫','=']])Row(children:[for(final key in row)Expanded(child:Padding(padding:const EdgeInsets.all(3),child:FilledButton.tonal(onPressed:()=>press(key),child:Text(key))))])])),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('OK'))]);
}
