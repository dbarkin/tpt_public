col grantee for a25

select grantee, granted_role, admin_option, default_role from dba_role_privs where upper(grantee) like upper('&1');

select grantee, privilege, admin_option from dba_sys_privs where upper(grantee) like upper('&1');

select grantee, owner, table_name, privilege from dba_tab_privs where upper(grantee) like upper('&1');
