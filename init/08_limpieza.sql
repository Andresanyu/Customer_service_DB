SET SERVEROUTPUT ON;
PROMPT ================================
PROMPT EJECUTANDO SCRIPT: PROCEDIMIENTO DE LIMPIEZA DE MODELO DE DATOS
PROMPT ================================

ALTER SESSION SET CONTAINER = XEPDB1;

CREATE OR REPLACE PROCEDURE sp_limpiar_modelo IS
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_agente';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_cliente';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_producto';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_categoria';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_canal';

    TRUNCATE TABLE fact_support_tickets;
    TRUNCATE TABLE agentes;
    TRUNCATE TABLE clientes;
    TRUNCATE TABLE productos;
    TRUNCATE TABLE categorias;
    TRUNCATE TABLE canales;

    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_agente';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_cliente';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_producto';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_categoria';
    EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_canal';

    INSERT INTO control_procesos(nombre_tabla,operacion,mensaje)
    VALUES('MODELO_COMPLETO','TRUNCATE','Limpieza general ejecutada correctamente');

    COMMIT;
END;
/