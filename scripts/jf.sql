prompt Display bloom filters used by a PX session from V$SQL_JOIN_FILTER...

SELECT
    QC_SESSION_ID    qc_sid    
  , QC_INSTANCE_ID   inst_id 
  , SQL_PLAN_HASH_VALUE sql_hash_value -- this is sql_hash_value, not plan hash value despite the column name
  , 'BF'||TRIM(TO_CHAR(filter_id, '0999')) f_id
  , LENGTH * 8     bytes_total --  there seems to be a bug in 12c (or maybe due to bloom folding)
  , LENGTH * 8 * 8 bits_total
  , BITS_SET   bits_set
  , TO_CHAR(ROUND((bits_set/(length*8))*100,1),'99999.0')||' %' pct_set          
  , FILTERED             
  , PROBED  
  , TO_CHAR(ROUND(filtered / probed * 100, 2), '999.0')||' %' rejected
  , ACTIVE               
FROM
    GV$SQL_JOIN_FILTER
WHERE
    active != 0
AND qc_session_id LIKE 
        upper(CASE 
          WHEN INSTR('&1','@') > 0 THEN 
              SUBSTR('&1',INSTR('&1','@')+1)
          ELSE
              '&1'
          END
             ) ESCAPE '\'
AND qc_instance_id LIKE
    CASE WHEN INSTR('&1','@') > 0 THEN
      UPPER(SUBSTR('&1',1,INSTR('&1','@')-1))
    ELSE
      USERENV('instance')
    END ESCAPE '\'
ORDER BY
    qc_instance_id
  , qc_session_id
  , sql_hash_value
  , f_id
/

