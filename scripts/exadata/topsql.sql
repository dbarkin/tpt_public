SELECT * FROM (
    SELECT 
        sql_id, executions, physical_read_bytes --, sql_text 
    FROM 
        v$sqlstats
    WHERE io_cell_offload_eligible_bytes = 0
    ORDER BY physical_read_bytes DESC
) 
WHERE 
    ROWNUM <= 10
/
