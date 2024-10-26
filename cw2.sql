CREATE EXTENSION postgis;

CREATE TABLE buildings(
	id_buildings SERIAL PRIMARY KEY,
	geometry GEOMETRY,
	name VARCHAR
);

CREATE TABLE roads(
	id SERIAL PRIMARY KEY,
	geometry GEOMETRY,
	name VARCHAR
);

CREATE TABLE poi(
	id SERIAL PRIMARY KEY,
	geometry GEOMETRY,
	name VARCHAR
);

INSERT INTO buildings(name, geometry) VALUES
('BuildingA', 'POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))');
('BuildingB', 'POLYGON((4 7, 4 5, 6 5, 6 7, 4 7))'),
('BuildingC', 'POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))'),
('BuildingD', 'POLYGON((9 9, 9 8, 10 8, 10 9, 9 9))'),
('BuildingF', 'POLYGON((1 1, 1 2, 2 2, 2 1, 1 1))');

INSERT INTO roads(name, geometry) VALUES
('RoadY', 'LINESTRING(7.5 10.5, 7.5 0)'),
('RoadX', 'LINESTRING(0 4.5, 12 4.5)');

INSERT INTO poi(name, geometry) VALUES
('G', 'POINT(1 3.5)'),
('H', 'POINT(5.5 1.5)'),
('I', 'POINT(9.5 6)'),
('J', 'POINT(6.5 6)'),
('K', 'POINT(6 9.5)');

--a)
SELECT SUM(ST_Length(r.geometry))
FROM roads AS r

--b)
SELECT ST_AsText(b.geometry), ST_Area(b.geometry) AS Area, ST_Perimeter(b.geometry) AS Perimeter
FROM buildings AS b
WHERE b.name='BuildingB'

--c)
SELECT b.name, ST_Area(b.geometry)
FROM buildings AS b
ORDER BY b.name 

--d)
SELECT b.name, ST_Perimeter(b.geometry) AS Perimeter
FROM buildings AS b
ORDER BY ST_Area(b.geometry) DESC 
LIMIT 2;

--e)
SELECT ST_Distance(b.geometry, p.geometry)
FROM buildings AS b
CROSS JOIN poi AS p 
WHERE b.name='BuildingC' AND p.name='K'

-- f)
SELECT ST_Area(ST_Difference(b.geometry, ST_Buffer(b2.geometry, 0.5)))
FROM buildings AS b
CROSS JOIN buildings AS b2
WHERE b.name='BuildingC' AND b2.name='BuildingB'

SELECT ST_Area(
    ST_Difference(
        b.geometry,
        ST_Buffer((SELECT geometry FROM buildings WHERE name='BuildingB'), 0.5)
    )
) AS area
FROM buildings AS b
WHERE b.name = 'BuildingC';

-- g)
SELECT b.name 
FROM buildings AS b
CROSS JOIN roads AS r
WHERE r.name='RoadX' AND ST_Y(ST_Centroid(b.geometry))>ST_Y(ST_Centroid(r.geometry));

-- h)
SELECT ST_Area(ST_SymDifference(b.geometry, 'POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'))
FROM buildings AS b
WHERE b.name='BuildingC';
