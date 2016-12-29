SET TIMING ON

DROP TABLE t_lock;
CREATE TABLE t_lock AS SELECT * FROM dual;

@pd enqueue_deadlock

DECLARE
    PROCEDURE p IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        j VARCHAR2(100);
    BEGIN
        --UPDATE t_lock SET dummy = 'Z';
        SELECT dummy INTO j FROM t_lock FOR UPDATE WAIT 6;
    END;
BEGIN
    UPDATE t_lock SET dummy = 'Z';
    p();
END;
/
