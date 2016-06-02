CREATE TABLE dob_buildingsnotfound (
geom geometry,
sourcehousenumber text,
sourcestreetname text,
sourceaddress text,
sourcebin numeric,
sourcebbl numeric,
responsebbl numeric
)

SELECT UpdateGeometrySRID('dob_permitsnotfound','geom',4326);

1000920001

INSERT INTO dob_buildingsnotfound (geom, sourcehousenumber, sourcestreetname, sourcebin, sourcebbl, responsebbl) VALUES (ST_GeomFromText('POINT(-74.00577123649295 40.710549798645296)'), '33', 'BEEKMAN STREET', 1813303,1000920001,1000927501)