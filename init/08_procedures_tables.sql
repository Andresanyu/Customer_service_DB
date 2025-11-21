SET SERVEROUTPUT ON;
PROMPT ================================
PROMPT EJECUTANDO SCRIPT: CREACION DE PROCEDIMIENTOS DEL MODELO
PROMPT ================================

CONNECT usuario_proyecto/Proyecto123@XEPDB1

CREATE OR REPLACE PROCEDURE sp_carga_general(p_fecha_carga DATE)
AS
BEGIN
    INSERT INTO control_procesos(nombre_tabla, operacion, fecha_carga_parametro)
    VALUES ('CONTROL_PROCESOS', 'INSERT', p_fecha_carga);
END;
/

CREATE OR REPLACE PROCEDURE sp_cargar_agentes(p_fecha_carga DATE) IS
    v_filas NUMBER;
BEGIN
    MERGE INTO agentes a
    USING (
        SELECT DISTINCT agent_name, supervisor, manager, tenure_bucket
        FROM temp_support_raw
        WHERE agent_name IS NOT NULL
    ) src
    ON (a.agent_name = src.agent_name)
    WHEN NOT MATCHED THEN
        INSERT (agent_name, supervisor, manager, tenure_bucket)
        VALUES (src.agent_name, src.supervisor, src.manager, src.tenure_bucket);
    v_filas := SQL%ROWCOUNT;
    INSERT INTO control_procesos(nombre_tabla, filas_afectadas, operacion, fecha_carga_parametro)
    VALUES ('AGENTES', v_filas, 'INSERT', p_fecha_carga);
END;
/

CREATE OR REPLACE PROCEDURE sp_cargar_clientes(p_fecha DATE) IS
    v_filas NUMBER;
BEGIN
    MERGE INTO clientes c
    USING (
        SELECT DISTINCT customer_city
        FROM temp_support_raw
        WHERE customer_city IS NOT NULL
    ) src
    ON (c.customer_city = src.customer_city)
    WHEN NOT MATCHED THEN
        INSERT (customer_city) VALUES (src.customer_city);
    v_filas := SQL%ROWCOUNT;
    INSERT INTO control_procesos(nombre_tabla, filas_afectadas, operacion, fecha_carga_parametro, mensaje)
    VALUES('CLIENTES', v_filas, 'INSERT', p_fecha, 'Carga exitosa de clientes');
END;
/

CREATE OR REPLACE PROCEDURE sp_cargar_productos(p_fecha DATE) IS
    v_filas NUMBER;
BEGIN
    MERGE INTO productos p
    USING (
        SELECT DISTINCT product_category
        FROM temp_support_raw
        WHERE product_category IS NOT NULL
    ) src
    ON (p.product_category = src.product_category)
    WHEN NOT MATCHED THEN
        INSERT (product_category) VALUES (src.product_category);
    v_filas := SQL%ROWCOUNT;
    INSERT INTO control_procesos(nombre_tabla, filas_afectadas, operacion, fecha_carga_parametro, mensaje)
    VALUES('PRODUCTOS', v_filas, 'INSERT', p_fecha, 'Carga exitosa de productos');
END;
/

CREATE OR REPLACE PROCEDURE sp_cargar_categorias(p_fecha DATE) IS
    v_filas NUMBER;
BEGIN
    MERGE INTO categorias cat
    USING (
        SELECT DISTINCT category, sub_category
        FROM temp_support_raw
        WHERE category IS NOT NULL
    ) src
    ON (cat.category = src.category AND cat.sub_category = src.sub_category)
    WHEN NOT MATCHED THEN
        INSERT (category, sub_category) VALUES (src.category, src.sub_category);
    v_filas := SQL%ROWCOUNT;
    INSERT INTO control_procesos(nombre_tabla, filas_afectadas, operacion, fecha_carga_parametro, mensaje)
    VALUES('CATEGORIAS', v_filas, 'INSERT', p_fecha, 'Carga exitosa de categorias');
END;
/

CREATE OR REPLACE PROCEDURE sp_cargar_canales(p_fecha DATE) IS
    v_filas NUMBER;
BEGIN
    MERGE INTO canales can
    USING (
        SELECT DISTINCT channel_name
        FROM temp_support_raw
        WHERE channel_name IS NOT NULL
    ) src
    ON (can.channel_name = src.channel_name)
    WHEN NOT MATCHED THEN
        INSERT (channel_name) VALUES (src.channel_name);
    v_filas := SQL%ROWCOUNT;
    INSERT INTO control_procesos(nombre_tabla, filas_afectadas, operacion, fecha_carga_parametro, mensaje)
    VALUES('CANALES', v_filas, 'INSERT', p_fecha, 'Carga exitosa de canales');
END;
/

CREATE OR REPLACE PROCEDURE sp_cargar_fact_support(p_fecha DATE) IS
    v_filas NUMBER;
BEGIN
    MERGE INTO fact_support_tickets f
    USING (
        SELECT
            t.unique_id,
            t.order_id,
            a.id_agente,
            cl.id_cliente,
            p.id_producto,
            cat.id_categoria,
            can.id_canal,
            TO_TIMESTAMP(t.order_date_time, 'YYYY-MM-DD HH24:MI:SS') AS order_date_time,
            TO_TIMESTAMP(t.issue_reported_at, 'YYYY-MM-DD HH24:MI:SS') AS issue_reported_at,
            TO_TIMESTAMP(t.issue_responded, 'YYYY-MM-DD HH24:MI:SS') AS issue_responded,
            TO_DATE(t.survey_response_date, 'YYYY-MM-DD') AS survey_response_date,
            t.customer_remarks,
            TO_NUMBER(t.item_price) AS item_price,
            TO_NUMBER(t.connected_handling_time) AS connected_handling_time,
            t.agent_shift,
            TO_NUMBER(t.csat_score) AS csat_score
        FROM temp_support_raw t
        LEFT JOIN agentes a ON a.agent_name = t.agent_name
        LEFT JOIN clientes cl ON cl.customer_city = t.customer_city
        LEFT JOIN productos p ON p.product_category = t.product_category
        LEFT JOIN categorias cat ON cat.category = t.category AND cat.sub_category = t.sub_category
        LEFT JOIN canales can ON can.channel_name = t.channel_name
    ) src
    ON (f.unique_id = src.unique_id)
    WHEN NOT MATCHED THEN
        INSERT (
            unique_id, order_id, id_agente, id_cliente, id_producto, 
            id_categoria, id_canal, order_date_time, issue_reported_at,
            issue_responded, survey_response_date, customer_remarks,
            item_price, connected_handling_time, agent_shift, csat_score
        )
        VALUES (
            src.unique_id, src.order_id, src.id_agente, src.id_cliente, src.id_producto,
            src.id_categoria, src.id_canal, src.order_date_time, src.issue_reported_at,
            src.issue_responded, src.survey_response_date, src.customer_remarks,
            src.item_price, src.connected_handling_time, src.agent_shift, src.csat_score
        );
    
    v_filas := SQL%ROWCOUNT;
    
    INSERT INTO control_procesos(nombre_tabla, filas_afectadas, operacion, fecha_carga_parametro, mensaje)
    VALUES('FACT_SUPPORT', v_filas, 'INSERT', p_fecha, 'Carga exitosa de hechos');
END;
/

-- Stored procedure para limpieza del modelo

CREATE OR REPLACE PROCEDURE sp_limpiar_modelo IS
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_agente';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_cliente';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_producto';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_categoria';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_canal';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE agentes';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE clientes';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE productos';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE categorias';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE canales';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE fact_support_tickets';

    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_agente';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_cliente';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_producto';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_categoria';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_canal';

    INSERT INTO control_procesos(nombre_tabla, operacion, mensaje)
    VALUES('MODELO_COMPLETO','TRUNCATE','Limpieza general ejecutada correctamente');

END;
/

-- Stored procedure para carga de modelo

CREATE OR REPLACE PROCEDURE sp_pipeline_carga_soporte IS
    v_fecha   DATE := SYSDATE;
    v_error   VARCHAR2(4000);
BEGIN
    sp_cargar_agentes(v_fecha);
    sp_cargar_clientes(v_fecha);
    sp_cargar_productos(v_fecha);
    sp_cargar_categorias(v_fecha);
    sp_cargar_canales(v_fecha);
    sp_cargar_fact_support(v_fecha);

    INSERT INTO control_procesos(nombre_tabla, operacion, mensaje, fecha_carga_parametro)
    VALUES ('PIPELINE_GENERAL', 'INSERT', 'Pipeline ejecutado correctamente', v_fecha);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        v_error := SQLERRM;
        INSERT INTO control_procesos(nombre_tabla, operacion, mensaje, estado)
        VALUES ('PIPELINE_GENERAL', 'INSERT', v_error, 'ERROR');
        COMMIT;
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER trg_agentes_audit
AFTER UPDATE OR DELETE ON agentes
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(20);
    v_mensaje CLOB;
BEGIN
    IF UPDATING THEN
        v_operacion := 'UPDATE';
        v_mensaje := 'Campos afectados: ' || CHR(10);
        
        IF :OLD.agent_name IS NULL OR :NEW.agent_name != :OLD.agent_name THEN
            v_mensaje := v_mensaje || 'Agent_Name: ' || :OLD.agent_name || ' -> ' || :NEW.agent_name || CHR(10);
        END IF;
        
        IF (:OLD.supervisor IS NULL AND :NEW.supervisor IS NOT NULL) OR
            (:OLD.supervisor IS NOT NULL AND :NEW.supervisor IS NULL) OR
            (:OLD.supervisor IS NOT NULL AND :NEW.supervisor != :OLD.supervisor) THEN
            v_mensaje := v_mensaje || 'Supervisor: ' || :OLD.supervisor || ' -> ' || :NEW.supervisor || CHR(10);
        END IF;

        IF (:OLD.manager IS NULL AND :NEW.manager IS NOT NULL) OR
            (:OLD.manager IS NOT NULL AND :NEW.manager IS NULL) OR
            (:OLD.manager IS NOT NULL AND :NEW.manager != :OLD.manager) THEN
            v_mensaje := v_mensaje || 'Manager: ' || :OLD.manager || ' -> ' || :NEW.manager || CHR(10);
        END IF;
        
    ELSIF DELETING THEN
        v_operacion := 'DELETE';
        v_mensaje := 'Registro eliminado: ' || CHR(10) ||
                    'ID_Agente: ' || :OLD.id_agente || CHR(10) ||
                    'Agent_Name: ' || :OLD.agent_name || CHR(10) ||
                    'Supervisor: ' || :OLD.supervisor;
    END IF;

    INSERT INTO control_procesos (nombre_tabla, filas_afectadas, operacion, fecha_proceso, usuario_proceso, mensaje)
    VALUES ('AGENTES', 1, v_operacion, SYSTIMESTAMP, SYS_CONTEXT('USERENV', 'OS_USER') || ' @ ' || SYS_CONTEXT('USERENV', 'HOST'), SUBSTR(v_mensaje, 1, 500));
END;
/

CREATE OR REPLACE TRIGGER trg_clientes_audit
AFTER UPDATE OR DELETE ON clientes
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(20);
    v_mensaje CLOB;
BEGIN
    IF UPDATING THEN
        v_operacion := 'UPDATE';
        v_mensaje := 'Campos afectados: ' || CHR(10);

        IF (:OLD.customer_city IS NULL AND :NEW.customer_city IS NOT NULL) OR
            (:OLD.customer_city IS NOT NULL AND :NEW.customer_city IS NULL) OR
            (:OLD.customer_city IS NOT NULL AND :NEW.customer_city != :OLD.customer_city) THEN
            v_mensaje := v_mensaje || 'Customer_City: ' || :OLD.customer_city || ' -> ' || :NEW.customer_city || CHR(10);
        END IF;

    ELSIF DELETING THEN
        v_operacion := 'DELETE';
        v_mensaje := 'Registro eliminado: ' || CHR(10) ||
                        'ID_Cliente: ' || :OLD.id_cliente || CHR(10) ||
                        'Customer_City: ' || :OLD.customer_city;
    END IF;

    INSERT INTO control_procesos (nombre_tabla, filas_afectadas, operacion, fecha_proceso, usuario_proceso, mensaje)
    VALUES ('CLIENTES', 1, v_operacion, SYSTIMESTAMP, SYS_CONTEXT('USERENV', 'OS_USER') || ' @ ' || SYS_CONTEXT('USERENV', 'HOST'), SUBSTR(v_mensaje, 1, 500));
END;
/

CREATE OR REPLACE TRIGGER trg_productos_audit
AFTER UPDATE OR DELETE ON productos
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(20);
    v_mensaje CLOB;
BEGIN
    IF UPDATING THEN
        v_operacion := 'UPDATE';
        v_mensaje := 'Campos afectados: ' || CHR(10);
        
        IF (:OLD.product_category IS NULL AND :NEW.product_category IS NOT NULL) OR
            (:OLD.product_category IS NOT NULL AND :NEW.product_category IS NULL) OR
            (:OLD.product_category IS NOT NULL AND :NEW.product_category != :OLD.product_category) THEN
                v_mensaje := v_mensaje || 'Product_Category: ' || :OLD.product_category || ' -> ' || :NEW.product_category || CHR(10);
        END IF;
        
    ELSIF DELETING THEN
        v_operacion := 'DELETE';
        v_mensaje := 'Registro eliminado: ' || CHR(10) ||
                        'ID_Producto: ' || :OLD.id_producto || CHR(10) ||
                        'Product_Category: ' || :OLD.product_category;
    END IF;

    INSERT INTO control_procesos (nombre_tabla, filas_afectadas, operacion, fecha_proceso, usuario_proceso, mensaje)
    VALUES ('PRODUCTOS', 1, v_operacion, SYSTIMESTAMP, SYS_CONTEXT('USERENV', 'OS_USER') || ' @ ' || SYS_CONTEXT('USERENV', 'HOST'), SUBSTR(v_mensaje, 1, 500));
END;
/

CREATE OR REPLACE TRIGGER trg_categorias_audit
AFTER UPDATE OR DELETE ON categorias
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(20);
    v_mensaje CLOB;
BEGIN
    IF UPDATING THEN
        v_operacion := 'UPDATE';
        v_mensaje := 'Campos afectados: ' || CHR(10);
        
        IF (:OLD.category IS NULL AND :NEW.category IS NOT NULL) OR 
            (:OLD.category IS NOT NULL AND :NEW.category IS NULL) OR
            (:OLD.category IS NOT NULL AND :NEW.category != :OLD.category) THEN
                v_mensaje := v_mensaje || 'Category: ' || :OLD.category || ' -> ' || :NEW.category || CHR(10);
        END IF;

        IF (:OLD.sub_category IS NULL AND :NEW.sub_category IS NOT NULL) OR 
            (:OLD.sub_category IS NOT NULL AND :NEW.sub_category IS NULL) OR
            (:OLD.sub_category IS NOT NULL AND :NEW.sub_category != :OLD.sub_category) THEN
                v_mensaje := v_mensaje || 'Sub_Category: ' || :OLD.sub_category || ' -> ' || :NEW.sub_category || CHR(10);
        END IF;
        
    ELSIF DELETING THEN
        v_operacion := 'DELETE';
        v_mensaje := 'Registro eliminado: ' || CHR(10) ||
                        'ID_Categoria: ' || :OLD.id_categoria || CHR(10) ||
                        'Category: ' || :OLD.category || CHR(10) ||
                        'Sub_Category: ' || :OLD.sub_category;
    END IF;

    INSERT INTO control_procesos (nombre_tabla, filas_afectadas, operacion, fecha_proceso, usuario_proceso, mensaje)
    VALUES ('CATEGORIAS', 1, v_operacion, SYSTIMESTAMP, SYS_CONTEXT('USERENV', 'OS_USER') || ' @ ' || SYS_CONTEXT('USERENV', 'HOST'), SUBSTR(v_mensaje, 1, 500));
END;
/

CREATE OR REPLACE TRIGGER trg_canales_audit
AFTER UPDATE OR DELETE ON canales
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(20);
    v_mensaje CLOB;
BEGIN
    IF UPDATING THEN
        v_operacion := 'UPDATE';
        v_mensaje := 'Campos afectados: ' || CHR(10);
        
        IF (:OLD.channel_name IS NULL AND :NEW.channel_name IS NOT NULL) OR
            (:OLD.channel_name IS NOT NULL AND :NEW.channel_name IS NULL) OR
            (:OLD.channel_name IS NOT NULL AND :NEW.channel_name != :OLD.channel_name) THEN
                v_mensaje := v_mensaje || 'Channel_Name: ' || :OLD.channel_name || ' -> ' || :NEW.channel_name || CHR(10);
        END IF;
        
    ELSIF DELETING THEN
        v_operacion := 'DELETE';
        v_mensaje := 'Registro eliminado: ' || CHR(10) ||
                        'ID_Canal: ' || :OLD.id_canal || CHR(10) ||
                        'Channel_Name: ' || :OLD.channel_name;
    END IF;

    INSERT INTO control_procesos (nombre_tabla, filas_afectadas, operacion, fecha_proceso, usuario_proceso, mensaje)
    VALUES ('CANALES', 1, v_operacion, SYSTIMESTAMP, SYS_CONTEXT('USERENV', 'OS_USER') || ' @ ' || SYS_CONTEXT('USERENV', 'HOST'), SUBSTR(v_mensaje, 1, 500));
END;
/

CREATE OR REPLACE TRIGGER trg_tickets_audit
AFTER UPDATE OR DELETE ON fact_support_tickets
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(20);
    v_mensaje CLOB;
BEGIN
    IF UPDATING THEN
        v_operacion := 'UPDATE';
        v_mensaje := 'ID Ticket: ' || :OLD.id_ticket || '. Campos afectados: ' || CHR(10);
        
        IF :OLD.unique_id IS NULL OR :NEW.unique_id != :OLD.unique_id THEN
            v_mensaje := v_mensaje || 'Unique_ID: ' || :OLD.unique_id || ' -> ' || :NEW.unique_id || CHR(10);
        END IF;

        IF (:OLD.id_agente IS NULL AND :NEW.id_agente IS NOT NULL) OR
            (:OLD.id_agente IS NOT NULL AND :NEW.id_agente IS NULL) OR
            (:OLD.id_agente IS NOT NULL AND :NEW.id_agente != :OLD.id_agente) THEN
                v_mensaje := v_mensaje || 'ID_Agente: ' || :OLD.id_agente || ' -> ' || :NEW.id_agente || CHR(10);
        END IF;

        IF (:OLD.csat_score IS NULL AND :NEW.csat_score IS NOT NULL) OR
            (:OLD.csat_score IS NOT NULL AND :NEW.csat_score IS NULL) OR
            (:OLD.csat_score IS NOT NULL AND :NEW.csat_score != :OLD.csat_score) THEN
                v_mensaje := v_mensaje || 'CSAT_Score: ' || :OLD.csat_score || ' -> ' || :NEW.csat_score || CHR(10);
        END IF;

        IF (:OLD.item_price IS NULL AND :NEW.item_price IS NOT NULL) OR
            (:OLD.item_price IS NOT NULL AND :NEW.item_price IS NULL) OR
            (:OLD.item_price IS NOT NULL AND :NEW.item_price != :OLD.item_price) THEN
                v_mensaje := v_mensaje || 'Item_Price: ' || :OLD.item_price || ' -> ' || :NEW.item_price || CHR(10);
        END IF;
        
    ELSIF DELETING THEN
        v_operacion := 'DELETE';
        v_mensaje := 'Registro eliminado: ' || CHR(10) ||
                        'ID_Ticket: ' || :OLD.id_ticket || CHR(10) ||
                        'Unique_ID: ' || :OLD.unique_id || CHR(10) ||
                        'CSAT_Score: ' || :OLD.csat_score;
    END IF;

    INSERT INTO control_procesos (nombre_tabla, filas_afectadas, operacion, fecha_proceso, usuario_proceso, mensaje)
    VALUES ('FACT_SUPPORT', 1, v_operacion, SYSTIMESTAMP, SYS_CONTEXT('USERENV', 'OS_USER') || ' @ ' || SYS_CONTEXT('USERENV', 'HOST'), SUBSTR(v_mensaje, 1, 500));
END;
/

COMMIT;