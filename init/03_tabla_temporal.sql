SET SERVEROUTPUT ON;
PROMPT ================================
PROMPT EJECUTANDO SCRIPT: TABLA TEMPORAL Y ESTRUCTURA DE DATOS
PROMPT ================================

ALTER SESSION SET CONTAINER = XEPDB1;

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

COMMIT;