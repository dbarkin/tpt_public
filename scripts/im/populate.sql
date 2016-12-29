ALTER SESSION SET "_inmemory_populate_wait"=TRUE;
EXEC SYS.DBMS_INMEMORY.POPULATE('&1','&2');
ALTER SESSION SET "_inmemory_populate_wait"=FALSE;
@imseg &1..&2

