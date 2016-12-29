select 
    TO_CHAR(sysdate, 'yyyy-mm-dd hh24:mi:ss') as "SYSDATE",
    (to_date(sysdate) - to_date('01011970','ddmmyyyy')) * 24*60*60 SECONDS_EPOCH,
    to_char((to_date(sysdate) - to_date('01011970','ddmmyyyy')) * 24*60*60, 'XXXXXXXX') SEC_HEX
from 
    dual
/
