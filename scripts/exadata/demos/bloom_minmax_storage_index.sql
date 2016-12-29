SET ECHO ON
-- ALTER SESSION SET "_serial_direct_read"=ALWAYS;
-- ALTER SESSION SET "_cell_storidx_mode"=EVA; 

SELECT
    /*+ LEADING(c)
        NO_SWAP_JOIN_INPUTS(o)
        INDEX_RS_ASC(c(cust_email))
        FULL(o)
        MONITOR
    */
    *
FROM
    soe.customers c
  , soe.orders o
WHERE
    o.customer_id = c.customer_id
AND c.cust_email = 'florencio@ivtboge.com'
--AND c.cust_email = 'anthony.pena@bellsouth.com'
/
SET ECHO OFF



-- 11.2.0.4 estrella@socxankh.com
