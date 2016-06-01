ALTER TABLE dob_permits ADD "geom" geometry;
UPDATE dob_permits
SET geom = CASE 
	WHEN exists(SELECT 1 FROM dcp_mappluto b WHERE (a.bbl = b.bbl))
    	THEN  (SELECT ST_CENTROID(geom) FROM dcp_mappluto b WHERE (a.bbl = b.bbl))
END
FROM dob_permits a;

