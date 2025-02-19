SELECT
	year,
	teams.team_id,
	team,
	w,
	barthag,
	efg_o,
	efg_d,
	tor,
	tord,
	adjoe,
	adjde,
	adjoe,
	"2p_o",
	"2p_d",
	"3p_o",
	"3p_d",
	ftr,
	ftrd,
	adj_t
FROM teams
INNER JOIN postseason ON postseason.team_id = teams.team_id
INNER JOIN metrics ON metrics.season_id = postseason.season_id
	AND metrics.team_id = teams.team_id
	AND metrics.team_id = postseason.team_id
INNER JOIN seasons ON seasons.season_id = postseason.season_id
	AND seasons.season_id = metrics.season_id
WHERE postseason = 'Champions'
ORDER BY year ASC;