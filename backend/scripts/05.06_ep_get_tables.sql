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
        select * from tables where restaurant = reservation_id;
    end;
$$ language plpgsql security definer;

grant execute on function get_tables_for_reservation(reservation_id int) to manager;