set search_path to public;

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

