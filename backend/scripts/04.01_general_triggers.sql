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

create or replace trigger check_unchanged_user_role
before update on users
    for each row
    execute procedure check_user_role();
