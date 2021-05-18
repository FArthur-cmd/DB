
set search_path to consumtion, purchases;

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
