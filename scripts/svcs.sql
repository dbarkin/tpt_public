select
  service_name
, stat_name
, value
from 
  v$service_stats
where
    lower(service_name) like lower('&1')
and lower(stat_name) like lower('&2')
/

