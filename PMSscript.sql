
set serveroutput on
declare
    v_view_exists varchar(1) := 'Y';
    v_sql varchar(2000);
begin
   dbms_output.put_line('Start view cleanup');
   for i in (select view_name from all_views
where owner='PMS' )
   loop
   dbms_output.put_line('....Drop VIEW PMS.'||i.view_name);
   begin
       select 'Y' into v_view_exists
       from all_views
       where view_name=i.view_name ;

       v_sql := 'drop VIEW PMS.'||i.view_name;
       execute immediate v_sql;
       dbms_output.put_line('........VIEW '||i.view_name||' dropped successfully');
       
   exception
       when no_data_found then
           dbms_output.put_line('........VIEW already dropped');
   end;
   end loop;
   dbms_output.put_line('VIEW cleanup successfully completed');
exception
   when others then
      dbms_output.put_line('Failed to execute code:'||sqlerrm);
end;
/

set serveroutput on
declare
    v_table_exists varchar(1) := 'Y';
    v_sql varchar(2000);
begin
   dbms_output.put_line('Start schema cleanup');
   for i in (select table_name from user_tables
   )
   loop
   dbms_output.put_line('....Drop table '||i.table_name);
   begin
       select 'Y' into v_table_exists
       from USER_TABLES
       where TABLE_NAME=i.table_name;

       v_sql := 'drop table '||i.table_name ||' cascade constraints';
       execute immediate v_sql;
       dbms_output.put_line('........Table '||i.table_name||' dropped successfully');
       
   exception
       when no_data_found then
           dbms_output.put_line('........Table already dropped');
   end;
   end loop;
   dbms_output.put_line('Schema cleanup successfully completed');
exception
   when others then
      dbms_output.put_line('Failed to execute code:'||sqlerrm);
end;
/

BEGIN
  DECLARE
    user_count INTEGER;
  BEGIN
    SELECT COUNT(*) INTO user_count FROM all_users WHERE username = 'PMS';
    IF user_count > 0 THEN
      EXECUTE IMMEDIATE 'DROP USER PMS CASCADE';
    END IF;
  END;
END;
/

create user PMS identified by Admin#1234567890;
ALTER USER PMS QUOTA 100M ON USERS;
/*User table*/
CREATE TABLE PMS.USER_TABLE 
(
  USER_ID NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 NOT NULL 
, USERNAME VARCHAR2(30 BYTE) NOT NULL 
, ROLE VARCHAR2(20 BYTE) NOT NULL 
, FIRST_NAME VARCHAR2(20 BYTE) NOT NULL 
, LAST_NAME VARCHAR2(20 BYTE) NOT NULL 
, CONSTRAINT TABLE1_PK PRIMARY KEY 
  (
    USER_ID 
  )
  USING INDEX 
  (
      CREATE UNIQUE INDEX PMS.TABLE1_PK ON PMS.USER_TABLE (USER_ID ASC) 
      LOGGING 
      TABLESPACE DATA 
      PCTFREE 10 
      INITRANS 20 
      STORAGE 
      ( 
        BUFFER_POOL DEFAULT 
      ) 
      NOPARALLEL 
  )
  ENABLE 
);

alter table PMS.USER_TABLE
modify USER_ID generated always as identity restart start with 1;

/*address table.*/ 
CREATE TABLE PMS.ADDRESS 
(
  ADD_ID NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 MAXVALUE 9999999999999999999999999999 MINVALUE 1 CACHE 20 NOT NULL 
, STREET VARCHAR2(60 BYTE) NOT NULL 
, STATE VARCHAR2(20 BYTE) NOT NULL 
, ZIPCODE NUMBER NOT NULL 
, STATUS VARCHAR2(20 BYTE) NOT NULL 
, ACTOR_ID NUMBER NOT NULL 
, CONSTRAINT ADDRESS_PK PRIMARY KEY 
  (
    ADD_ID 
  )
  USING INDEX 
  (
      CREATE UNIQUE INDEX PMS.ADDRESS_PK ON PMS.ADDRESS (ADD_ID ASC) 
      LOGGING 
      TABLESPACE DATA 
      PCTFREE 10 
      INITRANS 20 
      STORAGE 
      ( 
        BUFFER_POOL DEFAULT 
      ) 
      NOPARALLEL 
  )
  ENABLE 
);

ALTER TABLE PMS.ADDRESS
ADD CONSTRAINT ADDRESS_FK1 FOREIGN KEY
(
  ACTOR_ID 
)
REFERENCES PMS.USER_TABLE
(
  USER_ID 
)
ENABLE;

alter table PMS.ADDRESS
modify ADD_ID generated always as identity restart start with 1;

/*Requisition header table.*/
CREATE TABLE PMS.REQUISITION_HEADER 
(
  REQ_ID NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 NOT NULL 
, REQ_APPROVER_ID NUMBER NOT NULL 
, REQ_CREATOR_ID NUMBER NOT NULL 
, REQ_STATUS VARCHAR2(20) NOT NULL 
, REQ_DESC VARCHAR2(200) NOT NULL 
, APPROVAL_DATE DATE NOT NULL 
, BUDGET_CHECK VARCHAR2(20) NOT NULL 
, REQ_CREATED DATE NOT NULL  
, CONSTRAINT REQ_HDR_PK PRIMARY KEY 
  (
    REQ_ID 
  )
  ENABLE 
);

ALTER TABLE PMS.REQUISITION_HEADER
ADD CONSTRAINT REQ_HDR_FK2 FOREIGN KEY
(
  REQ_APPROVER_ID 
)
REFERENCES PMS.USER_TABLE
(
  USER_ID 
)
ENABLE;

ALTER TABLE PMS.REQUISITION_HEADER
ADD CONSTRAINT REQ_HDR_FK3 FOREIGN KEY
(
  REQ_CREATOR_ID 
)
REFERENCES PMS.USER_TABLE
(
  USER_ID 
)
ENABLE;

alter table PMS.REQUISITION_HEADER
modify REQ_ID generated always as identity restart start with 1;

/*Requisition Line Table.*/
CREATE TABLE PMS.REQUISITION_LINE 
(
  REQ_LINE_NO NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 NOT NULL 
, REQ_ID NUMBER NOT NULL 
, ITEM_VENDOR_ID NUMBER NOT NULL 
, QUANTITY NUMBER NOT NULL 
, CONSTRAINT REQ_LINE_PK PRIMARY KEY 
  (
    REQ_LINE_NO 
  )
  ENABLE 
);

ALTER TABLE PMS.REQUISITION_LINE
ADD CONSTRAINT REQ_LINE_FK1 FOREIGN KEY
(
  REQ_ID 
)
REFERENCES PMS.REQUISITION_HEADER
(
  REQ_ID 
)
ENABLE;

alter table PMS.REQUISITION_LINE
modify REQ_LINE_NO generated always as identity restart start with 1;

/*Contact table.*/
CREATE TABLE PMS.CONTACT 
(
  CONT_ID NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 NOT NULL 
, PHONE_NO NUMBER NOT NULL 
, EMAIL VARCHAR2(30) NOT NULL 
, STATUS VARCHAR2(20) NOT NULL 
, ACTOR_ID NUMBER NOT NULL 
, CONSTRAINT CONTACT_PK PRIMARY KEY 
  (
    CONT_ID 
  )
  ENABLE 
);

ALTER TABLE PMS.CONTACT
ADD CONSTRAINT CONTACT_FK1 FOREIGN KEY
(
  ACTOR_ID 
)
REFERENCES PMS.USER_TABLE
(
  USER_ID 
)
ENABLE;

alter table PMS.CONTACT
modify CONT_ID generated always as identity restart start with 1;

/* Vendor Table */
CREATE TABLE PMS.VENDOR 
(
  VENDOR_ID NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 NOT NULL 
, VENDOR_NAME VARCHAR2(20) NOT NULL 
, ACC_NUM NUMBER NOT NULL 
, STATUS CHAR NOT NULL 
, PAYMENT_METHOD VARCHAR2(20) NOT NULL 
, USER_ID NUMBER NOT NULL 
, CURRENCY VARCHAR2(20) NOT NULL 
, CONSTRAINT VENDOR_PK PRIMARY KEY 
  (
    VENDOR_ID 
  )
  ENABLE 
);

ALTER TABLE PMS.VENDOR
ADD CONSTRAINT VENDOR_FK1 FOREIGN KEY
(
  USER_ID 
)
REFERENCES PMS.USER_TABLE
(
  USER_ID 
)
ENABLE;

alter table PMS.VENDOR
modify VENDOR_ID generated always as identity restart start with 1;

/* Purchase Order Table */
CREATE TABLE PMS.PURCHASE_ORDER_HEADER 
(
  PO_ID NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 MAXVALUE 9999999999999999999999999999 MINVALUE 1 CACHE 20 NOT NULL 
, REQ_ID NUMBER NOT NULL 
, VENDOR_ID NUMBER NOT NULL 
, PO_DATE DATE NOT NULL 
, PO_STATUS VARCHAR2(20 BYTE) NOT NULL 
, PO_TOTAL NUMBER NOT NULL 
, CONSTRAINT PURCHASE_ORDER_HEADER_PK PRIMARY KEY 
  (
    PO_ID 
  )
  USING INDEX 
  (
      CREATE UNIQUE INDEX PMS.PURCHASE_ORDER_HEADER_PK ON PMS.PURCHASE_ORDER_HEADER (PO_ID ASC) 
      LOGGING 
      TABLESPACE DATA 
      PCTFREE 10 
      INITRANS 20 
      STORAGE 
      ( 
        BUFFER_POOL DEFAULT 
      ) 
      NOPARALLEL 
  )
  ENABLE 
);

ALTER TABLE PMS.PURCHASE_ORDER_HEADER
ADD CONSTRAINT PURCHASE_ORDER_HEADER_FK1 FOREIGN KEY
(
  VENDOR_ID 
)
REFERENCES PMS.VENDOR
(
  VENDOR_ID 
)
ENABLE;

ALTER TABLE PMS.PURCHASE_ORDER_HEADER
ADD CONSTRAINT PURCHASE_ORDER_HEADER_FK2 FOREIGN KEY
(
  REQ_ID 
)
REFERENCES PMS.REQUISITION_HEADER
(
  REQ_ID 
)
ENABLE;

alter table PMS.PURCHASE_ORDER_HEADER
modify PO_ID generated always as identity restart start with 1;

/* Purchase Order Line */
CREATE TABLE PMS.PURCHASE_ORDER_LINE 
(
  PO_LINE_NO NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 NOT NULL 
, PO_ID NUMBER NOT NULL 
, REQ_LINE_NO NUMBER NOT NULL 
, CONSTRAINT PURCHASE_ORDER_LINE_PK PRIMARY KEY 
  (
    PO_LINE_NO 
  )
  ENABLE 
);

ALTER TABLE PMS.PURCHASE_ORDER_LINE
ADD CONSTRAINT PURCHASE_ORDER_LINE_FK1 FOREIGN KEY
(
  PO_ID 
)
REFERENCES PMS.PURCHASE_ORDER_HEADER
(
  PO_ID 
)
ENABLE;

ALTER TABLE PMS.PURCHASE_ORDER_LINE
ADD CONSTRAINT PURCHASE_ORDER_LINE_FK2 FOREIGN KEY
(
  REQ_LINE_NO 
)
REFERENCES PMS.REQUISITION_LINE
(
  REQ_LINE_NO 
)
ENABLE;

alter table PMS.PURCHASE_ORDER_LINE
modify PO_LINE_NO generated always as identity restart start with 1;

/* Item Table */
CREATE TABLE PMS.ITEM 
(
  ITEM_ID NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 NOT NULL 
, CATEGORY_NAME VARCHAR2(20) NOT NULL 
, ITEM_NAME VARCHAR2(20) NOT NULL 
, ITEM_DESC VARCHAR2(30) NOT NULL 
, CONSTRAINT ITEM_PK PRIMARY KEY 
  (
    ITEM_ID 
  )
  ENABLE 
);

alter table PMS.ITEM
modify ITEM_ID generated always as identity restart start with 1;

/* Item Vendor Table */
CREATE TABLE PMS.ITEM_VENDOR 
(
  ITEM_VENDOR_ID NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 NOT NULL 
, ITEM_ID NUMBER NOT NULL 
, VENDOR_ID NUMBER NOT NULL 
, PRICE NUMBER NOT NULL 
, MINIMUM_ORDER NUMBER NOT NULL 
, CREATED_DATE DATE NOT NULL 
, UPDATED_DATE DATE NOT NULL 
, CONSTRAINT ITEM_VENDOR_PK PRIMARY KEY 
  (
    ITEM_VENDOR_ID 
  )
  ENABLE 
);

ALTER TABLE PMS.ITEM_VENDOR
ADD CONSTRAINT ITEM_VENDOR_FK1 FOREIGN KEY
(
  ITEM_ID 
)
REFERENCES PMS.ITEM
(
  ITEM_ID 
)
ENABLE;

ALTER TABLE PMS.ITEM_VENDOR
ADD CONSTRAINT ITEM_VENDOR_FK2 FOREIGN KEY
(
  VENDOR_ID 
)
REFERENCES PMS.VENDOR
(
  VENDOR_ID 
)
ENABLE;

alter table PMS.ITEM_VENDOR
modify ITEM_VENDOR_ID generated always as identity restart start with 1;

/* Invoice */
CREATE TABLE PMS.INVOICE 
(
  INVOICE_ID NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 NOT NULL 
, PO_ID NUMBER NOT NULL 
, GROSS_AMT NUMBER NOT NULL 
, CREATED_DATE DATE NOT NULL 
, CONSTRAINT INVOICE_PK PRIMARY KEY 
  (
    INVOICE_ID 
  )
  ENABLE 
);

ALTER TABLE PMS.INVOICE
ADD CONSTRAINT INVOICE_FK1 FOREIGN KEY
(
  PO_ID 
)
REFERENCES PMS.PURCHASE_ORDER_HEADER
(
  PO_ID 
)
ENABLE;

alter table PMS.INVOICE
modify INVOICE_ID generated always as identity restart start with 1;

/* Voucher */
CREATE TABLE PMS.VOUCHER 
(
  VOUCHER_ID NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 NOT NULL 
, INVOICE_ID NUMBER NOT NULL 
, VENDOR_ID NUMBER NOT NULL 
, INVOICE_DATE DATE NOT NULL 
, STATUS VARCHAR2(20) NOT NULL 
, GROSS_AMT NUMBER NOT NULL 
, ACCOUNTING_DATE DATE NOT NULL 
, CONSTRAINT VOUCHER_PK PRIMARY KEY 
  (
    VOUCHER_ID 
  )
  ENABLE 
);

ALTER TABLE PMS.VOUCHER
ADD CONSTRAINT VOUCHER_FK1 FOREIGN KEY
(
  VENDOR_ID 
)
REFERENCES PMS.VENDOR
(
  VENDOR_ID 
)
ENABLE;

ALTER TABLE PMS.VOUCHER
ADD CONSTRAINT VOUCHER_FK2 FOREIGN KEY
(
  INVOICE_ID 
)
REFERENCES PMS.INVOICE
(
  INVOICE_ID 
)
ENABLE;

alter table PMS.VOUCHER
modify VOUCHER_ID generated always as identity restart start with 1;

/* Journal Header */
CREATE TABLE PMS.JOURNAL_HEADER 
(
  JRNL_ID NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 NOT NULL 
, JRNL_DATE DATE NOT NULL 
, FISCAL_YEAR NUMBER NOT NULL 
, ACCOUNTING_PERIOD NUMBER NOT NULL 
, STATUS VARCHAR2(20) 
, CONSTRAINT JOURNAL_HEADER_PK PRIMARY KEY 
  (
    JRNL_ID 
  )
  ENABLE 
);

alter table PMS.JOURNAL_HEADER
modify JRNL_ID generated always as identity restart start with 1;

/* Journal Line */
CREATE TABLE PMS.JOURNAL_LINE 
(
  JRNL_LINE_NO NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 NOT NULL 
, JRNL_ID NUMBER NOT NULL 
, ACCOUNT_ID NUMBER NOT NULL 
, AMOUNT NUMBER NOT NULL 
, DESCRIPTION VARCHAR2(60) NOT NULL 
, TRANSACTION_FLAG VARCHAR2(20) NOT NULL 
, CONSTRAINT JOURNAL_LINE_PK PRIMARY KEY 
  (
    JRNL_LINE_NO 
  )
  ENABLE 
);

ALTER TABLE PMS.JOURNAL_LINE
ADD CONSTRAINT JOURNAL_LINE_FK1 FOREIGN KEY
(
  JRNL_ID 
)
REFERENCES PMS.JOURNAL_HEADER
(
  JRNL_ID 
)
ENABLE;

/* Account Table */
CREATE TABLE PMS.ACCOUNT 
(
  ACCOUNT_ID NUMBER NOT NULL 
, ACCOUNT_NAME VARCHAR2(40) NOT NULL 
, ACCOUNT_TYPE VARCHAR2(20) NOT NULL 
, CONSTRAINT ACCOUNT_PK PRIMARY KEY 
  (
    ACCOUNT_ID 
  )
  ENABLE 
);

ALTER TABLE PMS.JOURNAL_LINE
ADD CONSTRAINT JOURNAL_LINE_FK2 FOREIGN KEY
(
  ACCOUNT_ID 
)
REFERENCES PMS.ACCOUNT
(
  ACCOUNT_ID 
)
ENABLE;

ALTER TABLE PMS.JOURNAL_LINE  
MODIFY (DESCRIPTION VARCHAR2(100 BYTE) );

alter table PMS.JOURNAL_LINE
modify JRNL_LINE_NO generated always as identity restart start with 1;

/* Ledger Table */
CREATE TABLE PMS.LEDGER 
(
  LEDGER_ID NUMBER GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 NOT NULL 
, JRNL_ID NUMBER NOT NULL 
, JRNL_LINE_NO NUMBER NOT NULL 
, ACCOUNT_ID NUMBER NOT NULL 
, ACCOUNTING_DATE DATE NOT NULL 
, TRANSACTION_FLAG varchar(20) NOT NULL 
, AMOUNT NUMBER NOT NULL 
, CONSTRAINT LEDGER_PK PRIMARY KEY 
  (
    LEDGER_ID 
  )
  ENABLE 
);

ALTER TABLE PMS.LEDGER
ADD CONSTRAINT LEDGER_FK1 FOREIGN KEY
(
  JRNL_ID 
)
REFERENCES PMS.JOURNAL_HEADER
(
  JRNL_ID 
)
ENABLE;

ALTER TABLE PMS.LEDGER
ADD CONSTRAINT LEDGER_FK2 FOREIGN KEY
(
  JRNL_LINE_NO 
)
REFERENCES PMS.JOURNAL_LINE
(
  JRNL_LINE_NO 
)
ENABLE;

ALTER TABLE PMS.LEDGER
ADD CONSTRAINT LEDGER_FK3 FOREIGN KEY
(
  ACCOUNT_ID 
)
REFERENCES PMS.ACCOUNT
(
  ACCOUNT_ID 
)
ENABLE;

alter table PMS.LEDGER
modify LEDGER_ID generated always as identity restart start with 1;

--CLEANUP SCRIPT

BEGIN
  FOR r IN (select sid,serial# from v$session where USERNAME in(
'REQUESTOR_USER',
'PROCUREMENT_ANALYST_USER',
'VENDOR_USER',
'ACCOUNTANT_USER',
'FINANCE_OFFICER_USER',
'USER_ADMIN_USER',
'INVENTORY_ADMIN_USER',
'VENDOR_USER_WALMART',
'VENDOR_USER_WAYFAIR',
'VENDOR_USER_PRICERITE',
'VENDOR_USER_BESTBUY',
'VENDOR_USER_STAPLES'
))
  LOOP
      EXECUTE IMMEDIATE 'alter system kill session ''' || r.sid  || ',' 
        || r.serial# || ''' immediate';
  END LOOP;
END;
/
set serveroutput on
declare
    v_user_exists varchar(1) := 'Y';
    v_sql varchar(2000);
begin
   dbms_output.put_line('Start user cleanup');
   for i in (select USERNAME from all_users
WHERE USERNAME in(
'REQUESTOR_USER',
'PROCUREMENT_ANALYST_USER',
'VENDOR_USER',
'ACCOUNTANT_USER',
'FINANCE_OFFICER_USER',
'USER_ADMIN_USER',
'INVENTORY_ADMIN_USER',
'VENDOR_USER_WALMART',
'VENDOR_USER_WAYFAIR',
'VENDOR_USER_PRICERITE',
'VENDOR_USER_BESTBUY',
'VENDOR_USER_STAPLES'
)
   )
   loop
   dbms_output.put_line('....Drop user '||i.USERNAME);
   begin
       select 'Y' into v_user_exists
       from all_users
       where USERNAME= i.USERNAME;

       v_sql := 'drop user '||i.USERNAME;
       execute immediate v_sql;
       dbms_output.put_line('........User '||i.USERNAME||' dropped successfully');
       
   exception
       when no_data_found then
           dbms_output.put_line('........User already dropped');
   end;
   end loop;
   dbms_output.put_line('User cleanup successfully completed');
exception
   when others then
      dbms_output.put_line('Failed to execute code:'||sqlerrm);
end;
/

--Role CLEANUP SCRIPT
set serveroutput on
declare
    v_role_exists varchar(1) := 'Y';
    v_sql varchar(2000);
begin
   dbms_output.put_line('Start role cleanup');
   for i in (select distinct role
from DBA_ROLES
where role in (
'REQUESTOR',
'PROCUREMENT_ANALYST',
'VENDOR',
'ACCOUNTANT',
'FINANCE_OFFICER',
'USER_ADMIN',
'INVENTORY_ADMIN')
   )
   loop
   dbms_output.put_line('....Drop role '||i.role);
   begin
       select 'Y' into v_role_exists
       from DBA_ROLES
       where role= i.role;

       v_sql := 'drop role '||i.role;
       execute immediate v_sql;
       dbms_output.put_line('........Role '||i.role||' dropped successfully');
       
   exception
       when no_data_found then
           dbms_output.put_line('........Role already dropped');
   end;
   end loop;
   dbms_output.put_line('Role cleanup successfully completed');
exception
   when others then
      dbms_output.put_line('Failed to execute code:'||sqlerrm);
end;
/

-- Create Roles

CREATE ROLE REQUESTOR;
CREATE ROLE PROCUREMENT_ANALYST;
CREATE ROLE VENDOR;
CREATE ROLE ACCOUNTANT;
CREATE ROLE FINANCE_OFFICER;
CREATE ROLE USER_ADMIN;
CREATE ROLE INVENTORY_ADMIN;

GRANT  INSERT, SELECT, UPDATE, DELETE  ON PMS.requisition_line TO REQUESTOR;
GRANT  INSERT, SELECT, UPDATE, DELETE  ON PMS.REQUISITION_HEADER TO REQUESTOR;	
GRANT  SELECT ON PMS.item_vendor TO REQUESTOR;
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.requisition_header TO "PROCUREMENT_ANALYST";	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.requisition_line TO "PROCUREMENT_ANALYST";
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.purchase_order_header TO "PROCUREMENT_ANALYST";	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.purchase_order_line TO "PROCUREMENT_ANALYST";
GRANT  SELECT ON PMS.item_vendor TO "PROCUREMENT_ANALYST";
GRANT  SELECT ON PMS.item_vendor TO VENDOR;
GRANT  SELECT ON PMS.purchase_order_line TO VENDOR;
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.invoice TO VENDOR;	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.item_vendor TO VENDOR;	
GRANT  SELECT ON PMS.item TO Vendor;
GRANT  SELECT ON PMS.invoice TO Accountant;
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.voucher TO ACCOUNTANT;	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.journal_header TO ACCOUNTANT;	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.journal_line TO ACCOUNTANT;	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.account TO ACCOUNTANT;	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.journal_header TO "FINANCE_OFFICER";	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.journal_line TO "FINANCE_OFFICER";	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.account TO "FINANCE_OFFICER";	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.ledger TO "FINANCE_OFFICER";	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.user_table TO "USER_ADMIN";	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.address TO "USER_ADMIN";	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.contact TO "USER_ADMIN";	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.item TO "INVENTORY_ADMIN";	
GRANT  INSERT, SELECT,UPDATE, DELETE  ON PMS.vendor TO "INVENTORY_ADMIN";	


--Create Users

create user requestor_user IDENTIFIED BY REQpmsspring2023;
grant REQUESTOR to requestor_user;

create user procurement_analyst_user IDENTIFIED BY PROpmsspring2023;
grant PROCUREMENT_ANALYST to procurement_analyst_user;

create user vendor_user IDENTIFIED BY VENpmsspring2023;
grant VENDOR to vendor_user;

create user accountant_user IDENTIFIED BY ACCpmsspring2023;
grant ACCOUNTANT to accountant_user;

create user finance_officer_user IDENTIFIED BY FINpmsspring2023;
grant FINANCE_OFFICER to finance_officer_user;

create user user_admin_user IDENTIFIED BY USRpmsspring2023;
grant USER_ADMIN to user_admin_user;

create user inventory_admin_user IDENTIFIED BY INVpmsspring2023;
grant INVENTORY_ADMIN to inventory_admin_user;

create user vendor_user_Walmart IDENTIFIED BY VENpmsspring2023;
grant VENDOR to vendor_user;

create user vendor_user_Wayfair IDENTIFIED BY VENpmsspring2023;
grant VENDOR to vendor_user;

create user vendor_user_Pricerite IDENTIFIED BY VENpmsspring2023;
grant VENDOR to vendor_user;

create user vendor_user_BestBuy IDENTIFIED BY VENpmsspring2023;
grant VENDOR to vendor_user;

create user vendor_user_Staples IDENTIFIED BY VENpmsspring2023;
grant VENDOR to vendor_user;


Grant CREATE SESSION to  requestor_user;
Grant CREATE SESSION to  procurement_analyst_user;
Grant CREATE SESSION to  vendor_user;
Grant CREATE SESSION to  accountant_user;
Grant CREATE SESSION to  finance_officer_user;
Grant CREATE SESSION to  user_admin_user;
Grant CREATE SESSION to  inventory_admin_user;
Grant CREATE SESSION to  vendor_user_Walmart;
Grant CREATE SESSION to  vendor_user_Wayfair;
Grant CREATE SESSION to  vendor_user_Pricerite;
Grant CREATE SESSION to  vendor_user_BestBuy;
Grant CREATE SESSION to  vendor_user_Staples;
Grant CREATE SESSION to  PMS;

create or replace procedure     pms.usp_approve_requisition
(REQI_ID number)as
v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM PMS.REQUISITION_HEADER where REQ_ID=REQI_ID;
    IF v_count > 0 THEN
UPDATE PMS.REQUISITION_HEADER SET REQ_STATUS ='approved', APPROVAL_DATE = sysdate where REQ_ID=req_id;

INSERT INTO PMS.PURCHASE_ORDER_HEADER (REQ_ID, VENDOR_ID, PO_DATE, PO_STATUS, PO_TOTAL) 
select a.req_id, b.vendor_id, sysdate, 'dispatched', a.quantity*b.price
FROM PMS.requisition_line a
inner join PMS.item_vendor b on a.item_vendor_id=b.item_vendor_id
where a.req_id=REQI_ID;
COMMIT;

    ELSE
        dbms_output.put_line('Value Not Found');
    END IF;
END;
/

create or replace PROCEDURE         pms.usp_create_requisition (
    REQ_CREATOR_ID NUMBER,
    REQI_DESC VARCHAR2,
    ITEM_VENDOR_ID VARCHAR2,
    QUANTITY VARCHAR2,
    REQ_APPROVR_ID NUMBER
) AS
    TYPE string_array IS TABLE OF VARCHAR2(100);
    v_values string_array := string_array();
    q_values string_array := string_array();
    v_count NUMBER;

BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM PMS.ITEM_VENDOR
    WHERE ITEM_VENDOR_ID IN (SELECT TRIM(REGEXP_SUBSTR(ITEM_VENDOR_ID, '[^,]+', 1, LEVEL)) 
                             FROM DUAL
                             CONNECT BY REGEXP_SUBSTR(ITEM_VENDOR_ID, '[^,]+', 1, LEVEL) IS NOT NULL);

    IF v_count > 0 THEN
        INSERT INTO PMS.REQUISITION_HEADER (REQ_APPROVER_ID, REQ_CREATOR_ID, REQ_STATUS, REQ_DESC, APPROVAL_DATE, BUDGET_CHECK, REQ_CREATED)
        VALUES (REQ_APPROVR_ID, REQ_CREATOR_ID, 'pending', REQI_DESC, TO_DATE('02-Jan-23', 'DD-MON-RR'), 'true', SYSDATE);

        SELECT TRIM(REGEXP_SUBSTR(ITEM_VENDOR_ID, '[^,]+', 1, LEVEL)) 
        BULK COLLECT INTO v_values 
        FROM DUAL
        CONNECT BY REGEXP_SUBSTR(ITEM_VENDOR_ID, '[^,]+', 1, LEVEL) IS NOT NULL;

        SELECT TRIM(REGEXP_SUBSTR(QUANTITY, '[^,]+', 1, LEVEL)) 
        BULK COLLECT INTO q_values 
        FROM DUAL
        CONNECT BY REGEXP_SUBSTR(QUANTITY, '[^,]+', 1, LEVEL) IS NOT NULL;

        FOR i IN 1..v_values.COUNT LOOP
            INSERT INTO PMS.REQUISITION_LINE (REQ_ID, ITEM_VENDOR_ID, QUANTITY) 
            SELECT REQ_ID, v_values(i), q_values(i) FROM PMS.REQUISITION_HEADER WHERE REQ_DESC = REQI_DESC;
        END LOOP;

        COMMIT;

    ELSE
        dbms_output.put_line('Value Not Found');
    END IF;

END;
/

create or replace PROCEDURE     pms.USP_GL_ACCOUNT_DATA 
(ACCOUNT_ID NUMBER,
ACCOUNT_NAME VARCHAR2,
ACCOUNT_TYPE VARCHAR2)
AS 
BEGIN

  INSERT INTO PMS.ACCOUNT (ACCOUNT_ID,ACCOUNT_NAME,ACCOUNT_TYPE)
  VALUES (ACCOUNT_ID,ACCOUNT_NAME,ACCOUNT_TYPE);

COMMIT;

END USP_GL_ACCOUNT_DATA;
/

create or replace PROCEDURE     pms.USP_GL_JOURNAL_HEADER_DATA
(JRNL_DATE DATE,
FISCAL_YEAR NUMBER,
ACCOUNTING_PERIOD NUMBER,
STATUS VARCHAR2
) AS 
BEGIN

  INSERT INTO PMS.JOURNAL_HEADER (JRNL_DATE,FISCAL_YEAR,ACCOUNTING_PERIOD,STATUS)
  VALUES (JRNL_DATE,FISCAL_YEAR,ACCOUNTING_PERIOD,STATUS);

  COMMIT;

END USP_GL_JOURNAL_HEADER_DATA;
/

create or replace PROCEDURE      pms.USP_GL_JOURNAL_HEADER_STATUS_UPDATE
(STATUS_VAL VARCHAR2) AS 
BEGIN

  UPDATE PMS.JOURNAL_HEADER SET STATUS=STATUS_VAL;
COMMIT;
END USP_GL_JOURNAL_HEADER_STATUS_UPDATE;
/

create or replace PROCEDURE         pms.USP_GL_JOURNAL_LINE_DATA
(JRNL_ID NUMBER,
ACCOUNT_ID NUMBER,
AMOUNT NUMBER,
DESCRIPTION VARCHAR2,
TRANSACTION_FLAG VARCHAR2) AS 
BEGIN

   INSERT INTO PMS.JOURNAL_LINE (JRNL_ID, ACCOUNT_ID, AMOUNT, DESCRIPTION, TRANSACTION_FLAG)
  VALUES (JRNL_ID, ACCOUNT_ID, AMOUNT, DESCRIPTION, TRANSACTION_FLAG);

COMMIT;
END USP_GL_JOURNAL_LINE_DATA;
/

create or replace PROCEDURE     pms.USP_GL_LEDGER_DATA 
(JRNL_ID NUMBER,
JRNL_LINE_NO NUMBER,
ACCOUNT_ID NUMBER,
ACCOUNTING_DATE DATE,
TRANSACTION_FLAG VARCHAR2,
AMOUNT NUMBER) AS 
BEGIN

  INSERT INTO PMS.LEDGER (JRNL_ID,JRNL_LINE_NO,ACCOUNT_ID,ACCOUNTING_DATE,TRANSACTION_FLAG,AMOUNT)
  VALUES (JRNL_ID,JRNL_LINE_NO,ACCOUNT_ID,ACCOUNTING_DATE,TRANSACTION_FLAG,AMOUNT);

  COMMIT;

END USP_GL_LEDGER_DATA;
/

create or replace PROCEDURE     pms.USP_INVOICE_DATA (
    POrder_ID NUMBER,
   GROSS_AMOUNT NUMBER
)AS 
BEGIN
    INSERT INTO PMS.INVOICE (PO_ID, GROSS_AMT, CREATED_DATE) 
    VALUES (POrder_ID, GROSS_AMOUNT, SYSDATE);

    COMMIT;
END USP_INVOICE_DATA;
/

create or replace PROCEDURE     pms.USP_ITEM_DATA (
    CATEGORY_NAME VARCHAR2,
    ITEM_NAME VARCHAR2,
    ITEM_DESC VARCHAR2
) AS 
BEGIN
    INSERT INTO PMS.ITEM (CATEGORY_NAME, ITEM_NAME, ITEM_DESC) 
    VALUES (CATEGORY_NAME, ITEM_NAME, ITEM_DESC);

    COMMIT;
END USP_ITEM_DATA;
/

create or replace PROCEDURE     pms.USP_ITEM_VENDOR_DATA (
    ITEM_ID NUMBER,
    VENDOR_ID NUMBER,
    PRICE NUMBER,
    MINIMUM_ORDER NUMBER,
    CREATED_DATE VARCHAR2,
    UPDATED_DATE VARCHAR2
) AS
BEGIN
    INSERT INTO PMS.ITEM_VENDOR (ITEM_ID, VENDOR_ID, PRICE, MINIMUM_ORDER, CREATED_DATE, UPDATED_DATE) 
    VALUES (ITEM_ID, VENDOR_ID, PRICE, MINIMUM_ORDER, to_date(CREATED_DATE, 'DD-MON-RR'), to_date(UPDATED_DATE, 'DD-MON-RR'));

    COMMIT;
END USP_ITEM_VENDOR_DATA;
/

create or replace PROCEDURE     pms.USP_PO_HEADER_STATUS_UPDATE (
    ID NUMBER,
    STATUS_VAL VARCHAR2
) AS 
BEGIN
    UPDATE PMS.PURCHASE_ORDER_HEADER SET PO_status = STATUS_VAL WHERE PO_ID=ID;
    COMMIT;
END USP_PO_HEADER_STATUS_UPDATE;
/

create or replace PROCEDURE     pms.USP_PO_LINE_DATA (
    POID NUMBER,
    ReqLineNo NUMBER
)AS 
BEGIN
    INSERT INTO PMS.PURCHASE_ORDER_LINE (PO_ID, REQ_LINE_NO) 
   VALUES (POID,ReqLineNo);


END USP_PO_LINE_DATA;
/

create or replace PROCEDURE           pms.USP_UPDATE_VOUCHER_STATUS (
    ID NUMBER,
    STATUS_VAL VARCHAR2
) AS 
BEGIN
    UPDATE PMS.VOUCHER SET status = STATUS_VAL WHERE VOUCHER_ID=ID;
    COMMIT;
END USP_UPDATE_VOUCHER_STATUS;
/

create or replace PROCEDURE     pms.USP_USER_DATA (
    USERNAME VARCHAR2,
    ROLE VARCHAR2,
    FIRST_NAME VARCHAR2,
    LAST_NAME VARCHAR2,
    STREET VARCHAR2,
    STATE VARCHAR2,
    ZIPCODE NUMBER,
    STATUS_A VARCHAR2,
    PHONE_NO NUMBER,
    EMAIL VARCHAR2,
    STATUS_C VARCHAR2
) AS 
   id number;
BEGIN
    INSERT INTO PMS.USER_TABLE (username,role,first_name,last_name) 
    VALUES (USERNAME,ROLE,FIRST_NAME,LAST_NAME) returning user_id into id;

    INSERT INTO PMS.ADDRESS (STREET, STATE, ZIPCODE, STATUS, ACTOR_ID) 
    VALUES (STREET, STATE, ZIPCODE, STATUS_A, id);

    INSERT INTO PMS.CONTACT (PHONE_NO, EMAIL, STATUS, ACTOR_ID) 
    VALUES (PHONE_NO, EMAIL, STATUS_C, id);

    COMMIT;

END USP_USER_DATA;
/

create or replace PROCEDURE     pms.USP_VENDOR_DATA (
    VENDOR_NAME VARCHAR2,
    ACC_NUM NUMBER,
    STATUS_V VARCHAR2,
    PAYMENT_METHOD VARCHAR2,
    USER_ID NUMBER,
    CURRENCY VARCHAR2,
    STREET VARCHAR2,
    STATE VARCHAR2,
    ZIPCODE NUMBER,
    STATUS_A VARCHAR2,
    PHONE_NO NUMBER,
    EMAIL VARCHAR2,
    STATUS_C VARCHAR2
)AS 
id number;
BEGIN
    INSERT INTO PMS.VENDOR (VENDOR_NAME, ACC_NUM, STATUS, PAYMENT_METHOD, USER_ID, CURRENCY) 
    VALUES (VENDOR_NAME, ACC_NUM, STATUS_V, PAYMENT_METHOD, USER_ID, CURRENCY) returning vendor_id into id;

    INSERT INTO PMS.ADDRESS (STREET, STATE, ZIPCODE, STATUS, ACTOR_ID) 
    VALUES (STREET, STATE, ZIPCODE, STATUS_A, id);

    INSERT INTO PMS.CONTACT (PHONE_NO, EMAIL, STATUS, ACTOR_ID) 
    VALUES (PHONE_NO, EMAIL, STATUS_C, id);

    COMMIT;
END USP_VENDOR_DATA;
/

create or replace PROCEDURE         pms.USP_VOUCHER_DATA (
    InvoiceID NUMBER,
    Status varchar
)AS 
BEGIN
    INSERT INTO PMS.VOUCHER (Invoice_ID, Vendor_id, invoice_date,status,gross_amt,accounting_date) 
    SELECT InvoiceID, b.vendor_id, a.created_date,Status,a.gross_amt,SYSDATE from pms.invoice a inner join pms.purchase_order_header b on a.po_id=b.po_id
    where a.Invoice_ID=InvoiceID;
    commit;

END USP_VOUCHER_DATA;
/

GRANT EXECUTE ON PMS.USP_USER_DATA TO user_admin;
GRANT EXECUTE ON PMS.USP_ITEM_VENDOR_DATA TO VENDOR_USER;
GRANT EXECUTE ON PMS.USP_ITEM_DATA TO INVENTORY_ADMIN;
GRANT EXECUTE ON PMS.USP_VENDOR_DATA TO INVENTORY_ADMIN;
GRANT EXECUTE ON PMS.USP_CREATE_REQUISITION TO REQUESTOR_USER;

GRANT EXECUTE ON PMS.USP_APPROVE_REQUISITION TO PROCUREMENT_ANALYST_USER;
GRANT EXECUTE ON PMS.USP_CREATE_REQUISITION TO REQUESTOR_USER;
GRANT EXECUTE ON PMS.USP_APPROVE_REQUISITION TO PROCUREMENT_ANALYST_USER;
GRANT EXECUTE ON PMS.USP_PO_HEADER_STATUS_UPDATE TO PROCUREMENT_ANALYST_USER;

GRANT EXECUTE ON PMS.USP_VOUCHER_DATA TO ACCOUNTANT_USER;
GRANT EXECUTE ON PMS.USP_INVOICE_DATA TO VENDOR_USER;
GRANT EXECUTE ON PMS.USP_UPDATE_VOUCHER_STATUS TO ACCOUNTANT_USER;

GRANT EXECUTE ON PMS.USP_PO_LINE_DATA TO PROCUREMENT_ANALYST_USER;
GRANT EXECUTE ON PMS.USP_CREATE_REQUISITION TO REQUESTOR_USER;
GRANT EXECUTE ON PMS.USP_GL_JOURNAL_HEADER_DATA TO ACCOUNTANT_USER;
GRANT EXECUTE ON PMS.USP_GL_ACCOUNT_DATA TO ACCOUNTANT_USER;
GRANT EXECUTE ON PMS.USP_GL_JOURNAL_LINE_DATA TO ACCOUNTANT_USER;
GRANT EXECUTE ON PMS.USP_GL_JOURNAL_HEADER_STATUS_UPDATE TO FINANCE_OFFICER_USER;
GRANT EXECUTE ON PMS.USP_GL_LEDGER_DATA TO FINANCE_OFFICER_USER;



--User data creation



exec pms.usp_user_data('requestor_user','REQUESTOR','Hugh','Jackman','Main Street','MA', 2115,'A',8573130698, 'hughjackman@gmail.com', 'A');

exec pms.usp_user_data('procurement_analyst_user','PROCUREMENT_ANALYST','Nicole','Kidman','Elm Street', 'MA', 2215, 'A',8514540231, 'Nicole@hotmail.com', 'A');

exec pms.usp_user_data('vendor_user','VENDOR','Jane','Doe','Maple Ave', 'MA', 3640, 'A',8573130202, 'janedoe@gmail.com', 'A');

exec pms.usp_user_data ('accountant_user','ACCOUNTANT','Johnny','Evans','Oak Street', 'MA', 5501, 'A',8573130605, 'Jonny@yahoo.com', 'A');

exec pms.usp_user_data   ('finance_officer_user','FINANCE_OFFICER','Chris','Hemsworth','Pine St', 'MA', 1125, 'A',8546160202, 'Chrishems@hotmail.com', 'A');

exec pms.usp_user_data   ('user_admin_user','USER_ADMIN','Jessica','Chastian','Cedar Rd', 'MA', 9874, 'A',8574142323, 'jessica@yahoo.com', 'A');

exec pms.usp_user_data   ('inventory_admin_user','INVENTORY_ADMIN','Ajith','Patil','Chestnut St', 'MA', 4751, 'A',8574142324, 'AjitPatil@gmail.com', 'A',);

exec pms.usp_user_data  ('vendor_user_Walmart','VENDOR','Doug','Mcmillon','Cherry Street', 'MA', 4851, 'A',8574142325, 'DougM@yahoo.com', 'A');

exec pms.usp_user_data  ('vendor_user_Wayfair','VENDOR','Neeraj','Shah','Birch Ave', 'MA', 4951, 'A',8574142326, 'NeerajShah@hotmail.com', 'A');

exec pms.usp_user_data ('vendor_user_Pricerite','VENDOR','Joseph','Colalillo','Mission park', 'MA', 41051, 'A',8574142327, 'Joseph@outlook.com', 'A');

exec pms.usp_user_data  ('vendor_user_BestBuy','VENDOR','Corie','Barry','Spruce Street', 'MA', 41151, 'A'8574142328, 'coriebarry@gmail.com', 'A');

exec pms.usp_user_data ('vendor_user_Staples','VENDOR','John','Lederer', 'Peach street', 'MA', 41251, 'A',8574142329, 'JohnLed@yahoo.com', 'A',);

--Item Insert

exec pms.usp_item_data('Goods', 'Dell_Laptop', 'Pavilion_edition');
exec pms.usp_item_data ('Non - goods', 'Xerox_machine', 'BlackWhite');
exec pms.usp_item_data('Goods', 'Dell_Notebook', 'PavilionX_edition');
exec pms.usp_item_data('Goods', 'Macbook', 'Pro');
exec pms.usp_item_data('Goods' , 'iPad', 'Pro');
exec pms.usp_item_data('Goods', 'iPad', 'Air');
exec pms.usp_item_data('Goods', 'ASUS_notebook', 'LightSeries');
exec pms.usp_item_data('Goods', 'ASUS_thinkpad', 'Useries');
exec pms.usp_item_data('Goods', 'Lenovo_Laptop', 'Touchscreen');
exec pms.usp_item_data('Goods', 'Lenovo_tab', 'Yogoseries');
exec pms.usp_item_data('Goods', 'HP_laptop', '360Series');
exec pms.usp_item_data('Goods', 'HP_Printers', 'Colour');
exec pms.usp_item_data('Non - goods', 'chair', 'furniture');
exec pms.usp_item_data('Non - goods', 'desk', 'furniture');
exec pms.usp_item_data('Non - goods', 'Locker', 'furniture');
exec pms.usp_item_data('Goods', 'Microsoft_laptop', 'Kseries');
exec pms.usp_item_data('Goods', 'Samsung_Laptop', 'Pro');
exec pms.usp_item_data('Goods', 'TV', 'OLED');

--Vendor data insert
exec pms.usp_vendor_data('Costco', 1201301200, 'A', 'cash', 3, 'USD','Maple Ave', 'MA', 3640, 'A',8573130202, 'janedoe@gmail.com', 'A')
exec pms.usp_vendor_data('Walmart', 1201301201, 'A', 'cash', 8, 'USD','Cherry Street', 'MA', 4851, 'A',8574142325, 'DougM@yahoo.com', 'A')
exec pms.usp_vendor_data('Wayfair', 1201301202, 'A', 'cash', 9, 'USD','Birch Ave', 'MA', 4951, 'A',8574142326, 'NeerajShah@hotmail.com', 'A')
exec pms.usp_vendor_data('Pricerite', 1201301203, 'A', 'cheque', 10, 'USD','Mission park', 'MA', 41051, 'A',8574142327, 'Joseph@outlook.com', 'A')
exec pms.usp_vendor_data('BestBuy', 1201301204, 'A', 'cheque', 11, 'USD' , 'Spruce Street', 'MA', 41151, 'A',8574142328, 'coriebarry@gmail.com', 'A')
exec pms.usp_vendor_data('Staples', 1201301205, 'A', 'cheque', 12, 'USD','Peach street', 'MA', 41251, 'A',8574142329, 'JohnLed@yahoo.com', 'A')

--Item Vendor data insert
exec pms.usp_item_vendor_data (1, 1, 500, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
exec pms.usp_item_vendor_data(2, 5, 5000, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
exec pms.usp_item_vendor_data(3, 6, 300, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
exec pms.usp_item_vendor_data(4, 1, 1000, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
exec pms.usp_item_vendor_data(5, 5, 800, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
 exec pms.usp_item_vendor_data(6, 1, 750, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
 exec pms.usp_item_vendor_data(7, 1, 400, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
 exec pms.usp_item_vendor_data(8, 4, 250, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
 exec pms.usp_item_vendor_data(9, 1, 250, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
 exec pms.usp_item_vendor_data(10, 2, 850, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
 exec pms.usp_item_vendor_data(11, 1, 850, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
exec pms.usp_item_vendor_data (12, 3, 500, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
 exec pms.usp_item_vendor_data(13, 3, 1000, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
exec pms.usp_item_vendor_data (14, 1, 500, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
 exec pms.usp_item_vendor_data(15, 1, 500, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
 exec pms.usp_item_vendor_data(16, 5, 500, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
 exec pms.usp_item_vendor_data(17, 2, 600, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'));
exec pms.usp_item_vendor_data(9, 5, 250, 1, to_date('01-JAN-23', 'DD-MON-RR'), to_date('23-MAR-23', 'DD-MON-RR'))


/* Requisitions create & Requisition line create */

DECLARE
  req_creator_id NUMBER := 2;
  req_approver_id NUMBER := 1;
  reqi_desc VARCHAR2(100) := 'Purchase nongoods chair(5 qty) and Desk Furniture(5 qty)(CASH) for office use';
  item_vendor_id VARCHAR2(100) := '14,15';
  quantity VARCHAR2(100) := '5,5';
  
BEGIN
  PMS.usp_create_requisition(req_creator_id, reqi_desc, item_vendor_id, quantity, req_approver_id);
END;

DECLARE
  req_creator_id NUMBER := 2;
  req_approver_id NUMBER := 1;
  reqi_desc VARCHAR2(100) := 'Purchase nongoods Xerox Machine(1 qty)(Bank) for 5000';
  item_vendor_id VARCHAR2(100) := '2';
  quantity VARCHAR2(100) := '1';
  
BEGIN
  PMS.usp_create_requisition(req_creator_id, reqi_desc, item_vendor_id, quantity, req_approver_id);
END;

DECLARE
  req_creator_id NUMBER := 2;
  req_approver_id NUMBER := 1;
  reqi_desc VARCHAR2(100) := 'Purchase goods Macbook Air (2 qty) Laptop (CASH) for 2000';
  item_vendor_id VARCHAR2(100) := '4';
  quantity VARCHAR2(100) := '2';
  
BEGIN
  PMS.usp_create_requisition(req_creator_id, reqi_desc, item_vendor_id, quantity, req_approver_id);
END;

DECLARE
  req_creator_id NUMBER := 2;
  req_approver_id NUMBER := 1;
  reqi_desc VARCHAR2(100) := 'Purchase goods Apple Ipad Pro (10 qty) Asus ThinkPad (10 qty)(for Credit) for 10,000';
  item_vendor_id VARCHAR2(100) := '6,9';
  quantity VARCHAR2(100) := '10,10';
  
BEGIN
  PMS.usp_create_requisition(req_creator_id, reqi_desc, item_vendor_id, quantity, req_approver_id);
END;


DECLARE
  req_creator_id NUMBER := 2;
  req_approver_id NUMBER := 1;
  reqi_desc VARCHAR2(100) := 'Purchase goods TV(1),Ipad Pro(4ty),Macbook Air (10 qty)(CASH) for 15000';
  item_vendor_id VARCHAR2(100) := '19,6,4';
  quantity VARCHAR2(100) := '1,4,10';
  
BEGIN
  PMS.usp_create_requisition(req_creator_id, reqi_desc, item_vendor_id, quantity, req_approver_id);
END;

DECLARE
  req_creator_id NUMBER := 2;
  req_approver_id NUMBER := 1;
  reqi_desc VARCHAR2(100) := 'Purchase goods HP Laptop(2 qty) and Printer(1 qty)(CASH) of 2000';
  item_vendor_id VARCHAR2(100) := '12,13';
  quantity VARCHAR2(100) := '2,1';
  
BEGIN
  PMS.usp_create_requisition(req_creator_id, reqi_desc, item_vendor_id, quantity, req_approver_id);
END;

DECLARE
  req_creator_id NUMBER := 2;
  req_approver_id NUMBER := 1;
  reqi_desc VARCHAR2(100) := 'Purchase goods(1500 - Bank Payment) ASUS notebook (3 qty) and thinkpad(3 qty)';
  item_vendor_id VARCHAR2(100) := '8,20';
  quantity VARCHAR2(100) := '3,3';
  
BEGIN
 PMS.usp_create_requisition(req_creator_id, reqi_desc, item_vendor_id, quantity, req_approver_id);
END;

DECLARE
  req_creator_id NUMBER := 2;
  req_approver_id NUMBER := 1;
  reqi_desc VARCHAR2(100) := 'Purchase nongoods (2000 - Bank Payment ) Locker (4 qty)';
  item_vendor_id VARCHAR2(100) := '16';
  quantity VARCHAR2(100) := '4';
  
BEGIN
  PMS.usp_create_requisition(req_creator_id, reqi_desc, item_vendor_id, quantity, req_approver_id);
END;

DECLARE
  req_creator_id NUMBER := 2;
  req_approver_id NUMBER := 1;
  reqi_desc VARCHAR2(100) := 'Purchase goods (3200 $) Macbook Pro on Credit(4 qty)';
  item_vendor_id VARCHAR2(100) := '5';
  quantity VARCHAR2(100) := '4';
  
BEGIN
  PMS.usp_create_requisition(req_creator_id, reqi_desc, item_vendor_id, quantity, req_approver_id);
END;

-- Update Requesition header status to approved & Purchase Order insert

exec pms.usp_approve_requisition(1);
exec pms.usp_approve_requisition(2);
exec pms.usp_approve_requisition(3);
exec pms.usp_approve_requisition(4);
exec pms.usp_approve_requisition(5);
exec pms.usp_approve_requisition(6);
exec pms.usp_approve_requisition(7);
exec pms.usp_approve_requisition(8);
exec pms.usp_approve_requisition(9);

-- Purchase Order Line Insert
exec pms.usp_po_line_data (1, 1);

exec pms.usp_po_line_data (1, 2);

exec pms.usp_po_line_data (2, 3);

exec pms.usp_po_line_data (3, 4);
 
exec pms.usp_po_line_data (4, 5);

exec pms.usp_po_line_data (4, 6);

exec pms.usp_po_line_data (5, 7);

exec pms.usp_po_line_data (6, 8);

exec pms.usp_po_line_data (6, 9);

exec pms.usp_po_line_data (7, 10);

exec pms.usp_po_line_data (7, 11);

exec pms.usp_po_line_data (8, 12);

exec pms.usp_po_line_data (9, 13);

exec pms.usp_po_line_data (10, 14);

exec pms.usp_po_line_data (11, 15);

-- Update Purchase Order status to completed
exec pms.usp_po_header_status_update(1,'completed')
exec pms.usp_po_header_status_update(2,'completed')
exec pms.usp_po_header_status_update(3,'completed')
exec pms.usp_po_header_status_update(4,'completed')
exec pms.usp_po_header_status_update(5,'completed')
exec pms.usp_po_header_status_update(6,'completed')
exec pms.usp_po_header_status_update(7,'completed')
exec pms.usp_po_header_status_update(8,'completed')
exec pms.usp_po_header_status_update(9,'completed')
exec pms.usp_po_header_status_update(10,'completed')
exec pms.usp_po_header_status_update(11,'completed')

--Invoice data insert
EXEC PMS.USP_INVOICE_DATA(1,1000);
EXEC PMS.USP_INVOICE_DATA(2,5000);
EXEC PMS.USP_INVOICE_DATA(3,1000);
EXEC PMS.USP_INVOICE_DATA(4,1000);
EXEC PMS.USP_INVOICE_DATA(5,2000);
EXEC PMS.USP_INVOICE_DATA(6,1750);
EXEC PMS.USP_INVOICE_DATA(7,1500);
EXEC PMS.USP_INVOICE_DATA(8,250);
EXEC PMS.USP_INVOICE_DATA(9,250);
EXEC PMS.USP_INVOICE_DATA(10,500);
EXEC PMS.USP_INVOICE_DATA(11,800);


--Voucher Data insert

exec pms.usp_voucher_data(1,'UNPAID');
exec pms.usp_voucher_data(2,'UNPAID');
exec pms.usp_voucher_data(3,'UNPAID');
exec pms.usp_voucher_data(4,'UNPAID');
exec pms.usp_voucher_data(5,'UNPAID');
exec pms.usp_voucher_data(6,'UNPAID');
exec pms.usp_voucher_data(7,'UNPAID');
exec pms.usp_voucher_data(8,'UNPAID');
exec pms.usp_voucher_data(9,'UNPAID');
exec pms.usp_voucher_data(10,'UNPAID');
exec pms.usp_voucher_data(11,'UNPAID');


exec pms.usp_update_voucher_status(1,'PAID');
exec pms.usp_update_voucher_status(2,'PAID');
exec pms.usp_update_voucher_status(3,'PAID');
exec pms.usp_update_voucher_status(4,'PAID');
exec pms.usp_update_voucher_status(5,'PAID');
exec pms.usp_update_voucher_status(6,'PAID');
exec pms.usp_update_voucher_status(7,'PAID');
exec pms.usp_update_voucher_status(8,'PAID');
exec pms.usp_update_voucher_status(9,'PAID');
exec pms.usp_update_voucher_status(10,'PAID');
exec pms.usp_update_voucher_status(11,'PAID');







---GL ACCOUNT

EXEC PMS.USP_GL_ACCOUNT_DATA  (4000, 'BUSINESS CAPITAL ACCOUNT', 'CAPITAL');
EXEC PMS.USP_GL_ACCOUNT_DATA  (2000, 'BUSINESS LIABILITY ACCOUNT', 'LIABILITY');
EXEC PMS.USP_GL_ACCOUNT_DATA  (1000, 'BUSINESS CASH ACCOUNT', 'ASSET');
EXEC PMS.USP_GL_ACCOUNT_DATA  (1001, 'BUSINESS BANK ACCOUNT', 'ASSET');
EXEC PMS.USP_GL_ACCOUNT_DATA  (1002, 'BUSINESS FURNITURE ACCOUNT', 'ASSET');
EXEC PMS.USP_GL_ACCOUNT_DATA  (1003, 'BUSINESS STATIONARY ACCOUNT', 'ASSET');
EXEC PMS.USP_GL_ACCOUNT_DATA  (1004, 'BUSINESS GOODS ACCOUNT', 'ASSET');



---GL JOURNAL HEADER

EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('01-JAN-23', 'DD-MON-RR'), 2023, 1, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('04-JAN-23', 'DD-MON-RR'), 2023, 1, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('07-JAN-23', 'DD-MON-RR'), 2023, 1, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('09-JAN-23', 'DD-MON-RR'), 2023, 1, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('11-JAN-23', 'DD-MON-RR'), 2023, 1, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('14-JAN-23', 'DD-MON-RR'), 2023, 1, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('27-JAN-23', 'DD-MON-RR'), 2023, 1, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('28-JAN-23', 'DD-MON-RR'), 2023, 1, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('29-JAN-23', 'DD-MON-RR'), 2023, 1, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('01-FEB-23', 'DD-MON-RR'), 2023, 2, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('04-FEB-23', 'DD-MON-RR'), 2023, 2, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('06-FEB-23', 'DD-MON-RR'), 2023, 2, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('07-FEB-23', 'DD-MON-RR'), 2023, 2, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('12-FEB-23', 'DD-MON-RR'), 2023, 2, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('14-FEB-23', 'DD-MON-RR'), 2023, 2, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('17-FEB-23', 'DD-MON-RR'), 2023, 2, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('27-FEB-23', 'DD-MON-RR'), 2023, 2, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('28-FEB-23', 'DD-MON-RR'), 2023, 2, 'Open');
EXEC PMS.USP_GL_JOURNAL_HEADER_DATA  (to_date('01-MAR-23', 'DD-MON-RR'), 2023, 3, 'Open');


--GL JOURNAL LINE DATA

EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (1, 1000, 50000, 'Business Started with CASH', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (1, 1001, 50000, 'Business Started with Bank', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (1, 4000, -100000, 'Business Started with Capital', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (2, 1002, 5000, 'Purchase nongoods chair(5 qty) and Desk Furniture(5 qty)(CASH) for 5000 $', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (2, 1000, -5000, 'Purchase nongoods chair(5 qty) and Desk Furniture(5 qty)(CASH) for 5000 $', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (3, 1003, 5000, 'Purchase nongoods Xerox Machine(1 qty)(Bank) for 5000 $', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (3, 1001, -5000, 'Purchase nongoods Xerox Machine(1 qty)(Bank) for 5000 $', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (4, 1004, 2000, 'purchase goods Macbook Air (2 qty) Laptop (CASH) for 2000 $', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (4, 1000, -2000, 'purchase goods Macbook Air (2 qty) Laptop (CASH) for 2000 $', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (5, 1000, 3000, 'Sold goods Laptop(for CASH) 3000 purchased at 2000 $', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (5, 1004, -2000, 'Sold goods Laptop(for CASH) 3000 purchased at 2000 $', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (5, 4000, -1000, 'Sold goods Laptop(for CASH) 3000 purchased at 2000 $', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (6, 1004, 10000.0, 'purchase goods Apple Ipad Pro (10 qty)and Asus ThinkPad (10 qty)(for Credit) for 10,000 $', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (6, 2000, -10000.0, 'purchase goods Apple Ipad Pro (10 qty)and Asus ThinkPad (10 qty)(for Credit) for 10,000 $', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (7, 2000, 10000.0, 'payment of Apple Ipad and Asus ThinkPad goods (10,000) with CASH', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (7, 1000, -10000.0, 'payment of Apple Ipad and Asus ThinkPad goods (10,000) with CASH', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (8, 1000, 8000, 'sold goods Mobiles of 5000 (purchased) at 8000 $', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (8, 1004, -5000, 'sold goods Mobiles of 5000 (purchased) at 8000 $', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (8, 4000, -3000, 'sold goods Mobiles of 5000 (purchased) at 8000 $', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (9, 4000, 10000.0, 'RENT And Salary payment(CASH) 10,000 $', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (9, 1000, -10000.0, 'RENT And Salary payment(CASH) 10,000 $', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (10, 1000, 34000, 'Opening JRNL FEB', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (10, 1001, 45000, 'Opening JRNL FEB', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (10, 1002, 5000, 'Opening JRNL FEB', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (10, 1003, 5000, 'Opening JRNL FEB', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (10, 1004, 5000, 'Opening JRNL FEB', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (10, 4000, -94000, 'Opening JRNL FEB', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (11, 1004, 15000, 'Purchase goods TV(1),Ipad Pro(4ty),Macbook Air (10 qty)(CASH) for 15000 $', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (11, 1000, -15000, 'Purchase goods TV(1),Ipad Pro(4ty),Macbook Air (10 qty)(CASH) for 15000 $', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (12, 1004, 2000, 'Purchase goods HP Laptop(2 qty) and Printer(1 qty)(CASH) of 2000 $', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (12, 1000, -2000, 'Purchase goods HP Laptop(2 qty) and Printer(1 qty)(CASH) of 2000 $', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (13, 1000, 3000, 'Sold goods of 2000 at 3000(HP Laptop and Printer)', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (13, 1004, -2000, 'Sold goods of 2000 at 3000(HP Laptop and Printer)', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (13, 4000, -1000, 'Sold goods of 2000 at 3000(HP Laptop and Printer)', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (14, 1004, 1500, 'purchase goods(1500 - Bank Payment) ASUS notebook (3 qty)and thinkpad(3 qty)', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (14, 1001, -1500, 'purchase goods(1500 - Bank Payment) ASUS notebook (3 qty)and thinkpad(3 qty)', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (15, 1003, 2000, 'purchase nongoods (2000 - Bank Payment ) Locker (4 qty)', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (15, 1001, -2000, 'purchase nongoods (2000 - Bank Payment ) Locker (4 qty)', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (16, 1004, 3200, 'purchase goods (3200 $) Macbook Pro on Credit(4 qty)', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (16, 2000, -3200, 'purchase goods (3200 $) Macbook Pro on Credit(4 qty)', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (17, 2000, 3200, 'payment of goods (3200) Macbook Pro - Bank Payment', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (17, 1001, -3200, 'payment of goods (3200) Macbook Pro - Bank Payment', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (18, 4000, 10000.0, 'RENT And Salary payment(BANK) 10,000 $', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (18, 1001, -10000.0, 'RENT And Salary payment(BANK) 10,000 $', 'Credit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (19, 1000, 20000, 'Opening JRNL March', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (19, 1001, 28300, 'Opening JRNL March', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (19, 1002, 5000, 'Opening JRNL March', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (19, 1003, 7000, 'Opening JRNL March', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (19, 1004, 24700, 'Opening JRNL March', 'Debit');
EXEC PMS.USP_GL_JOURNAL_LINE_DATA  (19, 4000, -85000, 'Opening JRNL March', 'Credit');








EXEC PMS.USP_GL_JOURNAL_HEADER_STATUS_UPDATE ('POST');


---GL LEDGER DATA---


EXEC PMS.USP_GL_LEDGER_DATA (1, 1, 1000, to_date('1-Jan-23', 'DD-MON-RR'), 'Debit', 50000);
EXEC PMS.USP_GL_LEDGER_DATA (1, 2, 1001, to_date('1-Jan-23', 'DD-MON-RR'), 'Debit', 50000);
EXEC PMS.USP_GL_LEDGER_DATA (1, 3, 4000, to_date('1-Jan-23', 'DD-MON-RR'), 'Credit', -100000);
EXEC PMS.USP_GL_LEDGER_DATA (2, 4, 1002, to_date('4-Jan-23', 'DD-MON-RR'), 'Debit', 5000);
EXEC PMS.USP_GL_LEDGER_DATA (2, 5, 1000, to_date('4-Jan-23', 'DD-MON-RR'), 'Credit', -5000);
EXEC PMS.USP_GL_LEDGER_DATA (3, 6, 1003, to_date('7-Jan-23', 'DD-MON-RR'), 'Debit', 5000);
EXEC PMS.USP_GL_LEDGER_DATA (3, 7, 1001, to_date('7-Jan-23', 'DD-MON-RR'), 'Credit', -5000);
EXEC PMS.USP_GL_LEDGER_DATA (4, 8, 1004, to_date('9-Jan-23', 'DD-MON-RR'), 'Debit', 2000);
EXEC PMS.USP_GL_LEDGER_DATA (4, 9, 1000, to_date('9-Jan-23', 'DD-MON-RR'), 'Credit', -2000);
EXEC PMS.USP_GL_LEDGER_DATA (5, 10, 1000, to_date('11-Jan-23', 'DD-MON-RR'), 'Debit', 3000);
EXEC PMS.USP_GL_LEDGER_DATA (5, 11, 1004, to_date('11-Jan-23', 'DD-MON-RR'), 'Credit', -2000);
EXEC PMS.USP_GL_LEDGER_DATA (5, 12, 4000, to_date('11-Jan-23', 'DD-MON-RR'), 'Credit', -1000);
EXEC PMS.USP_GL_LEDGER_DATA (6, 13, 1004, to_date('14-Jan-23', 'DD-MON-RR'), 'Debit', 10000);
EXEC PMS.USP_GL_LEDGER_DATA (6, 14, 2000, to_date('14-Jan-23', 'DD-MON-RR'), 'Credit', -10000);
EXEC PMS.USP_GL_LEDGER_DATA (7, 15, 2000, to_date('27-Jan-23', 'DD-MON-RR'), 'Debit', 10000);
EXEC PMS.USP_GL_LEDGER_DATA (7, 16, 1000, to_date('27-Jan-23', 'DD-MON-RR'), 'Credit', -10000);
EXEC PMS.USP_GL_LEDGER_DATA (8, 17, 1000, to_date('28-Jan-23', 'DD-MON-RR'), 'Debit', 8000);
EXEC PMS.USP_GL_LEDGER_DATA (8, 18, 1004, to_date('28-Jan-23', 'DD-MON-RR'), 'Credit', -5000);
EXEC PMS.USP_GL_LEDGER_DATA (8, 19, 4000, to_date('28-Jan-23', 'DD-MON-RR'), 'Credit', -3000);
EXEC PMS.USP_GL_LEDGER_DATA (9, 20, 4000, to_date('29-Jan-23', 'DD-MON-RR'), 'Debit', 10000);
EXEC PMS.USP_GL_LEDGER_DATA (9, 21, 1000, to_date('29-Jan-23', 'DD-MON-RR'), 'Credit', -10000);
EXEC PMS.USP_GL_LEDGER_DATA (10, 22, 1000, to_date('1-Feb-23', 'DD-MON-RR'), 'Debit', 34000);
EXEC PMS.USP_GL_LEDGER_DATA (10, 23, 1001, to_date('1-Feb-23', 'DD-MON-RR'), 'Debit', 45000);
EXEC PMS.USP_GL_LEDGER_DATA (10, 24, 1002, to_date('1-Feb-23', 'DD-MON-RR'), 'Debit', 5000);
EXEC PMS.USP_GL_LEDGER_DATA (10, 25, 1003, to_date('1-Feb-23', 'DD-MON-RR'), 'Debit', 5000);
EXEC PMS.USP_GL_LEDGER_DATA (10, 26, 1004, to_date('1-Feb-23', 'DD-MON-RR'), 'Debit', 5000);
EXEC PMS.USP_GL_LEDGER_DATA (10, 27, 4000, to_date('1-Feb-23', 'DD-MON-RR'), 'Credit', -94000);
EXEC PMS.USP_GL_LEDGER_DATA (11, 28, 1004, to_date('4-Feb-23', 'DD-MON-RR'), 'Debit', 15000);
EXEC PMS.USP_GL_LEDGER_DATA (11, 29, 1000, to_date('4-Feb-23', 'DD-MON-RR'), 'Credit', -15000);
EXEC PMS.USP_GL_LEDGER_DATA (12, 30, 1004, to_date('6-Feb-23', 'DD-MON-RR'), 'Debit', 2000);
EXEC PMS.USP_GL_LEDGER_DATA (12, 31, 1000, to_date('6-Feb-23', 'DD-MON-RR'), 'Credit', -2000);
EXEC PMS.USP_GL_LEDGER_DATA (13, 32, 1000, to_date('7-Feb-23', 'DD-MON-RR'), 'Debit', 3000);
EXEC PMS.USP_GL_LEDGER_DATA (13, 33, 1004, to_date('7-Feb-23', 'DD-MON-RR'), 'Credit', -2000);
EXEC PMS.USP_GL_LEDGER_DATA (13, 34, 4000, to_date('7-Feb-23', 'DD-MON-RR'), 'Credit', -1000);
EXEC PMS.USP_GL_LEDGER_DATA (14, 35, 1004, to_date('12-Feb-23', 'DD-MON-RR'), 'Debit', 1500);
EXEC PMS.USP_GL_LEDGER_DATA (14, 36, 1001, to_date('12-Feb-23', 'DD-MON-RR'), 'Credit', -1500);
EXEC PMS.USP_GL_LEDGER_DATA (15, 37, 1003, to_date('14-Feb-23', 'DD-MON-RR'), 'Debit', 2000);
EXEC PMS.USP_GL_LEDGER_DATA (15, 38, 1001, to_date('14-Feb-23', 'DD-MON-RR'), 'Credit', -2000);
EXEC PMS.USP_GL_LEDGER_DATA (16, 39, 1004, to_date('17-Feb-23', 'DD-MON-RR'), 'Debit', 3200);
EXEC PMS.USP_GL_LEDGER_DATA (16, 40, 2000, to_date('17-Feb-23', 'DD-MON-RR'), 'Credit', -3200);
EXEC PMS.USP_GL_LEDGER_DATA (17, 41, 2000, to_date('27-Feb-23', 'DD-MON-RR'), 'Debit', 3200);
EXEC PMS.USP_GL_LEDGER_DATA (17, 42, 1001, to_date('27-Feb-23', 'DD-MON-RR'), 'Credit', -3200);
EXEC PMS.USP_GL_LEDGER_DATA (18, 43, 4000, to_date('28-Feb-23', 'DD-MON-RR'), 'Debit', 10000);
EXEC PMS.USP_GL_LEDGER_DATA (18, 44, 1001, to_date('28-Feb-23', 'DD-MON-RR'), 'Credit', -10000);
EXEC PMS.USP_GL_LEDGER_DATA (19, 45, 1000, to_date('1-Mar-23', 'DD-MON-RR'), 'Debit', 20000);
EXEC PMS.USP_GL_LEDGER_DATA (19, 46, 1001, to_date('1-Mar-23', 'DD-MON-RR'), 'Debit', 28300);
EXEC PMS.USP_GL_LEDGER_DATA (19, 47, 1002, to_date('1-Mar-23', 'DD-MON-RR'), 'Debit', 5000);
EXEC PMS.USP_GL_LEDGER_DATA (19, 48, 1003, to_date('1-Mar-23', 'DD-MON-RR'), 'Debit', 7000);
EXEC PMS.USP_GL_LEDGER_DATA (19, 49, 1004, to_date('1-Mar-23', 'DD-MON-RR'), 'Debit', 24700);
EXEC PMS.USP_GL_LEDGER_DATA (19, 50, 4000, to_date('1-Mar-23', 'DD-MON-RR'), 'Credit', -85000);








