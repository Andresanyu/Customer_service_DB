SET SERVEROUTPUT ON;
PROMPT ================================
PROMPT EJECUTANDO SCRIPT: TABLAS FINALES DEL PROYECTO
PROMPT ================================

ALTER SESSION SET CONTAINER = XEPDB1;

CREATE TABLE agentes (
    id_agente NUMBER GENERATED ALWAYS AS IDENTITY,
    agent_name VARCHAR2(100) NOT NULL,
    supervisor VARCHAR2(100),
    manager VARCHAR2(100),
    tenure_bucket VARCHAR2(50),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP,
    CONSTRAINT pk_agentes PRIMARY KEY (id_agente) USING INDEX TABLESPACE tbs_proyecto_indices,
    CONSTRAINT uk_agente_nombre UNIQUE (agent_name) USING INDEX TABLESPACE tbs_proyecto_indices
) TABLESPACE tbs_proyecto_datos;

CREATE TABLE clientes (
    id_cliente NUMBER GENERATED ALWAYS AS IDENTITY,
    customer_city VARCHAR2(100),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_clientes PRIMARY KEY (id_cliente) USING INDEX TABLESPACE tbs_proyecto_indices
) TABLESPACE tbs_proyecto_datos;

CREATE TABLE productos (
    id_producto NUMBER GENERATED ALWAYS AS IDENTITY,
    product_category VARCHAR2(100) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_productos PRIMARY KEY (id_producto) USING INDEX TABLESPACE tbs_proyecto_indices,
    CONSTRAINT uk_producto_categoria UNIQUE (product_category) USING INDEX TABLESPACE tbs_proyecto_indices
) TABLESPACE tbs_proyecto_datos;

CREATE TABLE categorias (
    id_categoria NUMBER GENERATED ALWAYS AS IDENTITY,
    category VARCHAR2(100) NOT NULL,
    sub_category VARCHAR2(100),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_categorias PRIMARY KEY (id_categoria) USING INDEX TABLESPACE tbs_proyecto_indices,
    CONSTRAINT uk_cat_subcat UNIQUE (category, sub_category) USING INDEX TABLESPACE tbs_proyecto_indices
) TABLESPACE tbs_proyecto_datos;

CREATE TABLE canales (
    id_canal NUMBER GENERATED ALWAYS AS IDENTITY,
    channel_name VARCHAR2(50) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_canales PRIMARY KEY (id_canal) USING INDEX TABLESPACE tbs_proyecto_indices,
    CONSTRAINT uk_canal_nombre UNIQUE (channel_name) USING INDEX TABLESPACE tbs_proyecto_indices
) TABLESPACE tbs_proyecto_datos;

CREATE TABLE fact_support_tickets (
    id_ticket NUMBER GENERATED ALWAYS AS IDENTITY,
    unique_id VARCHAR2(100) NOT NULL,
    id_agente NUMBER,
    id_cliente NUMBER,
    id_producto NUMBER,
    id_categoria NUMBER,
    id_canal NUMBER,
    order_id VARCHAR2(50),
    order_date_time TIMESTAMP,
    issue_reported_at TIMESTAMP,
    issue_responded TIMESTAMP,
    survey_response_date DATE,
    customer_remarks CLOB,
    item_price NUMBER(10,2),
    connected_handling_time NUMBER(10,2),
    agent_shift VARCHAR2(50),
    csat_score NUMBER(1) CHECK (csat_score BETWEEN 1 AND 5),
    response_time_minutes NUMBER(10,2),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_fact_support PRIMARY KEY (id_ticket) USING INDEX TABLESPACE tbs_proyecto_indices,
    CONSTRAINT uk_unique_ticket UNIQUE (unique_id) USING INDEX TABLESPACE tbs_proyecto_indices,
    CONSTRAINT fk_agente FOREIGN KEY (id_agente) REFERENCES agentes(id_agente),
    CONSTRAINT fk_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    CONSTRAINT fk_categoria FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
    CONSTRAINT fk_canal FOREIGN KEY (id_canal) REFERENCES canales(id_canal)
) TABLESPACE tbs_proyecto_datos;

CREATE INDEX idx_fact_agente ON fact_support_tickets(id_agente) TABLESPACE tbs_proyecto_indices;
CREATE INDEX idx_fact_fecha ON fact_support_tickets(issue_reported_at) TABLESPACE tbs_proyecto_indices;
CREATE INDEX idx_fact_csat ON fact_support_tickets(csat_score) TABLESPACE tbs_proyecto_indices;

COMMIT;