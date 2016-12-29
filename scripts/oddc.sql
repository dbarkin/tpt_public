-- script by Tanel Poder (http://www.tanelpoder.com)

set termout off
spool oddc.tmp

oradebug doc component
spool off

host grep -i &1 oddc.tmp
host &_delete oddc.tmp

set termout on

prompt
prompt (spool is off)
