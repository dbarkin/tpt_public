set head off feedback off
select 'grant '||granted_role||' to '||grantee||decode(admin_option, 'YES', ' WITH ADMIN OPTION;',';') cmd from dba_role_privs where upper(grantee) like upper('%&1%');
select 'grant '||privilege||' to '||grantee||decode(admin_option, 'YES', ' WITH ADMIN OPTION;',';') cmd from dba_sys_privs where upper(grantee) like upper('%&1%');
select 'grant '||privilege||' on '||owner||'.'||table_name||' to '||grantee||decode(grantable, 'YES', ' WITH GRANT OPTION;',';') cmd from dba_tab_privs where upper(grantee) like upper('%&1%');
set head on feedback on
