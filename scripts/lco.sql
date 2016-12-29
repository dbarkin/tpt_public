SELECT
    *
FROM
    v$db_object_cache WHERE hash_value IN (&1); 
