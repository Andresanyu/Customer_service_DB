SET SERVEROUTPUT ON;
PROMPT ================================
PROMPT EJECUTANDO SCRIPT: VALIDACIONES
PROMPT ================================

CONNECT usuario_proyecto/Proyecto123@XEPDB1

CREATE OR REPLACE PACKAGE pkg_validaciones AS
    PROCEDURE validar_fecha_carga(p_fecha IN DATE);
    PROCEDURE validar_datos_temporales;
    PROCEDURE validar_integridad_datos;
    
    FUNCTION existe_datos_temporales RETURN BOOLEAN;
    FUNCTION contar_errores_datos RETURN NUMBER;
    FUNCTION validar_rango_fechas(p_inicio DATE, p_fin DATE) RETURN BOOLEAN;
END pkg_validaciones;
/

CREATE OR REPLACE PACKAGE BODY pkg_validaciones AS
    
    PROCEDURE validar_fecha_carga(p_fecha IN DATE) IS
        v_dia_semana VARCHAR2(10);
        v_hora NUMBER;
    BEGIN
        v_dia_semana := TO_CHAR(p_fecha, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN');
        IF v_dia_semana NOT IN ('MON','TUE','WED','THU','FRI') THEN
            RAISE_APPLICATION_ERROR(-20001, 'La fecha debe ser día hábil (lunes a viernes).');
        END IF;
        
        v_hora := TO_NUMBER(TO_CHAR(p_fecha, 'HH24'));
        IF v_hora NOT BETWEEN 8 AND 18 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Debe estar entre 08:00 y 18:00.');
        END IF;
        
        IF p_fecha < SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20003, 'La fecha no puede ser pasada.');
        END IF;
        
        IF p_fecha > SYSDATE + 3 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No puede ser más de 3 días hacia adelante.');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Fecha validada correctamente: ' || TO_CHAR(p_fecha, 'DD-MON-YYYY HH24:MI'));
    END validar_fecha_carga;
    
    PROCEDURE validar_datos_temporales IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM temp_support_raw;
        
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20010, 'No hay datos en la tabla temporal para procesar.');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Datos temporales validados: ' || v_count || ' registros encontrados');
    END validar_datos_temporales;
    
    PROCEDURE validar_integridad_datos IS
        v_errores NUMBER := 0;
        v_nulos NUMBER := 0;
    BEGIN
        SELECT COUNT(*) INTO v_nulos
        FROM temp_support_raw
        WHERE agent_name IS NULL 
            OR channel_name IS NULL
            OR category IS NULL;
        
        IF v_nulos > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Advertencia: ' || v_nulos || ' registros con campos obligatorios nulos');
            v_errores := v_errores + v_nulos;
        END IF;
        
        FOR rec IN (
            SELECT unique_id, COUNT(*) as cant
            FROM temp_support_raw
            GROUP BY unique_id
            HAVING COUNT(*) > 1
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Advertencia: ID duplicado: ' || rec.unique_id || ' (' || rec.cant || ' veces)');
            v_errores := v_errores + 1;
        END LOOP;
        
        IF v_errores = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Integridad de datos validada correctamente');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Se encontraron ' || v_errores || ' problemas de integridad');
        END IF;
    END validar_integridad_datos;
    
    FUNCTION existe_datos_temporales RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM temp_support_raw;
        RETURN v_count > 0;
    END existe_datos_temporales;
    
    FUNCTION contar_errores_datos RETURN NUMBER IS
        v_errores NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_errores
        FROM temp_support_raw
        WHERE agent_name IS NULL
            OR channel_name IS NULL
            OR category IS NULL
            OR unique_id IS NULL;
        RETURN v_errores;
    END contar_errores_datos;
    
    FUNCTION validar_rango_fechas(p_inicio DATE, p_fin DATE) RETURN BOOLEAN IS
    BEGIN
        IF p_inicio IS NULL OR p_fin IS NULL THEN
            RETURN FALSE;
        END IF;
        
        IF p_fin < p_inicio THEN
            RETURN FALSE;
        END IF;
        
        RETURN TRUE;
    END validar_rango_fechas;
    
END pkg_validaciones;
/

COMMIT;