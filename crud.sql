
set search_path to consumtion, purchases;
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