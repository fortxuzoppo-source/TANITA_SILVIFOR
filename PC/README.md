# PC SilviForTANITA

Aplicacion local `SilviForTANITA` para leer historicos de basculas Tanita BC-601/602 desde ficheros de tarjeta SD.

## Arranque facil

Haz doble clic en:

```text
Abrir_SilviForTANITA.bat
```

Ese archivo arranca el servidor local si hace falta y abre la app en el navegador.

## Arranque manual

```powershell
python .\server.py --host 127.0.0.1 --port 8765
```

Abre:

```text
http://127.0.0.1:8765/SilviForTANITA/
```

## Notas de privacidad

El repositorio incluye la aplicacion y sus recursos visuales. No incluye lecturas personales, exportaciones, la carpeta `TANITA/`, ni el programa antiguo `HealthyEdgeLite_V2_13_3/`.

La app guarda el estado local en:

```text
SilviForTANITA/data/silvifortanita_state.json
```

Ese archivo contiene datos de salud y queda ignorado por Git.
