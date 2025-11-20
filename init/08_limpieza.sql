CREATE OR REPLACE PROCEDURE sp_limpiar_modelo
AS
BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_agente';
EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_cliente';
EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_producto';
EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_categoria';
EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets DISABLE CONSTRAINT fk_canal';

TRUNCATE TABLE fact_support_tickets;
TRUNCATE TABLE dim_agentes;
TRUNCATE TABLE dim_clientes;
TRUNCATE TABLE dim_productos;
TRUNCATE TABLE dim_categorias;
TRUNCATE TABLE dim_canales;
TRUNCATE TABLE control_procesos;

EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_agente';
EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_cliente';
EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_producto';
EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_categoria';
EXECUTE IMMEDIATE 'ALTER TABLE fact_support_tickets ENABLE CONSTRAINT fk_canal';

DBMS_OUTPUT.PUT_LINE('Limpieza completa realizada correctamente.');
END;
/