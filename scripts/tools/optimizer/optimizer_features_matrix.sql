PROMPT display a matrix of optimizer parameters which change when changing optimizer_features_enabled...

CREATE TABLE opt_param_matrix(
    opt_features_enabled VARCHAR2(100) NOT NULL
  , parameter            VARCHAR2(55) NOT NULL
  , value                VARCHAR2(1000)
);



DECLARE

BEGIN
    FOR i IN (select value from v$parameter_valid_values where name = 'optimizer_features_enable' order by ordinal) LOOP
        EXECUTE IMMEDIATE 'alter session set optimizer_features_enable='''||i.value||'''';
        EXECUTE IMMEDIATE 'insert into opt_param_matrix select :opt_features_enable, n.ksppinm, c.ksppstvl from sys.x$ksppi n, sys.x$ksppcv c where n.indx=c.indx' using i.value;
    END LOOP;
END;
/

PROMPT To test, run: @cofep.sql 10.2.0.1 10.2.0.4

