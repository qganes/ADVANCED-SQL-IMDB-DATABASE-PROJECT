use imdb;

select * from director_mapping;
select * from names;
select * from genre;

select name from names having name like 'christopher %';

-- 1. Count the total number of records in each table of the database. 

Delimiter $$
create procedure Total_count()
Begin 
	select count(*) from  director_mapping;
	select count(*) from genre;
	select count(*) from movie;
	select count(*) from names;
	select count(*) from ratings;
	select count(*) from role_mapping;
end $$
Delimiter ;

call Total_count;

SELECT 
    TABLE_NAME, 
    TABLE_ROWS 
FROM 
    information_schema.TABLES 
WHERE 
    TABLE_SCHEMA = 'imdb';

-- 2.	Identify which columns in the movie table contain null values. 

select * from movie;
select id from movie where id is null;
select title from movie where title is null;
select year from movie where year is null;
select date_published from movie where date_published is null;
select duration from movie where duration is null;
select country from movie where country is null;
select worlwide_gross_income from movie where worlwide_gross_income is null;
select languages from movie where languages is null;
select production_company from movie where production_company is null;

select * from movie where id is null or title is null or year is null or date_published is null or duration is null or country is null or worlwide_gross_income is null or languages is null or production_company is null;


select Column_name from information_schema.COLUMNS where TABLE_NAME = 'movie' 
AND IS_NULLABLE = 'YES';

-- 3.Determine the total number of movies released each year, and analyze how the trend changes month-wise.

select * from movie;
select year, count(title) as Total_Number from movie group by year;

select 
    extract(month from date_published) as release_month, 
    count(*) as total_movie, 
    round(count(*) * 100.0 / (select count(*) from movie), 2) as percentage
from movie
group by  extract(month from date_published)
order by  release_month;

select count(title) as Total_movies, extract(month from date_published) as Month, year from movie group by extract(month from date_published), year order by Month;


-- 4.	How many movies were produced in either the USA or India in the year 2019?

select * from movie;
select count(title), country from movie group by country having country = "USA";
select count(title), country from movie group by country having country = "India";
select count(title), country, year from movie where year = 2019 group by country having country ="USA" or country ="India";

-- 5.	List the unique genres in the dataset, and count how many movies belong exclusively to one genre.

select * from genre;
select count(movie_id) as Total_movies, genre from genre group by genre order by count(movie_id) desc;

-- 6.	Which genre has the highest total number of movies produced? 

select * from genre;
select count(movie_id), genre from genre group by genre order by count(movie_id) desc limit 1;

-- 7.	Calculate the average movie duration for each genre. 

select * from genre;
select * from movie;
select avg(m.duration), g.genre
from movie m left join genre g
on m.id = g.movie_id
group by g.genre order by avg(m.duration) desc;


-- 8.	Identify actors or actresses who have appeared in more than three movies with an average rating below 5. 

select * from ratings;
select * from role_mapping;
select * from movie;

select m.Category, count(m.name_id) as Movies, r.avg_rating
from  role_mapping m inner join ratings r
on m.movie_id = r.movie_id
where r.avg_rating < 5
group by m.name_id, m.category, r.avg_rating having count(m.name_id) > 3 order by movies;

-- 9.	Find the minimum and maximum values for each column in the ratings table, excluding the movie_id column.

select * from ratings;
select min(avg_rating) as Min_avg_rating,max(avg_rating) as Max_avg_rating,
		min(total_votes) as Min_total_votes, max(total_votes) as Max_total_votes,
        min(median_rating) as Min_median_rating,max(median_rating) as Max_median_rating from ratings;

-- 10.	Which are the top 10 movies based on their average rating?

select * from ratings;
select * from movie;
select m.title, r.avg_rating
from movie m inner join ratings r
on m.id = r.movie_id
order by avg_rating desc limit 10;


select movie_id, avg_rating from ratings order by avg_rating desc limit 10;

-- 11.	Summarize the ratings table by grouping movies based on their median ratings.

select * from ratings;
select * from movie;
select count(m.title),r.median_rating
from movie m inner join ratings r
on m.id = r.movie_id
group by r.median_rating order by r.median_rating desc;


-- 12.	How many movies, released in March 2017 in the USA within a specific genre, had more than 1,000 votes?

select * from movie;
select * from genre;
select * from ratings;
select count(title), country, year from movie where year = 2017 group by country having country ="USA";

select m.title, m.year, m.country, group_concat(g.genre), r.total_votes
from movie m inner join genre g
on m.id = g.movie_id
inner join ratings r
on m.id = r.movie_id
where year = 2017
and r.total_votes > 1000 and m.country like '%USA%'
group by m.title, m.year, m.country, r.total_votes
order by r.total_votes desc;

-- 13.	Find movies from each genre that begin with the word “The” and have an average rating greater than 8.

select * from movie;
select * from genre;
select * from ratings;
use imdb;

select m.title, group_concat(g.genre), r.avg_rating
from movie m inner join genre g
on m.id = g.movie_id
inner join ratings r
on m.id = r.movie_id
where r.avg_rating > 8
group by m.title, r.avg_rating having m.title like 'The%';

-- 14.	Of the movies released between April 1, 2018, and April 1, 2019, how many received a median rating of 8?

select * from movie;
select * from ratings;
select m.title, m.date_published, r.median_rating
from movie m inner join ratings r
on r.movie_id = m.id
where m.date_published between '2018-04-01' and '2019-04-01'
and r.avg_rating = 8 order by m.date_published asc;

-- 15.	Do German movies receive more votes on average than Italian movies? 

select * from movie;
select * from ratings;
select m.country, avg(r.total_votes)
from movie m inner join ratings r
on r.movie_id = m.id
where m.country = "Germany" or m.country = "Italy"
group by m.country;

-- 16.	Identify the columns in the names table that contain null values. 

select * from names;
 
select id from names where id is null;
select name from names where name is null;
select height from names where height is null;
select date_of_birth from names where date_of_birth is null;
select known_for_movies from names where known_for_movies is null;


select Column_name from information_schema.COLUMNS where TABLE_NAME = 'names' 
AND IS_NULLABLE = 'YES';

-- 17.	Who are the top two actors whose movies have a median rating of 8 or higher?

select * from names;
select * from movie;
select * from ratings;
select * from role_mapping;

select rm.name_id,n.name,rm.category,m.title as Movie_Name,r.median_rating
from role_mapping rm
inner join movie m
on rm.movie_id = m.id
inner join ratings r 
on rm.movie_id = r.movie_id 
inner join names n
on rm.name_id = n.id
where r.median_rating>=8 order by r.median_rating desc limit 2;


-- 18.	Which are the top three production companies based on the total number of votes their movies received?

select * from movie;
select * from ratings;

select m.production_company, m.title, r.total_votes
from movie m inner join ratings r
on r.movie_id = m.id
order by total_votes desc limit 3;

-- 19.	How many directors have worked on more than three movies?

select * from director_mapping;
select * from movie;
select * from ratings;
select * from names;

select count(dm.name_id) as Movie_count, dm.name_id,n.name
from director_mapping dm inner join names n
on dm.name_id = n.id
inner join movie m
on dm.movie_id = m.id
group by dm.name_id having Movie_count>3 order by Movie_count desc;

use imdb;

-- 20.	Calculate the average height of actors and actresses separately.

select * from role_mapping;
select * from names;

select rm.category, avg(n.height)
from role_mapping rm inner join names n
on n.id = rm.name_id
group by rm.category;

-- 21.	List the 10 oldest movies in the dataset along with their title, country, and director.

select * from movie;
select * from director_mapping;
select * from names;

select dm.movie_id, n.name, m.title, m.date_published, m.country
from director_mapping dm inner join names n
on dm.name_id = n.id
inner join movie m
on dm.movie_id = m.id
order by m.date_published asc limit 10;


-- 22.	List the top 5 movies with the highest total votes, along with their genres.

select * from movie;
select * from genre;
select * from ratings;

select m.title, r.total_votes, group_concat(distinct g.genre) as genre
from movie m inner join genre g
on m.id = g.movie_id
inner join ratings r
on m.id = r.movie_id
group by m.title, r.total_votes
order by r.total_votes desc limit 5;

-- 23.	Identify the movie with the longest duration, along with its genre and production company.

select * from movie;
select * from genre;

select m.title, m.duration, m.production_company, group_concat(distinct g.genre) as genre
from movie m inner join genre g
on m.id = movie_id
group by m.title, m.duration, m.production_company
order by m.duration desc limit 1;

-- 24.	Determine the total number of votes for each movie released in 2018.

select * from movie;
select * from ratings;

select m.title, m.year, r.total_votes
from movie m inner join ratings r
on m.id = r.movie_id
having m.year = 2018
order by r.total_votes desc limit 15;


select worlwide_gross_income from movie where worlwide_gross_income is null;
select count(*) from movie;

-- 25. What is the most common language in which movies were produced?


/*/
select char_length(languages), languages from movie;
select substring(languages,1,2),languages from movie;
select * from Movie;
select count(languages) from movie where languages like '%english%';
select count(languages) from movie where languages like '%german%';
select count(languages) from movie where languages like '%french%';

select Eng_lan,sum(count_eng),Ger_lan,sum(count_ger) FROM (
select 'english' as Eng_lan,
case
when m.languages like '%english%' then count(m.languages)
else 0 
end
as count_Eng,
'german' as Ger_lan,
case
when m.languages like '%german%' then count(m.languages)
else 0 
end count_ger
from movie m group by m.languages) as X group by Eng_lan,Ger_lan;
/*/
select
    Languages,
    COUNT(*) as Movie_count
from (
    select
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(languages, ',', n.n), ',', -1)) as Languages
    from movie
    inner join (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    ) n on CHAR_LENGTH(languages) - CHAR_LENGTH(replace(languages, ',', '')) >= n.n - 1
) sub
group by languages
order by movie_count desc;