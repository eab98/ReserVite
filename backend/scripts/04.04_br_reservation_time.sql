set search_path to public;

/*
    (BR-04) L'heure d'une réservation confirmée, terminée ou en attente doit être comprise entre l'heure de début et
    l'heure de fin d'un service pour le même jour de la semaine.
 */

create or replace function reservation_time() returns trigger as
    $$
        begin
            if(old.status in ('pending', 'confirmed', 'cancelled'))
                and exists(select *
                           from services s, restaurants resto, reservations resa
                           where resa.restaurant = resto.id and s.restaurant = resto.id
                           and extract(isodow from resa.datetime) = s.day_of_week
                           and (resa.datetime < s.start_time or resa.datetime > s.end_time)
                           ) then
                raise exception 'Reservation time outside of service window';
            end if;

        end;
    $$language plpgsql;