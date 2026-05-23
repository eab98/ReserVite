set search_path to public;

/*
 End points singup
 */


create or replace function check_email_available(email text)
       returns boolean as
       $$
    begin
        return not exists(select 1 from users where trim(lower(users.email)) = trim(lower(check_email_available.email)));
    end;
       $$language plpgsql;

grant execute on function check_email_available to anon;


create or replace function check_full_name_available(full_name text)
       returns boolean as
    $$
    begin
        return not exists(select 1 from users where trim(lower(users.full_name)) = trim(lower(check_full_name_available.full_name)));
    end;
    $$language plpgsql;

grant execute on function check_full_name_available to anon;