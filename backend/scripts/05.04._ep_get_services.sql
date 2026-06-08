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

create or replace function set_service(service_id int, new_start TIME, new_end TIME)
returns void as
$$
    begin
        update services set start_time = new_start, end_time = new_end where id = service_id;
    end;
$$ language plpgsql security definer;

grant execute on function set_service(service_id int, new_start TIME, new_end TIME) to manager;

create or replace function add_service(restaurant_id int, week_day int, new_start_time TIME, new_end_time TIME)
returns void as
$$
    begin
        insert into services (restaurant, day_of_week, start_time, end_time) VALUES (restaurant_id, week_day, new_start_time, new_end_time);
    end;
$$ language plpgsql security definer;

grant execute on function add_service(restaurant_id int, week_day int, new_start_time TIME, new_end_time TIME) to manager;