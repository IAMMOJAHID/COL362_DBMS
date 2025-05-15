SELECT 
    c.caregiver_id,
    COALESCE(p.procedureevents_count, 0) AS procedureevents_count,
    COALESCE(ch.chartevents_count, 0) AS chartevents_count,
    COALESCE(d.datetimeevents_count, 0) AS datetimeevents_count
FROM (
    SELECT DISTINCT caregiver_id FROM icu.procedureevents
    UNION
    SELECT DISTINCT caregiver_id FROM icu.chartevents
    UNION
    SELECT DISTINCT caregiver_id FROM icu.datetimeevents
) c
LEFT JOIN (
    SELECT caregiver_id, COUNT(*) AS procedureevents_count
    FROM icu.procedureevents
    GROUP BY 1
) p ON c.caregiver_id = p.caregiver_id
LEFT JOIN (
    SELECT caregiver_id, COUNT(*) AS chartevents_count
    FROM icu.chartevents
    GROUP BY 1
) ch ON c.caregiver_id = ch.caregiver_id
LEFT JOIN (
    SELECT caregiver_id, COUNT(*) AS datetimeevents_count
    FROM icu.datetimeevents
    GROUP BY 1
) d ON c.caregiver_id = d.caregiver_id
ORDER BY 1, 2, 3, 4;