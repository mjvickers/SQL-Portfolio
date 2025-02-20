WITH sr AS (
-- seed rounds
	SELECT
		seed,
		COUNT(*) AS total_teams,
		SUM(CASE WHEN postseason = 'R64' THEN 1 ELSE 0 END) AS r1,
		SUM(CASE WHEN postseason = 'R32' THEN 1 ELSE 0 END) AS r2,
		SUM(CASE WHEN postseason = 'S16' THEN 1 ELSE 0 END) AS r3,
		SUM(CASE WHEN postseason = 'E8' THEN 1 ELSE 0 END) AS r4,
		SUM(CASE WHEN postseason = 'F4' THEN 1 ELSE 0 END) AS r5,
		SUM(CASE 
			WHEN postseason = '2ND' THEN 1 
			WHEN postseason = 'Champions' THEN 1
			ELSE 0 END) AS r6
	FROM postseason
	WHERE seed IS NOT NULL AND postseason IS NOT NULL
	GROUP BY seed
),

er AS (
-- expected rounds
	SELECT
		seed,
		ROUND((COALESCE(r1, 0) * 0.0 +
			COALESCE(r2, 0) * 1.0 +
			COALESCE(r3, 0) * 2.0 +
			COALESCE(r4, 0) * 3.0 +
			COALESCE(r5, 0) * 4.0 +
			COALESCE(r6, 0) * 5.0
		) / total_teams, 2) AS expected_rounds
	FROM sr
	ORDER BY seed ASC
),

ar AS (
-- actual rounds
	SELECT
		team,
		year,
		seed,
		postseason,
		CASE
			WHEN postseason = 'R64' THEN 0
			WHEN postseason = 'R32' THEN 1
			WHEN postseason = 'S16' THEN 2
			WHEN postseason = 'E8' THEN 3
			WHEN postseason = 'F4' THEN 4
			WHEN postseason = '2ND' THEN 5
			WHEN postseason = 'Champions' THEN 5
			ELSE 0
		END AS actual_rounds
	FROM postseason
	INNER JOIN teams ON teams.team_id = postseason.team_id
	INNER JOIN seasons ON seasons.season_id = postseason.season_id
)

SELECT
	team,
	year,
	ar.seed,
	postseason,
	expected_rounds,
	actual_rounds,
	(actual_rounds - expected_rounds) AS cinderella_matrix
FROM ar
INNER JOIN er ON er.seed = ar.seed
ORDER BY cinderella_matrix DESC;