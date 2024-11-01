CREATE EXTENSION postgis;

--zad 1
CREATE VIEW zmiany_nowe_budynki AS
WITH zmiany AS (
    SELECT b2.gid AS gid19, b2.polygon_id, b2.geom 
    FROM buildings_2018 AS b1
    JOIN buildings_2019 AS b2 ON b1.polygon_id = b2.polygon_id
    WHERE b1.height != b2.height OR NOT ST_Equals(b1.geom, b2.geom)
),
nowe_budynki AS (
    SELECT b2.gid AS gid19, b2.polygon_id, b2.geom
    FROM buildings_2019 AS b2
    LEFT JOIN buildings_2018 AS b1 ON b1.polygon_id = b2.polygon_id
    WHERE b1.polygon_id IS NULL
)
SELECT * FROM zmiany
UNION
SELECT * FROM nowe_budynki;

--zad 2
--C:\Program Files\PostgreSQL\17\bin>shp2pgsql.exe 
-- "C:\\xx\\Ćwiczenia 3\\Karlsruhe_Germany_Shapefile\\T2018_KAR_GERMANY\\T2018_KAR_POI_TABLE.shp" 
-- poi_2018 | psql -h localhost -p 5432 -U postgres -d BDP3

--trwa 11s
CREATE VIEW poi500 AS
SELECT DISTINCT p.poi_name, p.type
FROM poi_2018 AS p
JOIN zmiany_nowe_budynki AS n ON ST_DWithin(p.geom::geography, n.geom::geography, 500)

SELECT p.type, COUNT(p.type)
FROM poi500 AS p
GROUP BY p.type;

--zad 3
-- C:\Program Files\PostgreSQL\17\bin>shp2pgsql.exe -s 3068 
-- "C:\\Users\\xx\\bazy danych przestrzennych\\cwiczenia\\cw3\\Ćwiczenia 3
-- \\Karlsruhe_Germany_Shapefile\\T2019_KAR_GERMANY\\T2019_KAR_STREETS.shp" 
-- streets_reprojected | psql -h localhost -p 5432 -U postgres -d BDP3

--zad 4
CREATE TABLE input_points(
id SERIAL PRIMARY KEY,
geom geometry
);

INSERT INTO input_points(geom) VALUES 
('POINT(8.36093 49.03174)'),
('POINT(8.39876 49.00644)');

--zad 5
UPDATE input_points AS p
SET geom = ST_SetSRID(geom, 3068)
WHERE ST_SRID(geom) = 0;

--3068

--zad 6
--dane załadowane przez shp2pgsql do DHDN.Berlin/Cassini
-- C:\Program Files\PostgreSQL\17\bin>shp2pgsql.exe -s 3068 
-- "C:\\Users\\xx\bazy danych przestrzennych
-- \\cwiczenia\\cw3\\Ćwiczenia 3\\Karlsruhe_Germany_Shapefile\\T2019_KAR_GERMANY
-- \\T2019_KAR_STREET_NODE.shp" street_nodes2019 | psql -h localhost -p 5432 
-- -U postgres -d BDP3
UPDATE input_points AS p
SET geom = ST_SetSRID(geom, 4326);
SELECT ST_AsText(geom) FROM street_nodes2019 WHERE street_nodes2019.intersect='Y';
UPDATE street_nodes2019 AS p
SET geom = ST_SetSRID(geom, 4326);

-- DROP TABLE street_nodes2019;

SELECT n.gid, n.node_id
FROM street_nodes2019 n
WHERE n.intersect='Y' AND 
ST_DWithin(n.geom, ST_MakeLine(ARRAY(SELECT p.geom FROM input_points p)), 200);

-- SELECT * FROM street_nodes2019 n WHERE n.intersect='Y';
-- SELECT ST_SRID(n.geom) FROM street_nodes2019 n;
SELECT ST_SRID(n.geom) FROM input_points n;

-- SELECT ST_AsText(ST_MakeLine(ARRAY(SELECT p.geom FROM input_points p)))


--zad 7
-- C:\Program Files\PostgreSQL\17\bin>shp2pgsql.exe 
-- "C:\\Users\\xx\\bazy danych przestrzennych\\cwiczenia\\cw3\\Ćwiczenia 3\\
-- Karlsruhe_Germany_Shapefile\\T2019_KAR_GERMANY\\T2019_KAR_LAND_USE_A.shp" 
-- parks_2019 | psql -h localhost -p 5432 -U postgres -d BDP3

SELECT * 
FROM poi_2019 p  
JOIN parks_2019 parks ON ST_DWithin(
p.geom::geography, parks.geom::geography, 300)
WHERE p.type='Sporting Goods Store';

--zad 8
CREATE TABLE bridge AS
SELECT
    ST_Intersection(w.geom, r.geom) 
FROM
    water_lines_2019 AS w,
    railways_2019 AS r
WHERE
    ST_Intersects(w.geom, r.geom);