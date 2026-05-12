set search_path to public;

/*
 ==========================================

(BR-14) Une réservation ne peut pas être créée dans le passé (ne doit être vérifié qu'au moment de la création).
    remarque : on prend en compte le temps simulé si défini, sinon on prend le temps réel
 ==========================================
 */


create or replace function resa_created_past() returns trigger as
    $$
    begin
        if exists(select st.simulated_time
                  from system_time st) then
            if exists(select st.simulated_time
                      from system_time st, reservations r
                      where r.id = new.id and r.datetime < st.simulated_time) then
                raise exception 'Cannot create a reservation in the past';
            end if;
        else
            if new.datetime < now() then
                raise exception 'Cannot create a reservation in the past';
            end if;
        end if;
        return new;
    end;
    $$language plpgsql;

