#dob-permit-geocode

This is a set of scripts to transform the publicly available NYC DOB permits dataset into a spatial dataset by adding a point geometry to each record.

##How to use
1. `sh get.sh` This downloads and saves the csv from DOB
2. `sh push.sh` This file cleans the data and then runs multiple SQL queries (explained below) in order to create the final table of geocoded records.

##Geocoding Methodology

The source dataset is transformed with the following steps:

1. `get.sh` downloads the source dataset as CSV from [data.cityofnewyork.us](https://nycopendata.socrata.com/api/views/ipu4-2q9a/rows.csv?accessType=DOWNLOAD) (Approximately 546k rows as of 2 June 2016).

2. Approximately 19 rows from the source CSV contain strange pipe-delimited values, so **sed** is used to get rid of rows with pipe characters. The code for this step is in `push.sh`

3. `push.sh` calls the `create.sql` script -- Creates a new PostgreSQL table from the CSV.

4. `push.sh` calls the `makebbl.sql` script -- Assembles a bbl column from the borough, block, and lot columns.

5. `push.sh` calls the `geocode.sql` script -- Joins with mappluto 16v1 on bbl, appends parcel centroids to permits. Then joins with building footprints on bin, append parcel centroids to permits.  96% of the data are matched using mappluto and buildingfootprints.

6. `push.sh` calls the `gslookup.sql` script -- Joins with the geosupport lookup table (this table contains the results of running all rows that do not match mappluto or building footprints through the geoclient API.  The results are logged in a table so we can join them without hitting the API every time.) 13k rows are matched using the geosupport lookup table as of 2 June 2016.

7. `push.sh` calls the `geocode.js` script -- Any rows that still do not match are run through the geoclient API, if they return lat/lon, those details are added to the geosupport lookup table.

8. `push.sh` calls the `gslookup.sql` script again -- Joins with the geosupport lookup table AGAIN to capture any new matches.

9. `push.sh` calls the `dropnulls.sql` script -- Drop rows that are still unmatched (~975 as of 2 June 2016) .17% of original.  Not bad.

- Export to shapefile -- final step in `push.sh`

- TODO: Create an output file of unmatched BBLs so that DOB and DCP can figure out where the discrepancies are.
 
