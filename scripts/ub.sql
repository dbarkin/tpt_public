col u_username head USERNAME for a23
col u_sid head SID for a14 
col u_audsid head AUDSID for 9999999999
col u_osuser head OSUSER for a16
col u_machine head MACHINE for a18 TRUNCATE
col u_program head PROGRAM for a20

prompt Show background sessions belonging to background processes...

select 
--	s.username u_username, 
	'''' || s.sid || ',' || s.serial# || '''' u_sid, 
--       s.audsid u_audsid,
       s.osuser u_osuser, 
       substr(s.machine,instr(s.machine,'\')) u_machine, 
       substr(s.program,instr(s.program,'('),20) u_program,
       p.pid,
       p.spid, 
       -- s.sql_address, 
       s.sql_hash_value, 
       s.last_call_et lastcall, 
       s.status 
       --, s.logon_time
from 
    v$session s,
    v$process p
where
    s.paddr=p.addr
and s.type='BACKGROUND'
--and s.status='ACTIVE'
/

