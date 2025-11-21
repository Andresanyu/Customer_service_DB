SET SERVEROUTPUT ON;
PROMPT ================================
PROMPT EJECUTANDO SCRIPT: PROCEDIMIENTOS Y REPORTES
PROMPT ================================

CONNECT usuario_proyecto/Proyecto123@XEPDB1

CREATE OR REPLACE PROCEDURE GENERAR_REPORTE_RESUMEN (p_fecha_inicio IN DATE, p_fecha_fin IN DATE) IS
BEGIN
    DELETE FROM REPORTES_RESUMEN
    WHERE FECHA_INICIO = p_fecha_inicio
    AND FECHA_FIN = p_fecha_fin;

    INSERT INTO REPORTES_RESUMEN (FECHA_INICIO, FECHA_FIN, CATEGORY_NAME, CHANNEL_NAME, AGENT_NAME, TOTAL_TICKETS, PROMEDIO_CSAT, PROMEDIO_PRECIO, PROMEDIO_RESPUESTA)
    SELECT
        p_fecha_inicio,
        p_fecha_fin,
        cat.CATEGORY AS CATEGORY_NAME,
        can.CHANNEL_NAME,
        ag.AGENT_NAME,
        COUNT(*) AS TOTAL_TICKETS,
        AVG(t.CSAT_SCORE) AS PROMEDIO_CSAT,
        AVG(t.ITEM_PRICE) AS PROMEDIO_PRECIO,
        AVG(t.RESPONSE_TIME_MINUTES) AS PROMEDIO_RESPUESTA
    FROM
        FACT_SUPPORT_TICKETS t
        LEFT JOIN CATEGORIAS cat ON t.ID_CATEGORIA = cat.ID_CATEGORIA
        LEFT JOIN CANALES can ON t.ID_CANAL = can.ID_CANAL
        LEFT JOIN AGENTES ag ON t.ID_AGENTE = ag.ID_AGENTE
    WHERE
        t.ORDER_DATE_TIME BETWEEN CAST(p_fecha_inicio AS TIMESTAMP)
                            AND CAST(p_fecha_fin AS TIMESTAMP) + INTERVAL '23:59:59' HOUR TO SECOND
    GROUP BY
        cat.CATEGORY,
        can.CHANNEL_NAME,
        ag.AGENT_NAME;

    COMMIT;
END;
/

CREATE OR REPLACE VIEW VW_TICKETS_PIVOT AS
SELECT *
FROM (
    SELECT
        c.CATEGORY,
        ca.CHANNEL_NAME
    FROM
        FACT_SUPPORT_TICKETS t
        JOIN CATEGORIAS c ON t.ID_CATEGORIA = c.ID_CATEGORIA
        JOIN CANALES ca ON t.ID_CANAL = ca.ID_CANAL
) PIVOT (
    COUNT(CHANNEL_NAME)
    FOR CHANNEL_NAME IN (
        'Email' AS email,
        'Inbound' AS inbound,
        'Outcall' AS outcall
    )
)
ORDER BY CATEGORY;

CREATE OR REPLACE PACKAGE pkg_reportes AS
    PROCEDURE generar_reporte_periodo(p_fecha_inicio DATE, p_fecha_fin DATE);
    PROCEDURE mostrar_estadisticas_sistema;
    PROCEDURE mostrar_resumen_carga;
END pkg_reportes;
/

CREATE OR REPLACE PACKAGE BODY pkg_reportes AS
    
    PROCEDURE generar_reporte_periodo(p_fecha_inicio DATE, p_fecha_fin DATE) IS
        v_filas NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Inicio: ' || TO_CHAR(p_fecha_inicio, 'DD-MON-YYYY'));
        DBMS_OUTPUT.PUT_LINE('Fin: ' || TO_CHAR(p_fecha_fin, 'DD-MON-YYYY'));
        
        IF NOT pkg_validaciones.validar_rango_fechas(p_fecha_inicio, p_fecha_fin) THEN
            RAISE_APPLICATION_ERROR(-20020, 'Rango de fechas inválido');
        END IF;
        
        GENERAR_REPORTE_RESUMEN(p_fecha_inicio, p_fecha_fin);
        
        SELECT COUNT(*) INTO v_filas
        FROM reportes_resumen
        WHERE fecha_inicio = p_fecha_inicio AND fecha_fin = p_fecha_fin;
        
        DBMS_OUTPUT.PUT_LINE('Reporte generado: ' || v_filas || ' registros');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
    END generar_reporte_periodo;
    
    PROCEDURE mostrar_estadisticas_sistema IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('---------------------------------');
        DBMS_OUTPUT.PUT_LINE('ESTADÍSTICAS GENERALES DEL SISTEMA');
        DBMS_OUTPUT.PUT_LINE('---------------------------------');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('---------------------------------');
        DBMS_OUTPUT.PUT_LINE('Tablas finales:');
        DBMS_OUTPUT.PUT_LINE('---------------------------------');
        
        FOR rec IN (
            SELECT 'Agentes' AS entidad, COUNT(*) AS total FROM agentes
            UNION ALL SELECT 'Clientes', COUNT(*) FROM clientes
            UNION ALL SELECT 'Productos', COUNT(*) FROM productos
            UNION ALL SELECT 'Categorías', COUNT(*) FROM categorias
            UNION ALL SELECT 'Canales', COUNT(*) FROM canales
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('  ' || RPAD(rec.entidad, 20) || ': ' || LPAD(TO_CHAR(rec.total), 8));
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('---------------------------------');
        DBMS_OUTPUT.PUT_LINE('HECHOS:');
        DBMS_OUTPUT.PUT_LINE('---------------------------------');
        DBMS_OUTPUT.PUT_LINE('');
        
        FOR rec IN (
            SELECT
                COUNT(*) AS total_tickets,
                ROUND(AVG(csat_score), 2) AS csat_promedio,
                ROUND(AVG(item_price), 2) AS precio_promedio
            FROM fact_support_tickets
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Total Tickets: ' || rec.total_tickets);
            DBMS_OUTPUT.PUT_LINE('CSAT Promedio: ' || rec.csat_promedio);
            DBMS_OUTPUT.PUT_LINE('Precio Promedio: $' || rec.precio_promedio);
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('---------------------------------');
    END mostrar_estadisticas_sistema;
    
    PROCEDURE mostrar_resumen_carga IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('---------------------------------');
        DBMS_OUTPUT.PUT_LINE('RESUMEN DE ÚLTIMA CARGA');
        DBMS_OUTPUT.PUT_LINE('---------------------------------');
        DBMS_OUTPUT.PUT_LINE('');
        
        FOR rec IN (
            SELECT
                nombre_tabla,
                filas_afectadas,
                operacion,
                TO_CHAR(fecha_proceso, 'DD-MON-YYYY HH24:MI:SS') AS fecha,
                mensaje,
                estado
            FROM control_procesos
            WHERE fecha_proceso >= SYSDATE - 1
            ORDER BY fecha_proceso DESC
            FETCH FIRST 10 ROWS ONLY
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Tabla:' || rec.nombre_tabla);
            DBMS_OUTPUT.PUT_LINE('Operación: ' || rec.operacion);
            DBMS_OUTPUT.PUT_LINE('Filas: ' || NVL(TO_CHAR(rec.filas_afectadas), '0'));
            DBMS_OUTPUT.PUT_LINE('Estado: ' || rec.estado);
            DBMS_OUTPUT.PUT_LINE('Fecha: ' || rec.fecha);
            IF rec.mensaje IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('Mensaje: ' || rec.mensaje);
            END IF;
            DBMS_OUTPUT.PUT_LINE('---------------------------------');
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('');
    END mostrar_resumen_carga;
    
END pkg_reportes;
/

COMMIT;