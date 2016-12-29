select 
	n.statistic# stat#,
	trim(to_char(s.statistic#, 'XXXX')) hex#,
	n.statistic# * 8 offset,
	n.name, 
	s.value
from v$mystat s, v$statname n
where s.statistic#=n.statistic#
and (
    lower(n.name) like lower('%&1%') 
or  lower(to_char(s.statistic#)) like lower('&1')
or  lower(trim(to_char(s.statistic#, 'XXXX'))) like lower('&1')
or  to_char(n.statistic# * 8) like '%&1%'
)
/



