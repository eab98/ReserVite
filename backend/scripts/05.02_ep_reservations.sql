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

--on regarde à quel service un certain TimeStamp correspond
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

    $$language plpgsql;


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

create or replace function check_slot