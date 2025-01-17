SELECT
    teams.team,
    conferences.conf,
    seasons.year
FROM seasons
INNER JOIN conferences ON conferences.season_id = seasons.season_id
INNER JOIN postseason ON postseason.season_id = seasons.season_id 
    AND postseason.team_id = conferences.team_id
INNER JOIN teams ON teams.team_id = conferences.team_id
WHERE postseason.postseason = 'Champions'
ORDER BY seasons.year ASC;