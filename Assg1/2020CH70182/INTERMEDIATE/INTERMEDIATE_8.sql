SELECT subject_id, 
       AVG(dischtime::timestamp - admittime::timestamp) AS avg_duration
FROM hosp.admissions
WHERE dischtime IS NOT NULL
GROUP BY 1
ORDER BY 1;
