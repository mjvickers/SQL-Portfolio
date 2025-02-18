SELECT
	conf,
	ROUND(AVG(w), 0) AS avg_w,
	ROUND(AVG(barthag), 4) AS avg_barthag,
	ROUND(AVG(efg_o), 2) AS avg_efg_o,
	ROUND(AVG(efg_d), 2) AS avg_efg_d,
	ROUND(AVG(tor), 2) AS avg_tor,
	ROUND(AVG(tord), 2) AS avg_tord,
	ROUND(AVG(adjoe), 2) AS avg_adjoe,
	ROUND(AVG(adjde), 2) AS avg_adjde,
	ROUND((AVG(adjoe) - AVG(adjde)), 2) AS eff_pm,
	ROUND(AVG("2p_o"), 2) AS avg_2p_o,
	ROUND(AVG("2p_d"), 2) AS avg_2p_d,
	ROUND(AVG("3p_o"), 2) AS avg_3p_o,
	ROUND(AVG(ftr), 2) AS avg_ftr,
	ROUND(AVG(ftrd), 2) AS avg_ftrd,
	ROUND(AVG(adj_t), 2) AS avg_adj_t
FROM conferences
INNER JOIN metrics ON metrics.season_id = conferences.season_id
	AND metrics.team_id = conferences.team_id
GROUP BY conf
ORDER BY avg_adjoe DESC;