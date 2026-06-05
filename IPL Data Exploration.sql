-- Q1 Find the Total Spending on players for each team

SELECT i.Team , SUM(i.Price_in_cr ) AS 'Total spending'
FROM IPLPlayers i 
GROUP BY i.Team 
ORDER BY 'Total spending' DESC 


-- Q2 Find the top 3 highest-paid "All rounders" across all teams

SELECT TOP 3
	i.Player ,
	i.Team ,
	i.[Role] ,
	i.Price_in_cr 
FROM IPLPlayers i 
WHERE 
	i.[Role] = 'All-rounder'
ORDER BY Price_in_cr DESC 


-- Q3 Find the highest-priced player in each team

WITH CTE_MP AS(
	SELECT i.Team , MAX(i.Price_in_cr) AS MaxPrice
	FROM IPLPlayers i 
	GROUP BY i.Team
)
SELECT i.Team , i.Player , c.MaxPrice 
FROM IPLPlayers i 
JOIN CTE_MP AS c ON i.Team = c.Team 
WHERE i.Price_in_cr = c.MaxPrice 


-- Q4 Rank players by their price within each team & list the top 2 for every team

WITH RankedPlayers AS ( 
	SELECT i.Player , i.Team , i.Price_in_cr,
	ROW_NUMBER() OVER (PARTITION BY i.Team ORDER BY i.Price_in_cr DESC) AS RankWithinTeam
	FROM IPLPlayers i 
	)
SELECT Player, Team , Price_in_cr , RankWithinTeam 
FROM RankedPlayers 
WHERE RankWithinTeam <= 2


-- Q5 Find the most expensive player from each Team, along with the second-most expensive player's name and price

WITH RankedPlayers AS ( 
	SELECT i.Player , i.Team , i.Price_in_cr,
	ROW_NUMBER() OVER (PARTITION BY i.Team ORDER BY i.Price_in_cr DESC) AS RankWithinTeam
	FROM IPLPlayers i 
	)
SELECT Team, 
	MAX(CASE WHEN RankWithinTeam = 1 THEN Player END) AS MostExpensivePlayer,
	MAX(CASE WHEN RankWithinTeam = 1 THEN Price_in_cr END) AS HighestPrice,
	MAX(CASE WHEN RankWithinTeam = 2 THEN Player END) AS SecondMostExpensivePlayer,
	MAX(CASE WHEN RankWithinTeam = 2 THEN Price_in_cr END) AS SecondMostHighestPrice
FROM RankedPlayers 
GROUP BY Team 


-- Q6 Calculate the percentage contribution of each player's price to their team's total spending

SELECT 
	i.Player , 
	i.Team ,
	(i.Price_in_cr/ SUM(i.Price_in_cr) OVER (PARTITION BY i.Team))*100 AS 'ContributionPercentage'
FROM IPLPlayers i 


-- Q7 Classify players as 'High', 'Medium', or 'Low' priced based on the following rules:
-- High: Price > 15 cr
-- Medium: Price between 5-15 cr
-- Low: Price < 5 cr
-- And find out the number of players in each bracket

WITH CTE_BR AS (
	SELECT i.Player , i.Team , i.Price_in_cr ,
		CASE 
			WHEN i.Price_in_cr > 15 THEN 'High'
			WHEN i.Price_in_cr BETWEEN 5 AND 15 THEN 'Medium'
			ELSE 'Low'
		END AS PriceCategory
	FROM IPLPlayers i 
)
SELECT Team, PriceCategory, COUNT(*) AS 'NoOfPlayers'
FROM CTE_BR 
GROUP BY Team, PriceCategory 
ORDER BY Team , PriceCategory 


-- Q8 Find the average price of Indian players and compare it with overseas players using a subquery

SELECT 
	'Indian' AS PlayerType,
		(SELECT AVG(i.Price_in_cr) 
		FROM IPLPlayers i 
		WHERE i.[Type] LIKE 'Indian%') AS 'AvgPrice'
UNION ALL
SELECT 
	'Overseas' AS PlayerType,
		(SELECT AVG(i.Price_in_cr) 
		FROM IPLPlayers i 
		WHERE i.[Type] LIKE 'Overseas%') AS 'AvgPrice'
		

-- Q9 Identify players who earn more than the average price of their team

SELECT i.Player , i.Team , i.Price_in_cr 
FROM IPLPlayers i 
WHERE i.Price_in_cr > (
	SELECT AVG(i.Price_in_cr)
	FROM IPLPlayers i 
	WHERE i.Team = i.Team )

	
-- Q10 For each role, find the most expensive player and their price using a correlated subquery
	
SELECT Player , Team , [Role] , Price_in_cr 
FROM IPLPlayers i
WHERE Price_in_cr = (
	SELECT MAX(Price_in_cr)
	FROM IPLPlayers
	WHERE [Role] = i.[Role] 
					)



