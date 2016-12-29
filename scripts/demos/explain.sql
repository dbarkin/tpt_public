drop table t;
create table t as select * from all_objects;
create index i on t(object_id);
@gts t

explain plan for
select * from t where object_id = 10000;

select * from table(dbms_xplan.display);

rollback;
var v number
exec :v:=10000;

explain plan for 
select * from t where object_id = :v;

select * from table(dbms_xplan.display);
