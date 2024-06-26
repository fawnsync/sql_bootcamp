WITH RECURSIVE
    path(last_point, tour) AS (SELECT point1, ARRAY [point1]:: char(1)[], 0 AS prise
                               FROM node
                               WHERE point1 = 'A'
                               UNION
                               SELECT node.point2                                    AS last_point,
                                      (path.tour || ARRAY [node.point2]):: char(1)[] AS tour,
                                      path.prise + node.prise
                               FROM node,
                                    path
                               WHERE node.point1 = path.last_point
                                 AND NOT node.point2 = ANY (path.tour)),
    result_path AS (SELECT array_append(tour, 'A')      AS tour,
                           prise + (SELECT prise
                                    FROM node
                                    WHERE point1 = path.last_point
                                      AND point2 = 'A') AS prise
                    FROM path
                    WHERE (SELECT array_length(path.tour, 1)) = 4)
SELECT prise AS total_cost, tour
FROM result_path
ORDER BY total_cost, tour;