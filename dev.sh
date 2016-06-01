curl "https://nycopendata.socrata.com/api/views/ipu4-2q9a/rows.csv?accessType=DOWNLOAD" | head -n 1000 > dobpermits1000.csv
psql -U postgres -d dobpermits -f create.sql
psql -U postgres -d dobpermits -c "\COPY dob_permits FROM 'dobpermits1000.csv' CSV HEADER;"  
psql -U postgres -d dobpermits -f makebbl.sql
psql -U postgres -d dobpermits -f geocode.sql
