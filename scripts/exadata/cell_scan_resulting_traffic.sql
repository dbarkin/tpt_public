DROP TABLE cell_traffic_test;
CREATE TABLE cell_traffic_test
PARALLEL 8
AS
SELECT 'TANEL_TEST' col, a.*, b.* FROM
    (SELECT ROWNUM r FROM dual CONNECT BY LEVEL <= 100) a
  , dba_objects b
ORDER BY
   DBMS_RANDOM.VALUE
-- b.owner, b.object_type
/
@gts cell_traffic_test

ALTER TABLE cell_traffic_test NOPARALLEL;

CREATE TABLE
