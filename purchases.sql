create schema if not exists purchases;

set search_path to purchases, public;

drop table if exists category cascade;
create table if not exists category
(
    CATEGORY_ID SERIAL PRIMARY KEY,
    CATEGORY_NM VARCHAR(30) NOT NULL UNIQUE,
    TYPE        VARCHAR(10) DEFAULT 'SOLID'
);

drop table if exists product cascade;
create table if not exists product
(
    PRODUCT_ID     SERIAL PRIMARY KEY,
    CATEGORY_ID    SERIAL,
    PRICE          INTEGER CHECK (PRICE >= 0),
    BEST_BEFORE_DT DATE CHECK (BEST_BEFORE_DT >= now()::date),
    NEED_FREEZE    BOOLEAN DEFAULT TRUE,
    MASS           INTEGER,
    AMOUNT         INTEGER,
    VOLUME         INTEGER,
    MASS_TOTAL     INTEGER,
    AMOUNT_TOTAL   INTEGER,
    VOLUME_TOTAL   INTEGER,

    CONSTRAINT FK_category FOREIGN KEY (CATEGORY_ID)
        REFERENCES category (CATEGORY_ID)
        ON DELETE CASCADE
        ON UPDATE RESTRICT
);

drop table if exists room cascade;
create table if not exists room
(
    ROOM_ID  SERIAL PRIMARY KEY,
    ROOM_NUM INTEGER NOT NULL UNIQUE
);

drop table if exists person cascade;
create table if not exists person
(
    PERSON_ID SERIAL PRIMARY KEY,
    PERSON_NM VARCHAR(30) NOT NULL,
    ROOM_ID   INTEGER,

    CONSTRAINT FK_room FOREIGN KEY (ROOM_ID)
        REFERENCES room (ROOM_ID)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

drop table if exists storage cascade;
create table if not exists storage
(
    STORAGE_ID   SERIAL PRIMARY KEY,
    STORAGE_TYPE VARCHAR(30) NOT NULL,
    ROOM_ID      INTEGER,

    CONSTRAINT FK_room FOREIGN KEY (ROOM_ID)
        REFERENCES room (ROOM_ID)
        ON DELETE CASCADE
        ON UPDATE RESTRICT
);

drop table if exists product_x_storage;
create table if not exists product_x_storage
(
    PRODUCT_ID SERIAL PRIMARY KEY,
    STORAGE_ID SERIAL REFERENCES storage (STORAGE_ID),

    CONSTRAINT foreign_key_to_product_id
        FOREIGN KEY (PRODUCT_ID)
            REFERENCES product (PRODUCT_ID)
            ON DELETE CASCADE
            ON UPDATE RESTRICT
);

drop table if exists purchase cascade;
create table if not exists purchase
(
    PURCHASE_ID  SERIAL PRIMARY KEY,
    BUYER_ID     SERIAL,
    PURCHASE_DTM TIMESTAMP CHECK ( PURCHASE_DTM >= now() ),
    SHOP_NM      VARCHAR(30) NOT NULL,

    CONSTRAINT FK_buyer
        FOREIGN KEY (BUYER_ID)
            REFERENCES person (PERSON_ID)
            ON DELETE CASCADE
            ON UPDATE RESTRICT
);

drop table if exists product_x_purchase;
create table if not exists product_x_purchase
(
    PRODUCT_ID  SERIAL PRIMARY KEY,
    PURCHASE_ID SERIAL,

    CONSTRAINT foreign_key_to_product_id
        FOREIGN KEY (PURCHASE_ID)
            REFERENCES purchase (PURCHASE_ID)
            ON DELETE CASCADE
            ON UPDATE RESTRICT
);

drop table if exists product_x_person;
create table if not exists product_x_person
(
    PERSON_ID  SERIAL,
    PRODUCT_ID SERIAL,

    CONSTRAINT foreign_keys
        FOREIGN KEY (PERSON_ID)
            REFERENCES person (PERSON_ID)
            ON DELETE CASCADE
            ON UPDATE RESTRICT,
        FOREIGN KEY (PRODUCT_ID)
            REFERENCES product (PRODUCT_ID)
            ON DELETE CASCADE
            ON UPDATE RESTRICT
);

alter table product_x_person
    add constraint primary_keys
        primary key (PERSON_ID, PRODUCT_ID);
