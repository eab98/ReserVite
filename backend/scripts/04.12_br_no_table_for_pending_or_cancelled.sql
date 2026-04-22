set search_path to public;

/*
 ==========================================

 (BR-12) Une réservation en attente ou annulée ne peut être associée à aucune une table.

 ==========================================
 */

create or replace function check_no_tables() returns trigger as
$$
    begin
        if new.reservation in (select reservations.id from reservations where reservations.status in ('pending', 'cancelled')) then
            raise exception 'A table cannot be associated with a pending or cancelled reservation';
        end if;
        return new;
    end;
$$ language plpgsql;

create or replace trigger check_nothing_for_pending_or_cancelled
before insert or update on reservation_tables
    execute procedure check_no_tables();