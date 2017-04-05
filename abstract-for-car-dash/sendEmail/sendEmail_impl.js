'use strict'

/**
 * MARK:PROPERTIES\
 */

let AWS = require('aws-sdk'); // eslint-disable-line import/no-extraneous-dependencies
var helper = require('sendgrid').mail;
var sg = require('sendgrid')('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');
const sendEmails = require('./sendEmail.js');
let emailMe  = new sendEmails(helper)


/**
 * Default Lambda Handler for Lambdda function sendMail
 *
 * @param {Object} event - The Lambda event
 */

module.exports.sendEmail = (event) => {

  let email_subject = ''

  if(event.Records[0].Sns.Message !== null) {

      email_subject = event.Records[0].Sns.Message
  }else {
    email_subject = 'dude didnt put a subject'
  }

  emailMe.send(sg, email_subject)


};
