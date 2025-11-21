# Customer_service_DB

**Resumen:**: Repositorio para desplegar una base de datos Oracle XE (contenedor), crear el esquema del proyecto, cargar el CSV de soporte y ejecutar el pipeline que transforma los datos en un modelo relacional y reportes resumen.

**Estructura**:
- **`docker-compose.yml`**: define el servicio `oracle-db` (Oracle XE) y monta las carpetas `init/` y `data/` dentro del contenedor.
- **`carga-soporte.bat`**: script Windows (cmd) para ejecutar `sqlldr` dentro del contenedor y disparar el pipeline PL/SQL.
- **`data/`**: contiene `Customer_support_data.csv` y `control-temp.ctl` (control file para SQL*Loader).
- **`init/`**: scripts SQL que inicializan tablespaces, usuario, tablas temporales, tablas finales, validaciones y procedimientos.

**Requisitos (previos)**:
- **Docker**: instalado y corriendo en Windows.
- **Docker Compose**: disponible (v1 o v2 compatible con `docker-compose.yml`).
- **Cuenta Oracle (opcional)**: la imagen en `docker-compose.yml` usa `container-registry.oracle.com/database/express:21.3.0-xe` — puede requerir `docker login` a `container-registry.oracle.com` con credenciales Oracle para poder descargar la imagen. Alternativa: usar una imagen pública compatible (p. ej. `gvenzl/oracle-xe`), si prefiere.
- Espacio en disco suficiente para el volumen de Oracle y los datafiles (el compose crea volúmenes locales).

**Pasos para ejecutar (Windows `cmd.exe`)**:

1) Abrir `cmd.exe` como administrador (recomendado) y situarse en la raíz del repo:

	 `cd "c:\Users\Acer1\Escritorio\Customer_service Database"`

2) (Si aplica) iniciar sesión en el registro Oracle si la imagen lo requiere:

	 `docker login container-registry.oracle.com`

3) Levantar el contenedor de la base de datos:

	 `docker-compose up -d`

	 - Ver logs para comprobar el arranque:
		 `docker logs -f oracle-db-proyecto`
	 - Espere varios minutos la primera vez (creación de instancia y ejecución de scripts de arranque puede tardar).

4) Comportamiento de los scripts `init/`:

	 - `docker-compose.yml` monta `./init` en `/opt/oracle/scripts/startup` dentro del contenedor. Muchas imágenes de Oracle ejecutan automáticamente los scripts SQL ubicados allí en el primer arranque. Si su imagen lo hace, los scripts se ejecutarán en el orden de archivos al iniciar el contenedor.
	 - Si no se ejecutan automáticamente, puede correrlos manualmente dentro del contenedor:

		 `docker exec -it oracle-db-proyecto bash`
		 `# dentro del contenedor` 
		 `sqlplus / as sysdba`
		 `ALTER SESSION SET CONTAINER = XEPDB1;`
		 `@/opt/oracle/scripts/startup/01_tablespaces.sql`
		 `@/opt/oracle/scripts/startup/02_users.sql`
		 `@/opt/oracle/scripts/startup/03_tabla_temporal.sql`
		 `@/opt/oracle/scripts/startup/04_tabla_auditoria.sql`
		 `@/opt/oracle/scripts/startup/05_tablas_finales.sql`
		 `@/opt/oracle/scripts/startup/06_validaciones.sql`
		 `@/opt/oracle/scripts/startup/07_procedures.sql`
		 `@/opt/oracle/scripts/startup/08_procedures_tables.sql`

	 - Orden de ejecución recomendado: `01` → `02` → `03` → `04` → `05` → `06` → `07` → `08`.

5) Cargar los datos (CSV) y ejecutar pipeline:

	 - En Windows, desde la raíz del repo puede ejecutar el batch que invoca `sqlldr` dentro del contenedor y luego llama al pipeline PL/SQL:

		 `carga-soporte.bat`

	 - Qué hace `carga-soporte.bat`:
		 - Ejecuta `sqlldr usuario_proyecto/Proyecto123@XEPDB1 control=/opt/oracle/data/control-temp.ctl` dentro del contenedor `oracle-db-proyecto`.
		 - Luego crea un `temp_script.sql` para invocar `sp_pipeline_carga_soporte` y otros comandos (ej. `GENERAR_REPORTE_RESUMEN`) y lo ejecuta con `sqlplus`.

	 - Archivos relevantes:
		 - `data/control-temp.ctl` debe apuntar a `/opt/oracle/data/Customer_support_data.csv` (el `docker-compose.yml` monta `./data` en `/opt/oracle/data`).
		 - Si hay errores en la carga, revise los archivos: `/opt/oracle/data/carga.log`, `/opt/oracle/data/carga.bad` y `/opt/oracle/data/carga.dsc`.

6) Verificar resultados (consultas rápidas desde `cmd.exe`):

	 - Conectar con `sqlplus` desde host al contenedor (ejecutando dentro del contenedor o con `docker exec`):

		 `docker exec -it oracle-db-proyecto sqlplus usuario_proyecto/Proyecto123@XEPDB1`

	 - Consultas de verificación:

		 `SELECT COUNT(*) FROM temp_support_raw;`
		 `SELECT COUNT(*) FROM fact_support_tickets;`
		 `SELECT * FROM control_procesos ORDER BY fecha_proceso DESC FETCH FIRST 20 ROWS ONLY;`
		 `EXEC GENERAR_REPORTE_RESUMEN(TO_DATE('2023-01-01','YYYY-MM-DD'), TO_DATE('2025-12-31','YYYY-MM-DD'));`
		 `SELECT * FROM REPORTES_RESUMEN;`

**Puntos importantes / Consideraciones**:
- `docker-compose.yml` define `ORACLE_PWD=OraclePass123` para la instancia de sistema; el usuario del proyecto creado en `02_users.sql` es `usuario_proyecto` con contraseña `Proyecto123` — esos credenciales son usados por los scripts y `carga-soporte.bat`.
- La ruta de los datafiles en `init/01_tablespaces.sql` apunta a `/opt/oracle/oradata/XE/...` — el contenedor debe permitir crear esos archivos en el volumen `oracle-data`.
- Si la imagen oficial de Oracle no permite descargar sin autenticar, use una imagen alternativa pública o descargue la imagen manualmente tras login.

**Resolución de problemas comunes**:
- Si `docker-compose up` falla al bajar la imagen: realice `docker login container-registry.oracle.com` o reemplace la imagen por otra pública.
- Si los scripts SQL no se ejecutan al inicio: conéctese manualmente y ejecute los scripts en el orden recomendado.
- Si `sqlldr` no encuentra el archivo CSV: confirme que `./data/Customer_support_data.csv` existe y que el volumen está montado; dentro del contenedor verifique `/opt/oracle/data/Customer_support_data.csv`.
- Revisar logs de carga: `docker exec -it oracle-db-proyecto bash -c "ls -l /opt/oracle/data && tail -n 200 /opt/oracle/data/carga.log"`.
- Errores en conversiones de tipos (p. ej. `TO_TIMESTAMP`): revise formatos de fecha en CSV y ajuste las expresiones `TO_TIMESTAMP` en `init/08_procedures_tables.sql` si es necesario.

**Comprobaciones Post-ejecución**:
- `docker ps` → confirma que `oracle-db-proyecto` está en ejecución.
- `docker logs oracle-db-proyecto` → ver mensajes de arranque o errores.
- Consultas rápidas con `sqlplus` para verificar filas en `temp_support_raw` y `fact_support_tickets`.

**Siguientes pasos sugeridos**:
- (Opcional) Añadir un script PowerShell o instrucción para ejecutar todo de forma no interactiva.
- (Opcional) Añadir `README` en inglés y un small `run.ps1` que capture logs y salidas.

Si quieres, puedo:
- Ejecutar una validación más profunda (buscar dependencias faltantes o líneas problemáticas en SQL).
- Añadir un script PowerShell equivalente a `carga-soporte.bat`.

---
Archivo editado automáticamente: `README.md` — contiene los pasos para arranque, carga de datos y verificación.
