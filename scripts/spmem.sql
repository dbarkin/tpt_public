prompt
prompt WARNING!!! This script will query X$KSMSP, which will cause heavy shared pool latch contention 
prompt in systems under load and with large shared pool. This may even completely hang 
prompt your instance until the query has finished! You probably do not want to run this in production!
prompt
pause  Press ENTER to continue, CTRL+C to cancel...

select ksmchcls, ksmchcom, count(*), sum(ksmchsiz), avg(ksmchsiz), max(ksmchsiz) from x$ksmsp group by ksmchcls, ksmchcom
/
