CREATE TABLE node
(
    id     BIGINT PRIMARY KEY,
    point1 VARCHAR NOT NULL,
    point2 VARCHAR NOT NULL,
    prise  INT     NOT NULL
);

INSERT INTO node
VALUES (1, 'A', 'B', 10);
INSERT INTO node
VALUES (2, 'B', 'A', 10);

INSERT INTO node
VALUES (3, 'B', 'C', 35);
INSERT INTO node
VALUES (4, 'C', 'B', 35);

INSERT INTO node
VALUES (5, 'A', 'C', 15);
INSERT INTO node
VALUES (6, 'C', 'A', 15);

INSERT INTO node
VALUES (7, 'A', 'D', 20);
INSERT INTO node
VALUES (8, 'D', 'A', 20);

INSERT INTO node
VALUES (9, 'B', 'D', 25);
INSERT INTO node
VALUES (10, 'D', 'B', 25);

INSERT INTO node
VALUES (11, 'C', 'D', 30);
INSERT INTO node
VALUES (12, 'D', 'C', 30);

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
WHERE prise = (SELECT MIN(prise) FROM result_path)
ORDER BY total_cost, tour;

