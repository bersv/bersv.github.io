--=============== МОДУЛЬ 4. РАБОТА С POSTGRESQL =======================================

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
--Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим 
--так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

--Номера платежей от 1 до N по дате
select customer_id, payment_id, payment_date,
	row_number() over (order by payment_date)
from payment 

--Номера платежей от 1 до N по дате (Альтернатива)
select customer_id, payment_id, payment_date,
	row_number() over (partition by payment_date::date order by payment_date)
from payment 

--Номера платежей для каждого покупателя
select customer_id, payment_id, payment_date,
	row_number() over (partition by customer_id order by payment_date)
from payment

--Нарастающий итог суммы платежей для каждого покупателя
select customer_id, payment_id, payment_date::date, amount,
	sum(amount) over (partition by customer_id order by payment_date::date, amount)
from payment 

--Номера платежей для каждого покупателя по стоимости от больших к меньшим
select customer_id, payment_id, payment_date, amount,
	rank () over (partition by customer_id order by amount desc)
from payment

--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.

select customer_id, payment_id, payment_date, amount as "Текущий платёж", 
	lag(amount,1,0.) over (partition by customer_id order by payment_date) as "Предыдущий платёж"
from payment

--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.

select customer_id, payment_id, payment_date, amount as "Текущий платёж", 
	lead(amount,1,0.) over (partition by customer_id order by payment_date) as "Следующий платёж",
	lead(amount,1,0.) over (partition by customer_id order by payment_date) - amount as "Разница"
from payment

--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

select customer_id, payment_id, payment_date, amount 
from (
	select *, last_value(payment_id) over (partition by customer_id)
	from (
		select *
		from payment
		order by customer_id, payment_date) t) t
where payment_id = last_value

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.

select staff_id, payment_date::date, sum(amount),
	sum(sum(amount)) over (partition by staff_id order by payment_date::date)
from payment
where date_trunc('month', payment_date)='2005.08.01'
group by staff_id, payment_date::date

--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку

select customer_id, payment_id, payment_date, row_number
from (
	select *, row_number() over (order by payment_date)
	from payment
	where date_trunc('day', payment_date)='2005.08.20') t
where mod(row_number, 100)=0
	
--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм

with cte1 as (
	select distinct on (ctry.country) ctry.country as "Страна",  c.customer_id, sum(amount) as "max summ", c.first_name||' '||c.last_name as "NAME1"
	from payment p
	join customer c on p.customer_id = c.customer_id
	join address a on c.address_id = a.address_id 
	join city ct on a.city_id = ct.city_id 
	join country ctry on ct.country_id = ctry.country_id
	group by  ctry.country, c.customer_id
	order by "Страна", "max summ" desc),
cte2 as (
	select distinct on (ctry.country) ctry.country as "Страна", c.customer_id, count(distinct rental_id) as "max count", c.first_name||' '||c.last_name as "NAME2"
	from rental r
	join customer c on r.customer_id = c.customer_id
	join address a on c.address_id = a.address_id 
	join city ct on a.city_id = ct.city_id 
	join country ctry on ct.country_id = ctry.country_id
	group by  ctry.country, c.customer_id
	order by "Страна", "max count" desc),
cte3 as (
	select distinct on ("Страна") "Страна", customer_id, "last rental", "NAME3" 
	from (	
		select distinct on (c.customer_id) c.customer_id, ctry.country as "Страна", payment_date as "last rental", c.first_name||' '||c.last_name as "NAME3" 
		from payment p 
		join customer c on p.customer_id = c.customer_id
		join address a on c.address_id = a.address_id 
		join city ct on a.city_id = ct.city_id 
		join country ctry on ct.country_id = ctry.country_id
		order by c.customer_id, payment_date desc) t
	order by "Страна", "last rental" desc)
select cte3."Страна", "NAME2" as "Больше всех купил", "NAME1" as "Больше всех заплатил", "NAME3" as "Позже всех купил"
from cte3
join cte2 on cte3."Страна" = cte2."Страна"
join cte1 on cte2."Страна" = cte1."Страна"
order by "Страна"



