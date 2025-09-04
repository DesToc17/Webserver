DECLARE
    L_COUNT      NUMBER;
    VALIDACIONES NUMBER;
BEGIN
    SELECT
        COUNT(1) INTO L_COUNT
    FROM
        DBA_SCHEDULER_RUNNING_JOBS
    WHERE
        JOB_NAME = 'importar_pacientes_job';
    IF L_COUNT > 0 THEN
        HTP.P('0'); -- Job está en ejecución
    ELSE
        SELECT
            COUNT(*) INTO VALIDACIONES
        FROM
            CI_VALIDACIONES;
        IF VALIDACIONES = 0 THEN
            FOR C1 IN (
                SELECT
                    C.TPIDENTIF,
                    C.NUMIDENT,
                    T.TPIDNOMB                       AS NOMBRE_TIPO_DOC,
                    MIN(P.PACIID)                    AS PACIID,
                    MIN(P.PACIIDENT)                 AS PACIIDENT,
                    MIN(P.PACINOMB1
                        || ' '
                        || NVL(P.PACINOMB2, '')
                           || ' '
                           || P.PACIAPELL1
                           || ' '
                           || NVL(P.PACIAPELL2, '')) AS NOMBRE_COMPLETO
                FROM
                    CI_DETALLESPACIENTES_TEMP C
                    JOIN PA_TPIDENT T
                    ON T.TPIDID = C.TPIDENTIF
                    JOIN AG_PACIENTES P
                    ON P.PACIIDENT = C.NUMIDENT
                GROUP BY
                    C.TPIDENTIF,
                    C.NUMIDENT,
                    T.TPIDNOMB
            ) LOOP
                APEX_COLLECTION.ADD_MEMBER(
                    P_COLLECTION_NAME => 'DETALLES426',
                    P_C001 => :P425_CTIPID,
                    P_C002 => C1.PACIID,
                    P_C003 => 'A',
                    P_C004 => :APP_USER,
                    P_C005 => SYSDATE,
                    P_C006 => C1.NOMBRE_TIPO_DOC, -- nombre tipo documento
                    P_C007 => C1.NUMIDENT, -- número de identificación
                    P_C008 => C1.NOMBRE_COMPLETO, -- nombre completo paciente
                    P_GENERATE_MD5 => 'YES'
                );
            END LOOP;

            HTP.P('1'); -- Job ya terminó SIN VALIDACIONES
        ELSE
            FOR I IN (
                SELECT
                    VALIDACION
                FROM
                    CI_VALIDACIONES
            ) LOOP
                IF I.VALIDACION = '-1' THEN
                    HTP.P('-1'); -- NO HAY DETALLES POR IMPORTAR
                    EXIT;
                ELSE
                    HTP.P('2'); --Job ya terminó CON VALIDACIONES
                    EXIT;
                END IF;
            END LOOP;
        END IF;
    END IF;
END;