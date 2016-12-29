COL sqlfn_descr HEAD DESCRIPTION FOR A100 WORD_WRAP

SELECT
    func_id
  , name
  , offloadable
--  , usage
  , minargs
  , maxargs
    -- this is just to avoid clutter on screen
  , CASE WHEN name != descr THEN descr ELSE null END sqlfn_descr 
FROM
    v$sqlfn_metadata 
WHERE 
    UPPER(name) LIKE UPPER('%&1%')
/

