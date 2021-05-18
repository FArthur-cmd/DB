
set search_path to consumtion, purchases;

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
