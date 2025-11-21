set CONTAINER_NAME=oracle-db-proyecto
set DB_USER=usuario_proyecto
set DB_PASS=Proyecto123
set DB_CONN=XEPDB1
set CTL_FILE=/opt/oracle/data/control-temp.ctl
set LOG_FILE=/opt/oracle/data/carga.log
set BAD_FILE=/opt/oracle/data/carga.bad
set DSC_FILE=/opt/oracle/data/carga.dsc

echo    CARGA MASIVA DE DATOS - SOPORTE
echo.
echo Fecha: %date% %time%
echo.

echo [1/2] Cargando datos con SQL*Loader...
docker exec %CONTAINER_NAME% sqlldr %DB_USER%/%DB_PASS%@%DB_CONN% control=%CTL_FILE% log=%LOG_FILE% bad=%BAD_FILE% discard=%DSC_FILE%

echo       Carga completada exitosamente
echo.

echo [2/2] Ejecutando pipeline de transformacion...
setlocal DisableDelayedExpansion

> temp_script.sql (
    echo EXEC sp_pipeline_carga_soporte;
    echo TRUNCATE TABLE temp_support_raw;
    echo EXEC GENERAR_REPORTE_RESUMEN^(TO_DATE^('2023-01-01', 'YYYY-MM-DD'^), TO_DATE^('2025-12-31', 'YYYY-MM-DD'^)^);
    echo EXIT;
)

docker exec -i %CONTAINER_NAME% sqlplus -s %DB_USER%/%DB_PASS%@%DB_CONN% < temp_script.sql
del temp_script.sql

echo    PROCESO COMPLETADO EXITOSAMENTE
pause