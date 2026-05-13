set search_path to public;

create or replace function does_email_exist(email text)
       returns boolean as
       $$
    begin
        return exists(select 1 from users where users.email = does_email_exist.email);
    end;
       $$language plpgsql;

grant execute on function does_email_exist to anon;