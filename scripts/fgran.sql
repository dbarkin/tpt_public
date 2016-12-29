col fgran_component for a20

select
    t.component fgran_component
  , g.*
from 
    x$ksmge  g
  , x$kmgsct t
where 
    g.grantype = t.grantype
and
    to_number(substr('&1', instr(lower('&1'), 'x')+1) ,lpad('X',vsize(g.addr)*2,'X')) 
    between 
        to_number(g.baseaddr,lpad('X',vsize(g.addr)*2,'X'))
    and to_number(g.baseaddr,lpad('X',vsize(g.addr)*2,'X')) + g.gransize - 1
/
