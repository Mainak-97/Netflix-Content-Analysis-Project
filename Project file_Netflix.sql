/* Data analysis project:- NETFLIX */

-- Database creation
create database netflix_db;
use netflix_db;

-- Table creation
create table netflix 
(
	show_id	varchar(10),
	type varchar(10),
	title varchar(150),
	director varchar(250),
	casts varchar(1000),
	country	varchar(150),
	date_added varchar(50),
	release_year int,
	rating varchar(15),
    duration varchar(15),
	listed_in varchar(100),
	description varchar(270)
);

-- data(csv) importing
LOAD DATA INFILE 'D:/SQL projects YT/Netflix SQL Project (Zero Analyst)/netflix_titles.csv'
INTO TABLE netflix_db.netflix
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Analysis starts from here

/* Data analysis tasks */

-- 1: Count the Number of Movies and TV Shows.
select 
	type, count(*) as total_number
from netflix 
	group by type;
            
-- 2: Top 3 most common Rating for Movies and TV Shows. 
select 
	type, rating
from
(select 
		type, rating, count(*),
		rank() over(partition by type order by count(*) desc) as position
from netflix
	group by type, rating) as by_rank
where position in (1, 2, 3);

-- 3: List of all movies released in the year of 2020 and 2021
Select 
	title, type, release_year
from netflix 
	where 
		type = "movie" and release_year in (2020, 2021)
order by release_year desc;
        
-- 4: Find the top 5 countries with the most content on Netflix
select 
	country, count(show_id) as total_content
from netflix
where country <> ""
		group by country
		order by total_content desc
limit 5;

-- 5: Identification of the top 10 longest movies
select
	show_id,
    title as movie_name,
    duration as time_in_database,
    cast(substring_index(duration, " ", 1) as unsigned) as movie_time
from netflix 
	where type = "movie"
order by movie_time desc limit 10;

-- 6: Content added in the last 5 years
select *,
    str_to_date(date_added, "%M %d, %Y") as Formatted_date 
from 
	netflix
where
	str_to_date(date_added, "%M %d, %Y") >= date_sub(curdate(), interval 5 year);
    
-- 7: All the movies and TV shows by director 'Rajiv Chilaka'!
select 
	show_id, 
	director, 
    title
from  netflix 
	where director like "%Rajiv Chilaka%";

-- 8: All the TV shows with more than 5 seasons.
select  
	show_id, type, title, duration as default_duration,
    cast(substring_index(duration, " ", 1) as unsigned) as formatted_duration
from netflix 
where 
	type = "tv show"
and
	cast(substring_index(duration, " ", 1) as unsigned) > 5
	order by formatted_duration asc;
    
-- 9: The average numbers of content release in India on netflix with respect to each year.
select 
	released_year,
    round(avg(total),2) as average_movie_count
from
(select 
	release_year as released_year,
    count(show_id) as total
from netflix
	where country like "%India%"
		group by release_year)
as average_for_India
	group by released_year
    order by released_year desc;

-- 10. All the movies that are listed as documentaries.
select 
	show_id, 
    title, 
    listed_in
from netflix 
	where listed_in like "%Documentaries%";

-- 11. All the content without a director.
select * 
	from netflix 
		where trim(director) = "" or director is null;

-- 12. Top 10 Directors with the most titles, who have the most movies or shows on Netflix.
select 
	director, 
	count(title) as total_content
from netflix 
	where director <> ""
	group by director
	order by total_content desc
    limit 10;

-- 13. Content released trend: The number of movies released in each year.
select
	release_year,
    count(title) as total_movies
from netflix
	where release_year is not null
group by release_year
order by release_year desc;

-- 14. The number of titles featuring specific well-known actors, like 'Leonardo DiCaprio' or 'Scarlett Johansson'.
select 
	count(title) as total_movies
from netflix 
	where 
casts like "%Leonardo DiCaprio%"
	or 
casts like "%Scarlett Johansson%";

-- 15. Content with the longest descriptions: display the title and description for understanding content marketing trends.
select 
	title, 
	description, 
	length(description) as length_of_description 
from netflix 
	where length(description) =
	(select max(length(description)) from netflix);