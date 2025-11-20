SET SERVEROUTPUT ON;
PROMPT ================================
PROMPT EJECUTANDO SCRIPT: TABLA DE AUDITORIA DE PROCESOS
PROMPT ================================

ALTER SESSION SET CONTAINER = XEPDB1;

CREATE TABLE control_procesos (
    id_proceso NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_tabla VARCHAR2(100) NOT NULL,
    filas_afectadas NUMBER DEFAULT 0,
    operacion VARCHAR2(20) CHECK (operacion IN ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE')),
    fecha_proceso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_proceso VARCHAR2(100) DEFAULT USER,
    fecha_carga_parametro DATE,
    mensaje VARCHAR2(500),
    estado VARCHAR2(20) DEFAULT 'EXITOSO'
) TABLESPACE tbs_proyecto_datos;

COMMIT;