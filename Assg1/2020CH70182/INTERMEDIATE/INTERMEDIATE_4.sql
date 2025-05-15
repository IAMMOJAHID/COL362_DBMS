SELECT d.subject_id, 
       COUNT(DISTINCT a.hadm_id) AS count_admissions, 
       DATE_PART('year', a.admittime::TIMESTAMP) AS year
FROM hosp.diagnoses_icd d
JOIN hosp.d_icd_diagnoses di ON d.icd_code = di.icd_code AND d.icd_version = di.icd_version
JOIN hosp.admissions a ON d.hadm_id = a.hadm_id
WHERE di.long_title ILIKE '%infection%'
GROUP BY d.subject_id, DATE_PART('year', a.admittime::TIMESTAMP)
HAVING COUNT(DISTINCT a.hadm_id) > 1
ORDER BY 3, 2 DESC, 1;
