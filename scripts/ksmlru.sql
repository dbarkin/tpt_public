col ksmlridx head IDX for 99
col ksmlrdur head DUR for 99
col ksmlrshrpool head SP for a2

select
    KSMLRIDX        
  , KSMLRDUR        
  , KSMLRNUM          flushed
--  , decode(KSMLRSHRPOOL,1,'Y','N') ksmlrshrpool
  , KSMLRCOM          alloc_comment
  , KSMLRSIZ          alloc_size
  , KSMLRHON          object_name
  , KSMLROHV          hash_value
  , KSMLRSES          ses_addr
--  , KSMLRADU
--  , KSMLRNID
--  , KSMLRNSD
--  , KSMLRNCD
--  , KSMLRNED
from
    x$ksmlru
where
    ksmlrnum > 0
order by
    ksmlrnum desc
/
