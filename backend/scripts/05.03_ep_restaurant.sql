set search_path to public;

/*
     End points restaurant
 */

create or replace function get_matching_restaurants(filter varchar)
    returns table
        (id int,
        name varchar,
        address varchar,
        city varchar,
        phone varchar,
        description text,
        rating double precision,
        price_range int,
        slot_duration int,
        latest_reservation timestamp) as
$$
     declare substr varchar;
     begin
         perform auth.check_logged();
         substr = '%' || lower(filter) || '%';
         return query
         select distinct r.id, r.name, r.address, r.city, r.phone, r.description, r.rating, r.price_range, r.slot_duration, res.datetime
         from restaurants r join reservations res on r.id = res.restaurant
                  where lower(r.name) like substr or lower(r.description) like substr or lower(r.city) like substr
                  and res.datetime > ALL(select resa.datetime from reservations resa where resa.restaurant = r.id and resa.client = auth.id())
         order by res.datetime DESC;
     end;
$$ language plpgsql security definer;

grant execute on function get_matching_restaurants(filter varchar) to authenticated;

create or replace function get_my_restaurants()
    returns table
        (id int,
         name varchar,
         address varchar,
         city varchar,
         phone varchar,
         description text,
         rating double precision,
         price_range int,
         slot_duration int) as
$$
    begin
        perform auth.check_logged();
        return query
        select * from restaurants where restaurants.id in (select rm.restaurant from restaurant_managers rm where rm.manager = auth.id());
    end;
$$ language plpgsql security definer;

grant execute on function get_my_restaurants() to manager;



-- select * from get_matching_restaurants('BRU');