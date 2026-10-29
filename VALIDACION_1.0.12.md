# MafiFlow Android 1.0.12+23 — auditoría y validación

Base: MafiFlow_Android_1.0.11_Ahorro_Metas_Perfiles_Beta.zip, localizado en Descargas. No se usó el proyecto de Windows.

## Cambios

- `pubspec.yaml`: 1.0.11+22 → 1.0.12+23. El workflow ya no fuerza una versión antigua al compilar. La plantilla nativa de Flutter usa `versionCode = flutter.versionCode` y `versionName = flutter.versionName`; por tanto recibe 23 / 1.0.12. No había carpeta Android ni versionCode independiente en el ZIP original.
- Flutter fijado en 3.35.7 y Java 17. La carpeta Android se genera aparte y se copia, sin ejecutar `flutter create` sobre el código de la aplicación. Identidad original conservada: `com.mafistudio.mafiflow_mobile`.
- Acciones en main/master, ejecución manual y validación en pull requests. Los pull requests ejecutan análisis/pruebas, sin compilar entregables firmados ni acceder a secretos.
- Configuración de manifiesto y firma extraída a scripts verificables. La firma conserva el keystore aportado por secretos; no hay sustitución por firma debug. Se preservan contraseñas con espacios, signos y caracteres Unicode al escribir las propiedades Java.
- El APK se comprueba con aapt/apksigner: identidad, versión, permiso Internet y firma. El AAB debe existir, tener contenido y superar jarsigner con mensaje de archivo verificado. Ambos se exportan con error si faltan. Se adjuntan versión, commit, certificado del APK y sumas SHA256.
- «Otro» queda al final del selector de gastos/gastos desde ahorro, administrador de categorías y distribución por categorías en estadísticas, incluso después de agregar categorías personalizadas y aunque «Otro» tenga el importe mayor. Los IDs guardados no cambian; se siguen mostrando Other / Autre / Sonstiges / অন্যান্য según idioma. Ocultar «Otro» sigue siendo posible. Los movimientos conservan su orden cronológico.
- El asesor envía los últimos 20 mensajes, incluida la pregunta nueva. Antes enviaba los primeros 20 y omitía preguntas recientes al superar ese límite. El primer mensaje continúa incorporándose antes de crear la solicitud y los saldos se obtienen del perfil activo.

## Conexiones de interfaz auditadas en el código

| Función | Acceso y conexión |
| --- | --- |
| Agregar/retirar ahorro | Inicio y Movimientos → Agregar → acción de ahorro → performSavingsAction → guardar perfil |
| Gastar del ahorro | Movimientos → Agregar → Gastar del ahorro → gasto e historial vinculados; no doble descuento |
| Corregir ahorro | Inicio y Ajustes → correctSavingsBalance → guardar |
| Meta alcanzada y nueva meta | Inicio usa savingsGoalAchieved; botón y Ajustes llaman startNewSavingsGoal, conserva ahorro y reinicia progreso |
| Ahorro inicial | Asistente de perfil nuevo, controller initialSavings; se almacena separado del ingreso y reservado del saldo total |
| Datos para IA | financeContext incluye saldos iniciales, ahorro reservado, disponible y progreso; se añade al mensaje del sistema antes de la petición |
| Borrar perfil | Última opción de Ajustes → confirmación escrita localizada → resetActive → persistir; los demás perfiles se conservan |

Estas conexiones ya estaban presentes en 1.0.11; no se presentan como funciones nuevas creadas durante esta reparación. Las etiquetas de ahorro/metas/borrado existen en los cinco idiomas. Los controles de confirmación y meta utilizan colores del tema. Logos PNG conservados byte por byte.

## Ejecutado localmente

- `python scripts/check_source.py`: correcto (conexiones textuales, versión, etiquetas, recursos y pasos obligatorios).
- `python scripts/test_build_config.py`: 3 pruebas correctas; la prueba de firma cubre plantillas Kotlin y Groovy con claves simuladas, nunca con una clave real.
- YAML analizado con PyYAML 6.0.3: correcto; eventos y pasos interpretables. Esto no sustituye la evaluación de GitHub Actions.
- Scripts Python comprobados sintácticamente.
- Integridad CRC del ZIP final y comparación de recursos originales comprobadas al empaquetar.

## Pendiente y límites

No se encontró Flutter/Dart en PATH ni flutter.bat en Descargas, source, Documentos, AppData/Local y Program Files. No se ejecutaron `flutter analyze`, `flutter test`, Gradle, compilación ni instalación Android. Las pruebas Dart existentes más las nuevas de categorías/IA quedan para Actions. El análisis bloquea errores; avisos e información no bloquean, igual que en la base.

No se accedió a un repositorio GitHub ni a una ejecución real, secretos de firma, Google Play o proveedor IA. El workflow reparado exige compilar y exportar, pero su éxito real no está garantizado sin ejecutarlo. Este ZIP contiene fuentes, no APK/AAB. No hay pubspec.lock en la base ni se ha inventado uno: hasta resolver dependencias en Flutter, las versiones transitivas no quedan congeladas.

La plantilla Android fijada se contrastó con https://raw.githubusercontent.com/flutter/flutter/3.35.7/packages/flutter_tools/templates/app/android-kotlin.tmpl/app/build.gradle.kts.tmpl . El contrato de exportación se contrastó con https://github.com/actions/upload-artifact .

## Compilar y recoger los archivos

1. Extraer y copiar **el contenido** de MafiFlow-Mobile-main a la raíz del repositorio existente, incluyendo `.github`, `scripts`, `lib` y `test`. No subir solamente el ZIP ni colocar la carpeta completa dentro de otra carpeta del repositorio. Esta base genera Android desde cero; el paso se detendrá si ya existe una carpeta `android` para evitar sobrescribir configuración nativa sin revisarla.
2. Mantener los secretos `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, con la misma clave de actualización que corresponda a la app existente. Si falta uno, el release falla con su nombre.
3. Abrir Actions → Android Release APK + Google Play AAB → Run workflow. Esperar a que **todo el trabajo** termine verde; disponer de un APK parcial no demuestra que el AAB haya terminado.
4. Descargar artefactos `MafiFlow-1.0.12-23-Android-Release`, `MafiFlow-Google-Play-AAB` y `MafiFlow-1.0.12-23-verification` de esa misma ejecución. Revisar commit, 1.0.12 / 23 y certificado esperado. El workflow no publica automáticamente en Play.
5. Antes de distribuir, probar actualización sin desinstalar sobre una copia de datos existentes: metas alcanzadas/nuevas, depósito/retiro/gasto y eliminación de gasto, corrección de ahorro, primer mensaje IA y conversación con más de 20 mensajes. Confirmar además ahorro inicial en un perfil nuevo, borrado de un perfil con otro perfil intacto, categorías personalizadas y ambos temas en los cinco idiomas.

## Repetir comprobaciones con Flutter

Desde la raíz del proyecto, con Flutter 3.35.7:

```text
python scripts/check_source.py
python scripts/test_build_config.py
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

Para compilar localmente hace falta generar Android y configurar la firma siguiendo los mismos pasos del workflow. No introducir credenciales en el repositorio.
