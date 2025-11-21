# Customer_service_DB

Repositorio para desplegar una base de datos Oracle XE con la herramienta Docker, crear el esquema del proyecto, cargar el CSV de soporte y ejecutar el pipeline que transforma los datos en un modelo relacional y reportes resumen.

### Estructura:
- **`docker-compose.yml`**: define el servicio `oracle-db` el cual usa Oracle XE y monta las carpetas `init/` y `data/` dentro del contenedor.
- **`carga-soporte.bat`**: script Windows para ejecutar `sqlldr` dentro del contenedor y disparar el pipeline PL/SQL el cual pobla las tablas.
- **`data/`**: contiene `Customer_support_data.csv` y control file para SQL*Loader.
- **`init/`**: scripts SQL que inicializan tablespaces, usuario, tablas temporales, tablas finales, validaciones y procedimientos.

### Requisitos de ejecucion:
- **Docker**: instalado y corriendo en Windows.
- **Docker Compose**: disponible (v1 o v2 compatible con `docker-compose.yml`).
- Espacio en disco suficiente para el volumen de Oracle y los datasets.

### Pasos para ejecutar:

1) Abrir `cmd.exe` y situarse en la raíz del repositorio:

	 `cd "c:\Users\Acer1\Escritorio\Customer_service Database"`

2) Levantar el contenedor de la base de datos:

	 `docker-compose up -d`

	 - Ver logs para comprobar el arranque:
		 `docker logs -f oracle-db-proyecto`
	 - Espere varios minutos la primera vez a la creacion de la instacia, tablas, indices, procedimientos y demas.

3) Comportamiento de los scripts `init/`:

	 - `docker-compose.yml` monta `./init` en `/opt/oracle/scripts/startup` dentro del contenedor. Los scripts se ejecutarán en el orden de archivos al iniciar el contenedor.

        - `@/opt/oracle/scripts/startup/01_tablespaces.sql`
        Se encarga de crear los tablespaces correspondientes que va a usar el modelo.

        - `@/opt/oracle/scripts/startup/02_users.sql`
        Es el encargado de la creacion del usuario de la base de datos.
        
        - `@/opt/oracle/scripts/startup/03_tabla_temporal.sql`
        Su funcion es crear la tabla temporal que se usara posteriormente para cargar los datos.
        
        - `@/opt/oracle/scripts/startup/04_tabla_auditoria.sql`
        Crea la tabla de auditoria y monitoreo de las acciones ejecutadas en la base de datos.
        
        - `@/opt/oracle/scripts/startup/05_tablas_finales.sql`
        Uno de los mas importantes, el delegado de crear las tablas del modelo propuesto.
        
        - `@/opt/oracle/scripts/startup/06_validaciones.sql`
        Se requiere para hacer el procedimiento de validacion de fecha, el cual se usa en la carga de los datos.
        
        - `@/opt/oracle/scripts/startup/07_logica_de_negocio.sql`
        Este genera los procedures y paquetes que componen la logica de negocio para el modelo.
        
        - `@/opt/oracle/scripts/startup/08_procedures_loading.sql` - Se encarga de construir los procedimientos y triggers a usar posteriormente en la carga de los datos.

4) Cargar los datos (CSV) y ejecutar pipeline:

	 - En Windows, desde la raíz del repo puede ejecutar el batch que invoca `sqlldr` dentro del contenedor y luego llama al pipeline PL/SQL:

		 **`carga-soporte.bat`**

		 - Ejecuta `sqlldr usuario_proyecto/Proyecto123@XEPDB1 control=/opt/oracle/data/control-temp.ctl` dentro del contenedor `oracle-db-proyecto`.
		 - Luego crea un `temp_script.sql` para invocar `sp_pipeline_carga_soporte` y otros comandos, por ejemplo `GENERAR_REPORTE_RESUMEN` y lo ejecuta con `sqlplus`.

### Comprobaciones Post-ejecución:
- `docker ps` esto confirma que `oracle-db-proyecto` está en ejecución.
- `docker logs oracle-db-proyecto` sirve para ver mensajes de arranque o errores.