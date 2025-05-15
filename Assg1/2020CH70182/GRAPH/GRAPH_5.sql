
WITH RECURSIVE shortest_paths AS (

    SELECT subject_id1 AS start_id, 
           subject_id2 AS connected_id, 
           1 AS path_length
    FROM (
        SELECT a.subject_id AS subject_id1, 
               b.subject_id AS subject_id2
        FROM hosp.admissions a
        JOIN hosp.admissions b 
            ON a.subject_id <> b.subject_id
            and a.admittime < b.dischtime 
            and a.dischtime > b.admittime
        ORDER BY a.admittime
        limit 200
    ) directed_edges
    WHERE subject_id1 = 10037861

    UNION ALL

    select sp.start_id, d.subject_id2, sp.path_length + 1
    FROM shortest_paths sp
    JOIN (
        select a.subject_id AS subject_id1, 
               b.subject_id AS subject_id2
        from hosp.admissions a
        JOIN hosp.admissions b 
            ON a.subject_id <> b.subject_id
            and a.admittime < b.dischtime 
            and a.dischtime > b.admittime
        order by a.admittime
        limit 200
    ) d ON sp.connected_id = d.subject_id1
    WHERE sp.path_length < 20
)

select DISTINCT start_id, connected_id, MIN(path_length) as path_length
FROM shortest_paths
GROUP BY start_id, connected_id
ORDER BY 3 ASC, 2 ASC;
