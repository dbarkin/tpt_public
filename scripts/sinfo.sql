SELECT sid, username, program, service_name, module, action, client_identifier, client_info, ecid, machine, port
FROM v$session WHERE sid IN (&1);

