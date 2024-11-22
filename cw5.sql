-- zadanie 1
CREATE TABLE obiekty (
    id SERIAL PRIMARY KEY,
    nazwa TEXT NOT NULL,
    geometria GEOMETRY NOT NULL
);

INSERT INTO obiekty (nazwa, geometria)
VALUES 
('obiekt1', ST_GeomFromText('CIRCULARSTRING(0 1, 1 1, 2 0, 3 1, 4 2, 5 1, 6 1)', 0));

SELECT ST_HasArc(geometria) AS has_arc
FROM obiekty
WHERE nazwa = 'obiekt1';

INSERT INTO obiekty (nazwa, geometria) VALUES
('obiekt2', ST_GeomFromText('CURVEPOLYGON(
	CIRCULARSTRING(10 2, 10 6, 14 6, 16 4, 14 2, 12 0, 10 2),
	CIRCULARSTRING(11 2, 13 2, 11 2)
)', 0))

INSERT INTO obiekty (nazwa, geometria) VALUES
('obiekt3', ST_GeomFromText('POLYGON((7 15, 10 17, 12 13, 7 15))', 0));

INSERT INTO obiekty (nazwa, geometria) VALUES
('obiekt4', ST_GeomFromText('LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)', 0));

INSERT INTO obiekty (nazwa, geometria) VALUES
('obiekt5', ST_GeomFromText('MULTIPOINT((30 30 59), (38 32 234))', 0));

INSERT INTO obiekty (nazwa, geometria) VALUES
('obiekt6', ST_GeomFromText('GEOMETRYCOLLECTION(LINESTRING(1 1, 3 2), POINT(4 2))', 0));

SELECT id, nazwa, ST_AsText(geometria) FROM obiekty;

-- zadanie 2
WITH shortest_line AS (
    SELECT ST_ShortestLine(o1.geometria, o2.geometria) AS linia
    FROM obiekty o1, obiekty o2
    WHERE o1.nazwa = 'obiekt3' AND o2.nazwa = 'obiekt4'
)
SELECT 
    ST_Area(ST_Buffer(linia, 5)) AS pole_bufora
FROM shortest_line;

-- zadanie 3
--  Obiekt 4 musi być linią zamkniętą (czyli pierwsza i ostatnia współrzędna muszą być identyczne)
SELECT ST_IsClosed(geometria) AS czy_zamkniety
FROM obiekty
WHERE nazwa = 'obiekt4';

UPDATE obiekty
SET geometria = ST_AddPoint(geometria, ST_StartPoint(geometria))
WHERE nazwa = 'obiekt4';

UPDATE obiekty
SET geometria = ST_MakePolygon(geometria)
WHERE nazwa = 'obiekt4'

-- zadanie 4
INSERT INTO obiekty (nazwa, geometria) VALUES (
    'obiekt7', 
       	ST_Collect(
            (SELECT geometria FROM obiekty WHERE nazwa = 'obiekt3'),
            (SELECT geometria FROM obiekty WHERE nazwa = 'obiekt4')
			)
);

-- zadanie 5
SELECT SUM(ST_Area(ST_Buffer(geometria, 5)))
FROM obiekty
WHERE NOT ST_HasArc(geometria);

