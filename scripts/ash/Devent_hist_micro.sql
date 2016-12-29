-- This script show histogram of events by microseconds

Select * from (
SELECT  sample_time 
      , event evh_event
      , sql_id      
      , CASE WHEN time_waited = 0 THEN 0 ELSE ROUND(POWER(2,ROUND(LOG(2,time_waited)))) END evh_microsec
      , COUNT(*)  evh_sample_count
      , ROUND(CASE WHEN time_waited = 0 THEN 0 ELSE ROUND(POWER(2,ROUND(LOG(2,time_waited)))) END * SUM(CASE WHEN time_waited >= 1000000 THEN 1 WHEN time_waited = 0 THEN 0 ELSE 1000000 / time_waited END),1) evh_est_total_sec
    FROM 
        --V$ACTIVE_SESSION_HISTORY 
        dba_hist_active_sess_history
    WHERE 
        event like  'gc%' 
    AND session_state = 'WAITING' -- not really needed as "event" for ON CPU will be NULL in ASH, but added just for clarity
    AND time_waited > 0
	and sample_time between TIMESTAMP'2016-12-08 03:00:00'  and TIMESTAMP'2016-12-08 07:00:00'
    and dbid=1612081131 
	and instance_number=1
    GROUP BY
        sample_time 
      , event
      , sql_id      
      , CASE WHEN time_waited = 0 THEN 0 ELSE ROUND(POWER(2,ROUND(LOG(2,time_waited)))) END -- evh_microsec
      )
pivot 
(
   count(evh_sample_count)
   for evh_microsec in (
1
,2
,4
,8
,16
,32
,64
,128
,256
,512
,1024
,2048
,4096
,8192
,16384
,32768
,65536
,131072
   )
)
order by sample_time;

Select * from (
SELECT  sample_time 
      , event evh_event
      , sql_id
      , CASE WHEN time_waited = 0 THEN 0 ELSE ROUND(POWER(2,ROUND(LOG(2,time_waited)))) END evh_millisec
      , COUNT(*)  evh_sample_count
      , ROUND(SUM(CASE WHEN time_waited >= 1000000 THEN 1 WHEN time_waited = 0 THEN 0 ELSE 1000000 / time_waited END),1) evh_est_event_count
      , ROUND(CASE WHEN time_waited = 0 THEN 0 ELSE ROUND(POWER(2,ROUND(LOG(2,time_waited)))) END * SUM(CASE WHEN time_waited >= 1000000 THEN 1 WHEN time_waited = 0 THEN 0 ELSE 1000000 / time_waited END),1) evh_est_total_sec
    FROM 
        V$ACTIVE_SESSION_HISTORY 
    WHERE 
        event like  'gc%' 
    AND session_state = 'WAITING' -- not really needed as "event" for ON CPU will be NULL in ASH, but added just for clarity
    AND time_waited > 0
	and sample_time between TIMESTAMP'2016-12-29 10:00:00'  and TIMESTAMP'2016-12-29 10:20:00'
    GROUP BY
        sample_time 
      , event
      , sql_id
      , CASE WHEN time_waited = 0 THEN 0 ELSE ROUND(POWER(2,ROUND(LOG(2,time_waited)))) END -- evh_millisec
      )
pivot 
(
   count(evh_sample_count)
   for evh_millisec in (
1
,2
,4
,8
,16
,32
,64
,128
,256
,512
,1024
,2048
,4096
,8192
,16384
,32768
,65536
,131072
   )
)
order by sample_time
