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



-- select * from get_matching_restaurants('BRU');