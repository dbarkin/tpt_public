--------------------------------------------------------------------------------
--
-- File name:   demos/uga_alloc.sql
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--
-- Author:      Tanel Poder ( http://www.tanelpoder.com )
--
-- Copyright:   (c) 2007-2009 Tanel Poder
--
--------------------------------------------------------------------------------

set echo on

declare
    type tabtype is table of char(1000);
    t tabtype := NULL;
    

begin

     select object_name 
     bulk collect into t
     from dba_objects 
     order by lower(object_name);


     dbms_lock.sleep(999999);

end;
/

set echo off
