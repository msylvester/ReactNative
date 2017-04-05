var request = require("request");

var options = { method: 'POST',
  url: 'https://abstractai.auth0.com/oauth/token',
  headers: { 'content-type': 'application/json' },
  body: '{"client_id":"O5JoUoJlbr3jD2x0vhdDf15tXUnzjuRb","client_secret":"Ch-FeORjGhw0XsTxlsBhiEYgV_7pcQgup3VeCZq9NpbJTAZpa6-qCZJbxQ8eysF8","audience":"ff","grant_type":"client_credentials"}' };

request(options, (error, response, body) => {
  if (error) throw new Error(error);

  console.log(body);
});