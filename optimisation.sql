EXECUTE DBMS_STATS.GATHER_TABLE_STATS ('kbratosi', 'PATIENTS');

drop index pat_idx2;
create index pat_idx2 on PATIENTS(PATIENT_ID, P_SURNAME);

--
-- experiment 1: 2 indexes enabled
--

alter index pat_pk visible;
alter index pat_idx2 visible;

-- index range scan, cost = 7, uses pat_pk
explain plan for
select PATIENT_ID from PATIENTS where PATIENT_ID < 500;
select * from table (dbms_xplan.display);

-- index range scan, cost = 23, uses pat_pk
explain plan for
select PATIENT_ID from PATIENTS
    where PATIENT_ID between 1 and 2500;
select * from table (dbms_xplan.display);

-- index range scan, cost = 79, uses pat_pk
explain plan for
select PATIENT_ID from PATIENTS
    where PATIENT_ID between 1 and 9500;
select * from table (dbms_xplan.display);

-- index fast full scan, cost = 79, uses pat_pk
explain plan for
select PATIENT_ID from PATIENTS;
select * from table (dbms_xplan.display);

-- table access full, cost = 353, no indexes
explain plan for
select /*+ no_index(PATIENTS, pat_pk, pat_idx2) */ PATIENT_ID from PATIENTS;
select * from table (dbms_xplan.display);

-- index fast full scan, cost = 79, uses pat_pk
explain plan for
select /* +first_rows */ PATIENT_ID from PATIENTS;
select * from table (dbms_xplan.display);

-- table access by index rowid, cost = 92 plus index range scan, cost = 19, uses pat_pk
explain plan for
select P_NAME from PATIENTS
where PATIENT_ID between 1 and 2000;
select * from table (dbms_xplan.display);

-- table access full, cost = 353, no indexes used
explain plan for
select PESEL from PATIENTS
where P_NAME like 'A%';
select * from table (dbms_xplan.display);

--
-- experiment 2: pat_pt disabled, pat_idx2 enabled 
--

alter index pat_pk invisible;
alter index pat_idx2 visible;

-- index range scan, cost = 10, uses pat_idx2
explain plan for
select PATIENT_ID from PATIENTS where PATIENT_ID < 500;
select * from table (dbms_xplan.display);

-- index range scan, cost = 41, uses pat_idx2
explain plan for
select PATIENT_ID from PATIENTS
    where PATIENT_ID between 1 and 2500;
select * from table (dbms_xplan.display);

-- index range scan, cost = 149, uses pat_idx2
explain plan for
select PATIENT_ID from PATIENTS
    where PATIENT_ID between 1 and 9600;
select * from table (dbms_xplan.display);

-- index fast full scan, cost = 149, uses pat_idx2
explain plan for
select PATIENT_ID from PATIENTS;
select * from table (dbms_xplan.display);

-- index range scan, cost = 33, uses pat_idx2
explain plan for
select P_SURNAME from PATIENTS
where PATIENT_ID between 1 and 2000;
select * from table (dbms_xplan.display);

-- index fast full scan, cost = 149, uses pat_idx2
explain plan for
select P_SURNAME from PATIENTS
where P_SURNAME like 'Ko%';
select * from table (dbms_xplan.display);

-- table access by index rowid, cost = 106 plus index range scan, cost = 33, uses pat_idx2
explain plan for
select P_NAME from PATIENTS
where PATIENT_ID between 1 and 2000;
select * from table (dbms_xplan.display);

-- table access full, cost = 353, no indexes used
explain plan for
select PESEL from PATIENTS
where P_NAME like 'A%';
select * from table (dbms_xplan.display);

--
-- experiment 3: both indexes disabled
--

alter index pat_pk invisible;
alter index pat_idx2 invisible;

-- table access full, cost = 353
explain plan for
select PATIENT_ID from PATIENTS where PATIENT_ID < 500;
select * from table (dbms_xplan.display);

-- table access full, cost = 353
explain plan for
select PATIENT_ID from PATIENTS;
select * from table (dbms_xplan.display);

-- table access full, cost = 353
explain plan for
select P_NAME from PATIENTS
where PATIENT_ID between 1 and 2000;
select * from table (dbms_xplan.display);

-- table access full, cost = 353
explain plan for
select PESEL from PATIENTS
where P_NAME like 'A%';
select * from table (dbms_xplan.display);

--
-- joins
--

execute dbms_stats.gather_table_stats('kbratosi', 'APPOINTMENTS');
execute dbms_stats.gather_table_stats('kbratosi', 'PRESCRIPTIONS');

-- hash join, cost = 24
explain plan for
select a.EMPLOYEE_ID
from PRESCRIPTIONS p join APPOINTMENTS a
on p.APP_ID = a.APP_ID;
select * from table (dbms_xplan.display);

-- merge join, cost = 25
explain plan for
select /*+ use_merge(p, a) */ a.EMPLOYEE_ID
from PRESCRIPTIONS p join APPOINTMENTS a
on p.APP_ID = a.APP_ID;
select * from table (dbms_xplan.display);

-- nested loops, cost = 5012
explain plan for
select /*+ use_nl(p, a) */ a.EMPLOYEE_ID
from PRESCRIPTIONS p join APPOINTMENTS a
on p.APP_ID = a.APP_ID;
select * from table (dbms_xplan.display);

--

-- merge join, cost = 991
explain plan for
select p.RECEIPT_ID, a.EMPLOYEE_ID
from PRESCRIPTIONS p, APPOINTMENTS a
where a.APP_ID < 200;
select * from table (dbms_xplan.display);

-- hash join, cost = 17
explain plan for
select /*+ use_hash(p, a) */ p.RECEIPT_ID, a.EMPLOYEE_ID
from PRESCRIPTIONS p join APPOINTMENTS a 
on p.APP_ID = a.APP_ID
where a.APP_ID < 200;
select * from table (dbms_xplan.display);

-- nested loops, cost = 991
explain plan for
select /*+ use_nl(p, a) */ p.RECEIPT_ID, a.EMPLOYEE_ID
from PRESCRIPTIONS p, APPOINTMENTS a
where a.APP_ID < 200;
select * from table (dbms_xplan.display);

--

-- nested loops, cost = 12
explain plan for
select a.EMPLOYEE_ID, p.RECEIPT_ID
from (select * from PRESCRIPTIONS where RECEIPT_ID < 10) p 
join APPOINTMENTS a on a.APP_ID = p.APP_ID;
select * from table (dbms_xplan.display);

-- hash join, cost = 16
explain plan for
select /*+ use_hash(p, a) */ a.EMPLOYEE_ID, p.RECEIPT_ID
from (select * from PRESCRIPTIONS where RECEIPT_ID < 10) p 
join APPOINTMENTS a on a.APP_ID = p.APP_ID;
select * from table (dbms_xplan.display);

-- merge join, cost = 17
explain plan for
select /*+ use_merge(p, a) */ a.EMPLOYEE_ID, p.RECEIPT_ID
from (select * from PRESCRIPTIONS where RECEIPT_ID < 10) p 
join APPOINTMENTS a on a.APP_ID = p.APP_ID;
select * from table (dbms_xplan.display);

alter index pat_pk visible;
alter index pat_idx2 visible;