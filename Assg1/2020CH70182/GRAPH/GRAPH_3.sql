
with RECURSIVE bfs AS (
    SELECT subject_id1 AS start_id, subject_id2 AS next_id, 1 AS path_length
    from (
        select a.subject_id AS subject_id1, 
               b.subject_id AS subject_id2
        FROM hosp.admissions a
        join hosp.admissions b 
            ON a.subject_id <> b.subject_id
            AND a.admittime < b.dischtime 
            AND a.dischtime > b.admittime
        ORDER BY a.admittime
        limit 200
    ) directed_edges
    where subject_id1 = 10038081

    UNION ALL

    select d.subject_id1, d.subject_id2, bfs.path_length + 1
    FROM bfs
    JOIN (
        SELECT a.subject_id AS subject_id1, 
               b.subject_id AS subject_id2
        FROM hosp.admissions a
        join hosp.admissions b 
            ON a.subject_id <> b.subject_id
            and a.admittime < b.dischtime 
            AND a.dischtime > b.admittime
        ORDER BY a.admittime
        limit 200
    ) d ON bfs.next_id = d.subject_id1
    WHERE bfs.path_length < 20
)

select MIN(path_length) AS path_length
from bfs
WHERE next_id = 10021487;
