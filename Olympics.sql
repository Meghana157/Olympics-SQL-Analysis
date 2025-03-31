--Olympics data Analysis


CREATE TABLE athelete_events(
	ID INT,
	Name VARCHAR(300),
	Sex CHAR(1) CHECK(Sex IN ('M','F')),
	Age	INT,
	Height INT,
	Weight DECIMAL(10,2),
	Team VARCHAR(300),
	NOC CHAR(3) NOT NULL,
	Games VARCHAR(100),
	Year INT NOT NULL,
	Season VARCHAR(15),
	City VARCHAR(300),
	Sport VARCHAR(100),
	Event VARCHAR(400),
	Medal VARCHAR(10) CHECK(Medal IN ('Gold','Silver','Bronze',NULL))

);


COPY athelete_events FROM 'C:\Program Files\PostgreSQL\17\data\datacopy\athlete_events.csv'
DELIMITER ',' 
CSV HEADER 
NULL AS 'NA';


CREATE TABLE Noc_regions(
	NOC	CHAR(3) PRIMARY KEY,
	region VARCHAR(255) NOT NULL,
	notes VARCHAR(255)
);
 

COPY Noc_regions FROM 'C:\Program Files\PostgreSQL\17\data\datacopy\noc_regions.csv'
DELIMITER ','
CSV HEADER;


--1.Data Cleaning And Preprocessing

--The age, height, and weight columns are not stored as Text

--Handle Missing Data: Identify and count missing values in the age, height, and weight columns.

SELECT COUNT(*) as Total_rows,
COUNT(CASE WHEN age IS NULL THEN 1 END) as Missing_age,
COUNT(CASE WHEN Height IS NULL THEN 1 END) as Missing_height,
COUNT(CASE WHEN Weight IS NULL THEN 1 END) as Missing_Weight
FROM athelete_events;

SELECT * FROM athelete_events 
WHERE age IS NULL or height IS NULL or weight IS NULL
LIMIT 10; 


--Standardize Medal Names: The medal column may contain inconsistent values. If so, write a query to standardize all values to titlecase.

UPDATE athelete_events
SET Medal = INITCAP(Medal)
WHERE Medal IS NOT NULL;

--2.Data Analysis And Calculations

--Top Medal-Winning Countries: Find the top 10 countries with the highest number of total medals won.

SELECT n.region as Country,COUNT(a.Medal) Total_medals_won
FROM athelete_events a
JOIN Noc_regions n ON a.NOC=n.NOC
WHERE a.medal IS NOT NULL
GROUP BY n.region
ORDER BY Total_medals_won DESC
LIMIT 10;

--Medal Distribution By Season: Count the number of medals won by the top 10 countries in the Summer Games versus Winter Games.

WITH Top_countries as (
	SELECT n.region as country,COUNT(a.medal) Total_medals
FROM athelete_events a
JOIN noc_regions n ON a.noc=n.noc
WHERE a.medal IS NOT NULL
GROUP BY n.region
ORDER BY Total_medals DESC
LIMIT 10
)
SELECT t.country,a.season,count(a.medal) as medal_count
FROM athelete_events a
JOIN noc_regions n ON a.noc=n.noc
JOIN Top_countries t ON n.region=t.country
WHERE a.medal IS NOT NULL
GROUP BY t.country,a.season
ORDER BY t.country,a.season;


--Athlete Performance Analysis: Identify the top 5 athletes with the highest number of Olympic medals.

SELECT Name,COUNT(Medal) Total_medals
FROM athelete_events
WHERE medal IS NOT NULL
GROUP BY Name
ORDER BY Total_medals DESC
LIMIT 5;

--Country With The Highest Gold Medal Ratio: Find the country with the highest percentage of Gold medals out of its total medals.

SELECT Team,COUNT(CASE WHEN medal='Gold' THEN 1 END)*100/COUNT(medal) as gold_medal_percentage
FROM athelete_events
WHERE medal IS NOT NULL
GROUP BY Team
order by gold_medal_percentage DESC
LIMIT 1;

--Dynamic Country-Based Medal Count: Create a query that allows users to filter medals won by a selected country.

SELECT team,medal,COUNT(medal) medal_count
FROM athelete_events
WHERE medal IS NOT NULL and team='India'
GROUP BY team,medal
ORDER BY  medal_count DESC;

--Find Athletes Who Competed In Multiple Sports: Retrieve a list of athletes who participated in more than one sport.

SELECT name,COUNT(DISTINCT sport) as sport_count
from athelete_events
GROUP BY name
HAVING COUNT(sport)>1
ORDER BY sport_count DESC;

--Most Successful Athletes Per Country: Find the most successful athlete (most medals won) from each country.


SELECT DISTINCT ON (n.region) n.region as country, a.name as athlete, count(a.medal) as total_medals
FROM athelete_events a
JOIN noc_regions n ON a.noc=n.noc
WHERE a.medal IS NOT NULL
GROUP BY n.region,a.name
ORDER BY n.region,Total_medals DESC;

--Event Popularity Analysis: Identify the top 5 most popular events based on the number of athletes participating.

SELECT event,COUNT(DISTINCT ID) Athletes
FROM athelete_events
GROUP BY event
ORDER BY Athletes DESC
LIMIT 5;


--Region-Based Medal Analysis: Find the total number of medals won by each NOC.

SELECT n.region as Country,a.noc,COUNT(a.medal) medal_count
FROM athelete_events a
JOIN noc_regions n ON a.noc=n.noc
WHERE a.medal IS NOT NULL
GROUP BY a.noc,n.region
ORDER BY medal_count DESC

--Countries That Have Never Won a Medal: List all countries that have participated in the Olympic Games but never won a medal.

SELECT DISTINCT region as country
FROM noc_regions 
WHERE noc NOT IN (
	SELECT DISTINCT noc 
	FROM athelete_events 
	WHERE medal IS NOT NULL
)
ORDER BY country;












