--Most_Purchased_items_view 
CREATE OR REPLACE VIEW pms.most_purchased_items_view AS
select item_id, sum(quantity) as total_quantity from (
    select rq_l.quantity, iv.item_id from pms.voucher v 
    inner join pms.invoice i on v.invoice_id=i.invoice_id 
    inner join pms.purchase_order_line po_l on i.po_id=po_l.po_id
    inner join pms.requisition_line rq_l on po_l.req_line_no=rq_l.req_line_no
    inner join pms.item_vendor iv on iv.item_vendor_id=rq_l.item_vendor_id
    where v.status='PAID'
) group by item_id
order by total_quantity desc;

--Favorite_Vendor_view 
CREATE OR REPLACE VIEW pms.favorite_vendor_view AS
SELECT v.vendor_id, v.vendor_name, COUNT(*) AS total_purchases
FROM requisition_line rl
JOIN item_vendor vi ON rl.item_vendor_id = vi.item_vendor_id
JOIN vendor v ON vi.vendor_id = v.vendor_id
GROUP BY v.vendor_id,v.vendor_name
ORDER BY total_purchases DESC;


--Purchase_Report_view 
CREATE OR REPLACE VIEW pms.purchase_report_view AS
select i.item_name,
       v.vendor_name, 
       iv.price,        
       rq_l.quantity as quantity_bought,
       rq_l.req_line_no,
       u1.username as requestor,        
       rq_h.req_created,
       rq_h.req_status,
       u2.username as approver,
       po_h.po_date,
       po_h.po_status,
       i.gross_amt,
       v.status as voucher_status,
       v.accounting_date
from pms.item_vendor iv 
inner join pms.item i on i.item_id=iv.item_id
inner join pms.vendor v on v.vendor_id=iv.vendor_id
inner join pms.requisition_line rq_l on rq_l.item_vendor_id=iv.item_vendor_id 
inner join pms.requisition_header rq_h on rq_h.req_id=rq_l.req_id
inner join pms.purchase_order_header po_h on po_h.req_id=rq_h.req_id
left join pms.invoice i on i.po_id=po_h.po_id
left join pms.voucher v on v.invoice_id=i.invoice_id
inner join pms.user_table u1 on u1.user_id=rq_h.req_creator_id 
inner join pms.user_table u2 on u2.user_id=rq_h.req_approver_id
where iv.item_id = 9;

--Vendor_Details_view 
CREATE OR REPLACE VIEW pms.vendor_details_view AS
select v.vendor_id, v.vendor_name, c.phone_no, c.email, a.street, a.state, a.zipcode, v.currency, v.status 
from pms.vendor v
inner join pms.contact c on c.actor_id=v.vendor_id
inner join pms.address a on a.actor_id=v.vendor_id
where c.status='A' and a.status='A';


CREATE OR REPLACE VIEW PMS.FINANCIAL_REPORT_VIEW
AS 
select 
jh.fiscal_year,
jh.accounting_period,
jl.account_id,
a.account_type,
a.account_name,
sum(l.amount) as balance
from pms.Ledger l
inner join pms.account a
on a.account_id=l.account_id
inner join pms.journal_line jl
on jl.jrnl_line_no=l.jrnl_line_no
and jl.account_id=l.account_id
inner join pms.journal_header jh
on jh.jrnl_id=jl.jrnl_id
where a.account_type in ('ASSET','LIABILITY','CAPITAL')
group by jh.fiscal_year,jh.accounting_period,jl.account_id,a.account_type,a.account_name
order by jh.fiscal_year,jh.accounting_period,jl.account_id,a.account_type,a.account_name;


GRANT SELECT ON PMS.FINANCIAL_REPORT_VIEW TO public;
GRANT SELECT ON PMS.FAVORITE_VENDOR_VIEW TO public;
GRANT SELECT ON PMS.MOST_PURCHASED_ITEMS_VIEW TO public;
GRANT SELECT ON PMS.PURCHASE_REPORT_VIEW TO public;
GRANT SELECT ON PMS.VENDOR_DETAILS_VIEW TO public;


 
 
 CREATE OR REPLACE FUNCTION PMS.vendor_paid(id IN NUMBER) 
   RETURN VARCHAR
   IS VENDOR_NAME VARCHAR(100);
BEGIN 
   SELECT SUM(GROSS_AMT) 
   INTO VENDOR_NAME 
   FROM PMS.VOUCHER 
   WHERE VENDOR_ID = ID AND STATUS='PAID'; 
   
   RETURN(VENDOR_NAME); 
 END;
 
 /
 CREATE OR REPLACE FUNCTION PMS.get_capital(start_date in VARCHAR, end_date in VARCHAR) 
   RETURN NUMBER
   IS AMOUNT NUMBER(1,11);
BEGIN 
   
    select sum(amount) 
    INTO AMOUNT 
    from pms.ledger
    where account_id=4000
    and accounting_date between start_date and end_date
    order by ledger_id;
   
   RETURN(AMOUNT); 
 END;
 
 /
 GRANT EXECUTE ON PMS.get_capital TO public;
 GRANT EXECUTE ON PMS.vendor_paid TO public;
 