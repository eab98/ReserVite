set search_path to public;

/*
    (BR-06) Une table ne peut pas faire l'objet
    de deux réservations terminées ou confirmées pour une même date et un même service.
 */

/*
 Table reservation:
 INSERT:
 UPDATE: oui, si le status de la resa change
 DELETE:

 Table reservation_tables:
 INSERT: non, nouvelle resa donc statut "pending"
 UPDATE: oui, si la table change
 DELETE: non

 Table tables:
 */


 create or replace function resa_per_table() returns trigger as
     $$
     begin
         if (new.status in ('completed', 'confirmed') and (new is distinct from old) and
             exists (select *
              from reservations r1,
                   reservations r2,
                   reservation_tables rt1,
                   reservation_tables rt2,
                   restaurants resto,
                   services s
              where r1.id = rt1.reservation and r2.id = rt2.reservation and rt1."table" = rt2."table" and r1.datetime =r2.datetime and
                    rt1.reservation != rt2.reservation and r1.restaurant = resto.id and r2.restaurant = resto.id and
                    resto.id = s.restaurant and extract(isodow from r1.datetime::time)=s.day_of_week
                                                and (r1.datetime::time >= s.start_time
                                                 and r2.datetime::time >= s.start_time
                                                 and r1.datetime::time <= s.end_time
                                                 and r2.datetime::time <= s.end_time)
                    )
             ) then
             raise exception 'Two reservations cannot exist for the same table on the same date for the same service';
         end if;
     end;
     $$language plpgsql;

create or replace trigger check_resa_per_table_res
    before update on reservations
    for each row
    execute function resa_per_table();

create or replace trigger check_resa_per_table_res
    before update on reservation_tables
    for each row
    execute function resa_per_table();