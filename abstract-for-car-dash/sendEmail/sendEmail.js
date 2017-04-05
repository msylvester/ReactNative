'use strict';

class sendEmail {

  /**
   * Constructor
   *
   * @param {Object} helper - an object from the send grid module
   */

  constructor(helper) {

      this.helper = helper
      this.from_email = new helper.Email("msylvest55@gmail.com");
      this.to_email = new helper.Email("mike@abstract.ai");
      this.content = new helper.Content("text/plain", "and easy to do anywhere, even with Node.js");

  }

  /**
   * Send will take the send grid object and the message from publisher and send an email
   *
   * @param {Object} snsMessage - The message sent to the subscriber
   * @param {Object} sg - The sendgrid object
   */

  send(sg,snsMessage) {

     const subject = snsMessage

     let mail = this.helper.Mail(this.from_email, subject, this.to_email, this.content);

      var request = sg.emptyRequest({
        method: 'POST',
        path: '/v3/mail/send',
        body: mail.toJSON()
      });


      sg.API(request, (error, response) => {

        if(error !== null) {
          console.log(`there is an an error that is ${errorr}`)
        }
        console.log(response.statusCode);
        console.log(response.body);
        console.log(response.headers);
      })



  }
}

module.exports = sendEmail;
