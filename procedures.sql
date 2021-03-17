create or replace procedure generate_patients( amount number )
is
    sex int;
    unisex int;
    
	type MALE_NAMES is table of varchar(16);
    mal_n MALE_NAMES;
    type FEMALE_NAMES is table of varchar(16);
    fem_n FEMALE_NAMES;
    
    type MALE_SURNAMES is table of varchar(32);
    mal_s MALE_SURNAMES;
    type FEMALE_SURNAMES is table of varchar(32);
    fem_s FEMALE_SURNAMES;
    type UNISEX_SURNAMES is table of varchar(32);
    uni_s UNISEX_SURNAMES;
    
    mal_name_count int;
    fem_name_count int;
    mal_surn_count int;
    fem_surn_count int;
    uni_surn_count int;
    
    n_id int;
    s_id int;
    
    ins_name varchar(16);
    ins_surname varchar(32);
    
	birth_date date;
    b_y number(4);
    b_m number(2);
    b_d number(2);
    rand789 number(3);
    rand11 number(1);
    pesel varchar(11);
    
    phone number(9);
    
    address varchar(64);
    postal varchar(6);
    house_number number(3);
    flat number(2);
    tmp number(3);
    
begin
    if(amount > 0) then
        mal_n := MALE_NAMES( 'Adam', 'Bartlomiej', 'Bartosz', 'Boleslaw', 'Cyryl', 'Damian', 'Dominik', 'Edward', 'Franciszek',
        'Geralt', 'Grzegorz', 'Horacy', 'Hubert', 'Ignacy', 'Jakub', 'Jan', 'Kazimierz', 'Konrad', 'Krzysztof', 'Lech', 'Leslaw', 
        'Maksymilian', 'Mateusz', 'Milosz', 'Nikifor', 'Norbert', 'Olgierd', 'Patryk', 'Piotr', 'Robert', 'Stefan', 'Szymon', 
        'Tadeusz', 'Tomasz', 'Tymoteusz', 'Walery', 'Witold', 'Zdzislaw','Zenon');
        
        fem_n := FEMALE_NAMES( 'Ada', 'Aldona', 'Alicja', 'Anastazja', 'Barbara', 'Cecylia', 'Daria', 'Dominika', 'Ewa', 'Ewelina', 
        'Genowefa', 'Hanna', 'Jagoda', 'Janina', 'Jolanta', 'Julia', 'Kaja', 'Katarzyna', 'Liwia', 'Lucja', 'Malgorzata', 
        'Martyna', 'Monika', 'Natalia', 'Oliwia', 'Olga', 'Patrycja', 'Renata', 'Sonia', 'Sara', 'Tatjana', 'Ula', 'Weronika', 
        'Zofia', 'Zuzanna' );
        
        mal_s := MALE_SURNAMES( 'Borowski', 'Boniecki', 'Bukowski', 'Chylinski', 'Czajkowski', 'Galczynski', 'Grzybowski',
        'Kobuszewski', 'Kowalski', 'Lisowski', 'Lutoslawski', 'Majewski', 'Nosowski', 'Poznanski', 'Pulawski', 'Radoszewski', 
        'Skoneczny', 'Staszewski', 'Tarczynski', 'Wysocki', 'Wyszynski', 'Zawadzki', 'Zebrowski' );
       
        fem_s := FEMALE_SURNAMES( 'Borowska', 'Boniecka', 'Bukowska', 'Chylinska', 'Czajkowska', 'Grzybowska', 'Kobuszewska', 
        'Kowalska', 'Lipinska', 'Lisowska', 'Lutoslawska', 'Majewska', 'Nosowska', 'Poznanska','Pulawska', 'Radoszewska', 
        'Raniszewska', 'Tarczynska', 'Skoneczna', 'Wysocka', 'Wyszynska', 'Zawadzka', 'Zebrowska' );
        
        uni_s := UNISEX_SURNAMES( 'Andersen', 'Anielewicz', 'Aleksiejuk', 'Baszta', 'Bond', 'Buczek', 'Ciecierzyca', 'Dolas', 
        'Dyzma', 'Edziuk', 'Ferency', 'Frank', 'Fratczak', 'Galazka', 'Gombrowicz', 'Graczyk', 'Gzegzolka', 'Hiacynt', 
        'Himilsbach', 'Janiak', 'Klamka', 'Koniecpolski', 'Kostka', 'Kozakiewicz', 'Krawczyk', 'Kukulka', 'Maczek', 'Maklowicz', 
        'Malysz', 'Marczuk', 'Masluch', 'Matwiejuk', 'Nowak', 'Ochota', 'Okrasa', 'Organek', 'Pietrzak', 'Psikuta', 'Rebajlo', 
        'Rubinstein', 'Strauss', 'Szyc', 'Terpial', 'Tokarczuk', 'Zimmerman', 'Zawialow', 'Zyla' );
        
        mal_name_count := mal_n.count;
        fem_name_count := fem_n.count;
        mal_surn_count := mal_s.count;
        fem_surn_count := fem_s.count;
        uni_surn_count := uni_s.count;
        
        for i in 1..amount loop
            sex := dbms_random.value( 0, 9 );
            if( mod( sex, 2 ) = 1 ) then                      -- 0 - female, 1 - male
                n_id := dbms_random.value( 1, mal_name_count );
                ins_name := mal_n( n_id );
            else
                n_id := dbms_random.value( 1, fem_name_count );
                ins_name := fem_n( n_id );
            end if;
            
            unisex := dbms_random.value( 0, 1 );
            if( unisex = 1 ) then 
                s_id := dbms_random.value( 1, uni_surn_count );
                ins_surname := uni_s( s_id );
            else
                if( mod( sex, 2 ) = 1 ) then
                    s_id := dbms_random.value( 1, mal_surn_count );
                    ins_surname := mal_s( s_id );
                else
                    s_id := dbms_random.value( 1, fem_surn_count );
                    ins_surname := fem_s( s_id );
                end if;
            end if;
            
            birth_date := to_date( trunc( dbms_random.value( to_char( date '1900-01-01', 'J' ), to_char( sysdate, 'J' ) ) ), 'J' );
            b_y := extract( year from birth_date );
            b_m := extract( month from birth_date );
            if( b_y <= 1900 ) then
                b_m := b_m + 80;
            elsif( b_y > 2000 ) then
                b_m := b_m + 20;
            end if;
            b_y := floor( mod( extract( year from birth_date ), 100 ) );
            b_d := extract( day from birth_date );
            
            rand789 := dbms_random.value( 100, 999 );
            rand11 := dbms_random.value( 0, 9 );
            
            pesel := to_char( b_y, 'FM00' ) || to_char( b_m, 'FM00' ) || to_char(  b_d, 'FM00' ) || rand789 || sex || rand11;
            
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
            begin
                insert into PATIENTS values( -1, ins_surname, ins_name, pesel, phone, address, house_number, flat );
            exception
                when others then null;
            end;
        end loop;
    end if;
end;
/

create or replace procedure generate_appointments( attempts number )
is
    patient_count number;
    patient_ID number;
    personnel_ID number;
    app_hour int;
    quarter int;
    app_date date;
    
begin
    select count(*) into patient_count from PATIENTS;
    for i in 1..attempts loop
        patient_ID := dbms_random.value( 1, patient_count );
        select EMPLOYEE_ID into personnel_ID from( select EMPLOYEE_ID from MEDICAL_PERSONNEL order by dbms_random.value ) where rownum = 1;
        app_hour := dbms_random.value( 8, 15 );
        quarter := dbms_random.value( 0, 3 );
        app_date := to_date( trunc( dbms_random.value( to_char( sysdate - 14, 'J' ), to_char( sysdate + 14, 'J' ) ) ), 'J' );
        if( to_char(app_date, 'd') = 6 ) then
            app_date := app_date + dbms_random.value( 1, 6 );
        elsif( to_char(app_date, 'd') = 7 ) then
            app_date := app_date + dbms_random.value( 0, 5 );
        end if;
        app_date := to_date( to_char( app_date, 'yyyy-mm-dd' ) || '00:00', 'yyyy-mm-dd hh24:mi') + app_hour/24 + quarter * 15/24/60;
        begin
            insert into APPOINTMENTS values( -1, personnel_ID, patient_ID, app_date );
        exception
            when others then null;
        end;
    end loop;
end;
/

create or replace procedure generate_prescriptions( amount number )
is
    medicine_count number;
    medicine_id number;
    appointment_id number;
begin
    select count(*) into medicine_count from MEDICINES;
    for i in 1..amount loop
        medicine_id := dbms_random.value( 1, medicine_count );
        select APP_ID into appointment_id from( select APP_ID from APPOINTMENTS sample(1) where APP_DATE < sysdate order by dbms_random.value ) where rownum = 1;
        insert into PRESCRIPTIONS values( -1, appointment_id, medicine_id );
    end loop;
end;
/