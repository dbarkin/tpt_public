select
    level - 1 bit
   ,DECODE(bitand(to_number('&1','XXXXXXXXXXXXXXXX'),power(2,level-1)),0,0,1) is_set
   ,to_char(power(2,level-1),'XXXXXXXXXXXXXXXX') val_hex
   ,bitand(to_number('&1','XXXXXXXXXXXXXXXX'),power(2,level-1)) val_dec
from 
    dual
where
    DECODE(bitand(to_number('&1','XXXXXXXXXXXXXXXX'),power(2,level-1)),0,0,1) != 0
connect by
    level <= (select log(2,to_number('&1','XXXXXXXXXXXXXXXX'))+2 from dual)
/
