select * from artist
select * from canvas_size
select * from image_link
select * from museum
select * from museum_hours
select * from product_size
select * from subject
select * from work

--Question:-1 --
/*Fetch all the paintings which are not displayed on any museums?*/

select * 
from work AS w
where museum_id IS null

--Question:-2 --(*****)
/*Are there museums without any paintings?*/

select * from work 
where museum_id IS NULL

--Question:-3 --
/* How many paintings have an asking price of more than their regular price?*/

select * from product_size
where sale_price > regular_price;

--Question:-4 --
/*Identify the paintings whose asking price is less than 50% of its regular price*/

select * from (
	select *,regular_price/2 AS Half_Price from product_size As halfPriceTable
) where sale_price < Half_Price

--Question:-5 --
/*Which canva size costs the most?*/

select label
	,p.sale_price
	,rank() over(ORDER BY p.sale_price DESC) AS Rank
from canvas_size c
JOIN product_size p ON c.size_id::text = p.size_id  --TYPE CAST THE DATA TYPE
group by label,p.sale_price
limit 1

--Question:-6 --
/* Delete duplicate records from work, product_size, subject and image_link tables*/

delete from work
where(
select max(work_id) As Record_Count,work_id
from work
group by work_id
having count(work_id) > 1
)

--Question:-7 --
/*Identify the museums with invalid city information in the given dataset*/

select * from museum 
where city ~ '^[0-9]'

--Question:-8 --
/*Museum_Hours table has 1 invalid entry. Identify it and remove it.*/

select * from museum_hours

--Question:-9 --
/*Fetch the top 10 most famous painting subject*/

select count(subject) As Number_Subject,subject from subject
group by subject
order by Number_Subject DESC

--Question:-10 --
/* Identify the museums which are open on both Sunday and Monday. Display museum name, city.*/

select Distinct(m.name)
	,m.city
	,mh.day 
from museum m
JOIN museum_hours mh ON m.museum_id=mh.museum_id
where mh.day='Sunday' 

select Distinct(m.name)
	,m.city
	,mh.day 
from museum m
JOIN museum_hours mh ON m.museum_id=mh.museum_id
where mh.day='Monday'

--Question:-11 --
/*How many museums are open every single day?.*/

select count(1)
	from (select museum_id, count(1)
		  from museum_hours
		  group by museum_id
		  having count(1) = 7
		 ) x;


--Question:-12 --
/*Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)*/

select m.name,m.city
	,count(w.work_id) As Number_of_Painting
	,rank() over(order by count(w.work_id) DESC) AS Rank
from work w
JOIN museum m ON w.museum_id=m.museum_id
group by m.name,m.city
limit 5

--Question:-13 --
/*Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)*/

select a.artist_id
	,a.full_name,count(work_id) AS Number_of_Painting
	,rank() over(order by count(work_id) DESC) AS Rank_ar
from artist a 
JOIN  work w ON a.artist_id=w.artist_id
group by a.artist_id,a.full_name
limit 5

--Question:-14 --
/*Display the 3 least popular canva sizes.*/

select * from canvas_size

select width
	,row_number() over(Order by width) As Least_Famous
from canvas_size
group by width
order by width
limit 3

--Question:- 15 --
/*Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?*/

select --m.museum_id
	m.name
	,m.state
	,to_timestamp(open,'HH:MI AM') AS Open
	,to_timestamp(close,'HH:MI PM') AS Close
	,to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM') As Open_Duration
from museum_hours mh
JOIN museum m ON m.museum_id=mh.museum_id
order by Open_Duration DESC
limit 1

--Question:-16 --
/*Which museum has the most no of most popular painting style.*/

select m.name
	,count(distinct(w.style)) AS Number_of_Painting_Style
	,rank() over(order by count(w.style) DESC) AS Rank
 from work w
JOIN museum m ON w.museum_id=m.museum_id
group by m.name
limit 1

--Question:-17 --
/* Identify the artists whose paintings are displayed in multiple countries*/

select a.full_name
	,count(distinct(m.country)) AS DisplayIn_No0f_Country
	,rank() over(order by count(distinct(m.country)) DESC) AS rank
from work w
JOIN artist a ON w.artist_id=a.artist_id
JOIN museum m ON m.museum_id=w.museum_id
group by a.full_name
	
--Question:-18 --
/*Identify the artist and the museum where the most expensive and least expensive
painting is placed. Display the artist name, sale_price, painting name, museum
name, museum city and canvas label.*/

select * from
	(select
	 	w.work_id
	 	,m.name
		,w.name
		,a.full_name
		,p.sale_price
		,rank() over(order by p.sale_price DESC ) Heigest_Rate_Rank
		,rank() over(order by p.sale_price ) Lowest_Rate_Rank
	 	,m.city
	 	--,p.canvas
	from work w
	JOIN artist a ON w.artist_id=a.artist_id
	JOIN museum m ON m.museum_id=w.museum_id
	JOIN product_size p ON p.work_id=w.work_id
	)
where Heigest_Rate_Rank=1 OR Lowest_Rate_Rank=1


--Question:-19 --
/*Which country has the 5th highest no of paintings?*/

select * from
	(select m.country
		,count(w.work_id) AS Number_Of_Painting
		,rank() over(order by count(w.work_id ) DESC) AS Rank
	from museum m
	JOIN work w ON w.museum_id=m.museum_id
	GROUP BY m.country
	limit 5
	)
order by rank DESC

--Question:-20 --
/*Which are the 3 most popular and 3 least popular painting styles?.*/

select style
	,count(work_id) AS Number_Of_Painting
	,rank() over(order by count(work_id)) as Rank
from work
where style IS NOT NULL
group by style
limit 3

select style
	,count(work_id) AS Number_Of_Painting
	,rank() over(order by count(work_id) DESC) as Rank
from work
where style IS NOT NULL 
group by style
limit 3


