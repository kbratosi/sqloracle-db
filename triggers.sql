create or replace trigger patient_id
before insert on PATIENTS
for each row

begin
    select pat_id_seq.nextval
    into :new.PATIENT_ID
    from dual;
end;
/

create or replace trigger address_id
before insert on ADDRESSES
for each row

begin
    select addr_id_seq.nextval
    into :new.ID
    from dual;
end;
/

create or replace trigger job_id
before insert on JOB_LIST
for each row

begin
    select job_id_seq.nextval
    into :new.JOB_ID
    from dual;
end;
/

create or replace trigger medicine_id
before insert on MEDICINES
for each row

begin
    select med_id_seq.nextval
    into :new.MEDICINE_ID
    from dual;
end;
/

create or replace trigger appointment_id
before insert on APPOINTMENTS
for each row

begin
    select app_id_seq.nextval
    into :new.APP_ID
    from dual;
end;
/

create or replace trigger prescriptions_id
before insert on PRESCRIPTIONS
for each row

begin
    select pres_id_seq.nextval
    into :new.RECEIPT_ID
    from dual;
end;
/

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

create or replace trigger employees_data
before insert on EMPLOYEES
for each row

declare
    phone number(9);
    address varchar(64);
    postal varchar(6);
    house_number number(3);
    flat number (2);
    tmp number(3);
    
begin
    phone := dbms_random.value( 100000000, 999999999 );
    select count(*) into tmp from ADDRESSES;
    tmp := dbms_random.value( 1, tmp );
    select a.ADDRESS, a.POSTAL_CODE into address, postal from ADDRESSES a where a.ID = tmp;
    house_number := dbms_random.value( 1, 300 );
    if( postal = '95-100' ) then
        flat := dbms_random.value( 1, 10 );
    else
        flat := null;
    end if;
    select emp_id_seq.nextval, phone, address, house_number, flat 
    into :new.EMPLOYEE_ID, :new.PHONE_NUMBER, :new.ADDRESS, :new.HOUSE_NUMBER, :new.FLAT_NUMBER 
    from dual;
end;
/

create or replace trigger job_archive_init
after insert on SALARIES
for each row

declare
    start_date date;
begin
    start_date := to_date( trunc( dbms_random.value( to_char( date '1993-05-27', 'J' ), to_char( sysdate, 'J' ) ) ), 'J' );
    insert into JOB_ARCHIVE values( :new.EMPLOYEE_ID, :new.SALARY, start_date, null );
end;
/

create or replace trigger job_archive_update
before update on SALARIES
for each row

begin
    update JOB_ARCHIVE set JOB_END = sysdate where EMPLOYEE_ID = :old.EMPLOYEE_ID and JOB_END is null;
    delete from JOB_ARCHIVE where JOB_BEGIN >= JOB_END; -- if change of salary did not come into fruition at all (active for day or less, then changed) -> delete unnecessary records
    insert into JOB_ARCHIVE values( :old.EMPLOYEE_ID, :new.SALARY, sysdate + 1, null );
end;
/

create or replace trigger appointments_trg
before insert on APPOINTMENTS
for each row

declare
    appointments_count int;
    tmp int;
begin
    select count(*) into appointments_count from APPOINTMENTS;
    if(appointments_count > 0) then
        if( :new.APP_DATE > to_date( to_char( sysdate, 'yyyy-mm-dd' ) || '00:00', 'yyyy-mm-dd hh24:mi') ) then
            select count(*) into tmp from (select * from APPOINTMENTS a
                inner join MEDICAL_PERSONNEL m on a.EMPLOYEE_ID = m.EMPLOYEE_ID where a.PATIENT_ID = :new.PATIENT_ID)
                where JOB_ID = ( select JOB_ID from MEDICAL_PERSONNEL where EMPLOYEE_ID = :new.EMPLOYEE_ID );
            if( tmp > 0 ) then   
                raise_application_error( -20000, 'Patient is already on the list to such a doctor.' );
            end if;
        end if;     -- patient can get an appointment to a doctor of such type
        select count(*) into tmp from( select APP_DATE from APPOINTMENTS where EMPLOYEE_ID = :new.EMPLOYEE_ID )
            where APP_DATE = :new.APP_DATE;
        if( tmp > 0 ) then
             raise_application_error( -20001, 'Appointment date occupied.');
        end if;     -- patient can get an appointment to a doctor 
        select count(*) into tmp from( select APP_DATE from APPOINTMENTS where PATIENT_ID = :new.PATIENT_ID )
            where APP_DATE = :new.APP_DATE;
        if( tmp > 0 ) then
             raise_application_error( -20002, 'Patient already has/had an appointment at this time.');
        end if;
    end if;
end;
/