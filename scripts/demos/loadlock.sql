--------------------------------------------------------------------------------
--
-- File name:   demoX.sql
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--
--              If executed in multiple session, should cause library cache load lock contention
--
-- Author:      Tanel Poder ( http://www.tanelpoder.com )
--
-- Copyright:   (c) 2007-2009 Tanel Poder
--
--------------------------------------------------------------------------------

prompt compiling procedure p in loop...

begin
    for i in 1..100000 loop
        execute immediate 'alter system flush shared_pool'; 
        execute immediate 'alter procedure p compile'; 
end loop;
end;
/

