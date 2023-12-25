-- importing data 

-- create tables 
create table assembly (ID int,Assembly varchar(100)) -- assmebly table
-- load data
copy assembly from 'C:\Users\growth\Desktop\1A\csv\assembly.csv' delimiter ',' csv header ;

create table duration (id int,duration varchar (50)) -- duration table
-- load data
copy duration from 'C:\Users\growth\Desktop\1A\csv\duration.csv' delimiter ',' csv header ;

create table payment (id int ,method varchar(50)) --payment table 
-- load data
copy payment from 'C:\Users\growth\Desktop\1A\csv\payment.csv' delimiter ',' csv header ;

create table trips (trip_id int,faremethod int,fare int,loc_from int,loc_to int,
					driver_id int,cust_id int,distance int,duration int) -- trip table
-- load data 
copy trips from 'C:\Users\growth\Desktop\1A\csv\trips.csv' delimiter ',' csv header ;

create table  trip_details(trip_id int,loc_from int,searches int,searches_got_estimate int,
						   searches_for_quotes int,searches_got_quotes int,customer_not_cancelled int,
						   driver_not_cancelled int,otp_entered int,end_ride int)
-- load data
copy trip_details from 'C:\Users\growth\Desktop\1A\csv\trip_details.csv' delimiter ',' csv header ;

-- check 
select * from assembly
select * from duration
select * from payment
select * from trips 
select * from trip_details

-- connect each table 
alter table trips 
add primary key (trip_id)
						   
alter table trip_details
add primary key (trip_id)						   
						   
alter table trip_details
add foreign key (trip_id)references trips(trip_id);

---
select count(*) from trips

select count(*) from trip_details
where end_ride = 1
						   
-- note : all the searches stored in trip_details table						   
-- note: and the completed trip stored in trip table 
--- 

-- 1. total number of trip which is searches and completed !

-- duplicate trip_id check
select trip_id , count(trip_id) as frequency from trip_details
group by trip_id
having count(trip_id) >1
-- no trip_id have duplicate
select count(end_ride) from trip_details
where end_ride =1

-- 2. calculate total number of driver present 
select count( distinct driver_id) as total_driver
from trips

-- 3. find out the total earning 
select * from trips
select sum(fare) as total_earning from trips

-- 4. find out total number of completed trip
-- the trip table contain all the data which sucessfully completed 
select count(distinct trip_id) as completed_trip
from trips

-- 5. total number of searched which took place
select sum(searches) as searches from trip_details
where searches =1 -- although no need for this

--6. total number of searched which got estimate . customer try to look at the fare 
select sum(searches_got_estimate) fare_estimate
from trip_details
	
-- 7. estimate serches for quotes . how many customer serches for driver
select sum(searches_got_quotes) quotes_serches 
from trip_details

-- 8. total number of trip which is cancelled by driver 
select count(driver_not_cancelled)- sum(driver_not_cancelled)
from trip_details

-- 9. find the number of customers who enter OTP before the trip
select sum(otp_entered) as otp_entered from trip_details

-- 10. total completed trip. end_trip
select sum(end_ride) from trip_details

-- 11. what is the average distance of per trip
select avg(distance) from trips

-- 12. what is the average fare per trip
select avg(fare) from trips

-- 13. which one is the most payment method 

select p.method from payment as p inner join
(select faremethod,count(faremethod) from trips
group by faremethod
order by count(faremethod) desc
limit 1 ) as t
on p.id = t.faremethod

-- 14. the highest payment made through which instrument
select p.method from payment as p inner join
(select faremethod,fare from trips
order by fare desc
limit 1) as t
on t.faremethod= p.id

-- 15. which location had most no of trips
select * from (
select *,dense_rank()over(order by loc_f desc) as dn_rank from
(select loc_from,loc_to,count(trip_id) as loc_f from trips
group by loc_from,loc_to
order by count(trip_id) desc))
where dn_rank =1

-- 16. whos are the top five earning driver
select * from (
select *,dense_rank() over(order by fare desc) as driver_earning
from 
(select driver_id,sum(fare) as fare from trips
group by driver_id 
order by fare desc))
where driver_earning <=5

-- 17. which time duration had most trips
select * from (
select *,rank() over (order by frequency desc ) as index1 from
(select duration,count(distinct trip_id) as frequency from trips
group by duration))
where index1 =1

-- 18.which driver ,customer pair had more orders
select * from (
select *,rank()over(order by frequency desc) as index1 from
(select driver_id,cust_id,count(distinct trip_id) as frequency from trips
group by driver_id,cust_id))
where index1 =1

-- 19.what percentages searches to eastimate rate
select * from trip_details
select (sum(searches_got_estimate)*100)/sum(searches) from trip_details

-- 20.which location got the highest number of trips in each duration(time)
select * from (
select *,rank()over(partition by duration order by frequency desc) as rnk from
(select duration,loc_from,count(distinct trip_id) as frequency from trips
group by duration,loc_from))
where rnk=1
-- -- which location got the highest number of trips in each location
select * from (
select *,rank()over(partition by loc_from order by frequency desc) as rnk from
(select duration,loc_from,count(distinct trip_id) as frequency from trips
group by duration,loc_from))
where rnk=1

-- 21.which area got the highest fares
select* from (
select *,rank()over(order by hi_fare desc) as rnk
from (select loc_from,sum(fare) as hi_fare from trips
group by loc_from))
where rnk =1

-- 22.which area got the highest cacellation trips by driver
select * from
(select *,rank()over(order by driver_cancelled desc) as rnk
from(select loc_from,count(trip_id) - sum(driver_not_cancelled) as driver_cancelled
from trip_details
group by loc_from))
where rnk =1

-- 23.which area got the highest cacellation trips by customer
select * from
(select *,rank()over(order by cust_cancelled desc) as rnk
from(select loc_from,count(trip_id) - sum(customer_not_cancelled) as cust_cancelled
from trip_details
group by loc_from))
where rnk =1


-- 24.which duration got the highest fare
select * from(select *,rank()over(order by fare desc) as rnk
from(select duration,sum(fare) as fare from trips
group by duration))
where rnk =1

-- 25.which duration got the highest trip

select * from(
select *,rank()over(order by frequency desc) as rnk
from (select duration,count(distinct trip_id) as frequency from trips
group by duration))
where rnk =1
