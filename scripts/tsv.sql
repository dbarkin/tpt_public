.
@@saveset
-- set underline off if dont want dashes to appear between column headers and data
-- ----- this here is a TAB char ----+
--                                   |
--                                   v
set termout off feedback off colsep "	" lines 32767 trimspool on trimout on tab off newpage none underline off
spool &_TPT_TEMPDIR/output_&_i_inst..tab
/
spool off

@@loadset

host &_start &_TPT_TEMPDIR/output_&_i_inst..tab

