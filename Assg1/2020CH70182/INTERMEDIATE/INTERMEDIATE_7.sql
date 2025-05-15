WITH first_last_admissions AS (
    SELECT subject_id,
           MIN(admittime) AS first_admit,
           MAX(admittime) AS last_admit
    FROM hosp.admissions
    GROUP BY 1
),
matching_patients AS (
    SELECT f.subject_id, p.gender
    FROM first_last_admissions f
    JOIN hosp.patients p ON f.subject_id = p.subject_id
    JOIN hosp.diagnoses_icd d1 ON f.subject_id = d1.subject_id 
                          AND d1.hadm_id = (SELECT hadm_id FROM hosp.admissions WHERE subject_id = f.subject_id AND admittime = f.first_admit LIMIT 1)
    JOIN hosp.diagnoses_icd d2 ON f.subject_id = d2.subject_id 
                          AND d2.hadm_id = (SELECT hadm_id FROM hosp.admissions WHERE subject_id = f.subject_id AND admittime = f.last_admit LIMIT 1)
    GROUP BY 1, 2
    HAVING ARRAY_AGG(DISTINCT d1.icd_code ORDER BY d1.icd_code) = ARRAY_AGG(DISTINCT d2.icd_code ORDER BY d2.icd_code)
),
gender_distribution AS (
    SELECT gender, 
           COUNT(*) * 100.0 / (SELECT COUNT(*) FROM matching_patients) AS percentage
    FROM matching_patients
    GROUP BY 1
)
SELECT gender, ROUND(percentage, 2) AS percentage
FROM gender_distribution
ORDER BY 2 DESC;