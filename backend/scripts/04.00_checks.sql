set search_path to public;

/*
 ==========================================
 TABLE USERS
 ==========================================
 */

 alter table users drop constraint if exists name_length;

alter table users add constraint name_length
check ( length(trim(users.full_name) >= 3 ) NOT VALID;

/*
 ==========================================
 TABLE RESTAURANTS
 ==========================================
 */
alter table restaurants drop constraint if exists name_length;

alter table restaurants add constraint name_length
check ( length(trim(restaurants.name)) >= 5 ) not valid;

alter table restaurants drop constraint if exists address_length;

alter table restaurants add constraint address_length
    check ( length(trim(restaurants.address)) >= 5 ) not valid;

alter table restaurants drop constraint if exists city_length;

alter table restaurants add constraint city_length
    check ( length(trim(restaurants.city)) >= 3 ) not valid;

alter table restaurants drop constraint if exists check_phone_number_format;

alter table restaurants add constraint check_phone_number_format
    check ( restaurants.phone ~ '^(?:0\d(?:\s?\d{3})(?:\s?\d{2}){2}|0\d{2}(?:\s?\d{2}){3})$' ) not valid;
/*check ( restaurants.phone ~ '^0\d(?:\s?\d{3})(?:\s?\d{2}){2}$' || restaurants.phone ~ '^0\d{2}(?:\s?\d{2}){3}$' ||
    restaurants.phone ~ '^04\d{2}(?:\s?\d{2}){3}$') not valid;*/

alter table restaurants drop constraint if exists description_length;

alter table restaurants add constraint description_length
    check ( restaurants.description is null || length(trim(restaurants.description) >= 10) ) not valid;

alter table restaurants drop constraint if exists rating_check;

alter table restaurants add constraint rating_check
    check ( restaurants.rating is null || (restaurants.rating >= 0.0 && restaurants.rating <= 5.0)) not valid;

alter table restaurants drop constraint if exists price_range_check;

alter table restaurants add constraint price_range_check
    check ( restaurants.price_range is null || (restaurants.price_range >= 1 && restaurants.price_range <= 4) ) not valid;

alter table restaurants drop constraint if exists slot_check;

alter table restaurants add constraint slot_check
    check ( restaurants.slot_duration in (10, 15, 20, 30, 60) ) not valid;

/**************************************************************
  Table tables
 **************************************************************/
alter table tables
    drop constraint if exists nb_table_unique;

alter table tables
    add constraint nb_table_unique unique (table_number) not valid ;

alter table tables
    drop constraint if exists nb_table_value;

alter table tables
    add constraint nb_table_value
        check (tables.table_number >0);

alter table tables
    drop constraint if exists capacity_check;

alter table tables
    add constraint capacity_check
    check(tables.capacity>0) not valid;


