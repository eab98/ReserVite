set search_path to public;

/*
 ==========================================
 TABLE USERS
 ==========================================
 */

alter table users add constraint name_length
check ( length(trim(users.full_name) >= 3 ) NOT VALID;

alter table users add constraint password_check
check (users.password ~ '^(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?=.*[,;.:!?/$%&@#]).{8,}$') NOT VALID;

/*
 ==========================================
 TABLE RESTAURANTS
 ==========================================
 */

alter table restaurants add constraint name_length
check ( length(trim(restaurants.name)) >= 5 ) not valid;

alter table restaurants add constraint address_length
    check ( length(trim(restaurants.address)) >= 5 ) not valid;

alter table restaurants add constraint city_length
    check ( length(trim(restaurants.city)) >= 3 ) not valid;

alter table restaurants add constraint description_length
check ( restaurants.description is null || length(trim(restaurants.description) >= 10) ) not valid;
