.
@@saveset
-- set underline off if dont want dashes to appear between column headers and data
set termout off feedback off colsep &1 lines 32767 trimspool on trimout on tab off newpage none underline off 
spool &_TPT_TEMPDIR/output_&_i_inst..&2
/
spool off

@@loadset

host &_START &_TPT_TEMPDIR/output_&_i_inst..&2
