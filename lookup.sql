UPDATE dob_permits SET geom = CASE WHEN exists(SELECT 1 FROM dcp_mappluto b WHERE (a.bbl = b.bbl::text)) 
    THEN  (SELECT ST_CENTROID(geom) FROM dcp_mappluto b WHERE (a.bbl = b.bbl::text))
    WHEN exists(SELECT 1 FROM doitt_buildingfootprints b WHERE (a.binnumber = b.bin::text))
    THEN  (SELECT ST_CENTROID(geom) FROM doitt_buildingfootprints b WHERE (a.binnumber = b.bin::text))
    ELSE null
  END 
FROM dob_permits a 