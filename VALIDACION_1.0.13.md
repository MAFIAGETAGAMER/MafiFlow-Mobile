# MafiFlow Android 1.0.13+24 — corregir saldo disponible

Basado en la entrega corregida 1.0.12+23 de este chat. Incluye sus correcciones de categorías, historial IA y workflow.

## Cambio solicitado

En Inicio, dentro de la tarjeta del saldo disponible, aparece **Corregir saldo disponible**, con el mismo botón de lápiz y diálogo de cancelar/guardar que Corregir ahorro. El importe inicial del diálogo es el disponible actual, sin incluir ahorros. Admite coma decimal, cero y saldo negativo; rechaza valores no numéricos o infinitos.

En Ajustes se reemplazó el antiguo campo Corregir dinero inicial por una opción que abre ese mismo diálogo. Guardar otros ajustes ya no puede sobrescribir el saldo con un borrador antiguo de ese campo. El asistente inicial de perfiles conserva su pregunta de dinero inicial.

La corrección cambia el saldo base por la diferencia entre el disponible actual y el importe indicado. No añade ingresos/gastos ni altera movimientos, ahorro reservado, historial de ahorro o meta. Como ocurría al corregir el dinero inicial, cambiar el saldo base también recalcula los saldos históricos; no es un ajuste fechado. La IA obtiene el disponible corregido al construir la siguiente consulta.

Etiquetas y explicación incluidas en español, inglés, francés, alemán y bengalí. Los controles usan el tema de Flutter, con el mismo estilo del diálogo de ahorro.

Versión: `1.0.13+24`. El workflow continúa derivando versionName/versionCode de pubspec.yaml y los comprueba en el APK; nombres de artefactos actualizados a 1.0.13-24.

## Validación

- Ejecutadas comprobaciones estáticas de versión, conexiones de los dos accesos, traducciones, recursos y workflow.
- YAML interpretado con PyYAML; scripts Python comprobados sintácticamente.
- Comparados los archivos con 1.0.12+23: recursos gráficos y lógica ajena a esta petición conservados.
- ZIP comprobado por CRC y comparación del contenido empaquetado.
- Añadidas dos pruebas Dart para corrección con ingresos/gastos existentes, conservación de ahorro e historial, repetición, cero, saldo negativo y rechazo de valores infinitos. **No ejecutadas**: Flutter/Dart sigue sin estar disponible en PATH. Tampoco se ha compilado APK/AAB ni probado en dispositivo o GitHub Actions en esta entrega.

## Usar en GitHub

Extraer el ZIP y subir el contenido de `MafiFlow-Mobile-main` a la raíz del repositorio existente, incluyendo `.github`, `lib`, `scripts`, `test` y pubspec.yaml. Después ejecutar **Android Release APK + Google Play AAB** y esperar a que todo el trabajo termine verde. Se requieren los mismos secretos de firma de la entrega anterior. El ZIP contiene fuentes, no un APK.

Los detalles anteriores del workflow y sus límites están en VALIDACION_1.0.12.md, conservado como informe histórico.
