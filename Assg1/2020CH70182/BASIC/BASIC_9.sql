SELECT DISTINCT d.icd_code, d.icd_version FROM hosp.diagnoses_icd d JOIN hosp.procedures_icd p ON d.icd_code = p.icd_code AND d.icd_version = p.icd_version ORDER BY d.icd_code, d.icd_version;
