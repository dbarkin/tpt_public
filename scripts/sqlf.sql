col sqlf_sql_fulltext head SQL_FULLTEXT for a100 word_wrap

select sql_fulltext sqlf_sql_fulltext from v$sql where sql_id like '&1';
