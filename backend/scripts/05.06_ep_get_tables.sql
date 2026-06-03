set search_path to public;

/*
    End point pour récupérer les tables d'une réservation
*/

create or replace function get_tables_for_reservation(reservation_id int)
returns table (
            id int,
            restaurant int,
            table_number int,
            capacity int) as
$$
    begin
        perform auth.check_logged();
        return query
        select t.id, t.restaurant, t.table_number, t.capacity from tables t join reservation_tables rt on t.id = rt."table" where rt.reservation = reservation_id;
    end;
$$ language plpgsql security definer;

grant execute on function get_tables_for_reservation(reservation_id int) to manager;


create or replace function table_has_conflict_for_reservation(table_id int, reservation_id int)
    returns boolean as
$$
    declare
        current_res reservations;
        current_slot_duration int;
    begin
        select r.* into current_res from reservations r where r.id = reservation_id;
        if current_res.id is null then
            return true;
        end if;

        select rest.slot_duration into current_slot_duration from restaurants rest where rest.id = current_res.restaurant;

        return exists( select 1 from reservation_tables rt join reservations res on res.id = rt.reservation where rt."table" = table_id
                                                            and res.restaurant = current_res.restaurant and res.id <> current_res.id
                                                            and res.status in ('pending', 'confirmed')
                                                            and res.datetime < (current_res.datetime + current_slot_duration * interval '1 minute')
                                                            and (res.datetime + current_slot_duration * interval '1 minute') > current_res.datetime);
    end;
$$ language plpgsql security definer;

grant execute on function table_has_conflict_for_reservation(table_id int, reservation_id int) to manager;

create or replace function get_all_available_tables(reservation_id int)
    returns table (
        id int,
        restaurant int,
        table_number int,
        capacity int) as
$$
    declare
        current_restaurant int;
    begin
        perform auth.check_logged();
        select r.restaurant into current_restaurant from reservations r where r.id = reservation_id;
        return query
            select t.id, t.restaurant, t.table_number, t.capacity from tables t
                    where t.restaurant = current_restaurant and not table_has_conflict_for_reservation(t.id, reservation_id)
                    order by t.table_number;
    end;
$$ language plpgsql security definer;

grant execute on function get_all_available_tables(reservation_id int) to manager;

create or replace function assign_tables_to_reservation(reservation_id int, guests int, table_ids int[])
    returns void as
$$
declare
    total_capacity int;
begin

    perform auth.check_logged();

--     select coalesce(sum(t.capacity), 0) into total_capacity from tables t join reservations r
--                                                                 on r.restaurant = t.restaurant where r.id = reservation_id and t.id = any(table_ids);
--     if total_capacity < guests then
--         raise exception 'Selected tables capacity is not sufficient';
--     end if;

    delete from reservation_tables where reservation = reservation_id;

    insert into reservation_tables(reservation, "table") select reservation_id, unnest(table_ids);

    update reservations set status = 'confirmed'::status_type where id = reservation_id;
end;
$$ language plpgsql security definer;

grant execute on function assign_tables_to_reservation(reservation_id int, guests int, table_ids int[]) to manager;

-- select * from assign_tables_to_reservation(1, 2, array[1]);