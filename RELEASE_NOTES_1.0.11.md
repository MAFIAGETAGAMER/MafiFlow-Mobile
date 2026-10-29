# MafiFlow Android 1.0.11 (build 22) — ahorros, metas y privacidad

Fuente: versión Android 1.0.10 (build 21) con perfiles independientes ya probados.

## Cambios
- Meta lograda: mensaje de éxito y acción **Nueva meta**. El nuevo progreso comienza en cero, pero el dinero reservado sigue guardado. `savings_goal_base` identifica la parte de ahorro anterior a la nueva meta.
- **Movimientos**: registrar depósitos en el ahorro, retiradas del ahorro y **gastos pagados desde el ahorro**. Un gasto de ese tipo figura en las estadísticas y reduce el ahorro reservado a la vez, evitando doble descuento de saldo disponible.
- Lista de **movimientos de ahorro** en la pantalla de Movimientos. Los gastos desde ahorro se pueden eliminar y esa acción revierte el retiro ligado al gasto.
- **Corregir ahorro** en Inicio y Ajustes, para arreglar errores de cifra sin crear perfiles nuevos.
- Asistente IA: contexto con saldo inicial, ahorro ya existente al empezar a usar la app, reserva actual, objetivo y progreso de meta; resumen local incorpora ahorro inicial.
- Primer inicio de perfil: pregunta cuánto dinero había ya ahorrado (`savings_opening_known` preserva si ese valor se informó explícitamente; en instalaciones anteriores no se inventa). **Dinero total actual** incluye el ahorro; de ese total se separa la reserva, sin añadir ingresos inventados.
- Ajustes: también permite corregir el dinero inicial; al final aparece **Borrar toda la información del perfil**, con confirmación escrita y advertencia. No elimina otros perfiles; resetea onboarding del perfil seleccionado. Si corresponde, también borra la clave de datos antiguos `mafiflow_data` después de persistir.
- Todos los textos añadidos están traducidos a español, inglés, francés, alemán y bengalí. Botones de eliminación usan color de error del tema activo, compatible con los modos claro y oscuro.
- Se mantienen las claves de persistencia `mafiflow_profiles_v1` y el formato del backup `version: 1` para compatibilidad con versiones anteriores; se añaden campos opcionales, que versiones anteriores podrían ignorar.
- La reserva mensual automática queda limitada al saldo disponible y al progreso que falta por alcanzar la meta. Si no hay saldo, no crea una reserva negativa.

## Casos a validar con testers antes de Google Play
1. ACTUALIZAR una instalación que tenga perfiles, ahorros y pagos registrados; no desinstalar ni borrar almacenamiento. Verificar que todo se conserve. Exportar JSON primero.
2. Crear un perfil nuevo con dinero total 500 y ahorro inicial 100: disponible = 400 (sin contar el ahorro como ingreso). Confirmar que IA y resumen local reconocen 500, 100 y 400.
3. Reservar 40 desde disponible: disponible baja 40 y ahorro sube 40; retirar 10: cambios inversos.
4. Gastar 20 desde ahorro: gasto +20, ahorro -20 y disponible se mantiene. Eliminar esa compra: restaura el ahorro y elimina el gasto, sin doble cargo.
5. Corregir ahorro existente y ajustar dinero inicial desde Ajustes; comprobar que las estadísticas y el asesor recogen los valores.
6. Alcanzar meta, observar «Objetivo logrado», iniciar nueva meta: progreso = 0 pero ahorro total permanece.
7. Cambiar de perfil y repetir; usar botón borrar datos en el secundario: el principal queda intacto y el secundario vuelve al asistente de bienvenida.
8. Revisar diseños claro/oscuro e idiomas ES/EN/FR/DE/BN, incluido mensaje de confirmación de borrado.
9. GitHub Actions: ejecutar `flutter analyze`, `flutter test`, APK firmado y AAB firmado; verificar que se mantiene app id y firma de Play Console.

## Advertencias
- Este ZIP contiene **fuente**, no un APK/AAB compilado. El SDK Flutter/Dart no está instalado en este entorno: las pruebas Dart/Flutter **NO se han ejecutado aquí**. GitHub Actions las ejecutará al construir el artefacto.
- No usar `1.0.11+22` si el último versionCode usado en Play Console es 22 o superior; en ese caso incrementar el build-number tanto en `pubspec.yaml` como en el workflow.
- No cambiar de `version: 1` del archivo de perfiles ni forzar conversiones automáticas de moneda.
