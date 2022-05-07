CREATE OR REPLACE VIEW task1_shops AS
SELECT * FROM shops;

SELECT * FROM task1_shops;

CREATE OR REPLACE VIEW task1_shop_to_supp AS
SELECT * FROM shop_to_sup;

SELECT * FROM task1_shop_to_supp;

CREATE OR REPLACE VIEW task1_supplier AS
SELECT * FROM supplier;

SELECT * FROM task1_supplier;

CREATE OR REPLACE VIEW task1_producers AS
SELECT * FROM producers;

SELECT * FROM task1_producers;

CREATE OR REPLACE VIEW task1_products AS
SELECT * FROM products;

SELECT * FROM task1_products;

CREATE OR REPLACE VIEW task1_models AS
SELECT * FROM models;

SELECT * FROM task1_models;

CREATE OR REPLACE VIEW task1_brands AS
SELECT * FROM brands;

SELECT * FROM task1_brands;

CREATE OR REPLACE VIEW task1_orders AS
SELECT * FROM orders;

SELECT * FROM task1_orders;

CREATE OR REPLACE VIEW task1_users AS
SELECT * FROM users;

SELECT * FROM task1_users;

CREATE OR REPLACE VIEW task1_orders_prod AS
SELECT * FROM orders_prod;

SELECT * FROM task1_orders_prod;

---------------------------------------------------------------

CREATE OR REPLACE VIEW task2_1 AS
SELECT * FROM models
WHERE model_type_name::text LIKE '%drip' AND id != 3;

SELECT * FROM task2_1;

CREATE OR REPLACE VIEW task2_2 AS
SELECT * FROM models
WHERE volume BETWEEN 10 AND 200 AND id != 2;

SELECT * FROM task2_2;

CREATE OR REPLACE VIEW task2_3 AS
SELECT br.name, company_name, link
FROM models
    JOIN brands br ON br.id = models.brand_id
WHERE induction IN (true, false, null);

SELECT * FROM task2_3;

---------------------------------------------------------------

CREATE OR REPLACE VIEW task3 AS
SELECT AVG(count) AS avarage_count
FROM supplier
WHERE id/2 = 0;

SELECT * FROM task3;

---------------------------------------------------------------

CREATE OR REPLACE VIEW task4_1 AS
SELECT name, count, last_date
FROM supplier
ORDER BY count, last_date;

SELECT * FROM task4_1;

CREATE OR REPLACE VIEW task4_2 AS
SELECT name, count, last_date
FROM supplier
ORDER BY last_date, count;

SELECT * FROM task4_2;

--------------------------------------------------------------

CREATE OR REPLACE VIEW task5 AS
SELECT COUNT(*) AS num_of_models, AVG(volume) AS avg_volume,
SUM(volume) AS sum_volume
FROM models
    JOIN products prod_id ON prod_id.model_id = models.id
WHERE model_type_name = 'drip'
group by model_type_name;

SELECT * FROM task5;

-------------------------------------------------------------

CREATE OR REPLACE VIEW task6_1 AS
SELECT shops.name, location
FROM shops
    JOIN shop_to_sup ss_i ON ss_i.shop_sup_id = shops.id
    JOIN supplier sup ON sup.id = ss_i.supplier_id;

SELECT * FROM task6_1;

CREATE OR REPLACE VIEW task6_2 AS
SELECT shops.name AS shop_name, shops.location AS shop_loc, p.name, p.location
FROM shops
    JOIN shop_to_sup ss_i ON shops.id = ss_i.shop_sup_id
    JOIN supplier sup ON sup.id = ss_i.supplier_id
    JOIN producers p ON p.id = sup.producer_id;

SELECT * FROM task6_2;

-----------------------------------------------------------

CREATE OR REPLACE VIEW task7 AS
SELECT users.user_name, ord.count AS ord_count, ord.order_date, m.model_name, COUNT(id_user)
FROM users
    JOIN orders ord ON users.id = ord.id_user
    JOIN orders_prod op ON ord.id = op.ord_prod_id
    JOIN products prod ON op.product_id = prod.id
    JOIN models m on m.id = prod.model_id
GROUP BY users.user_name, ord.count, ord.order_date, m.model_name
HAVING ord.count >= 10;

SELECT * FROM task7;

----------------------------------------------------------

CREATE OR REPLACE VIEW task8 AS
SELECT *
FROM ( SELECT users.user_name, ord.count AS ord_count, ord.order_date
FROM users
    JOIN orders ord ON users.id = ord.id_user) as order_user
WHERE order_user.order_date BETWEEN '2100-12-31 00:00:00' AND '2200-12-31 00:00:00';

SELECT * FROM task8;

----------------------------------------------------------

INSERT INTO brands (name, company_name, description, link) VALUES
	('Delonghi','ОАО Delonghi','История De’Longhi началась в 1902 году, когда в провинциальном городке Тревизо открылась мастерская по изготовлению частей для печей и газовых плит.','https://delonghi.ru');

INSERT INTO models (model_name, model_type_name, volume, induction, brand_id) VALUES
	('EC785.GY Dedica', 'carob', 1, false, 26);

INSERT INTO products (model_id, remainder, producer_id) VALUES
	(23, 100, 4);

INSERT INTO producers (name, location) VALUES
	('E=mc^2', 'Tereza st. 34');

INSERT INTO supplier (name, last_date, producer_id, count) VALUES
	('Deliv2You', '2031-12-23 21:09:54', 24, 132);

INSERT INTO users (id, user_name, hash, address) VALUES
    (DEFAULT, 'Lucy', '134fbe459c8fa9efd6fa7a78265a0025', 'Obukhovo st. 23');

INSERT INTO orders (id, id_user, count, order_date, shop_id) VALUES
    (DEFAULT, 26, 1, '2021-01-11 20:23:54', 1);

INSERT INTO orders_prod (product_id, ord_prod_id) VALUES
    (23, 23);

INSERT INTO shops (id, name, location) VALUES
    (DEFAULT,'TastyC', 'Polytechnic st. 93');

INSERT INTO shop_to_sup (supplier_id, shop_sup_id) VALUES
    (23, 24);
--------------------------------------------------------

UPDATE products SET remainder = remainder + 10
WHERE products.id IN (SELECT products.id FROM products
    JOIN orders_prod ord_p_i ON products.id = ord_p_i.product_id
    JOIN orders ord ON ord_p_i.ord_prod_id = ord.id
WHERE ord.id / 2 = 0);

--------------------------------------------------------

INSERT INTO users (id, user_name, hash, address) VALUES
    (DEFAULT, 'Lucy', '000000000000000000007a78265a0025', 'Obukhovo st. 23');
SELECT hash from users WHERE hash=(SELECT MIN(hash) FROM users) AND id NOT IN (SELECT id_user FROM orders);
DELETE FROM users
WHERE hash = (SELECT MIN(hash) FROM users) AND id NOT IN (SELECT id_user FROM orders);


INSERT INTO brands (name, company_name, description, link) VALUES
	('Delonghi','ОАО Delonghi','История De’Longhi началась в 1902 году, когда в провинциальном городке Тревизо открылась мастерская по изготовлению частей для печей и газовых плит.','https://delonghi.ru');
INSERT INTO models (model_name, model_type_name, volume, induction, brand_id) VALUES
	('newModel', 'carob', 1, false, 27);
DELETE FROM models
WHERE NOT EXISTS(SELECT * FROM products WHERE models.id = products.model_id);

--------------------------------------------------------------------
DROP VIEW IF EXISTS ind1, ind2;

CREATE OR REPLACE VIEW ind1 as
    SELECT sup.name, remainder, prod.id
    FROM shops
        JOIN shop_to_sup sts on shops.id = sts.shop_sup_id
        JOIN supplier sup on sts.supplier_id = sup.id
        JOIN producers p on sup.producer_id = p.id
        JOIN products prod on prod.producer_id = p.id
        WHERE remainder > 0
        GROUP BY sup.name, remainder, prod.id ORDER BY sup.name
SELECT * FROM ind1;

CREATE OR REPLACE VIEW ind2 as
SELECT SUM(orders.count) AS amount, br.name, order_date
FROM orders
        JOIN orders_prod op ON orders.id = op.ord_prod_id
        JOIN products prod ON op.product_id = prod.id
        JOIN models mod ON prod.model_id = mod.id
        JOIN brands br ON mod.brand_id = br.id
WHERE orders.order_date BETWEEN '2021-01-01 00:00:00.000000' AND '2021-12-31 23:59:59.000000'
GROUP BY br.name, order_date ORDER BY amount DESC
LIMIT 5;
SELECT * FROM ind2;

DROP PROCEDURE IF EXISTS ind3;

CREATE OR REPLACE PROCEDURE ind3(id_ integer, count_ integer) AS $$
    BEGIN
        UPDATE products SET remainder = remainder + count_
        WHERE products.id = id_;
        INSERT INTO supplier (name, last_date, producer_id, count) VALUES
	    ('Deliv2You', now(), 3, count_);

    END $$ LANGUAGE plpgsql;

CALL ind3(3, 4);
