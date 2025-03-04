SELECT lo.object_id, o.object_name, o.object_type, s.sid, s.serial#, s.username, s.status
FROM v$locked_object lo
JOIN dba_objects o ON lo.object_id = o.object_id
JOIN v$session s ON lo.session_id = s.sid;