SELECT 
    d.subject_id,
    COUNT(DISTINCT d.hadm_id) AS total_admissions,
    COUNT(DISTINCT ARRAY[d.icd_code]) AS num_distinct_diagnoses_set_count,
    COUNT(DISTINCT ARRAY[p.drug]) AS num_distinct_medications_set_count
FROM 
    hosp.diagnoses_icd d
LEFT JOIN 
    hosp.prescriptions p ON d.subject_id = p.subject_id AND d.hadm_id = p.hadm_id
GROUP BY 
    1
HAVING 
    COUNT(DISTINCT d.hadm_id) >= 3 
    AND (
        COUNT(DISTINCT ARRAY[d.icd_code]) >= 3 
        OR COUNT(DISTINCT ARRAY[p.drug]) >= 3
    )
ORDER BY 
    2 DESC, 
    3 DESC, 
    1 ASC;