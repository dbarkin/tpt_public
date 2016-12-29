--------------------------------------------------------------------------------
--
-- Author:	Tanel Poder
-- Copyright:	(c) http://www.tanelpoder.com
-- 
-- Notes:	This software is provided AS IS and doesn't guarantee anything
-- 		Proofread before you execute it!
--
--------------------------------------------------------------------------------

@@drop_grants_syns.sql

drop view sawr$sess_event;
drop view sawr$sess_stat;

drop sequence sawr$snapid_seq;

drop table sawr$snapshots;
drop table sawr$sessions;
drop table sawr$session_events;
drop table sawr$session_stats;
drop table sawr$session_stat_mode;

drop type sawr$SIDList;

