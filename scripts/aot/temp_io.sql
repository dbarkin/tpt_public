ALTER SESSION SET workarea_size_policy=MANUAL;
ALTER SESSION SET sort_area_size=40960;
ALTER SESSION SET sort_area_retained_size=40960;

VAR c REFCURSOR

DECLARE
    t VARCHAR2(4000);
BEGIN
    LOOP
        OPEN :c FOR SELECT TO_CHAR(rownum)||LPAD('x',3900,'x') text FROM dual CONNECT BY LEVEL <=1000 ORDER BY text;
        FETCH :c INTO t;
        CLOSE :c;
    END LOOP;
END;
/

