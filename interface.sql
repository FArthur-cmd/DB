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
