set search_path to consumtion, purchases;

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