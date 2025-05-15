SELECT ROUND(AVG(CAST(o.result_value AS NUMERIC)), 10) AS avg_BMI
FROM hosp.omr o
JOIN (
    SELECT p.subject_id
    FROM hosp.prescriptions p
    WHERE p.drug IN ('OxyCODONE (Immediate Release)', 'Insulin')
    GROUP BY p.subject_id
    HAVING COUNT(DISTINCT p.drug) = 2
) t1 ON o.subject_id = t1.subject_id
WHERE o.result_name = 'BMI';