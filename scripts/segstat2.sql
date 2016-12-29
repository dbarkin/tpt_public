col segstat_statistic_name head STATISTIC_NAME for a35
col subobject_name for a20

SELECT * FROM (
  SELECT 
	owner, 
    object_name, 
    SUBOBJECT_NAME,   
	statistic_name segstat_statistic_name,
	value 
  FROM 
	v$segment_statistics 
  WHERE 
	lower(object_name) LIKE lower('&1')
  and lower(statistic_name) LIKE lower('&2')
   order by value desc
)
--WHERE rownum <= 40
/
