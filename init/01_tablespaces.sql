SET SERVEROUTPUT ON
PROMPT ================================
PROMPT EJECUTANDO SCRIPT: TABLESPACES
PROMPT ================================

-- TABLESPACE DATOS
CREATE TABLESPACE tbs_proyecto_datos
DATAFILE '/opt/oracle/oradata/XE/tbs_proyecto_datos01.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE 1G
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

-- TABLESPACE INDICES
CREATE TABLESPACE tbs_proyecto_indices
DATAFILE '/opt/oracle/oradata/XE/tbs_proyecto_indices01.dbf'
SIZE 50M
AUTOEXTEND ON NEXT 10M MAXSIZE 500M
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

-- TABLESPACE TEMPORAL
CREATE TEMPORARY TABLESPACE tbs_proyecto_temp
TEMPFILE '/opt/oracle/oradata/XE/tbs_proyecto_temp01.dbf'
SIZE 50M
AUTOEXTEND ON NEXT 10M MAXSIZE 500M;

PROMPT ===== RESUMEN TABLESPACES =====

SELECT tablespace_name,
       status,
       contents
FROM dba_tablespaces
WHERE tablespace_name LIKE 'TBS_PROYECTO%';

SELECT tablespace_name,
       ROUND(SUM(bytes)/1024/1024, 2) AS size_mb
FROM dba_data_files
WHERE tablespace_name LIKE 'TBS_PROYECTO%'
GROUP BY tablespace_name;

COMMIT;