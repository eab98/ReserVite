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
        slot_duration int) as
$$
     declare substr varchar;
     begin
         perform auth.check_logged();
         substr = '%' || lower(filter) || '%';
         return query
         select * from restaurants r where lower(r.name) like substr or lower(r.description) like substr or lower(r.city) like substr;
     end;
$$ language plpgsql security definer;

grant execute on function get_matching_restaurants(filter varchar) to authenticated;

create or replace function get_my_restaurants(manager_id int)
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
        return query
        select * from restaurants where restaurants.id in (select rm.restaurant from restaurant_managers rm where rm.manager = manager_id)
    end;
$$ language plpgsql security definer;



-- select * from get_matching_restaurants('BRU');