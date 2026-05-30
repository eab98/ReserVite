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