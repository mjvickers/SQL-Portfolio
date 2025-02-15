WITH cm AS (
-- champion metrics
SELECT
	season_id,
	team_id,
	w,
	RANK() OVER(
		PARTITION BY season_id ORDER BY w DESC
	) AS win_rank
FROM metrics
)

SELECT
	teams.team_id,
	team,
	conf AS conference,
	seed,
	w AS rs_wins,
	win_rank,
	postseason AS mm_result,
	year
FROM teams
INNER JOIN conferences AS conf ON conf.team_id = teams.team_id
INNER JOIN seasons AS szn ON szn.season_id = conf.season_id
INNER JOIN postseason AS pstszn ON pstszn.team_id = teams.team_id
	AND pstszn.team_id = conf.team_id
	AND pstszn.season_id = szn.season_id
INNER JOIN cm ON cm.team_id = teams.team_id
	AND cm.team_id = conf.team_id
	AND cm.season_id = szn.season_id
	ANd cm.season_id = pstszn.season_id
WHERE postseason in ('Champions', '2ND')
ORDER BY year ASC, mm_result;