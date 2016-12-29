CREATE TABLE myspstat ( 
    sample_time DATE
  , subpool     NUMBER
  , name        VARCHAR2(100)
  , bytes       NUMBER
);

BEGIN
    WHILE TRUE LOOP 
        INSERT INTO myspstat 
        SELECT
            SYSDATE
          , ksmdsidx
          , ksmssnam
          , SUM(ksmsslen)
        FROM
            x$ksmss
        WHERE
            ksmsslen > 0
        AND ksmdsidx > 0
        GROUP BY
            SYSDATE
          , ksmdsidx
          , ksmssnam;
                  
        COMMIT;
        DBMS_LOCK.SLEEP(5);
   END LOOP;
END;
/
