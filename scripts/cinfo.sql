SELECT sid, client_info FROM v$session WHERE sid IN (&1);
