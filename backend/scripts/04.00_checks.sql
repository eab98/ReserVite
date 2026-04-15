set search_path to public;

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

