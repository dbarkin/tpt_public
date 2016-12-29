COL cell_cell_path HEAD CELL_PATH FOR A30

SELECT
    c.cell_path  cell_cell_path
  , c.cell_hashval
FROM
    v$cell c
/

