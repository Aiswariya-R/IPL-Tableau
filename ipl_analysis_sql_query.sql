--1. Top 10 batters based on past 3 years total runs scored

select batsmanName, sum(runs) as total_runs_scored
from planar-contact-401917.ipl_dataset.batting_summary
group by batsmanName
order by sum(runs) desc
limit 10

--2. Top 10 batters based on past 3 years batting average. (min 60 balls faced in each season)

select b.batsmanName,sum(b.runs)as total_runs,sum(b.balls)as balls_faced,sum(case when b.out_not_out='out'then 1 else 0 end) as out_total,round(sum(b.runs)/sum(case when b.out_not_out='out'then 1 else 0 end),2) as batting_average
from planar-contact-401917.ipl_dataset.batting_summary as b
join planar-contact-401917.ipl_dataset.match_summary as m on
m.match_id = b.match_id
where m.year in (2021, 2022, 2023) 
group by b.batsmanName
having 
 SUM(CASE WHEN m.year = 2021 THEN b.balls ELSE 0 END) >= 60
    AND SUM(CASE WHEN m.year = 2022 THEN b.balls ELSE 0 END) >= 60 
    AND SUM(CASE WHEN m.year = 2023 THEN b.balls ELSE 0 END) >= 60
order by batting_average desc, balls_faced asc
limit 10

--3. Top 10 batters based on past 3 years strike rate (min 60 balls faced in each season)

select b.batsmanName, round(avg(cast(b.SR as float64)),2) as strike_rate
from planar-contact-401917.ipl_dataset.batting_summary as b
join planar-contact-401917.ipl_dataset.match_summary as m on
m.match_id = b.match_id
where m.year in (2021, 2022, 2023) and b.SR != '-'
group by b.batsmanName
having 
 SUM(CASE WHEN m.year = 2021 THEN b.balls ELSE 0 END) >= 60
    AND SUM(CASE WHEN m.year = 2022 THEN b.balls ELSE 0 END) >= 60
    AND SUM(CASE WHEN m.year = 2023 THEN b.balls ELSE 0 END) >= 60
order by strike_rate desc
limit 10

--4. Top 10 bowlers based on past 3 years total wickets taken.

select bowlerName, sum(wickets) as total_wickets
from planar-contact-401917.ipl_dataset.bowling_summary
group by bowlerName
order by total_wickets desc
limit 10

--5. Top 10 bowlers based on past 3 years bowling average. (min 60 balls bowled in each season)

select bo.bowlerName, round(sum(bo.runs)/sum(bo.wickets),2) as bowling_average
from planar-contact-401917.ipl_dataset.bowling_summary as bo
join planar-contact-401917.ipl_dataset.match_summary as m on
m.match_id = bo.match_id
where m.year in (2021, 2022, 2023)
group by bo.bowlerName
having 
 SUM(CASE WHEN m.year = 2021 THEN bo.overs ELSE 0 END) >= 10
    AND SUM(CASE WHEN m.year = 2022 THEN bo.overs ELSE 0 END) >= 10
    AND SUM(CASE WHEN m.year = 2023 THEN bo.overs ELSE 0 END) >= 10
order by bowling_average 
limit 10

--6. Top 10 bowlers based on past 3 years economy rate. (min 60 balls bowled in each season)

select bo.bowlerName, round(avg(bo.economy),2) as economy_rate
from planar-contact-401917.ipl_dataset.bowling_summary as bo
join planar-contact-401917.ipl_dataset.match_summary as m on
m.match_id = bo.match_id
where m.year in (2021, 2022, 2023)
group by bo.bowlerName
having 
 SUM(CASE WHEN m.year = 2021 THEN bo.overs ELSE 0 END) >= 10
    AND SUM(CASE WHEN m.year = 2022 THEN bo.overs ELSE 0 END) >= 10
    AND SUM(CASE WHEN m.year = 2023 THEN bo.overs ELSE 0 END) >= 10
order by economy_rate
limit 10

--7. Top 5 batters based on past 3 years boundary % (fours and sixes)

select b.batsmanName, sum(b._4s + b._6s) as boundary, 
case when sum(b.runs) = 0 then 0
else
(round((sum(b._4s+b._6s)/sum(b.runs)) *100,2))
end as boundary_percentage
from planar-contact-401917.ipl_dataset.batting_summary as b
join planar-contact-401917.ipl_dataset.match_summary as m on
m.match_id = b.match_id
where m.year in (2021, 2022, 2023)
group by b.batsmanName 
having 
 SUM(CASE WHEN m.year = 2021 THEN b.balls ELSE 0 END) >= 60
    AND SUM(CASE WHEN m.year = 2022 THEN b.balls ELSE 0 END) >= 60
    AND SUM(CASE WHEN m.year = 2023 THEN b.balls ELSE 0 END) >= 60
order by boundary_percentage desc, boundary desc
limit 5

--8. Top 5 bowlers based on past 3 years dot ball % (min 60 balls bowled in each season)

select bo.bowlerName, sum(bo._0s) as dot_balls, round((sum(bo._0s)/sum(bo.overs*6))*100,2) as dot_ball_percentage
from planar-contact-401917.ipl_dataset.bowling_summary as bo
join planar-contact-401917.ipl_dataset.match_summary as m on
m.match_id = bo.match_id
where m.year in (2021, 2022, 2023)
group by bo.bowlerName
having 
 SUM(CASE WHEN m.year = 2021 THEN bo.overs ELSE 0 END) >= 10
    AND SUM(CASE WHEN m.year = 2022 THEN bo.overs ELSE 0 END) >= 10
    AND SUM(CASE WHEN m.year = 2023 THEN bo.overs ELSE 0 END) >= 10
order by dot_ball_percentage desc, dot_balls desc
limit 5

--9. Top 4 teams based on past 3 years winning %

SELECT team,count(*) as total_matches, (SUM(CASE WHEN team = winner THEN 1 ELSE 0 END)) as total_wins, ROUND((SUM(CASE WHEN team = winner THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS win_percentage
FROM
    (SELECT team1 AS team, winner FROM planar-contact-401917.ipl_dataset.match_summary
     UNION ALL
     SELECT team2 AS team, winner FROM planar-contact-401917.ipl_dataset.match_summary) AS teams
GROUP BY team
order by win_percentage desc, total_wins
limit 4

--10.Top 2 teams with the highest number of wins achieved by chasing targets over the past 3 years

select team2, sum(case when team2= winner then 1 else 0 end) as chasing_wins
from planar-contact-401917.ipl_dataset.match_summary
group by team2
order by chasing_wins desc
limit 3