alter session set nls_date_format = 'DD/MM/YYYY HH24:MI';

create table PATIENTS(
    PATIENT_ID int,
    P_SURNAME varchar(32) not NULL,
    P_NAME varchar(16) not NULL,
    PESEL varchar(11) unique not NULL,
    PHONE_NUMBER int unique not NULL,
    ADDRESS varchar(64),
    HOUSE_NUMBER int,
    FLAT_NUMBER int,
    constraint pat_pk primary key( PATIENT_ID )
);

create table ADDRESSES(
    ID int primary key,
    ADDRESS varchar(64) unique not NULL,
    POSTAL_CODE varchar(6) not NULL
);

create table EMPLOYEES(
    EMPLOYEE_ID int primary key,
    E_SURNAME varchar(32) not NULL,
    E_NAME varchar(16) not NULL,
    JOB_ID int not NULL,
    OFFICE_NUMBER int,
    PHONE_NUMBER int,
    ADDRESS varchar(64),
    HOUSE_NUMBER int,
    FLAT_NUMBER int
);
                        
create table JOB_LIST(
    JOB_ID int primary key,
    JOB_TITLE varchar(64) not NULL
);
             
create table APPOINTMENTS(
    APP_ID int primary key,
    EMPLOYEE_ID int not NULL,
    PATIENT_ID int not NULL,
    APP_DATE date not NULL
);
                           
create table JOB_ARCHIVE( 
    EMPLOYEE_ID int not NULL,
    SALARY int not NULL,
    JOB_BEGIN date not NULL,
    JOB_END date
);

create table SALARIES(
    EMPLOYEE_ID int not NULL,
    SALARY int not NULL
);
                          
create table PRESCRIPTIONS( 
    RECEIPT_ID int primary key,
    APP_ID int not NULL,
    MEDICINE_ID int not NULL
);

create table MEDICINES( 
    MEDICINE_ID int primary key,
    MEDICINE_NAME varchar(32)
);

alter table EMPLOYEES add constraint emp_addr_fk foreign key( ADDRESS ) references ADDRESSES( ADDRESS );
alter table EMPLOYEES add constraint emp_job_fk foreign key( JOB_ID ) references JOB_LIST( JOB_ID );

alter table PATIENTS add constraint pesel_format check( regexp_like( PESEL, '\d{11}' ));
alter table PATIENTS add constraint pat_addr_fk foreign key( ADDRESS ) references ADDRESSES( ADDRESS );

alter table ADDRESSES add constraint postal_format check( regexp_like( POSTAL_CODE, '\d{2}-\d{3}' ));

alter table APPOINTMENTS add constraint app_emp_fk foreign key( EMPLOYEE_ID ) references EMPLOYEES( EMPLOYEE_ID );
alter table APPOINTMENTS add constraint app_pat_fk foreign key( PATIENT_ID ) references PATIENTS( PATIENT_ID );

alter table JOB_ARCHIVE add constraint arch_emp_fk foreign key( EMPLOYEE_ID ) references EMPLOYEES( EMPLOYEE_ID );

alter table SALARIES add constraint sal_emp_fk foreign key( EMPLOYEE_ID ) references EMPLOYEES( EMPLOYEE_ID );

alter table PRESCRIPTIONS add constraint pres_app_fk foreign key( APP_ID ) references APPOINTMENTS( APP_ID );
alter table PRESCRIPTIONS add constraint pres_med_fk foreign key( MEDICINE_ID ) references MEDICINES( MEDICINE_ID );

create sequence pat_id_seq start with 1;
create sequence job_id_seq start with 1;
create sequence med_id_seq start with 1;
create sequence addr_id_seq start with 1;
create sequence emp_id_seq start with 1;
create sequence app_id_seq start with 1;
create sequence pres_id_seq start with 1;