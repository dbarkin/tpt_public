DROP TABLE t;

CREATE TABLE t AS SELECT * FROM dba_objects;

CREATE INDEX t_i1 ON t (object_id);
CREATE INDEX t_i2 ON t (data_object_id);

EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'T');

SELECT owner FROM t WHERE object_id = 123 OR data_object_id = 456;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+OUTLINE'));

