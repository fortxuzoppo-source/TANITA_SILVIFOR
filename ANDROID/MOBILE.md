# Android SilviForTANITA

Esta carpeta usa Capacitor para empaquetar la app web de `../PC/SilviForTANITA` como app Android.

## Estructura

- `APK/`: proyecto nativo Android.
- `mobile-www/`: carpeta generada y limpia que se copia a las apps moviles. Esta ignorada por Git.
- `../PC/SilviForTANITA/`: app web fuente.

`mobile-www/` se genera desde `../PC/SilviForTANITA/`, pero excluye datos personales, la carpeta `data/` y respaldos `SilviForTANITA_*.csv`.

## Crear APK en Windows

La forma sencilla sera hacer doble clic en:

```text
ANDROID\Crear_APK_SilviForTANITA.bat
```

Necesita tener instalado Android Studio o un JDK + Android SDK. La APK debug queda en:

```text
ANDROID\APK\SilviForTANITA-debug.apk
```

## Actualizar las apps tras cambiar la web

```powershell
npm.cmd run android:sync
```
