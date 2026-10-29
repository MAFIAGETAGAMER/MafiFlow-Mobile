# MafiFlow Android 1.0.14+25 — orden visual final

Base: entrega 1.0.13+24 de este chat.

- Inicio: saldo disponible vuelve a ser una tarjeta compacta con icono e importe. Se quita su botón de corrección.
- Inicio: se quitan Agregar al ahorro, Retirar del ahorro y Corregir ahorro. Nueva meta permanece dentro de la condición savingsGoalAchieved, junto al mensaje de objetivo logrado; no aparece antes de cumplir la meta.
- Ajustes: primero Corregir saldo disponible, Corregir ahorro y Nueva meta, conservando sus iconos y diálogos; después un separador y los campos de configuración existentes.
- La sección final de ayuda, perfiles, categorías, exportar/importar JSON y borrado se conserva literalmente igual. Los movimientos de ahorro siguen accesibles en Movimientos → Agregar.
- Etiquetas, traducciones, colores del tema, recursos gráficos y lógica financiera sin cambios. Versión y nombres de artefactos actualizados a 1.0.14+25.

Verificación realizada: comprobaciones de código de ausencia de los botones en Inicio, condición de meta cumplida conservada, orden de las tres acciones en Ajustes, sección final idéntica, comprobador estático del proyecto, sintaxis YAML y Python, integridad del ZIP y recursos gráficos idénticos.

Sin SDK Flutter disponible: no se ejecutaron analyze, pruebas Dart, compilación APK/AAB ni prueba visual de la app. Las capturas del usuario se usaron como referencia del cambio solicitado; no se presentan como capturas de esta entrega. GitHub Actions debe ejecutar las comprobaciones y la compilación real con los secretos de firma existentes.

Extraer el ZIP y copiar el contenido de MafiFlow-Mobile-main a la raíz del repositorio, incluyendo .github, scripts, lib, test y pubspec.yaml. Ejecutar Android Release APK + Google Play AAB y esperar a que termine todo el trabajo. Este paquete contiene fuentes.

Los informes 1.0.12 y 1.0.13 se conservan como historial; describen versiones anteriores de la interfaz.
