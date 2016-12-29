DECLARE
    cmd VARCHAR2(1000);
BEGIN
    FOR i IN (SELECT owner,table_name FROM dba_tables WHERE owner = '&1') LOOP
        cmd := 'ALTER TABLE '||i.owner||'.'||i.table_name||' NO INMEMORY';
        DBMS_OUTPUT.PUT_LINE(cmd);
        EXECUTE IMMEDIATE cmd;
    END LOOP;
END;
/

