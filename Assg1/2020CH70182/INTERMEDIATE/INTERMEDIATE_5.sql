SELECT a.subject_id, 
       a.hadm_id, 
       COALESCE(COUNT(DISTINCT p.icd_code), 0) AS count_procedures, 
       COALESCE(COUNT(DISTINCT d.icd_code), 0) AS count_diagnoses
FROM hosp.admissions a
LEFT JOIN hosp.procedures_icd p ON a.hadm_id = p.hadm_id
LEFT JOIN hosp.diagnoses_icd d ON a.hadm_id = d.hadm_id
WHERE a.admission_type = 'URGENT' 
AND a.hospital_expire_flag = 1
GROUP BY 1, 2
ORDER BY 1, 2, 3 DESC, 4 DESC;
