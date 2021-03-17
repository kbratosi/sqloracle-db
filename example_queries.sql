-- data generation
exec generate_patients( 50000 );
exec generate_appointments( 5000 );
exec generate_prescriptions( 5000 );
commit;

-- oblicz sum� miesi�cznych p�ac pracownik�w
select sum( SALARY ) from SALARIES;

-- oblicz �redni� pensj� lekarza rodzinnego
select round( avg( SALARY ), 0 ) from ( 
    select SALARY from SALARIES s
        inner join EMPLOYEES e on s.EMPLOYEE_ID = e.EMPLOYEE_ID
        inner join JOB_LIST j on e.JOB_ID = j.JOB_ID
        where j.JOB_TITLE = 'Lekarz rodzinny' );

-- wy�wietl ilu pacjentom w ciagu ostatnich 5 dni przepisano Cirrus, z podzialem na adres
select count(RECEIPT_ID), p.ADDRESS from PATIENTS p 
    join APPOINTMENTS a on p.PATIENT_ID = a.PATIENT_ID
    join PRESCRIPTIONS r on r.APP_ID = a.APP_ID
    join MEDICINES m on m.MEDICINE_ID = r.MEDICINE_ID
    where m.MEDICINE_NAME = 'Cirrus'
    and a.APP_DATE > sysdate - 5
    group by p.ADDRESS
    order by p.ADDRESS;

alter session set nls_date_format = 'DD/MM/YYYY';

-- wy�wietl ilo�� pacjent�w mieszkajacych przy ul. Konstantynowskiej, zapisanych na wizyty przez najbli�sze 10 dni
select count(*) "Ilo��", trunc(a.APP_DATE) "Data" from PATIENTS p 
    join APPOINTMENTS a on p.PATIENT_ID = a.PATIENT_ID
    where p.ADDRESS = 'Konstantynowska'
    group by trunc(a.APP_DATE)
    having trunc(a.APP_DATE) <= trunc(sysdate + 10)
    and trunc(a.APP_DATE) > trunc(sysdate)
    order by trunc(a.APP_DATE);

-- wy�wietl ilo�� pacjent�w zapisanych na wizyt� do Pani/Pana Prawdy przez najbli�szy tydzie� 
select count(*) "Ilo��", trunc(a.APP_DATE) "Data" from PATIENTS p 
    join APPOINTMENTS a on p.PATIENT_ID = a.PATIENT_ID
    join EMPLOYEES e on e.EMPLOYEE_ID = a.EMPLOYEE_ID
    where e.E_SURNAME = 'Prawda'
    group by trunc(a.APP_DATE)
    having trunc(a.APP_DATE) < trunc(sysdate + 7)
    and trunc(a.APP_DATE) >  trunc(sysdate)
    order by trunc(a.APP_DATE);
    
alter session set nls_date_format = 'DD/MM/YYYY HH24:MI';