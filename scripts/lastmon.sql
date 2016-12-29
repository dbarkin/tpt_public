SELECT
    sql_exec_start
  , sql_id
  , ROUND(elapsed_time/1000) ela_ms
  , ROUND(cpu_time/1000)     cpu_ms
  , buffer_gets              lios
  , ROUND(physical_read_bytes/1024/1024,2)      rd_mb
  , ROUND(physical_write_bytes/1024/1024,2)     wr_mb
FROM
    v$sql_monitor
WHERE
    sid = SYS_CONTEXT('USERENV','SID')
AND last_refresh_time = (SELECT MAX(last_refresh_time) 
                         FROM v$sql_monitor
                         WHERE sid = SYS_CONTEXT('USERENV','SID')
                        )
/

