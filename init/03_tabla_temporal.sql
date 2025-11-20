SET SERVEROUTPUT ON;
PROMPT ================================
PROMPT EJECUTANDO SCRIPT: TABLA TEMPORAL Y ESTRUCTURA DE DATOS
PROMPT ================================

CREATE TABLE temp_support_raw (
    unique_id VARCHAR2(100),
    channel_name VARCHAR2(100),
    category VARCHAR2(100),
    sub_category VARCHAR2(100),
    customer_remarks CLOB,
    order_id VARCHAR2(100),
    order_date_time VARCHAR2(100),
    issue_reported_at VARCHAR2(100),
    issue_responded VARCHAR2(100),
    survey_response_date VARCHAR2(100),
    customer_city VARCHAR2(100),
    product_category VARCHAR2(100),
    item_price VARCHAR2(50),
    connected_handling_time VARCHAR2(50),
    agent_name VARCHAR2(100),
    supervisor VARCHAR2(100),
    manager VARCHAR2(100),
    tenure_bucket VARCHAR2(100),
    agent_shift VARCHAR2(100),
    csat_score VARCHAR2(10),
    row_number NUMBER,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) TABLESPACE tbs_proyecto_temp;

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
) TABLESPACE tbs_proyecto_temp;

COMMIT;