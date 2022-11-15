const http = require('http');
var jsonPath = require('JSONPath');

http.createServer((request, response) => {
  const { headers, method, url } = request;
  let body = [];
  request.on('error', (err) => {
    console.error(err);
  }).on('data', (chunk) => {
    body.push(chunk);
  }).on('end', () => {
    body = Buffer.concat(body).toString();
    // BEGINNING OF NEW STUFF

    //console.log(body);
    var o = JSON.parse(body);
    var result = jsonPath.eval(o, "$..full_name");
    console.log("Full Name of the repo added:")
    console.log(result); 
   // call the script to protect with two parameters - main branch and repo name got from the json. Script is available online. hence not writing it. Providing a link here
   // can also github cli if needed
   // https://gist.github.com/edudobay/decc7d772c8a11db130aef9340d392bf is the link for the
   //code
    response.on('error', (err) => {
      console.error(err);
    });

    response.statusCode = 200;
    response.setHeader('Content-Type', 'application/json');
    // Note: the 2 lines above could be replaced with this next one:
    // response.writeHead(200, {'Content-Type': 'application/json'})

    const responseBody = { headers, method, url, body };

    response.write(JSON.stringify(responseBody));
    response.end();
    // Note: the 2 lines above could be replaced with this next one:
    // response.end(JSON.stringify(responseBody))

    // END OF NEW STUFF
  });
}).listen(12345);
