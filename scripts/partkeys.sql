col partkeys_column_name head COLUMN_NAME for a30
col partkeys_object_ype HEAD OBJECT_TYPE FOR A10
col partkeys_owner HEAD OWNER FOR A30
col partkeys_name HEAD NAME FOR A30

select
    object_type     partkeys_object_type
  , owner           partkeys_owner
  , name            partkeys_name
  , column_name     partkeys_column_name
  , column_position 
from
    dba_part_key_columns
where
    upper(name) LIKE 
                upper(CASE 
                    WHEN INSTR('&1','.') > 0 THEN 
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND owner LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
ORDER BY
    object_type
  , owner
  , name
  , column_position
/

