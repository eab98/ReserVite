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
        where resa.restaurant = resto.id and resa.client = auth.id();
    end;
    $$language plpgsql security definer;;

grant execute on function get_my_reservations() to authenticated;

