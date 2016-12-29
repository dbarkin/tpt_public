SET HEADING OFF LINESIZE 32767 PAGESIZE 0 TRIMSPOOL ON TRIMOUT ON LONG 9999999 VERIFY OFF LONGCHUNKSIZE 100000 FEEDBACK OFF
SET SERVEROUT ON SIZE UNLIMITED
SET TERMOUT OFF TIMING OFF
SET DEFINE ON

col _sid                NEW_VALUE _v_sid
col _sql_id             NEW_VALUE _v_sql_id
col _sql_exec_id        NEW_VALUE _v_sql_exec_id
col _sql_exec_start     NEW_VALUE _v_sql_exec_start
col _sql_exec_start_glu NEW_VALUE _v_sql_exec_start_glu
col _plan_hash_value    NEW_VALUE _v_plan_hash_value
col _sql_child_number   NEW_VALUE _v_sql_child_number
SELECT m.sid                                                    AS "_sid"
,      MAX(m.sql_id) KEEP
          (DENSE_RANK FIRST ORDER BY m.last_refresh_time DESC)  AS "_sql_id"
,      TO_CHAR(MAX(m.sql_exec_id) KEEP
          (DENSE_RANK FIRST ORDER BY m.last_refresh_time DESC)) AS "_sql_exec_id"
,      TO_CHAR(MAX(m.sql_exec_start) KEEP
          (DENSE_RANK FIRST ORDER BY m.last_refresh_time DESC),
          'YYMMDD_HH24MISS')                                    AS "_sql_exec_start"
,      TO_CHAR(MAX(m.sql_exec_start) KEEP
          (DENSE_RANK FIRST ORDER BY m.last_refresh_time DESC),
          'YYYYMMDD_HH24MISS')                                  AS "_sql_exec_start_glu"
,      MAX(m.sql_plan_hash_value) KEEP
          (DENSE_RANK FIRST ORDER BY m.last_refresh_time DESC)  AS "_plan_hash_value"
,      MAX(s.child_number) KEEP
          (DENSE_RANK FIRST ORDER BY m.last_refresh_time DESC)  AS "_sql_child_number"
FROM   v$sql_monitor    m
       INNER JOIN
       v$sql            s
       ON (    s.sql_id        = m.sql_id
           AND s.child_address = m.sql_child_address)
WHERE  m.sid = &1
AND    UPPER(m.sql_text) NOT LIKE 'EXPLAIN PLAN%'
GROUP  BY
       m.sid
;

SPOOL sqlmon_&_v_sql_id._&_v_sql_exec_id._&_v_sql_exec_start..html

SELECT
  REGEXP_REPLACE(
    DBMS_SQLTUNE.REPORT_SQL_MONITOR(
      session_id     => &_v_sid,
      sql_id         => '&_v_sql_id',
      sql_exec_id    => '&_v_sql_exec_id',
      sql_exec_start => TO_DATE('&_v_sql_exec_start', 'YYMMDD_HH24MISS'),
      report_level   => 'ALL',
      type           => 'ACTIVE'),
    'overflow:hidden', '')
FROM dual
/

DECLARE
    invalid_file_op EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_file_op, -29283);
    l_sid               NUMBER                  := &_v_sid;
    l_sql_id            VARCHAR2(200)           := '&_v_sql_id';
    l_sql_exec_id       NUMBER                  := &_v_sql_exec_id;
    l_sql_exec_start    VARCHAR2(200)           := '&_v_sql_exec_start';
    l_sql_exec_start_glu VARCHAR2(200)           := '&_v_sql_exec_start_glu.';
    l_plan_hash_value   NUMBER                  := '&_v_plan_hash_value';
    l_child_number      NUMBER                  := '&_v_sql_child_number';
    l_trace_file        VARCHAR2(1000)          := 'conn_' || l_sql_id || '_' || l_sql_exec_start_glu || '.trace';
    f                   UTL_FILE.FILE_TYPE;
    pf                  UTL_FILE.FILE_TYPE;
    l_line              VARCHAR2(32767);
    l_last_newline      NUMBER := 0;
    l_sql_monitor       VARCHAR2(32767);
    l_raw               VARCHAR2(32767);
    l_template          CLOB;
    l_rem               CLOB;
    l_profile           CLOB;
    l_plan_line         VARCHAR2(1000);
    TYPE line_ntt IS TABLE OF NUMBER;
    l_initialised       line_ntt                := line_ntt();
    l_assign_line       VARCHAR2(1000);
    l_assign_template   VARCHAR2(1000)          := 'd["%pl%"]["%var%"] = (d["%pl%"]["%var%"] || 0)';
    l_info_details      VARCHAR2(32767);
    l_stat_subtype      VARCHAR2(30);
    TYPE master_stats_rt IS RECORD
    ( cpu_secs          NUMBER := 0
    , rows_read         NUMBER := 0
    , rows_written      NUMBER := 0
    , bytes_read        NUMBER := 0
    , bytes_written     NUMBER := 0
    );
    l_master_stats      master_stats_rt;
    l_jfpd              VARCHAR2(4000);
BEGIN

    f := UTL_FILE.FOPEN('OFFLOAD_BIN', 'sqlmon_template.html', 'R', 32767);
    LOOP
        BEGIN
            UTL_FILE.GET_RAW(f, l_raw);
            l_template := l_template || UTL_RAW.CAST_TO_VARCHAR2(l_raw);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
               EXIT;
        END;
    END LOOP;
    UTL_FILE.FCLOSE(f);

    -- Start with the Impala and Connector trace statistics...
    FOR pl IN (SELECT DISTINCT(plan_line_id) AS plan_line FROM TABLE(offload.read_trace_file(l_trace_file)))
    LOOP
        l_template := REPLACE(l_template, '%next%', 'd["' || pl.plan_line || '"] = {};' || CHR(10) || '%next%');
    END LOOP;

    FOR r_stat IN ( SELECT v.*
                    ,      ROW_NUMBER() OVER (PARTITION BY plan_line ORDER BY stat_subtype) AS line_no
                    FROM  (
                            SELECT stat_subtype
                            ,      plan_line_id                                         AS plan_line
                            ,      GROUPING(plan_line_id)                               AS grouping_flag
                            ,      SUM(bytes_read)                                      AS bytes_read
                            ,      SUM(bytes_written)                                   AS bytes_written
                            ,      SUM(rows_read)                                       AS rows_read
                            ,      SUM(rows_written)                                    AS rows_written
                            ,      SUM(cpu_secs)                                        AS cpu_secs
                            FROM   TABLE(offload.read_trace_file(l_trace_file))
                            WHERE  stat_type = 'SUMMARY'
                            GROUP  BY GROUPING SETS ( (stat_subtype), (stat_subtype,plan_line_id) )
                            ORDER  BY
                                   plan_line_id NULLS LAST
                            ,      stat_subtype
                         ) v )
    LOOP

        l_stat_subtype := CASE r_stat.stat_subtype WHEN 'Impala' THEN 'hadoop' ELSE 'connect' END;

        IF r_stat.grouping_flag = 0 THEN

            IF r_stat.line_no = 1 THEN
                -- TODO: Oracle initialisation possibly not needed...
                l_template := REPLACE(l_template, '%next%', 'd["' || r_stat.plan_line || '"]["table_name"] = "";' || CHR(10) || '%next%');
                l_template := REPLACE(l_template, '%next%', 'd["' || r_stat.plan_line || '"]["oracle_read_bytes"] = 0;' || CHR(10) || '%next%');
                l_template := REPLACE(l_template, '%next%', 'd["' || r_stat.plan_line || '"]["oracle_write_bytes"] = 0;' || CHR(10) || '%next%');
                l_template := REPLACE(l_template, '%next%', 'd["' || r_stat.plan_line || '"]["oracle_write_rows"] = 0;' || CHR(10) || '%next%');
                l_template := REPLACE(l_template, '%next%', 'd["' || r_stat.plan_line || '"]["oracle_cpu_secs"] = 0;' || CHR(10) || '%next%');
                l_template := REPLACE(l_template, '%next%', 'd["' || r_stat.plan_line || '"]["oracle_sql_before_rewrite"] = "";' || CHR(10) || '%next%');
                l_template := REPLACE(l_template, '%next%', 'd["' || r_stat.plan_line || '"]["oracle_sql_after_rewrite"] = "";' || CHR(10) || '%next%');
                l_template := REPLACE(l_template, '%next%', 'd["' || r_stat.plan_line || '"]["oracle_join_filter_pulldown"] = "";' || CHR(10) || '%next%');
            END IF;

            IF r_stat.stat_subtype IN ('Impala','Connect') THEN
                l_template := REPLACE(l_template, '%next%', 'd["' || r_stat.plan_line || '"]["' || l_stat_subtype || '_read_bytes"] = ' || r_stat.bytes_read || ';' || CHR(10) || '%next%');
                l_template := REPLACE(l_template, '%next%', 'd["' || r_stat.plan_line || '"]["' || l_stat_subtype || '_write_bytes"] = ' || r_stat.bytes_written || ';' || CHR(10) || '%next%');
                l_template := REPLACE(l_template, '%next%', 'd["' || r_stat.plan_line || '"]["' || l_stat_subtype || '_read_rows"] = ' || r_stat.rows_read || ';' || CHR(10) || '%next%');
                l_template := REPLACE(l_template, '%next%', 'd["' || r_stat.plan_line || '"]["' || l_stat_subtype || '_write_rows"] = ' || r_stat.rows_written || ';' || CHR(10) || '%next%');
                l_template := REPLACE(l_template, '%next%', 'd["' || r_stat.plan_line || '"]["' || l_stat_subtype || '_cpu_secs"] = ' || r_stat.cpu_secs || ';' || CHR(10) || '%next%');
            END IF;

        ELSE
            -- Master report section goes here...
            l_template := REPLACE(l_template, '%next%', 'ss["' || l_stat_subtype || '_read_bytes"] = ' || r_stat.bytes_read || ';' || CHR(10) || '%next%');
            l_template := REPLACE(l_template, '%next%', 'ss["' || l_stat_subtype || '_write_bytes"] = ' || r_stat.bytes_written || ';' || CHR(10) || '%next%');
            l_template := REPLACE(l_template, '%next%', 'ss["' || l_stat_subtype || '_read_rows"] = ' || r_stat.rows_read || ';' || CHR(10) || '%next%');
            l_template := REPLACE(l_template, '%next%', 'ss["' || l_stat_subtype || '_write_rows"] = ' || r_stat.rows_written || ';' || CHR(10) || '%next%');
            l_template := REPLACE(l_template, '%next%', 'ss["' || l_stat_subtype || '_cpu_secs"] = ' || r_stat.cpu_secs || ';' || CHR(10) || '%next%');
        END IF;

    END LOOP;

    -- Add in the Hadoop Info, Profile and Join Filter Pulldown result...
    FOR r_info IN ( SELECT plan_line
                    ,      stat_subtype
                    ,      info_details
                    FROM  (
                           SELECT plan_line_id AS plan_line
                           ,      stat_subtype
                           ,      info_details
                           ,      ROW_NUMBER() OVER (PARTITION BY plan_line_id, stat_subtype ORDER BY ROWNUM) AS subtype_rn
                           FROM   TABLE(offload.read_trace_file(l_trace_file))
                           WHERE  stat_type = 'INFO'
                          )
                    WHERE  subtype_rn = 1 )
    LOOP

        -- Insert SQL...
        l_info_details := SUBSTR(r_info.info_details, 1, 32767);
        l_template := REPLACE(l_template, '%next%', 'd["' || r_info.plan_line || '"]["' || r_info.stat_subtype || '"] = "' || l_info_details || '";' || CHR(10) || '%next%');

        -- Insert profile...
        IF NOT REGEXP_LIKE(l_template, 'd\["' || r_info.plan_line || '"\]\["plan"\]') THEN
            BEGIN
                pf := UTL_FILE.FOPEN('OFFLOAD_LOG', 'conn_' || l_sql_id || '_' || r_info.plan_line || '_' || l_sql_exec_start || '.profile', 'R', 32767);
                l_template := REPLACE(l_template, '%next%', 'd["' || r_info.plan_line || '"]["plan"] = "%next%');
                LOOP
                    BEGIN
                        UTL_FILE.GET_RAW(pf, l_raw, 16000);
                        l_profile := l_profile || UTL_RAW.CAST_TO_VARCHAR2(l_raw);
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            EXIT;
                    END;
                END LOOP;
                l_profile := REPLACE(l_profile, CHR(10), '<br>');
                l_template := REPLACE(l_template, '%next%', SUBSTR(l_profile, 1, 32000) || '";' || CHR(10) || '%next%');
                UTL_FILE.FCLOSE(pf);
            EXCEPTION
                WHEN invalid_file_op THEN NULL;
            END;
        END IF;

        -- Insert join filter pulldown warning...
        l_jfpd := NULL;
        FOR r_jfpd IN ( WITH join_filters AS (
                                SELECT subquery_rowsource
                                ,      message
                                FROM   TABLE(offload.join_filters( p_sql_id          => l_sql_id,
                                                                   p_child_number    => l_child_number,
                                                                   p_plan_hash_value => l_plan_hash_value,
                                                                   p_plan_line_id    => r_info.plan_line ))

                                )
                        ,    final_results AS (
                                SELECT TO_NUMBER(0) AS block_no
                                ,      ROW_NUMBER() OVER (ORDER BY subquery_rowsource) AS order_no
                                ,      CASE
                                          WHEN ROW_NUMBER() OVER (ORDER BY subquery_rowsource) = 1
                                          THEN 'Join filter pulldown applied using following rowsources:' || CHR(10)
                                        END || ' ' || TO_CHAR(ROW_NUMBER() OVER (ORDER BY subquery_rowsource), 'fm09') || ') ' || subquery_rowsource AS message
                                FROM   join_filters
                                WHERE  message IS NULL
                                --
                                UNION ALL
                                --
                                SELECT 1 AS block_no
                                ,      ROW_NUMBER() OVER (ORDER BY message) AS order_no
                                ,      CASE
                                          WHEN ROW_NUMBER() OVER (ORDER BY message) = 1
                                          THEN 'Join filter pulldown not applied:' || CHR(10)
                                       END || ' ' || TO_CHAR(ROW_NUMBER() OVER (ORDER BY message), 'fm09') || ') ' || SUBSTR(message, INSTR(message, ' ')+1) AS message
                                FROM   join_filters
                                WHERE  message IS NOT NULL
                                )
                        SELECT message
                        FROM   final_results
                        ORDER  BY
                               block_no
                        ,      order_no)
        LOOP
            l_jfpd := l_jfpd || r_jfpd.message || CHR(10);
        END LOOP;
        l_template := REPLACE(l_template, '%next%', 'd["' || r_info.plan_line || '"]["oracle_join_filter_pulldown"] = "'|| REPLACE(LTRIM(RTRIM(l_jfpd, CHR(10)), CHR(10)), CHR(10), '<br>') ||'";' || CHR(10) || '%next%');

    END LOOP;

    -- Finally add the Oracle statistics...
    FOR r_mon IN ( SELECT sql_id
                   ,      sql_exec_id
                   ,      sql_exec_start
                   ,      SUM(cpu_time)/1e6         AS cpu_secs
                   FROM   v$sql_monitor
                   WHERE  sql_id          = l_sql_id
                   AND    sql_exec_id     = l_sql_exec_id
                   AND    sql_exec_start  = TO_DATE(l_sql_exec_start, 'YYMMDD HH24MISS')
                   AND   (   sid          = l_sid
                          OR px_qcsid     = l_sid)
                   GROUP  BY
                          sql_id
                   ,      sql_exec_id
                   ,      sql_exec_start )
    LOOP

        FOR r_plan IN ( WITH plan_monitor_data AS (
                                SELECT plan_line_id
                                ,      MAX(plan_object_owner)                                                      AS owner
                                ,      MAX(plan_object_name)                                                       AS table_name
                                ,      offload.get_hybrid_view_name(MAX(plan_object_owner), MAX(plan_object_name)) AS rule_name
                                ,      SUM(physical_read_bytes)                                                    AS read_bytes
                                ,      SUM(physical_write_bytes)                                                   AS write_bytes
                                ,      SUM(output_rows)                                                            AS output_rows
                                FROM   v$sql_plan_monitor
                                WHERE  sql_id         = r_mon.sql_id
                                AND    sql_exec_id    = r_mon.sql_exec_id
                                AND    sql_exec_start = r_mon.sql_exec_start
                                AND    plan_operation = 'EXTERNAL TABLE ACCESS'
                                GROUP  BY
                                       plan_line_id
                                )
                        ,    ash_data AS (
                                SELECT plan_line_id
                                ,      MAX(cpu_samples_total)     AS cpu_samples_qry
                                ,      MAX(cpu_samples_plan_line) AS cpu_samples_ext
                                FROM  (
                                        SELECT sql_plan_line_id                                                                                   AS plan_line_id
                                        ,      sql_plan_operation                                                                                 AS plan_operation
                                        ,      COUNT(DECODE(session_state, 'ON CPU', 1)) OVER ()                                                  AS cpu_samples_total
                                        ,      COUNT(DECODE(session_state, 'ON CPU', 1)) OVER (PARTITION BY sql_plan_line_id, sql_plan_operation) AS cpu_samples_plan_line
                                        FROM   v$active_session_history
                                        WHERE  sql_id         = r_mon.sql_id
                                        AND    sql_exec_id    = r_mon.sql_exec_id
                                        AND    sql_exec_start = r_mon.sql_exec_start
                                     )
                                WHERE  plan_operation = 'EXTERNAL TABLE ACCESS'
                                GROUP  BY
                                       plan_line_id
                                )
                        SELECT pm.plan_line_id
                        ,      pm.owner
                        ,      pm.table_name
                        ,      NVL(pm.read_bytes, 0)  AS read_bytes
                        ,      NVL(pm.write_bytes, 0) AS write_bytes
                        ,      NVL(pm.output_rows, 0) AS output_rows
                        ,      NVL(ROUND(r_mon.cpu_secs * CASE
                                                             WHEN ash.cpu_samples_ext = 0
                                                             OR   ash.cpu_samples_qry = 0
                                                             THEN 0
                                                             ELSE ash.cpu_samples_ext/ash.cpu_samples_qry
                                                          END, 3), 0) AS cpu_secs
                        ,      dre.source_stmt      AS sql_before_rewrite
                        ,      dre.destination_stmt AS sql_after_rewrite
                        FROM   plan_monitor_data        pm
                               LEFT OUTER JOIN
                               ash_data                 ash
                               ON (ash.plan_line_id     = pm.plan_line_id)
                               LEFT OUTER JOIN
                               dba_rewrite_equivalences dre
                               ON (    dre.owner        = pm.owner
                                   AND dre.name         = pm.rule_name) )
        LOOP
            l_master_stats.cpu_secs      := l_master_stats.cpu_secs + r_plan.cpu_secs;
            l_master_stats.bytes_read    := l_master_stats.bytes_read + r_plan.read_bytes;
            l_master_stats.bytes_written := l_master_stats.bytes_written + r_plan.write_bytes;
            l_master_stats.rows_written  := l_master_stats.rows_written + r_plan.output_rows;
            l_template := REPLACE(l_template, '%next%', 'd["' || r_plan.plan_line_id || '"]["table_name"] = "' || r_plan.owner || '.' || r_plan.table_name || '";' || CHR(10) || '%next%');
            l_template := REPLACE(l_template, '%next%', 'd["' || r_plan.plan_line_id || '"]["oracle_read_bytes"] = ' || r_plan.read_bytes || ';' || CHR(10) || '%next%');
            l_template := REPLACE(l_template, '%next%', 'd["' || r_plan.plan_line_id || '"]["oracle_write_bytes"] = ' || r_plan.write_bytes || ';' || CHR(10) || '%next%');
            l_template := REPLACE(l_template, '%next%', 'd["' || r_plan.plan_line_id || '"]["oracle_write_rows"] = ' || r_plan.output_rows || ';' || CHR(10) || '%next%');
            l_template := REPLACE(l_template, '%next%', 'd["' || r_plan.plan_line_id || '"]["oracle_cpu_secs"] = ' || r_plan.cpu_secs || ';' || CHR(10) || '%next%');
            l_template := REPLACE(l_template, '%next%', 'd["' || r_plan.plan_line_id || '"]["oracle_sql_before_rewrite"] = "' || REPLACE(REPLACE(SUBSTR(r_plan.sql_before_rewrite,1,32000), CHR(10), '<br>'), '"', '\"') || '";' || CHR(10) || '%next%');
            l_template := REPLACE(l_template, '%next%', 'd["' || r_plan.plan_line_id || '"]["oracle_sql_after_rewrite"] = "' || REPLACE(REPLACE(SUBSTR(r_plan.sql_after_rewrite,1,32000), CHR(10), '<br>'), '"', '\"') || '";' || CHR(10) || '%next%');
        END LOOP;

        l_template := REPLACE(l_template, '%next%', 'ss["' || 'oracle_read_bytes"] = ' || l_master_stats.bytes_read || ';' || CHR(10) || '%next%');
        l_template := REPLACE(l_template, '%next%', 'ss["' || 'oracle_write_bytes"] = ' || l_master_stats.bytes_written || ';' || CHR(10) || '%next%');
        l_template := REPLACE(l_template, '%next%', 'ss["' || 'oracle_read_rows"] = 0;' || CHR(10) || '%next%');
        l_template := REPLACE(l_template, '%next%', 'ss["' || 'oracle_write_rows"] = ' || l_master_stats.rows_written || ';' || CHR(10) || '%next%');
        l_template := REPLACE(l_template, '%next%', 'ss["' || 'oracle_cpu_secs"] = ' || l_master_stats.cpu_secs || ';' || CHR(10) || '%next%');

    END LOOP;

    l_rem := REPLACE(l_template, '%next%');

    WHILE LENGTH(l_rem) > 0 LOOP
        l_last_newline := INSTR(SUBSTR(l_rem, 1, 32767), CHR(10), -1);
        IF l_last_newline = 0 THEN
            l_last_newline := 32767;
        END IF;
        DBMS_OUTPUT.PUT_LINE(SUBSTR(l_rem, 1, l_last_newline));
        l_rem := SUBSTR(l_rem, l_last_newline + 1);
    END LOOP;

EXCEPTION
    WHEN invalid_file_op THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERROR: Sqlmon error for sql_id ' || l_sql_id || ' and sql_exec_start ' || l_sql_exec_start);
END;
/

SPOOL OFF

SET TERMOUT ON HEADING ON PAGESIZE 5000 LINESIZE 999 FEEDBACK ON SERVEROUT OFF
SET TIMING ON

HOST open sqlmon_&_v_sql_id._&_v_sql_exec_id._&_v_sql_exec_start..html

undefine _v_sid
undefine _v_sql_id
undefine _v_sql_exec_id
undefine _v_sql_exec_start
undefine _v_plan_hash_value
undefine _v_sql_child_number
