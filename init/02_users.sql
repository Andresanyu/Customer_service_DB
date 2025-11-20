SET SERVEROUTPUT ON;

PROMPT ---------------------------------------------------------------
PROMPT CREACIÓN DE USUARIO Y ASIGNACIÓN DE PERMISOS
PROMPT ---------------------------------------------------------------

CREATE USER usr_proyecto
IDENTIFIED BY ProyectoDB123
DEFAULT TABLESPACE tbs_proyecto_datos
TEMPORARY TABLESPACE tbs_proyecto_temp
QUOTA UNLIMITED ON tbs_proyecto_datos
QUOTA UNLIMITED ON tbs_proyecto_indices;

GRANT CREATE SESSION TO usr_proyecto;
GRANT CONNECT TO usr_proyecto;
GRANT RESOURCE TO usr_proyecto;

GRANT CREATE TABLE TO usr_proyecto;
GRANT CREATE VIEW TO usr_proyecto;
GRANT CREATE SEQUENCE TO usr_proyecto;
GRANT CREATE SYNONYM TO usr_proyecto;

GRANT CREATE PROCEDURE TO usr_proyecto;
GRANT CREATE TRIGGER TO usr_proyecto;

GRANT SELECT ANY TABLE TO usr_proyecto;
GRANT INSERT ANY TABLE TO usr_proyecto;
GRANT UPDATE ANY TABLE TO usr_proyecto;
GRANT DELETE ANY TABLE TO usr_proyecto;

GRANT CREATE ANY INDEX TO usr_proyecto;

GRANT EXECUTE ON DBMS_LOCK TO usr_proyecto;
GRANT EXECUTE ON DBMS_OUTPUT TO usr_proyecto;

GRANT SELECT ON DBA_TABLESPACES TO usr_proyecto;
GRANT SELECT ON DBA_DATA_FILES TO usr_proyecto;
GRANT SELECT ON DBA_TABLES TO usr_proyecto;
GRANT SELECT ON DBA_INDEXES TO usr_proyecto;

COMMIT;