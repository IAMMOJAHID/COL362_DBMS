SELECT subject_id, pharmacy_id
FROM hosp.prescriptions
GROUP BY 1, 2
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC, 1, 2;