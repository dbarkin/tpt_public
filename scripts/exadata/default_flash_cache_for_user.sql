DECLARE
    cmd VARCHAR2(1000);
BEGIN
    FOR i IN (SELECT owner,table_name FROM dba_tables WHERE owner = '&1') LOOP
        cmd := 'ALTER TABLE '||i.owner||'.'||i.table_name||' STORAGE (CELL_FLASH_CACHE DEFAULT)';
        DBMS_OUTPUT.PUT_LINE(cmd);
        EXECUTE IMMEDIATE cmd;
    END LOOP;

    FOR i IN (SELECT owner,index_name FROM dba_indexes WHERE owner = '&1') LOOP
        cmd := 'ALTER INDEX '||i.owner||'.'||i.index_name||' STORAGE (CELL_FLASH_CACHE DEFAULT)';
        DBMS_OUTPUT.PUT_LINE(cmd);
        EXECUTE IMMEDIATE cmd;
    END LOOP;
END;
/

