create or replace function delete_func (owner_name in varchar2) return number
as
   num_deleted number;
begin
   -- this is a demo procedure
   -- it does not do anything useful!

   DELETE FROM mytab WHERE owner = owner_name;
   COMMIT;

   num_deleted := SQL%ROWCOUNT;
   DBMS_OUTPUT.PUT_LINE('Deleted rows ='|| TO_CHAR(num_deleted));

   return num_deleted;
end;
/
show err
