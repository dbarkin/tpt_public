COL owner FOR A30
COL table_name FOR A30

SELECT owner, table_name, type_name driver, default_directory_name dirname 
FROM dba_external_tables
WHERE
  UPPER(table_name) LIKE 
        UPPER(CASE 
          WHEN INSTR('&1','.') > 0 THEN 
              SUBSTR('&1',INSTR('&1','.')+1)
          ELSE
              '&1'
          END
             ) ESCAPE '\'
AND owner LIKE
    CASE WHEN INSTR('&1','.') > 0 THEN
      UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
    ELSE
      user
    END ESCAPE '\'
/

