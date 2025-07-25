--ЗАДАНИЕ №1
--Выведите название самолетов, которые имеют менее 50 посадочных мест

explain analyze --28.20//0.32

select aircraft_code, count(seat_no) as number_of_seats
from seats 
group by aircraft_code
having count(seat_no)<50


--ЗАДАНИЕ №2
--Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых

explain analyze --82460.51//220.08

with recursive r as (
	select min(date_trunc('month', book_date)) x
	from bookings
	union
	select x + interval '1 month'
	from r
	where x < (select max(date_trunc('month', book_date)) from bookings))	
select x::date, sum_of_bookings,
	coalesce(((sum_of_bookings-lag(sum_of_bookings) over (order by x))/(lag(sum_of_bookings) over (order by x)/100)),0)::numeric(5,2) as percent_change
from r
left join (
	select date_trunc('month', book_date) as month_booking,
		sum(total_amount) as sum_of_bookings		
	from bookings b 
	group by 1) t on t.month_booking = x	
order by x


--ЗАДАНИЕ №3
--Выведите названия самолетов не имеющих бизнес - класс. Решение должно быть через функцию array_agg

explain analyze --29.37//0.46

select model
from 
	(select aircraft_code, array_agg(fare_conditions) as service_class 
	from seats
	group by 1) t
join aircrafts using (aircraft_code)
where array_position (service_class, 'Business') is null


--Попытка решения без подзапроса
explain analyze --34.60//0.80

select model
from seats
join aircrafts using (aircraft_code)
group by 1
having array_position (array_agg(fare_conditions), 'Business') is null



--ЗАДАНИЕ №4
--Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день,
--учитывая только те самолеты, которые летали пустыми и только те дни, где из одного аэропорта
--таких самолетов вылетало более одного.
--В результате должны быть код аэропорта, дата вылета, количество пустых мест и накопительный итог

explain analyze --12543.00//169.8

with cte1 as (
	select *
	from (
		select f.flight_id, f.aircraft_code, f.departure_airport, f.actual_departure,
			count(flight_id) over (partition by departure_airport, actual_departure::date) as number_of_departures
		from flights f 
		left join boarding_passes bp using (flight_id)
		where bp.boarding_no is null and f.actual_departure is not null
		order by 3,4)t
	where number_of_departures>1),
cte2 as (
	select aircraft_code, count(seat_no) as number_of_seats
	from seats
	group by aircraft_code)
select cte1.departure_airport, cte1.actual_departure, sum(number_of_seats) as number_of_free_seats,
	sum(sum(number_of_seats)) over (partition by departure_airport, actual_departure::date order by actual_departure) as total_number_of_free_seats
from cte1
join cte2 using (aircraft_code)
group by departure_airport, actual_departure


--ЗАДАНИЕ №5
--Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов.
--Выведите в результат названия аэропортов и процентное отношение.
--Решение должно быть через оконную функцию.

explain analyze --2482.5//53.2

select airport_names,  count(route) as "amount", sum(count(route)) over () as total_amount,
	round((count(route)/sum(count(route)) over ()*100.),2)||'%' as percentage_ratio
from (
	select concat(departure_airport, ' - ', arrival_airport) as route,
		concat(a.airport_name, ' - ', aa.airport_name) as airport_names  
	from flights f
	join airports a on f.departure_airport =a.airport_code
	join airports aa on f.arrival_airport =aa.airport_code) t
group by 1
order by 1


--ЗАДАНИЕ №6
--Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код
--оператора - это три символа после +7

explain analyze --73173.30//842.9

select substring(contact_data ->>'phone' FROM 3 FOR 3) as operator_code,
	count(substring(contact_data ->>'phone' FROM 3 FOR 3)) as passengers_amount
from tickets
group by 1
order by 1


--ЗАДАНИЕ №7
--Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
--До 50 млн - low
--От 50 млн включительно до 150 млн - middle
--От 150 млн включительно - high
--Выведите в результат количество маршрутов в каждом полученном классе


explain analyze --21016.72//353.5

with cte as (
	select route, total,
		case
			when total < 50000000 then 'low'
			when total >= 50000000 and total < 150000000 then 'middle'
			else 'hight'
		end cost_class
	from (
		select sum(amount) as "total", concat(departure_airport, ' - ', arrival_airport) as route
		from ticket_flights
		join flights using (flight_id)
		group by route
		order by route) t)
select cost_class, count(route) as number_of_routes
from cte
group by 1


--ЗАДАНИЕ №8
--Вычислите медиану стоимости билетов, медиану стоимости бронирования и отношение медианы
--бронирования к медиане стоимости билетов, округленной до сотых

explain analyze --30016.77//783.9

with cte1 as (
	select percentile_cont(0.5) within group(order by total_amount) as median_for_bookings
	from bookings),
cte2 as (
select percentile_cont(0.5) within group(order by amount) as median_for_tickets
from ticket_flights)
select median_for_bookings, median_for_tickets,
	round((median_for_bookings/median_for_tickets)::numeric,2) as ratio
from cte1
natural join cte2


--ЗАДАНИЕ №9
--Найдите значение минимальной стоимости полета 1 км для пассажира. То есть нужно найти
--расстояние между аэропортами и с учетом стоимости билетов получить искомый результат.

create extension "cube";
create extension "earthdistance";

explain analyze --46575.87//733.5

with cte1 as (
	select f.flight_id, f.departure_airport, f.arrival_airport,
		earth_distance (ll_to_earth(a.latitude, a.longitude), ll_to_earth(aa.latitude, aa.longitude))::numeric(10,2) as distance
	from flights f 
	join airports a on f.departure_airport =a.airport_code
	join airports aa on f.arrival_airport =aa.airport_code)
select cte1.*, ticket_price, round(ticket_price/distance*1000,2) as price_per_km
from cte1
left join (
	select tf.flight_id, min(amount) as ticket_price
	from ticket_flights tf 
	group by tf.flight_id) u on cte1.flight_id=u.flight_id 
order by price_per_km
limit 1
