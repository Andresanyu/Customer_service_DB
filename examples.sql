SET SERVEROUTPUT ON;

EXEC pkg_validaciones.validar_fecha_carga(CAST(SYSTIMESTAMP AS DATE));
EXEC pkg_validaciones.validar_integridad_datos;
SELECT pkg_validaciones.contar_errores_datos FROM DUAL;

DECLARE
    v_resultado BOOLEAN;
BEGIN
    v_resultado := pkg_validaciones.validar_rango_fechas(
        TO_DATE('01-01-2023', 'DD-MM-YYYY'),
        TO_DATE('31-12-2025', 'DD-MM-YYYY')
    );
    
    IF v_resultado THEN
        DBMS_OUTPUT.PUT_LINE('Rango valido');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Rango invalido');
    END IF;
END;
/

BEGIN
    IF pkg_validaciones.validar_rango_fechas(TO_DATE('01-01-2027', 'DD-MM-YYYY'), TO_DATE('31-12-2025', 'DD-MM-YYYY')) THEN
        DBMS_OUTPUT.PUT_LINE('Rango valido');
    END IF;
END;
/

BEGIN
    IF pkg_validaciones.validar_rango_fechas(
        CAST(TO_TIMESTAMP('01-01-2027 00:00:00', 'DD-MM-YYYY HH24:MI:SS') AS DATE),
        CAST(TO_TIMESTAMP('31-12-2025 23:59:59', 'DD-MM-YYYY HH24:MI:SS') AS DATE)
    ) THEN
        DBMS_OUTPUT.PUT_LINE('Rango valido');
    END IF;
END;
/