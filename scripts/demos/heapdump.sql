set echo on

declare
    type tabtype is table of char(100);
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