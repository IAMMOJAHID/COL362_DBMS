WITH Table1 AS (
    SELECT subject_id, hadm_id, admittime, dischtime
    FROM hosp.admissions
    ORDER BY 3
    LIMIT 200
),
Table2 AS (
    SELECT a.subject_id AS subject_id1, 
           b.subject_id AS subject_id2
    FROM Table1 a
    JOIN Table1 b 
        ON a.subject_id <> b.subject_id
        AND a.admittime < b.dischtime 
        AND a.dischtime > b.admittime
)
SELECT CASE 
           WHEN EXISTS (
               SELECT 1 FROM Table2 
               WHERE subject_id1 = 10006580 AND subject_id2 = 10003400
           ) 
           THEN 1 ELSE 0 
       END AS path_exists;
