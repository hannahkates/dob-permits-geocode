curl "https://nycopendata.socrata.com/api/views/ipu4-2q9a/rows.csv?accessType=DOWNLOAD" | head -n 10000 > dobpermits1000.csv
psql -U postgres -d postgres -f create.sql
psql -U postgres -d postgres -c "\COPY dob_permits FROM 'dobpermits1000.csv' CSV HEADER;"  
psql -U postgres -d postgres -f makebbl.sql
psql -U postgres -d postgres -f geocode.sql
