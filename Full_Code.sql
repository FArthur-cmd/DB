create schema consumtion;

set search_path to consumtion, purchases;
/*
Структура, аналогичная такой же в другой части.
Может быть использован этот прототип, но тогда теряется часть функциональности,
так как данные о покупках и о ценах хранятся в другой половине.

-- Сущность продукт в холодильнике (связь с другой частью проекта)
create table if not exists ProductInStorage (
    ProductID INTEGER PRIMARY KEY,
    StorageID INTEGER
);
*/
-- List of all cooked dishes
create table if not exists CookedDish
(
    Dish        SERIAL PRIMARY KEY,
    TimeSpent   TIME,
    ExpiryDate  TIMESTAMP,
    CountEaten  INTEGER        NOT NULL DEFAULT 0,
    Finished    BOOLEAN        NOT NULL DEFAULT FALSE,
    Cost        DECIMAL(10, 2) NOT NULL DEFAULT 0,
    Recipe      INTEGER        NOT NULL,
    CookingDate TIMESTAMP      NOT NULL DEFAULT now()::timestamp,
    CONSTRAINT PositiveCost CHECK (Cost >= 0)
);

alter table CookedDish
    add column Name CHAR(30) NOT NULL DEFAULT 'Snack';

--Recipe to understand what products are used
create table if not exists Recipe
(
    Dish       INTEGER,
    Ingredient INTEGER,
    Count      INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT FK_Ingredient FOREIGN KEY (Ingredient) REFERENCES purchases.product_x_storage (product_id)
        ON UPDATE RESTRICT -- We don't want to see changes in this field
        ON DELETE CASCADE, -- we should delete all
    CONSTRAINT FK_Dish FOREIGN KEY (Dish) REFERENCES CookedDish (Dish)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

ALTER table Recipe
    ADD CONSTRAINT "DishIng" PRIMARY KEY (Dish, Ingredient);

/*
This part can be used for isolated functionality, but we have project for two people and that is why
I prefer to use already created part.

drop table if exists Person cascade;
-- Person info
create table if not exists Person (
    PersonID SERIAL PRIMARY KEY,
    Name     CHAR(20) NOT NULL,
    ROOM_ID   INTEGER
);
*/

ALTER TABLE purchases.person
    ADD COLUMN Surname CHAR(30) NOT NULL DEFAULT 'Undefined';

-- connecting cooker table
create table if not exists Cooker
(
    PersonID INTEGER,
    DishID   INTEGER,
    CONSTRAINT FK_Person FOREIGN KEY (PersonID) REFERENCES purchases.Person (person_id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,
    CONSTRAINT FK_Dish FOREIGN KEY (DishID) REFERENCES CookedDish (Dish)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

ALTER table Cooker
    ADD CONSTRAINT "CookePK" PRIMARY KEY (PersonID, DishID);

-- consumtions
create table if not exists Consumtions
(
    ConsumtionID SERIAL PRIMARY KEY,
    PersonID     INTEGER NOT NULL,
    DT           TIMESTAMP DEFAULT now()::timestamp,
    CONSTRAINT FK_Person FOREIGN KEY (PersonID) REFERENCES purchases.Person (person_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- product and cosumtion references
create table if not exists ProductInConsumtion
(
    ConsumtionID INTEGER,
    ProductID    INTEGER,
    Count        INTEGER DEFAULT 0,

    CONSTRAINT FK_Cons FOREIGN KEY (ConsumtionID) REFERENCES Consumtions (ConsumtionID)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,
    CONSTRAINT FK_Prod FOREIGN KEY (ProductID) REFERENCES purchases.product_x_storage (product_id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,
    CONSTRAINT IsPos CHECK (Count >= 0)
);

ALTER table ProductInConsumtion
    ADD CONSTRAINT "PrInCo" PRIMARY KEY (ConsumtionID, ProductID);

--dishes in storage
create table if not exists DishInStorage
(
    Dish    INTEGER PRIMARY KEY,
    Storage INTEGER,
    CONSTRAINT FK_Dish FOREIGN KEY (Dish) REFERENCES CookedDish (Dish)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Dish in consumtion
create table if not exists DishInConsumtion
(
    ConsumtionID INTEGER,
    DishID       INTEGER,
    CONSTRAINT FK_Cons FOREIGN KEY (ConsumtionID) REFERENCES Consumtions (ConsumtionID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT FK_Dish FOREIGN KEY (DishID) REFERENCES DishInStorage (Dish)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

ALTER table DishInConsumtion
    ADD CONSTRAINT "DishInComPK" PRIMARY KEY (ConsumtionID, DishID);

-------------------------------------------------------------------------------------------
-- Fill tables
-------------------------------------------------------------------------------------------
-- Foreign tables
INSERT INTO purchases.room(room_num)
VALUES (205),
       (213);

SELECT *
from purchases.room;


-------------------------------------------------
INSERT INTO purchases.Person(PERSON_NM, room_id, surname)
VALUES ('Artur', 1, 'Fil'),
       ('Ivan', 1, 'Kudr'),
       ('Aleksey', 1, 'Kudr'),
       ('Anastas', 1, 'Belia'),
       ('Kamil', 2, 'Lotful'),
       ('Seva', 2, 'Undefined');

Select *
from purchases.Person;
----------------------------------------------

insert into purchases.purchase
values (DEFAULT,
        (select PERSON_ID
         from purchases.person
         where PERSON_NM = 'Artur'),
        '2021-12-24 11:23:43'::timestamp, '5ka');
insert into purchases.purchase
values (DEFAULT,
        (select PERSON_ID
         from purchases.person
         where PERSON_NM = 'Ivan'),
        '2021-12-24 11:23:44'::timestamp, '5ka');
insert into purchases.purchase
values (DEFAULT,
        (select PERSON_ID
         from purchases.person
         where PERSON_NM = 'Artur'),
        '2021-12-25 11:23:43'::timestamp, 'Miratorg');
insert into purchases.purchase
values (DEFAULT,
        (select PERSON_ID
         from purchases.person
         where PERSON_NM = 'Ivan'),
        '2021-12-26 11:23:43'::timestamp, '5ka');
select *
from purchases.purchase;

insert into purchases.category
values (DEFAULT, 'яйца');
insert into purchases.category
values (DEFAULT, 'молоко');
insert into purchases.category
values (DEFAULT, 'сыр');
insert into purchases.category
values (DEFAULT, 'хлеб');
insert into purchases.category
values (DEFAULT, 'колбаса');

select *
from purchases.category;

insert into purchases.product
values (DEFAULT,
        (select CATEGORY_ID
         from purchases.category
         where CATEGORY_NM = 'яйца'),
        200, '2021-12-26'::timestamp, True, 500, NULL, NULL, 500, NULL, NULL);
insert into purchases.product
values (DEFAULT,
        (select CATEGORY_ID
         from purchases.category
         where CATEGORY_NM = 'хлеб'),
        100, '2021-12-27'::timestamp, True, 500, NULL, NULL, 500, NULL, NULL);
insert into purchases.product
values (DEFAULT,
        (select CATEGORY_ID
         from purchases.category
         where CATEGORY_NM = 'хлеб'),
        300, '2021-12-26'::timestamp, True, 250, NULL, NULL, 250, NULL, NULL);
insert into purchases.product
values (DEFAULT,
        (select CATEGORY_ID
         from purchases.category
         where CATEGORY_NM = 'колбаса'),
        202, '2021-12-26'::timestamp, True, 700, NULL, NULL, 700, NULL, NULL);
insert into purchases.product
values (DEFAULT,
        (select CATEGORY_ID
         from purchases.category
         where CATEGORY_NM = 'сыр'),
        150, '2021-12-26'::timestamp, True, 600, NULL, NULL, 600, NULL, NULL);
insert into purchases.product
values (DEFAULT,
        (select CATEGORY_ID
         from purchases.category
         where CATEGORY_NM = 'сыр'),
        200, '2021-12-26'::timestamp, True, 500, NULL, NULL, 500, NULL, NULL);
select *
from purchases.product;

insert into purchases.storage
values (DEFAULT, 'freezer', 1);
select *
from purchases.storage;

insert into purchases.product_x_storage
select PRODUCT_ID, 1
from purchases.product;

select *
from purchases.product_x_storage;

------------------------------------------------------
--My tables
------------------------------------------------------

INSERT INTO CookedDish(TimeSpent, ExpiryDate, CountEaten, Finished, Cost, Recipe, CookingDate, Name)
VALUES ('01:00:00', '2021-06-01', 0, False, 1500, 1, '2021-05-01', 'Student"s lunch'),
       ('01:30:00', '2021-06-02', 0, False, 500, 1, '2021-05-06', 'Student"s breakfast'),
       ('01:40:00', '2021-06-03', 0, False, 1250, 1, '2021-05-02', 'Lunch'),
       ('02:00:00', '2021-06-04', 0, False, 2000, 1, '2021-05-09', 'Supper'),
       ('00:20:00', '2021-06-05', 0, False, 300, 1, '2021-05-16', 'Dinner'),
       ('00:15:00', '2021-06-06', 0, False, 450, 1, '2021-05-21', 'Undefined'),
       ('01:00:00', '2021-06-07', 0, False, 1200, 1, '2021-05-11', 'Snack'),
       ('01:10:00', '2021-06-08', 0, False, 1300, 1, '2021-05-17', 'Snack'),
       ('00:05:00', '2021-05-31', 0, False, 100, 1, '2021-05-03', 'Dinner');

select *
from CookedDish;

INSERT INTO Cooker(PersonID, DishID)
VALUES ((
            select person_id
            from purchases.person
            where person_nm = 'Artur'
        ), 3),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Artur'
        ), 2),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Artur'
        ), 1),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Artur'
        ), 8),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Ivan'
        ), 7),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Ivan'
        ), 9),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Aleksey'
        ), 6);

select *
from Cooker;

insert into Recipe(Dish, Ingredient, Count)
VALUES (1, 2, 3),
       (1, 6, 2),
       (2, 5, 1),
       (2, 1, 4),
       (2, 4, 4),
       (3, 1, 6),
       (3, 5, 8),
       (3, 6, 9),
       (1, 3, 1);

select *
from Recipe;

insert into Consumtions(PersonID, DT)
VALUES ((
            select person_id
            from purchases.person
            where person_nm = 'Artur'
        ), '2021-05-31 20:00:00'),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Ivan'
        ), '2021-06-01 15:00:00'),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Artur'
        ), '2021-06-02 16:00:00'),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Anastas'
        ), '2021-06-02 17:00:00'),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Kamil'
        ), '2021-06-02 20:00:00'),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Seva'
        ), '2021-06-03 12:00:00'),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Aleksey'
        ), '2021-06-03 13:00:00'),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Ivan'
        ), '2021-06-03 16:00:00'),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Ivan'
        ), '2021-06-03 19:00:00'),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Kamil'
        ), '2021-06-04 06:00:00'),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Seva'
        ), '2021-06-04 13:00:00'),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Aleksey'
        ), '2021-06-04 20:00:00'),
       ((
            select person_id
            from purchases.person
            where person_nm = 'Anastas'
        ), '2021-06-02 15:00:00');

select *
from Consumtions;

insert into ProductInConsumtion(consumtionid, productid, count)
VALUES (1, 5, 100),
       (2, 1, 50),
       (3, 1, 30),
       (3, 2, 20),
       (3, 3, 15),
       (5, 2, 56),
       (5, 4, 14),
       (6, 6, 12);

select *
from ProductInConsumtion;

INSERT INTO DishInStorage(Dish, Storage)
VALUES (1, 1),
       (2, 1),
       (3, 1),
       (4, 1),
       (5, 1),
       (6, 1),
       (7, 1),
       (8, 1),
       (9, 1);

select *
from DishInStorage;

INSERT INTO DishInConsumtion(consumtionid, dishid)
VALUES (1, 1),
       (1, 2),
       (2, 5),
       (2, 1),
       (2, 6),
       (3, 1),
       (4, 2),
       (4, 3),
       (5, 1);

select *
from DishInConsumtion;

---------------------------------------------------------------------------
/*
 Теперь, когда прошли наивные вставки и таблицы имеют какую-то информацию,
 приведем примеры смысловых запросов
 */
---------------------------------------------------------------------------

--На-какую-стоимость-поел-человек
select person_nm,
       sum(coalesce(CD.Cost, 0))  as dishes_sum_cost,
       sum(coalesce(pr.price, 0)) as all_products_price
from purchases.person
         inner join consumtions c on person.person_id = c.personid
         left join DishInConsumtion DIC on c.ConsumtionID = DIC.ConsumtionID
         left join DishInStorage DIS on DIC.DishID = DIS.Dish
         left join CookedDish CD on DIS.Dish = CD.Dish
         left join ProductInConsumtion PIC on c.ConsumtionID = PIC.ConsumtionID
         left join purchases.product_x_storage on PIC.ProductID = product_x_storage.product_id
         left join purchases.product pr on product_x_storage.product_id = pr.product_id
group by person_id, person_nm;

--Как-часто-человек-готовил

select person_nm,
       person_id,
       count(TimeSpent) as count_of_cooking,
       sum(TimeSpent)   as whole_time
from purchases.person p
         inner join Cooker ck on ck.personid = p.person_id
         inner join CookedDish CD on ck.DishID = CD.Dish
group by p.person_id, p.person_nm;

--Как-часто-человек-питается-в-комнате

select person_id,
       person_nm,
       count(ConsumtionID) as eat_in_room_times
from purchases.person
         inner join consumtions c on person.person_id = c.personid
group by person.person_id, person.person_nm
order by count(ConsumtionID) DESC;

--Какие-продукты-он-ест
select person_nm,
       pc.category_nm,
       sum(coalesce(price, 0)) as sum_price_of_product
from purchases.person
         inner join consumtions c on person.person_id = c.personid
         inner join ProductInConsumtion PIC on c.ConsumtionID = PIC.ConsumtionID
         inner join purchases.product_x_storage on PIC.ProductID = product_x_storage.product_id
         inner join purchases.product pr on product_x_storage.product_id = pr.product_id
         inner join purchases.category pc on pr.category_id = pc.category_id
group by person_nm, pr.product_id, pc.category_nm
order by person_nm;

--Какие-ингредиенты-входят-в-состав-блюда

select R.Dish,
       c.category_nm,
       pr.price
from CookedDish CD
         inner join Recipe R on CD.Dish = R.Dish
         inner join purchases.product_x_storage ps on R.Ingredient = ps.product_id
         inner join purchases.product pr on pr.product_id = ps.product_id
         inner join purchases.category c on c.category_id = pr.category_id;

--Стоимость-блюда-
select R.Dish,
       CD.Name,
       sum(coalesce(pr.price, 0))
from CookedDish CD
         inner join Recipe R on CD.Dish = R.Dish
         inner join purchases.product_x_storage ps on R.Ingredient = ps.product_id
         inner join purchases.product pr on pr.product_id = ps.product_id
group by R.Dish, CD.Name;

/*
 При создании запросов на добавление блюда аналогичные рассчеты
 будут устанавливать значение в соответствующую ячейку поля.
 */

-----------------------------------------------------------------
/*
 Написать CRUD-запрос (подсказка: 4 запроса) к двум любым таблице БД.
 */
----------------------------------------------------------------------
-- Create
INSERT INTO CookedDish(TimeSpent, ExpiryDate, CountEaten, Finished, Cost, Recipe, CookingDate, Name)
VALUES ('01:00:00', '2021-06-01', 0, False, 999, 2, '2021-05-01', 'sleepless night');

-- Read
SELECT *
from CookedDish
where Name like '%night%';

-- Update
UPDATE CookedDish
SET ExpiryDate='2099-06-01'
WHERE Name like '%night%';

-- Delete
DELETE
FROM CookedDish
WHERE ExpiryDate > '2050-01-01';
----------------------------------------------------------------------------
/*
 Повторим аналогичные действия для еще одной таблицы.
 */
-----------------------------------------------------------------------------
-- Create
INSERT INTO purchases.person(person_nm, room_id, surname)
VALUES ('Art', (select room_id
                from purchases.room
                where room.room_num = 205), 'Fil');


-- Read
SELECT *
from purchases.person
where room_id = (select room_id
                 from purchases.room
                 where room.room_num = 205);

-- Update
UPDATE purchases.person
SET room_id=2
WHERE person.surname like 'Fil';

-- Delete
DELETE
FROM purchases.person
WHERE person.surname = 'Fil';
---------------------------------------------------
/*
 Создать по 1 представлению на каждую таблицу. В представлениях должен быть
реализован механизм маскирования личных (секретных) данных и скрытия технических
полей (суррогатных ключей и т.п.)
 */
-------------------------------------------------------

--Функция для защиты информации
create or replace function HideInformation(
    TextToHide varchar,
    ShowSymbols int default 2,
    CoverWithSymbols character default '*'
) returns varchar as
$$
declare
    Information  varchar = '';
    SymbolsCount int;
    Length       int;
begin
    Length = char_length(TextToHide);
    SymbolsCount = Length - ShowSymbols;
    if ShowSymbols < 0
    then
        raise exception 'Exception in function secret_suffix.';
    end if;

    Information = repeat(CoverWithSymbols, SymbolsCount);
    TextToHide = overlay(
            TextToHide placing Information
            from ShowSymbols for SymbolsCount
        );
    return TextToHide;
end;
$$ language plpgsql;

----------------------------------------------------------------------
--person view
create or replace view Inhabitants as
SELECT person_nm                        as name,
       HideInformation(surname, 2, '#') as surname,
       room_num                         as room_number
FROM purchases.person
         inner join
     purchases.room
     on person.room_id = room.room_id;


select *
from Inhabitants;
------------------------------------------------------------------------
--Cooked Dishes view
create or replace view Food as
SELECT Name,
       Cost,
       TimeSpent,
       CountEaten,
       Finished,
       ExpiryDate::date,
       CookingDate::date
FROM CookedDish;


select *
from Food;

--Consumptions view
create or replace view ConsumptionsInfo as
SELECT
    CD.Name as food_name,
    pr.person_nm as person_name,
    HideInformation(surname, 2, '#') as surname,
    c.DT::date as date
FROM
     Consumtions c
     inner join
     purchases.person pr
     on pr.person_id=c.personid
     inner join dishinconsumtion d on c.ConsumtionID = d.consumtionid
     inner join dishinstorage ds on d.DishID = ds.Dish
     inner join CookedDish CD on ds.Dish = CD.Dish;


select *
from ConsumptionsInfo;

/* Next data consists only of keys and is not for demonstration
 * Cooker view
 * Recipe view
 * Product In Storage view
 * Dish in Storage view
 * Dish in Consumption view
 * Product in Consumptions view
 */
----------------------------------------------
--Создать 2 сложных представления (с over, если верить дошедшей информации).
----------------------------------------------

--На какую сумму поел каждый человек за все время
create or replace view MoneyForFood as
select
     DISTINCT per.person_nm,
     sum(coalesce(CD.Cost, 0)) over (PARTITION BY person_nm order by person_nm) as dish_costs,
     sum(coalesce(p.price * PIC.Count, 0)) over (PARTITION BY person_nm order by person_nm) as product_cost
from Consumtions c
     left join DishInConsumtion DIC on c.ConsumtionID = DIC.ConsumtionID
     left join DishInStorage DIS on DIS.Dish = DIC.DishID
     left join CookedDish CD on CD.Dish = DIS.Dish
     left join ProductInConsumtion PIC on c.ConsumtionID = PIC.ConsumtionID
     left join product_x_storage pxs on PIC.ProductID = pxs.product_id
     left join product p on p.product_id = pxs.product_id
     left join purchases.person per on per.person_id=c.personid;

select * from MoneyForFood;

--Разница в потреблении
create or replace view MoneyForFoodDifference as
select
    person_nm,
    dish_costs,
    product_cost,
    lag(dish_costs::integer, 1, 0) over (order by dish_costs DESC ) - dish_costs as dish_cost_difference,
    lag(product_cost::integer, 1, 0) over (order by dish_costs DESC) -  product_cost  as product_cost_difference
from MoneyForFood;

select * from MoneyForFoodDifference;
--------------------------------------------------------------------------------------
--Создать 2 триггера на любые таблицы БД. Логика работы обговаривается c семинаристом.
--------------------------------------------------------------------------------------


create or replace function EatDish() returns trigger as
$$
declare
    dishID INTEGER default 0;
BEGIN
    dishID := new.DishID;

    UPDATE CookedDish
    SET counteaten = counteaten + 1
    where Dish in (
        Select Dish
        from DishInStorage
        WHERE Dish = dishID);

    return new;
END;
$$
    LANGUAGE plpgsql;

create trigger GetNewConsumption
    after insert on DishInConsumtion
    for row execute procedure EatDish();

SELECT * from CookedDish;
SELECT * from Consumtions;

INSERT INTO DishInConsumtion(consumtionid, dishid) VALUES
(6, 2)

