--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

explain analyze --41.52
select last_name ||' '|| first_name as "Customer name", address, city, country
from customer
join address using(address_id)
join city using(city_id)
join country using(country_id)

--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

select store_id as "ID магазина", count(customer_id) as "Количество покупателей"
from store 
join customer using(store_id)
group by store_id 

--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

select store_id as "ID магазина", count(customer_id) as "Количество покупателей"
from store 
join customer using(store_id)
group by store_id 
having count(customer_id)>300

-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

select store_id as "ID магазина", count(customer_id) as "Количество покупателей", city as "Город", staff.last_name ||' '|| staff.first_name as "Имя сотрудника"
from store 
join customer using(store_id)
join address on store.address_id=address.address_id 
join city using (city_id)
join staff using (store_id)
group by store_id, city_id, staff_id 
having count(customer_id)>300

--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов

select last_name ||' '|| first_name as "Фамилия и имя покупателя",
	count(distinct rental_id) as "Количество фильмов"
from customer
join rental using (customer_id)
group by customer_id
order by "Количество фильмов" desc 
limit 5

--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма

select  c.last_name ||' '|| c.first_name as "Фамилия и имя покупателя",
	count(distinct r.rental_id) as "Количество фильмов",
	sum(amount)::int as "Общая стоимость платежей", 
	min(amount) as "Минимальная стоимость платежа",
	max(amount) as "Макимальная стоимость платежа"
from payment
join customer c using(customer_id)
join rental r using (rental_id)
group by c.customer_id

--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
--чтобы в результате не было пар с одинаковыми названиями городов. 
--Для решения необходимо использовать декартово произведение.
 
select c1.city as "Город 1", c2.city as "Город 2"
from city c1
cross join city c2
where c1.city < c2.city 

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 
select customer_id  as "ID покупателя",
	round(avg(date(return_date)-date(rental_date)),2)
	from rental
group by customer_id

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.

select f.title as "Название фильма",
	f.rating as "Рейтинг",
	c.name as "Жанр",
	f.release_year as "Год выпуска",
	l.name as "Язык",
	count(r.inventory_id) as "Количество аренд",
	sum(amount) as "Общая стоимость аренды"
from film f 
join "language" l using(language_id)
join film_category fc using(film_id)
join category c using(category_id)
join inventory using(film_id)
join rental r using(inventory_id)
join payment p using(rental_id)
group by f.film_id, c.category_id, l.language_id

--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.

select f.title as "Название фильма",
	f.rating as "Рейтинг",
	c.name as "Жанр",
	f.release_year as "Год выпуска",
	l.name as "Язык",
	count(r.inventory_id) as "Количество аренд",
	sum(amount) as "Общая стоимость аренды"
from film f 
join "language" l using(language_id)
join film_category fc using(film_id)
join category c using(category_id)
left join inventory using(film_id)
left join rental r using(inventory_id)
left join payment p using(rental_id)
group by f.film_id, c.category_id, l.language_id
having count(r.inventory_id) =0

--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".

select staff_id, count(payment_id) as "Количество продаж",
	case
		when count(payment_id) >7300 then 'Да' 
		else 'Нет'
	end as "Премия"
	from payment p 
group by staff_id
