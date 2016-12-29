drop table t;

Prompt Creating table with NO rowdependencies...


create table t tablespace users as select * From dba_objects;

update t set object_id = 1;

alter system flush buffer_cache;

@db
commit;

pause Press any key to select count(*) from t...

select distinct ora_rowscn from t;

pause Done. Press any key to continue...

drop table t;

Prompt Creating table WITH rowdependencies...


create table t tablespace users ROWDEPENDENCIES as select * From dba_objects;

update t set object_id = 1;

alter system flush buffer_cache;

@db
commit;

pause Press any key to select count(*) from t...

select distinct ora_rowscn from t;
