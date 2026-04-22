set search_path to public;

/*
    (BR-09) Une nouvelle réservation doit avoir le status pending. Une réservation existante ne peut pas revenir "en arrière"
    dans son cycle de vie. Les transitions autorisées sont :
        pending -> confirmed
        pending -> cancelled
        confirmed -> completed
        confirmed -> cancelled
 */

 create or replace function status_rules() returns trigger as
     $$
     begin
         if(tg_op = 'INSERT' and new.status is distinct from 'pending') then
             raise exception 'Status must be pending for a new reservation';
         else if(tg_op = 'UPDATE' and ((old.status = 'pending' and new.status not in ('confirmed', 'cancelled'))
                     or (old.status = 'confirmed' and new.status not in ('completed', 'cancelled')))) then
             raise exception 'Status of the reservation cannot go backwards';
         else if(old.status in ('completed', 'cancelled')) then
             raise exception 'Cannot modify a completed or cancelled reservation';
         end if;
         end if;
         end if;

     end;
     $$language plpgsql;

create or replace trigger check_status_rules
    before insert or update of status on reservations
    for each row
    execute function status_rules();