'use strict';

/**
 *  MARK PROPERTIES
 */

const AWS = require('aws-sdk'); // eslint-disable-line import/no-extraneous-dependencies
const dynamoDb = new AWS.DynamoDB.DocumentClient();
const entryPoint = require('./entry.js');
const config = require('../config.js');
const sns = new AWS.SNS();
let entry = new entryPoint(dynamoDb, sns);


/**
 * Default Lambda Handler the lambda function get
 *
 * @param {Object} event - The Lambda event 
 * @param {Object} context - The Lambda context
 * @param {Object} callback - The Lambda callback
 */



module.exports.get = (event, context, callback) => {


    entry.respond(callback, config['awsAccountId'])



};
