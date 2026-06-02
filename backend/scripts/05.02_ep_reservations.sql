set search_path to public;

/*
     End points reservations
 */

create or replace function get_my_reservations()
    returns table
        (id int,
        name varchar,
        status status_type,
        city varchar,
        datetime timestamp,
        number_of_guests int) as
    $$
    begin
        perform auth.check_logged();
        return query
        select resa.id, resto.name, resa.status, resto.city, resa.datetime, resa.number_of_guests
        from reservations resa, restaurants resto
        where resa.restaurant = resto.id and resa.client = auth.id()
        order by resa.datetime DESC ;
    end;
    $$language plpgsql security definer;;

grant execute on function get_my_reservations() to authenticated;

--drop function get_reservation_details(_id int);

create or replace function get_reservation_details(_id int)
       returns table
       (
       id int,
       name varchar,
       status status_type,
       address varchar,
       city varchar,
       datetime timestamp,
       number_of_guests int,
       phone varchar,
       special_request text) as
    $$
    begin
        perform auth.check_logged();
        return query
        select resa.id, resto.name, resa.status, resto.address, resto.city, resa.datetime, resa.number_of_guests, resto.phone, resa.special_requests
        from reservations resa, restaurants resto
        where resa.restaurant = resto.id and resa.id = _id;
    end;
    $$language plpgsql security definer ;

grant execute on function get_reservation_details to authenticated;

create or replace function check_restaurant_closed(_restaurant int, _date date)
    returns boolean as
    $$
    begin
        return not exists(SELECT 1
                          FROM services s
                          where s.restaurant = _restaurant and s.day_of_week = extract(isodow from _date));
    end;
    $$language plpgsql security definer;

--on regarde à quel service un certain TimeStamp correspond, retourne service par restaurant pour un certain jour de la semaine
create or replace function get_service_for_datetime(_restaurant int, _date timestamp)
    returns services as
    $$
    declare
        serv services;
    begin
        select *
        from services s
        where s.restaurant = _restaurant and s.day_of_week = extract(isodow from _date)::int
            and _date::time>= s.start_time and _date::time < s.end_time into serv;
        return serv;
    end;

    $$language plpgsql security definer;


--on regarde si le client n'a pas déjà réservé pour ce même service au même jour et au même resto
create or replace function check_existing_reservation_for_service(_restaurant int, _date timestamp)
    returns boolean as
    $$
    declare
        serv services;
        client_id int;
    begin
        serv := get_service_for_datetime(_restaurant, _date);

        if serv.id is null then
            return false;
        end if;

        client_id := auth.id();

        return exists(
            SELECT 1
            FROM reservations resa
            WHERE resa.client = client_id and resa.restaurant = _restaurant and resa.datetime::date = _date::date
            and resa.datetime::time >= serv.start_time and resa.datetime::time < serv.end_time and resa.status in ('pending', 'confirmed')
        );


    end;
    $$language plpgsql security definer;

--on regarde s'il existe une table disponible pour un nombre de guest donné pour un créneau donné

create or replace function check_capacity(_restaurant int, _number_of_guests int, _date timestamp)
    returns boolean as
    $$
    begin
        return exists(
            SELECT 1
            FROM tables t
            WHERE t.restaurant = _restaurant and t.capacity>=_number_of_guests
              and t.id not in (select rt."table"
                               from reservation_tables rt, reservations resa
                               where rt."table" = t.id and rt.reservation = resa.id
                               and resa.datetime = _date
                               and resa.status in ('pending', 'confirmed'))

        );
    end;
    $$language plpgsql security definer;

--on regarde si un certain slot est disponible pour cette date la pour ce nombre de guests
create or replace function check_slot_available(_restaurant int, _date timestamp, _number_of_guests int)
    returns boolean as
    $$
    declare
        serv services;
    begin
        serv := get_service_for_datetime(_restaurant, _date);

        if(serv.id is null) then
            return false;
        end if;

        if (check_existing_reservation_for_service(_restaurant, _date)) then
            return false;
        end if;

        if not (check_capacity(_restaurant, _number_of_guests, _date)) then
            return false;
        end if;

        return true;
    end;
    $$language plpgsql security definer;

--on cherche les slots disponibles pour une date donnée, si aucun slot il faut un message d'erreur spécifique

create or replace function get_available_slots_for_date(_restaurant int, _date timestamp, _number_of_guests int)
returns table(slot_datetime timestamp) as
    $$
    declare
        _slot_duration int;

    begin
        perform auth.check_logged();

        select slot_duration into _slot_duration
        from restaurants where restaurants.id=_restaurant;

        --attention ici, date c est la date du jour, on a besoin de l'heure de debut du service, pour que ca fasse un datetime on doi additionner

        return query
        select slot_candidate
        from (
            select generate_series(
                    (_date + s.start_time)::timestamp,
                    (_date + s.end_time)::timestamp - (_slot_duration || ' minutes')::interval,
                    (_slot_duration || ' minutes')::interval
                    ) as slot_candidate
            from services s
            where s.restaurant=_restaurant and s.day_of_week = extract(isodow from _date)::int
            ) slot_candidates
            where check_slot_available(_restaurant, slot_candidate, _number_of_guests);

    end;
    $$language plpgsql security definer ;
grant execute on function get_available_slots_for_date(int, timestamp, int) to authenticated;

--on regrde la raison spécifique pour laquelle in l'y a pas de spot disponible
create or replace function get_specific_error_if_no_slots(_restaurant int, _date timestamp)
returns no_slots_reason as
    $$
    declare
        _total_services int;
        _booked_services int;
    begin
        perform auth.check_logged();

        if(check_restaurant_closed(_restaurant, _date::date)) then
            return 'closed';
        end if;


        select count(*) into _total_services
        from services s
        where s.restaurant = _restaurant
          and s.day_of_week = extract(isodow from _date)::int;

        select count(*) into _booked_services
        from services s
        where s.restaurant = _restaurant
          and s.day_of_week = extract(isodow from _date)::int
          and exists (
            select 1 from reservations r
            where r.restaurant = _restaurant
              and r.client = auth.id()
              and r.datetime::date = _date::date
              and r.datetime::time >= s.start_time
              and r.datetime::time <  s.end_time
              and r.status in ('pending','confirmed')
        );

        if _total_services > 0 and _booked_services = _total_services then
            return 'already_booked_service';
        end if;

        return 'no_capacity';

    end;
    $$language plpgsql security definer ;

grant execute on function get_specific_error_if_no_slots(int, timestamp) to authenticated;

--
-- --on cherche le premier slot dispo qui s'affiche une fois à l'ouverture de la page
-- --attention ici limit 1 permet d'avoir au moins et max une reponse donc on cherche jusqu'a ce qu'on trouve
-- create or replace function get_first_available_slot(_restaurant int, _date timestamp, _number_of_guests int)
-- returns timestamp as
--     $$
--     declare
--         _first_available_slot timestamp;
--     begin
--         select slot_datetime into _first_available_slot
--         from get_available_slots_for_date(_restaurant, _date, _number_of_guests)
--         order by slot_datetime
--         limit 1;
--
--     end;
--     $$language plpgsql security definer ;

select auth.login_for_test('brlacroix@epfc.eu');
select * from get_available_slots_for_date(3, '2024-12-09', 2);
select get_specific_error_if_no_slots(3, '2024-12-09');
select auth.logout_for_test();