set search_path to public;

/*
 ==========================================
 TABLE USERS
 ==========================================
 */

create or replace function check_user_role() returns trigger as
$$
     begin
         if new.role != users.role then
             raise exception 'Cannot change user role';
         end if;
         return new;
     end;
$$ language plpgsql;

create or replace trigger check_unchanged_user_role
    before update on users
    for each row
execute procedure check_user_role();

/*
 ==========================================
 TABLE TABLES
 ==========================================
 */

create or replace function update_restaurant_table()
returns trigger as
    $$
    begin
        if(LOWER(trim(new.restaurant)) is distinct from LOWER(trim(old.restaurant))) then
            raise exception 'Cannot modify the restaurant';
        end if;
        return new;
    end;
    $$language plpgsql;

create trigger forbid_update_restaurant_table
    before update of restaurant on tables for each row
    execute function update_restaurant_table();

/*
 ==========================================
 TABLE SERVICES
 ==========================================
 */

 create or replace function restaurant_update() returns trigger as
$$
     begin
         if new.restaurant != services.restaurant then
             raise exception 'Cannot modify the restaurant for a service';
         end if;
     end;
$$ language plpgsql;

create or replace trigger check_restaurant_update
    before update on services
    for each row
execute procedure restaurant_update();

/*
 ==========================================
 TABLE RESERVATIONS
 ==========================================
 */

 /*
  On ne peut pas modifier le resto ou client d'une resa
  */

create or replace function resa_update() returns trigger as
       $$
       begin
           if((LOWER(trim(new.restaurant)) is distinct from LOWER(trim(old.restaurant)))
                  || LOWER(trim(new.client)) is distinct from LOWER(trim(old.client)))then
               raise exception 'Cannot modify the restaurant or the cleint of an ongoing reservation';
           end if;
           return new;
       end;
       $$language plpgsql;

create or replace trigger check_resa_update
    before update on reservations
    for each row
    execute procedure resa_update();
