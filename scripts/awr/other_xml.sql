select
--      sql_id
--    , child_number
--    , plan_hash_value
     substr(extractvalue(value(d), '/hint'), 1, 100) as outline_hints
from
      xmltable('/*/outline_data/hint'
        passing (
           select
            xmltype(other_xml) as xmlval
           from
            dba_hist_sql_plan
           where
            sql_id = '&1'
           and  other_xml is not null
        )
) d
/
