SET SERVEROUTPUT ON;
PROMPT ================================
PROMPT EJECUTANDO SCRIPT: VALIDACIONES
PROMPT ================================

CONNECT usuario_proyecto/Proyecto123@XEPDB1

CREATE OR REPLACE PROCEDURE VALIDAR_FECHA_CARGA ( p_fecha_carga IN DATE ) IS
BEGIN
    IF TO_CHAR(p_fecha_carga, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN')
        NOT IN ('MON','TUE','WED','THU','FRI') THEN
        RAISE_APPLICATION_ERROR(-20001, 'La fecha debe ser día hábil (lunes a viernes).');
    END IF;

    IF TO_NUMBER(TO_CHAR(p_fecha_carga,'HH24')) NOT BETWEEN 8 AND 18 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Debe estar entre 08:00 y 18:00.');
    END IF;

    IF p_fecha_carga < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20003, 'La fecha no puede ser pasada.');
    END IF;

    IF p_fecha_carga > SYSDATE + 3 THEN
        RAISE_APPLICATION_ERROR(-20004, 'No puede ser más de 3 días hacia adelante.');
    END IF;
END;
/

COMMIT;