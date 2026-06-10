# SilviForTANITA

Primer MVP local para leer tarjetas SD de basculas Tanita BC-601/602.

## Hallazgos

- La tarjeta usa la estructura `GRAPHV1/SYSTEM` y `GRAPHV1/DATA`.
- `SYSTEM/PROF1.CSV` a `PROF4.CSV` guardan los cuatro perfiles.
- `DATA/DATA1.CSV` a `DATA4.CSV` guardan las mediciones por perfil.
- Las lineas no tienen cabecera: son pares `codigo,valor` con un prefijo tecnico al principio.
- El programa Healthy Edge Lite 2.13.3 ya importaba SD y emparejaba por nacimiento, sexo y altura.

## Codigos principales

| Codigo | Significado |
| --- | --- |
| `MO` | Modelo |
| `DB` | Fecha de nacimiento del perfil |
| `DT` / `Ti` | Fecha y hora de medicion |
| `Bt` | Modo corporal: `0` estandar, `2` atleta |
| `GE` | Sexo: `1` hombre, `2` mujer |
| `AG` | Edad |
| `Hm` | Altura en cm |
| `AL` | Actividad: `1` baja, `2` moderada, `3` intensa |
| `Wk` | Peso kg |
| `MI` | IMC |
| `FW` | Grasa corporal % |
| `Fr` / `Fl` | Grasa brazo derecho / izquierdo % |
| `FR` / `FL` | Grasa pierna derecha / izquierda % |
| `FT` | Grasa tronco % |
| `mW` | Musculo total kg |
| `mr` / `ml` | Musculo brazo derecho / izquierdo kg |
| `mR` / `mL` | Musculo pierna derecha / izquierda kg |
| `mT` | Musculo tronco kg |
| `bW` | Masa osea kg |
| `IF` | Grasa visceral |
| `rD` | DCI, calorias diarias estimadas |
| `rA` | Edad corporal o edad metabolica |
| `ww` | Agua corporal % |
| `CS` | Checksum |

## Datos actuales

- Perfil 1: 47 lecturas validas, del 16/03/2025 al 03/06/2026.
- Perfil 2: 112 lecturas validas, del 17/03/2025 al 06/06/2026.
- Perfil 4: 1 lectura, del 26/05/2026.
- Perfil 3 esta configurado, pero la lectura de `DATA3.CSV` coincide con el Perfil 4 y se deduplica.
- En `DATA2.CSV` hay tres pesos muy alejados de la serie normal. La app los excluye de graficas principales, pero se pueden revisar en la pestaña `Fuera de rango`.
- Si una lectura aparece duplicada o en un fichero de perfil que no coincide con sexo, altura y modo corporal, la app la reasigna y deduplica.

## Funciones del MVP

- Grafica con selector de metrica.
- Filtro de fechas `Desde` y `Hasta`.
- Barras deslizables para escala vertical, inicio visible y amplitud del rango temporal.
- Tooltip al pasar por encima de cada punto.
- Grafica y tabla de edad corporal (`rA`).
- Vista segmental tipo cuerpo con los modelos neutros guardados en `assets/` y grasa/musculo por brazo, pierna y tronco.
- Barras de analisis para IMC, grasa corporal, agua corporal y grasa visceral.
- Pestañas de tabla para lecturas validas y lecturas fuera de rango.
- Alta manual de nuevas lecturas.
- Exportacion CSV de respaldo completo con fecha y hora: perfiles, nombres visibles, ajustes, lecturas validas, fuera de rango y borrados.
- Importacion de ese CSV de respaldo desde `Importar archivos` para recuperar el estado de esa fecha.
- Historico local persistente en el navegador.
- Guardado en archivo local si se usa `server.py`: `SilviForTANITA/data/silvifortanita_state.json`.
- Importacion acumulativa: las nuevas lecturas se suman y las repetidas no se duplican.
- Borrado de lecturas concretas con memoria de borrado.
- Nombres personalizados de perfiles guardados para futuras aperturas.

## Referencias de rangos

- IMC adulto: CDC/NHLBI, rango saludable 18.5 a 24.9/25.
- Grasa corporal: tabla Tanita por sexo y edad.
- Agua corporal: Tanita Europe, mujeres 45% a 60%, hombres 50% a 65%.
- Grasa visceral: Tanita, 1 a 12 saludable; 13 a 59 alto.

## Uso

La forma sencilla es hacer doble clic en el archivo de la raiz del proyecto:

```text
Abrir_SilviForTANITA.bat
```

Ese lanzador arranca el servidor local si hace falta y abre la app en el navegador.

Si prefieres hacerlo manualmente, desde la carpeta raiz del proyecto arranca:

```powershell
python .\server.py --host 127.0.0.1 --port 8765
```

Y abre:

```text
http://127.0.0.1:8765/SilviForTANITA/
```

Con este servidor la app guarda automaticamente el estado completo en `SilviForTANITA/data/silvifortanita_state.json`. Al pulsar `Exportar respaldo CSV`, ademas de descargar el CSV, guarda una copia en `SilviForTANITA/data/exports/`.

Tambien se puede abrir como web estatica, pero entonces el guardado real en archivo no esta disponible y solo queda el historico del navegador.
