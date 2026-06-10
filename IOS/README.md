# iOS SilviForTANITA

Proyecto iOS de SilviForTANITA generado con Capacitor.

## Desde Windows sin Mac

El repo incluye un workflow manual de GitHub Actions que compila en macOS y genera un IPA sin firmar:

1. En GitHub, abre `Actions`.
2. Entra en `Build unsigned iOS IPA`.
3. Pulsa `Run workflow`.
4. Cuando termine, descarga el artifact `SilviForTANITA-unsigned-ipa`.
5. Instala el `.ipa` en el iPhone desde Windows con Sideloadly.

Con Apple ID gratis la instalacion puede caducar y requerir reinstalacion.

## En un Mac

```bash
npm install
npm run ios:sync
npm run ios:open
```

La app web fuente esta en `../PC/SilviForTANITA`.
