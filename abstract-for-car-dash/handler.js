'use strict';
const jwt = require('jsonwebtoken');

const generatePolicy = function(principalId, effect, resource) {
    var authResponse = {};
    authResponse.principalId = principalId;
    if (effect && resource) {
        var policyDocument = {};
        policyDocument.Version = '2012-10-17'; // default version
        policyDocument.Statement = [];
        var statementOne = {};
        statementOne.Action = 'execute-api:Invoke'; // default action
        statementOne.Effect = effect;
        statementOne.Resource = resource;
        policyDocument.Statement[0] = statementOne;
        authResponse.policyDocument = policyDocument;
    }
    return authResponse;
}

/**
 * Default Lambda Handler
 *
 * @param {Object} event - The Lambda event
 * @param {Object} context - The Lambda context
 * @param {Function} callback - The Lambda callback
 */

module.exports.auth = (event, context, callback) => {


  if (event.authorizationToken) {
    // remove "bearer " from token
    const token = event.authorizationToken.substring(7);
    const options = {
       audience: 'O5JoUoJlbr3jD2x0vhdDf15tXUnzjuRb'

    };

  const secretKey =  'b6hLLRDyk3u0IwbuwKAXrAT05cIkE1eb'

  jwt.verify(token, secretKey, (err, decoded) => {

    if(err){
    // respond to request with error
    console.log(`the error hit ${err}`)
    callback('Unauthorized');
    }else{
      // continue with the request
      callback(null, generatePolicy(decoded.sub, 'Allow', event.methodArn));

    }

  })

  } else {
    callback('Unauthorized');
  }




};
