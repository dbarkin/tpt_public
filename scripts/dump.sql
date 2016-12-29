-- prompt @dump <file#> <block#> <what regexp>

--select dump(&1) dec from dual;
--select dump(&1,16) hex from dual;

@ti
set termout off

alter system dump datafile &1 block &2;

--host "cat &trc | grep -v '\[................\]$' | grep -v 'col ' | grep -v 'tab ' | grep -v 'Dump of memory' | grep -v ' Repeat ' | grep &3"
host "cat &trc | grep -v '\[................\]' | grep -v '^\*\*\*' | grep -v '^Dump of memory' | grep -v '    Repeat ' | grep -A15 '&3'"

set termout on
