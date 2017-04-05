'use strict';

class entry {

  /**
   * Constructor
   *
   * @param {Object} db - dynamodb instance
   * @param {Object} sns - an sns instance

   */


  constructor(db, sns) {

       this.db = db;
       this.sns = sns;
  }

  /**
   *  respond send a message to the alert topic
   *
   * @param {Function} cb - Lambda callback function
   * @param {Object} config - a utitly js object with info

   */

  respond(cb, config) {

    const params = {
      Message: "Dum dum dum",
      TopicArn: `arn:aws:sns:us-east-1:985983045442:alert`,
     };

    this.sns.publish(params, (error) => {

      console.log(`here in the publish ${params}`)

      if (error) {

        console.error(error);
        cb(new Error('Couldn\'t add the note due an internal error. Please try again later.'));
      }
      // create a resonse
      try {
        const response = {

          statusCode: 200,
          body: JSON.stringify({ message: 'Successfully added the note.' }),
        };
      catch (err) {
        console.error(err);
        cb(new Error('Couldn\'t add the note due an internal error. Please try again later.'));
      }

      cb(null, response);
    });
  }
}

module.exports = entry;
