SELECT module, action, client_identifier, ecid FROM v$session WHERE sid IN (&1);
