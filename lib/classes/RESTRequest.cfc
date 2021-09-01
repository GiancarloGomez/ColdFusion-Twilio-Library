/*
* The MIT License (MIT)
* Copyright (c) 2011 Jason Fill (@jasonfill)
*
* Script conversion and updates by @giancarlogomez
*/
component accessors=true output=false {

	property name="apiResponseFormat" 	type="string" default="json";
	property name="apiVersion" 			type="string" default="2010-04-01";
	property name="url" 				type="string";
	property name="parameterType" 		type="string";
	property name="parameters" 			type="struct";
	property name="response" 			type="RESTResponse";
	property name="request" 			type="struct";

	public RestRequest function init(){
		return this;
	}

	/**
	 * This array will be used to make sure the proper case is sent in the REST request
	 * as well as making sure that no extraneous parameters exist in the request
	 */
	public array function getValidParameterList(){
		return 	[
			"AccountSid","AreaCode","AnsweredBy","ApiVersion","Body",
			"CallDelay","CallDuration","CallSid","Contains","DateCreated",
			"DateSent","DateUpdated","Distance","EndTime","Extension",
			"FallbackMethod","FallbackUrl","FriendlyName","From","IfMachine",
			"IncomingPhoneNumberSid","InLata","InRateCenter","InRegion",
			"InPostalCode","IsoCountryCode","Log","MessageDate",
			"Method","Muted","NearLatLong","NearNumber","Page","PageSize",
			"PhoneNumber","Record","RecordingStatusCallback","SendDigits","SmsApplicationSid",
			"SmsFallbackMethod","SmsFallbackUrl","SmsMethod","SmsUrl","StartTime","Status",
			"StatusCallback","StatusCallbackMethod","Timeout","To","Url","ValidationCode",
			"VoiceApplicationSid","VoiceCallerIdLookup","VoiceFallbackMethod","VoiceFallbackUrl",
			"VoiceMethod","VoiceUrl"
		];
	}

	/**
	 * Handles the response that is returned from Twilio.
	 */
	public void function handleResponse( required struct response ){
		setResponse( new RESTResponse( this, arguments.Response ) );
	}
}