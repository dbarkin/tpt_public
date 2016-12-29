select 
    sysdate - ( sysdate - date'1970-01-01' - &1/1000/86400 )  result_date
 ,  round((( sysdate - &1 /1000/86400 ) - date'1970-01-01'),2 )      days
 ,  round((( sysdate - &1 /1000/86400 ) - date'1970-01-01') * 24, 2 ) hours
 ,  round((( sysdate - &1 /1000/86400 ) - date'1970-01-01') * 60 ) minutes
 ,  round((( sysdate - &1 /1000/86400 ) - date'1970-01-01') * 3600 ) seconds
from dual;

