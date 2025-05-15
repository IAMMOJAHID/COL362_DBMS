WITH Table1 AS (
    SELECT subject_id, hadm_id, admittime, dischtime
    FROM hosp.admissions
    ORDER BY 3
    LIMIT 200
),
Table2 AS (
    SELECT a.subject_id AS subject_id1, 
           b.subject_id AS subject_id2, 
           a.hadm_id AS hadm_id1, 
           b.hadm_id AS hadm_id2
    FROM Table1 a
    JOIN Table1 b 
        ON a.subject_id < b.subject_id 
        AND a.admittime < b.dischtime 
        AND a.dischtime > b.admittime
),
Table3 AS (
    SELECT DISTINCT oa.subject_id1, oa.subject_id2
    FROM Table2 oa
    JOIN hosp.diagnoses_icd d1 ON oa.hadm_id1 = d1.hadm_id
    JOIN hosp.diagnoses_icd d2 ON oa.hadm_id2 = d2.hadm_id
    WHERE d1.icd_code = d2.icd_code AND d1.icd_version = d2.icd_version
)

SELECT subject_id1, subject_id2
FROM Table3
ORDER BY 1, 2;