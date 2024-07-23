select count(*) from sharktank
select * from sharktank limit 2
truncate  table sharktank

LOAD DATA INFILE "C:/ProgramData/MySQL/sharktank.csv"
INTO TABLE sharktank
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- 1 You Team have to  promote shark Tank India  season 4, The senior come up with the idea to show highest funding domain wise  and you were assigned the task to  show the same.
SELECT *
FROM (
    SELECT industry, `Total_Deal_Amount(in_lakhs)`,
           ROW_NUMBER() OVER (PARTITION BY industry ORDER BY `Total_Deal_Amount(in_lakhs)` DESC) AS rnk
    FROM sharktank
) t
WHERE rnk = 1;


-- 2 You have been assigned the role of finding the domain where female as pitchers have female to male pitcher ratio >70%
select * ,(female/Male)*100 as ratio from
(
select Industry, sum(female_presenters) as 'Female', sum(male_presenters) as 'Male' from sharktank group by Industry having sum(female_presenters)>0  and sum(male_presenters)>0
)m where (female/Male)*100>70



-- 3 You are working at marketing firm of Shark Tank India, you have got the task to determine volume of per year sale pitch made, pitches who received 
-- offer and pitches that were converted. Also show the percentage of pitches converted and percentage of pitches received.
	select k.season_number , k.total_pitches , m.pitches_received, ((pitches_received/total_pitches)*100) as 'percentage  pitches received', l.pitches_converted 
	,((pitches_converted/pitches_received)*100) as 'Percentage pitches converted' 
	 from
	(
			(
			select season_number , count(startup_Name) as 'Total_pitches' from sharktank group by season_number
			)k 
			inner join
			(
			select season_number , count(startup_name) as 'Pitches_Received' from sharktank where received_offer='yes' group by season_number
			)m on k.season_number= m.season_number
			inner join
			(
			select season_number , count(Accepted_offer) as 'Pitches_Converted' from sharktank where  Accepted_offer='Yes' group by  season_number 
			)l on m.season_number= l.season_number
	)


-- 4 As a venture capital firm specializing in investing in startups featured on a renowned entrepreneurship TV show, how would you determine the season with the
-- highest average monthly sales and identify the top 5 industries with the highest average monthly sales during that season to optimize investment decisions?
-- Get the season with the highest average monthly sales
-- Get the season with the highest average monthly sales
SELECT season_number INTO @seas
FROM (
    SELECT season_number, ROUND(AVG(`Monthly_Sales(in_lakhs)`), 2) AS average
    FROM sharktank
    WHERE `Monthly_Sales(in_lakhs)` != 'Not_mentioned'
    GROUP BY season_number
) k
ORDER BY average DESC
LIMIT 1;

-- Verify the value of @seas
SELECT @seas;

-- Get the top 5 industries by average monthly sales for the selected season
SELECT industry, ROUND(AVG(`Monthly_Sales(in_lakhs)`), 2) AS average
FROM sharktank
WHERE season_number = @seas AND `Monthly_Sales(in_lakhs)` != 'Not_mentioned'
GROUP BY industry
ORDER BY average DESC
LIMIT 5;


-- 5.As a data scientist at our firm, your role involves solving real-world challenges like identifying industries with consistent increases in funds raised over 
-- multiple seasons. This requires focusing on industries where data is available across all three years.
--  Once these industries are pinpointed, your task is to delve into the specifics, analyzing the number of pitches made, offers received, and offers 
-- converted per season within each industry.



-- Summarize deal amounts by industry and season number
SELECT industry, season_number, SUM(`Total_Deal_Amount(in_lakhs)`) AS total_deal_amount
FROM sharktank
GROUP BY industry, season_number;

-- Using CTE for valid industries and final aggregation
WITH ValidIndustries AS (
    SELECT 
        industry, 
        MAX(CASE WHEN season_number = 1 THEN `Total_Deal_Amount(in_lakhs)` END) AS season_1,
        MAX(CASE WHEN season_number = 2 THEN `Total_Deal_Amount(in_lakhs)` END) AS season_2,
        MAX(CASE WHEN season_number = 3 THEN `Total_Deal_Amount(in_lakhs)` END) AS season_3
    FROM sharktank 
    GROUP BY industry 
    HAVING season_3 > season_2 AND season_2 > season_1 AND season_1 IS NOT NULL
)
SELECT 
    t.season_number,
    t.industry,
    COUNT(t.Startup_Name) AS Total,
    COUNT(CASE WHEN t.Received_Offer = 'Yes' THEN t.Startup_Name END) AS Received,
    COUNT(CASE WHEN t.Accepted_Offer = 'Yes' THEN t.Startup_Name END) AS Accepted
FROM sharktank AS t
JOIN ValidIndustries AS v 
ON t.industry = v.industry
GROUP BY t.season_number, t.industry
LIMIT 0, 1000;


-- 7. In the world of startup investing, we're curious to know which big-name investor, often referred to as "sharks," tends to put the most money into each
-- deal on average. This comparison helps us see who's the most generous with their investments and how they measure up against their fellow investors.

SELECT sharkname, ROUND(AVG(investment), 2) AS 'average'
FROM (
    SELECT `Namita_Investment_Amount(in lakhs)` AS investment, 'Namita' AS sharkname 
    FROM sharktank 
    WHERE `Namita_Investment_Amount(in lakhs)` > 0
    UNION ALL
    SELECT `Vineeta_Investment_Amount(in_lakhs)` AS investment, 'Vineeta' AS sharkname 
    FROM sharktank 
    WHERE `Vineeta_Investment_Amount(in_lakhs)` > 0
    UNION ALL
    SELECT `Anupam_Investment_Amount(in_lakhs)` AS investment, 'Anupam' AS sharkname 
    FROM sharktank 
    WHERE `Anupam_Investment_Amount(in_lakhs)` > 0
    UNION ALL
    SELECT `Aman_Investment_Amount(in_lakhs)` AS investment, 'Aman' AS sharkname 
    FROM sharktank 
    WHERE `Aman_Investment_Amount(in_lakhs)` > 0
    UNION ALL
    SELECT `Peyush_Investment_Amount((in_lakhs)` AS investment, 'Peyush' AS sharkname 
    FROM sharktank 
    WHERE `Peyush_Investment_Amount((in_lakhs)` > 0
    UNION ALL
    SELECT `Amit_Investment_Amount(in_lakhs)` AS investment, 'Amit' AS sharkname 
    FROM sharktank 
    WHERE `Amit_Investment_Amount(in_lakhs)` > 0
    UNION ALL
    SELECT `Ashneer_Investment_Amount` AS investment, 'Ashneer' AS sharkname 
    FROM sharktank 
    WHERE `Ashneer_Investment_Amount` > 0
) k 
GROUP BY sharkname;











