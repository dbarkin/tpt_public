DECLARE
    cmd VARCHAR2(1000);
BEGIN
    FOR i IN (SELECT owner,index_name FROM dba_indexes WHERE table_owner = '&1' AND table_owner NOT IN('SYS', 'SYSTEM') AND index_type NOT IN ('LOB', 'IOT - TOP')) LOOP
        cmd := 'ALTER INDEX '||i.owner||'.'||i.index_name||' INVISIBLE';
        DBMS_OUTPUT.PUT_LINE(cmd);
        EXECUTE IMMEDIATE cmd;
    END LOOP;
END;
/

