set search_path to consumtion, purchases;

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
