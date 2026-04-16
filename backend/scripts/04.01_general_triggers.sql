set search_path to public;

/*
 ==========================================
 TABLE USERS
 ==========================================
 */

create or replace function check_user_role() returns trigger as
$$
     begin
         if new.role == users.role then
             update users set role = new.role;
        else
             raise exception 'Cannot change user role';
         end if;
     end;
$$ language plpgsql;
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

create or replace trigger check_unchanged_user_role
before update on users
    for each row
    execute procedure check_user_role();


create trigger forbid_update_restaurant_table
    before update of restaurant on tables for each row
    execute function update_restaurant_table();

