
with RECURSIVE bfs AS (
    SELECT subject_id1 AS start_id, subject_id2 AS next_id, 1 AS depth
    FROM (
        SELECT a.subject_id AS subject_id1, 
               b.subject_id AS subject_id2
        FROM hosp.admissions a
        JOIN hosp.admissions b 
            ON a.subject_id <> b.subject_id
            AND a.admittime < b.dischtime 
            AND a.dischtime > b.admittime
        ORDER BY a.admittime
        limit 200
    ) directed_edges
    WHERE subject_id1 = 10038081

    UNION ALL

    SELECT d.subject_id1, d.subject_id2, bfs.depth + 1
    FROM bfs
    JOIN (
        SELECT a.subject_id AS subject_id1, 
               b.subject_id AS subject_id2
        FROM hosp.admissions a
        JOIN hosp.admissions b 
            ON a.subject_id <> b.subject_id
            AND a.admittime < b.dischtime 
            and a.dischtime > b.admittime
        ORDER BY a.admittime
        LIMIT 200
    ) d ON bfs.next_id = d.subject_id1
    where bfs.depth < 20
)


select COUNT(DISTINCT next_id) AS count
FROM bfs;
