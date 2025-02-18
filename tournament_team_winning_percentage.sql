WITH twl AS (
-- tournament wins & losses
SELECT
	teams.team_id,
	team,
	SUM(CASE
		WHEN postseason = 'R68' THEN 0
		WHEN postseason = 'R64' THEN 0
		WHEN postseason = 'R32' THEN 1
		WHEN postseason = 'S16' THEN 2
		WHEN postseason = 'E8' THEN 3
		WHEN postseason = 'F4' THEN 4
		WHEN postseason = '2ND' THEN 5
		WHEN postseason = 'Champions' THEN 6
		ELSE 0
	END) AS tournament_wins,
	SUM(CASE
		WHEN postseason = 'Champions' THEN 0
		ELSE 1
	END) AS tournament_losses
FROM teams
INNER JOIN postseason ON teams.team_id = postseason.team_id
GROUP BY teams.team_id, team
ORDER BY tournament_wins DESC
)

SELECT
	team_id,
	team,
	tournament_wins,
	tournament_losses,
	CONCAT(tournament_wins, '-', tournament_losses) AS win_loss_record,
	ROUND((CAST(tournament_wins AS DECIMAL) / (tournament_wins + tournament_losses)), 4) AS winning_percentage
FROM twl
ORDER BY winning_percentage DESC;