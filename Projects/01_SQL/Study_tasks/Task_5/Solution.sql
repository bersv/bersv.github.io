--=============== МОДУЛЬ 5. POSTGRESQL =======================================

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

explain analyze --67.50// 0.38
select *
from film
where special_features @> array['Behind the Scenes']


--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

explain analyze --67.50// 0.38
select *
from film
where special_features && array['Behind the Scenes'];

explain analyze --77.5// 0.31
select *
from film
where 'Behind the Scenes' = any(special_features);

explain analyze --67.50// 0.36
select *
from film
where array_position(special_features, 'Behind the Scenes') is not null;


--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

explain analyze --720.76//11.1
with cte1 as (
	select *
	from film
	where special_features @> array['Behind the Scenes'])
select c.customer_id, count(r.rental_id) as "Количество фильмов"
from customer c
join rental r using (customer_id)
join inventory i using(inventory_id)
join cte1 on i.film_id = cte1.film_id
group by c.customer_id
order by c.customer_id

--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

explain analyze --720.77//11.2
select c.customer_id, count(r.rental_id) as "Количество фильмов"
from (
	select *
	from film
	where special_features @> array['Behind the Scenes']) t
join inventory i using(film_id)
join rental r using (inventory_id)
join customer c using(customer_id)
group by c.customer_id
order by c.customer_id


--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

create materialized view task as 
select c.customer_id, count(r.rental_id) as "Количество фильмов"
from (
	select *
	from film
	where special_features @> array['Behind the Scenes']) t
join inventory i using(film_id)
join rental r using (inventory_id)
join customer c using(customer_id)
group by c.customer_id
order by c.customer_id

select * from task --2023-04-15 15:40:52.225 +0300

select * from task --2023-04-15 15:27:25.756 +0300

--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса

--ОТВЕТЫ:
--1. Поиск значения в массиве происходит быстрее с использованием оператора any()
--2. Вычисление с ипользованием CTE и вычисление с использованием подзапроса работают с идентичной скоростью  

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.

explain analyze --2401.40 /20.2
with cte1 as (
	select *
	from (
		select *, first_value(payment_id) over (partition by staff_id order by payment_date)
		from payment) t
	where payment_id = first_value
	order by staff_id)
select cte1.staff_id, film.film_id, film.title, cte1.amount, cte1.payment_date, customer.last_name, customer.first_name 
from cte1
join customer on cte1.customer_id = customer.customer_id 
join rental on cte1.rental_id = rental.rental_id 
join inventory on rental.inventory_id = inventory.inventory_id 
join film on inventory.film_id = film.film_id 


--ЗАДАНИЕ №2
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день

with cte1 as (
	select distinct on (store_id) store_id, rental_date::date as "День наибольшей аренды", count (rental_id) as "Количество фильмов"
	from rental 
	join customer c using (customer_id)
	join store using (store_id)
	group by store_id, rental_date::date
	order by store_id, "Количество фильмов" desc),
cte2 as (
	select distinct on (store_id) store.store_id, payment_date::date  as "День наименьшей продажи", sum(amount) as "Сумма продажи"
	from payment  
	join customer c using (customer_id)
	join store using (store_id)
	group by store_id, payment_date::date
	order by store_id, "Сумма продажи")
select *
from cte1
join cte2 using (store_id)

