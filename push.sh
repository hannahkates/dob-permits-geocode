
echo Rows in raw data:
wc -l < temp/dob_permits.csv
sed '/|/d' temp/dob_permits.csv > temp/dob_permits_cleaned.csv

echo Rows after removing invalid lines:
wc -l < temp/dob_permits_cleaned.csv

echo Creating table
psql -U postgres -d dobpermits -f create.sql

echo Loading data
psql -U postgres -d dobpermits -c "\COPY dob_permits FROM 'temp/dob_permits_cleaned.csv' CSV HEADER;"  

echo Assembling bbl column
psql -U postgres -d dobpermits -f makebbl.sql

echo Looking up BBLs in PLUTO and BINs in building footprints
psql -U postgres -d dobpermits -f geocode.sql

echo Looking up addresses in geosupport results table
psql -U postgres -d dobpermits -f gslookup.sql

echo Running anything not yet geocoded through geosupport 
node geocode.js

echo Looking up addresses in geosupport results table again
psql -U postgres -d dobpermits -f gslookup.sql 

echo Dropping null geometries
psql -U postgres -d dobpermits -f dropnulls.sql

echo Exporting to shapefile
ogr2ogr -f "ESRI Shapefile" temp/dob_permits.shp PG:"host=localhost user=postgres dbname=dobpermits password=postgres" -sql "SELECT * FROM dob_permits"