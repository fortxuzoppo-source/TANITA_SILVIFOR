# Apps moviles SilviForTANITA

Este proyecto usa Capacitor para empaquetar la app web actual como app Android e iOS.

## Estructura

- `APK/`: proyecto nativo Android.
- `IOS/`: proyecto nativo iOS para abrir en Xcode.
- `mobile-www/`: carpeta generada y limpia que se copia a las apps moviles. Esta ignorada por Git.
- `SilviForTANITA/`: app web fuente.

`mobile-www/` se genera desde `SilviForTANITA/`, pero excluye datos personales, la carpeta `data/` y respaldos `SilviForTANITA_*.csv`.

## Crear APK en Windows

La forma sencilla sera hacer doble clic en:

```text
Crear_APK_SilviForTANITA.bat
```

Necesita tener instalado Android Studio o un JDK + Android SDK. La APK debug queda en:

```text
APK\app\build\outputs\apk\debug\app-debug.apk
```

## Actualizar las apps tras cambiar la web

```powershell
npm.cmd run mobile:sync
```

## iOS

El proyecto iOS queda en `IOS/`. En Windows se puede dejar preparado, pero para compilar o subir a App Store hace falta macOS con Xcode.

En un Mac:

```bash
npm install
npm run ios:sync
npm run ios:open
```

Despues se compila desde Xcode.
