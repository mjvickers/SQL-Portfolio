WITH bd AS (
-- base data
SELECT
	year,
	team,
	conf,
	seed,
	postseason,
	barthag,
	wab,
	w,
	adjoe,
	adjde,
	tor,
	tord,
	orb,
	drb,
	ftr,
	ftrd,
	"2p_o",
	"2p_d",
	"3p_o",
	"3p_d",
	adj_t
FROM teams t
INNER JOIN conferences c ON t.team_id = c.team_id
INNER JOIN seasons s ON c.season_id = s.season_id
INNER JOIN postseason p ON s.season_id = p.season_id
	AND c.season_id = p.season_id
	AND t.team_id = p.team_id
INNER JOIN metrics m ON m.season_id = c.season_id
	AND m.season_id = s.season_id
	AND m.season_id = p.season_id
	AND m.team_id = t.team_id
	AND m.team_id = c.team_id
	AND m.team_id = p.team_id
WHERE postseason IS NOT NULL AND seed IS NOT NULL
),

sr AS (
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
	FROM bd
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
	FROM bd
),

wbp AS (
-- wab and barthag performance
	SELECT
		bd.year,
		bd.team,
		bd.seed,
		actual_rounds,
		expected_rounds,
		ROUND((actual_rounds - expected_rounds), 3) AS round_perform,
		ROUND(wab - (SELECT
					AVG(wab)
				FROM bd
				WHERE seed = bd.seed), 3) AS wab_perform,
		ROUND(barthag - (SELECT
						AVG(barthag)
					FROM bd
					WHERE seed = bd.seed), 3) AS barthag_perform,
		ROUND(adjoe - (SELECT
						AVG(adjoe)
					FROM bd
					WHERE seed = bd.seed), 3) AS adjoe_perform,
		ROUND((SELECT
						AVG(adjde)
					FROM bd
					WHERE seed = bd.seed) - adjde, 3) AS adjde_perform
	FROM bd
	INNER JOIN er ON er.seed = bd.seed
	INNER JOIN ar ON ar.year = bd.year
		AND ar.team = bd.team
		AND ar.seed = bd.seed
),

cm AS (
-- cinderella matrix
	SELECT
		year,
		team,
		seed,
		(barthag_perform  
		+ adjoe_perform 
		+ adjde_perform 
		+ round_perform) AS cinderella_matrix
	FROM wbp
),

acm AS(
-- average seed cinderella matrix
	SELECT
		seed,
		ROUND(AVG(cinderella_matrix), 3) AS avg_seed_cm
	FROM cm
	GROUP BY seed
),

arcm AS (
-- average round cinderella matrix
	SELECT
		postseason,
		ROUND(AVG(cinderella_matrix), 3) AS avg_round_cm
	FROM cm
	INNER JOIN postseason ON postseason.seed = cm.seed
	GROUP BY postseason
),

cmr AS (
-- cinderella matrix rank
	SELECT
		year,
		team,
		cm.seed,
		cinderella_matrix,
		RANK() OVER(
			PARTITION BY year ORDER BY cinderella_matrix DESC
		) AS cm_year_rank,
		avg_seed_cm
	FROM cm
	INNER JOIN acm ON acm.seed = cm.seed
)

SELECT
	bd.year,
	bd.team,
	conf,
	bd.seed,
	bd.postseason,
	barthag,
	barthag_perform,
	wab,
	wab_perform,
	w,
	adjoe,
	adjoe_perform,
	adjde,
	adjde_perform,
	tor,
	tord,
	orb,
	drb,
	ftr,
	ftrd,
	"2p_o",
	"2p_d",
	"3p_o",
	"3p_d",
	adj_t,
	actual_rounds,
	expected_rounds,
	round_perform,
	cinderella_matrix,
	cm_year_rank,
	avg_seed_cm,
	(cinderella_matrix - avg_seed_cm) AS cm_perform,
	avg_round_cm,
	(cinderella_matrix - avg_round_cm) AS cm_round_perform
FROM bd
INNER JOIN wbp ON wbp.year = bd.year
	AND wbp.team = bd.team
	AND wbp.seed = bd.seed
INNER JOIN cmr ON cmr.year = bd.year
	AND cmr.year = wbp.year
	AND cmr.team = wbp.team
	AND cmr.team = bd.team
	AND cmr.seed = bd.seed
	AND cmr.seed = wbp.seed
INNER JOIN arcm ON arcm.postseason = bd.postseason
ORDER BY cinderella_matrix DESC;
	