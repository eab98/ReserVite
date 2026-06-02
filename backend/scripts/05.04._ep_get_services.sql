set search_path to public;

/*
     End point get_services
 */

 create or replace function get_services(restaurant_id int)
 returns table (
     id INTEGER,
     restaurant INTEGER,
     day_of_week INTEGER,
     start_time TIME,
     end_time TIME )
 as
$$
     begin
         return query
         select * from services where services.restaurant = restaurant_id;
     end;
$$ language plpgsql security definer;

grant execute on function get_services(restaurant_id int) to authenticated;