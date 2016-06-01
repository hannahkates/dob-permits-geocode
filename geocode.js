
var pgp = require('pg-promise')(),
request = require('request'),
Mustache = require('mustache');

var config = require('./config.js'),
 apiCredentials = require('./apiCredentials.js'),
  db = pgp(config);

var i=0;
var nullGeomResults
//query the db for null geometries

var nullGeomQuery = 'SELECT * FROM dob_permits WHERE geom IS NULL LIMIT 10';

var geoclientTemplate = 'https://api.cityofnewyork.us/geoclient/v1/address.json?houseNumber={{housenumber}}&street={{streetname}}&borough={{borough}}&app_id={{app_id}}&app_key={{app_key}}';

db.any(nullGeomQuery)
  .then(function (data) {
    nullGeomResults = data
    addressLookup(nullGeomResults[i]);
  });


function addressLookup(row) {
  console.log(row.borough.trim(), row.housenumber.trim(), row.streetname.trim())

      var apiCall = Mustache.render(geoclientTemplate, {
        housenumber: row.housenumber.trim(),
        streetname: row.streetname.trim(),
        borough: row.borough.trim(),
        app_id: apiCredentials.app_id,
        app_key: apiCredentials.app_key
      })

      console.log(apiCall);

      request(apiCall, function(err, response, body) {
          var data = JSON.parse(body);
          data = data.address;

          appendToNotfound(data, row);
      })
}


function appendToNotfound(data, row) {
  console.log(row);
  var insertTemplate = 'INSERT INTO dob_permitsnotfound (geom, sourcehousenumber, sourcestreetname, sourcebin, sourcebbl, responsebbl) VALUES (ST_GeomFromText(\'POINT({{longitude}} {{latitude}})\'), \'{{sourcehousenumber}}\', \'{{sourcestreetname}}\', {{sourcebin}},{{sourcebbl}},{{responsebbl}})'

  var insert = Mustache.render(insertTemplate, {
    latitude: data.latitude,
    longitude: data.longitude,
    sourcehousenumber: row.housenumber.trim(),
    sourcestreetname: row.streetname.trim(),
    sourcebin: row.binnumber,
    sourcebbl: row.bbl,
    responsebbl: data.bbl
  })

  console.log(insert);

  db.none(insert).then(function(data) {
    i++;
    console.log(i,nullGeomResults.length)
    if (i<nullGeomResults.length) {
       addressLookup(nullGeomResults[i])
    } else {
      console.log('Done!')
    }
    
  })
}





