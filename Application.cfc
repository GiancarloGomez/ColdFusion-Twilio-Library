/**
 * This is a simple example setting up the twilio library as a singleton
 * in your application scope
 */
component {
	this.name = "twilio_lib_examples";

	boolean function onApplicationStart(){
		// set your twilio credentials
		// optional settings are fromNumber and enabled that I would
		// use to avoid having to type in various places and making sure
		// any call to a twilio resource is only ran if enabled
		application.twilioConfig = {
			"enabled" 	 : true,
			"fromNumber" : "",
			"accountSid" : "",
			"authToken"  : ""
		};
		// Create a new instance of the Twilio Lib
		if ( application.twilioConfig.enabled ){
			application.twilio = new lib.twilioLib(
				application.twilioConfig.accountSid,
				application.twilioConfig.authToken
			) ;
		}
		return true;
	}

	boolean function onRequestStart( targetPage ){
		// set a test number here to call and text to
		request.testNumber = "";

		if ( structKeyExists(url,"reload") ){
			applicationStop();
			location("./",false);
		}

		return true;
	}
}