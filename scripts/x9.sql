.
set termout off

def _x9_temp_env=&_tpt_tempdir/env_&_tpt_tempfile..sql
def _x9_temp_sql=&_tpt_tempdir/sql_&_tpt_tempfile..sql

store set &_x9_temp_env replace
save      &_x9_temp_sql replace

0 explain plan for
run

set termout on

select * from table(dbms_xplan.display());

set termout off
@/&_x9_temp_env
get &_x9_temp_sql
set termout on
