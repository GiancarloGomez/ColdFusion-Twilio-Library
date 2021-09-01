# CFML Twilio Helper Library
This fork is an updated version of the original [ColdFusion-Twilio-Library](https://github.com/jasonfill/ColdFusion-Twilio-Library) by Jason Fill. This update includes conversion of all code to `cfscript` along  with various updates such as code cleanup, use of accessors with properties expanded to individual variables rather than the previous single struct variables setting and various convinience functions for common use cases.

The Twilio REST SDK simplifies the process of makes calls to the Twilio REST.
The Twilio REST API lets to you initiate outgoing calls, list previous call,
and much more.  See https://www.twilio.com/docs for more information.

## USAGE
To test the code locally, you can pull this repo and run [CommandBox](https://www.ortussolutions.com/products/commandbox) from the root by executing `box server start`. Open up Application.cfc and enter the settings to be able to run the examples in the index file.

## EXAMPLES
The main entry point is still the same as the original version by using the `newRequest()` function as follows.
```js
// https://www.twilio.com/docs/sms/api/message-resource#create-a-message-resource

// Example based on library setup as singleton in application.twilio
application.twilio.newRequest(
    resource = "Accounts/{AccountSid}/SMS/Messages",
    method = "POST",
    parameters = {
        "from" 	: "+15555555555",
        "to" 	: "+15555555551",
        "body" 	: "This is a sample SMS message"
    }
);

/* 
* Due to pretty much all Twilio API calls following the same `path` "Accounts/AccountSid/..."
* this update updated version also allows you to create the calls without it in the resource 
* argument such as
*/
application.twilio.newRequest(
    "SMS/Messages",
    "POST",
    {
        "from" 	: "+15555555555",
        "to" 	: "+15555555551",
        "body" 	: "This is a sample SMS message"
    }
);

/* To make it even easier, this version has taken the liberty to include some 
* convenience functions that are all defined in the main `TwilioLib.cfc`. 
* As a quick example the call above can also be done as follows
*/
application.twilio.sms({
    "from" 	: "+15555555555",
    "to" 	: "+15555555551",
    "body" 	: "This is a sample SMS message"
});
```

## CONVENIENCE FUNCTIONS
The functions included in this version to lessen the amount of code required to make an api call are as follows:
```ts
// https://www.twilio.com/docs/phone-numbers/api/availablephonenumberlocal-resource
function availablePhoneNumbers(struct parameters, string countryCode = "US", string type = "Local"){}

// https://www.twilio.com/docs/voice/make-calls#initiate-an-outbound-call-with-twilio
function call( struct parameters ){}

// https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource
function incomingPhoneNumbers( struct parameters ){}

// https://www.twilio.com/docs/voice/api/outgoing-caller-ids
function outgoingCallerIds( struct parameters ){}
function outgoingCallerIdByID( string ID ){}

// https://www.twilio.com/docs/voice/api/recording#fetch-a-recording-resource
function recordingByID( string ID ){}
function recordingsByCallID( string ID ){}

// https://www.twilio.com/docs/sms/api/message-resource#create-a-message-resource
function sms( struct parameters ){}
```
LICENSE
-------
The Twilio CFML Helper Library is distributed under the MIT License