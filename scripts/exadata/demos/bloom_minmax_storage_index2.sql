SET ECHO ON
ALTER SESSION SET "_serial_direct_read"=ALWAYS;
ALTER SESSION SET "_cell_storidx_mode"=EVA; 

SELECT
    /*+ LEADING(c)
        NO_SWAP_JOIN_INPUTS(o)
        FULL(o)
        PARALLEL(2)
        MONITOR
    */
    *
FROM
    soe.customers2 c
  , soe.orders2 o
WHERE
    o.customer_id = c.customer_id
AND c.cust_email = 'rico@mbtuhkbv.com'
/
SET ECHO OFF

