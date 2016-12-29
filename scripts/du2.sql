col du_MB head MB FOR 99999999.9
col du_owner HEAD OWNER FOR A30

select
    owner              du_owner
  , sum(bytes)/1048576 du_MB
from
    dba_segments
where
    lower(owner) like lower('&1')
group by
    owner
order by
    du_MB desc
/
