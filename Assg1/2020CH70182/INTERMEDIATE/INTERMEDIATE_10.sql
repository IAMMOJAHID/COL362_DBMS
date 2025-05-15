WITH first_admissions AS (
    SELECT a.subject_id, a.hadm_id, a.admittime AS first_admit
    FROM hosp.admissions a
    WHERE a.admittime = (
        SELECT MIN(admittime) 
        FROM hosp.admissions 
        WHERE subject_id = a.subject_id
    )
),
kidney_patients AS (
    SELECT fa.subject_id, fa.first_admit
    FROM first_admissions fa
    JOIN hosp.diagnoses_icd d ON fa.hadm_id = d.hadm_id
    JOIN hosp.d_icd_diagnoses di ON d.icd_code = di.icd_code 
                                AND d.icd_version = di.icd_version
    WHERE di.long_title ILIKE '%kidney%'
),
readmitted_patients AS (
    SELECT DISTINCT a.subject_id
    FROM kidney_patients kp
    JOIN hosp.admissions a ON kp.subject_id = a.subject_id
    WHERE a.admittime > kp.first_admit
)
SELECT subject_id
FROM kidney_patients
WHERE subject_id IN (SELECT subject_id FROM readmitted_patients)
ORDER BY first_admit DESC
LIMIT 100;