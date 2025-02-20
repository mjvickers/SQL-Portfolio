SELECT
	year,
	postseason,
	team,
	conf,
	seed,
	wab,
	barthag,
	adjoe,
	adjde
FROM teams
INNER JOIN conferences ON conferences.team_id = teams.team_id
INNER JOIN seasons ON seasons.season_id = conferences.season_id
INNER JOIN postseason ON postseason.season_id = seasons.season_id
	AND postseason.team_id = teams.team_id
	AND postseason.team_id = conferences.team_id
INNER JOIN metrics ON metrics.season_id = seasons.season_id
	AND metrics.season_id = postseason.season_id
	AND metrics.team_id = teams.team_id
	AND metrics.team_id = conferences.team_id
	AND metrics.team_id = postseason.team_id
WHERE postseason IS NOT NULL
ORDER BY year ASC, seed ASC;
	