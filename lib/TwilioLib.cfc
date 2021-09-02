/*
* The MIT License (MIT)
* Copyright (c) 2011 Jason Fill (@jasonfill)
*
* Script conversion and updates by @giancarlogomez
*/
component accessors=true output=false {

	/**
	 * The AccountSid provided by Twilio.
	 */
	property name="AccountSid" type="string";
	/**
	 * The AuthToken provided by Twilio.
	 */
	property name="AuthToken" type="string";
	/**
	 * The version of the Twilio API to be used.
	 */
	property name="ApiVersion" type="string" default="2010-04-01";
	/**
	 * The Twilio API endpoint.
	 */
	property name="ApiEndPoint" type="string" default="api.twilio.com";
	/**
	 * The default return format that should be used.
	 * This can be overridden in for REST request as well.
	 */
	property name="ApiResponseFormat" type="string" default="json";
	property name="RESTClient" type="RESTClient";

	public TwilioLib function init(
		required string AccountSid,
		required string AuthToken,
		string ApiVersion,
		string ApiEndPoint,
		string ApiResponseFormat
	){
		setAccountSid( arguments.AccountSid );
		setAuthToken( arguments.AuthToken );
		if ( structKeyExists( arguments, "ApiVersion") )
			setApiVersion( arguments.ApiVersion );
		if ( structKeyExists( arguments, "ApiEndPoint") )
			setApiEndPoint( arguments.ApiEndPoint );
		if ( structKeyExists( arguments, "ApiResponseFormat") )
			setApiResponseFormat( arguments.ApiResponseFormat );
		setRESTClient( new classes.RESTClient( argumentCollection: arguments ) );
		return this;
	}

	/**
	 * Creates a new TwiML utility object.
	 */
	public any function getUtils(){
		return new classes.Utils( getAuthToken() );
	}

	/**
	 *Creates a new Twilio capability object.
	 */
	public any function getCapability(){
		return new classes.Capability( getAccountSid(), getAuthToken() );
	}

	/**
	* Creates a new REST request object.
	*
	* @resource      The resource that is to be consumed.
	* @method        The HTTP method to be used.
	* @parameters    The parameters that are to be sent with the request.
	* @resourceRoot  The default resource root, convinience argument not passsed to library and prepends to resource
	*/
	public any function newRequest(
		required string resource,
		string method = "GET",
		struct parameters = {},
		string resourceRoot = "Accounts/{AccountSid}/"
	){
		// prepend resource root
		if ( !findNoCase( arguments.resourceRoot, arguments.resource ) )
			arguments.resource = arguments.resourceRoot & arguments.resource;
		structDelete( arguments, "resourceRoot" );
		return getRESTClient().sendRequest( argumentCollection:arguments );
	}

	/**
	 * Creates a new TwiML response object.
	 */
	public any function newResponse(){
		return new classes.TwiML();
	}

	// ==========================================================================
	// Convinience Functions
	// ==========================================================================

	public any function availablePhoneNumbers(
		struct parameters,
		string countryCode = "US",
		string type = "Local"
	){
		return newRequest( "AvailablePhoneNumbers/" & arguments.countryCode & "/" & arguments.type, "GET", arguments.parameters ).getResponse().output();
	}

	public any function call( struct parameters ){
		return newRequest( "Calls", "POST", arguments.parameters ).getResponse().output();
	}

	public any function incomingPhoneNumbers( struct parameters ){
		return newRequest( "IncomingPhoneNumbers", "GET", arguments.parameters ).getResponse().output();
	}

	public any function outgoingCallerIds( struct parameters ){
		return newRequest( "OutgoingCallerIds", "GET", arguments.parameters ).getResponse().output();
	}

	public any function outgoingCallerIdByID( string ID ){
		return newRequest( "OutgoingCallerIds/" & arguments.ID ).getResponse().output();
	}

	public any function recordingByID( string ID ){
		return newRequest( "Recordings/" & arguments.ID ).getResponse().output();
	}

	public any function recordingsByCallID( string ID ){
		return newRequest( "Calls/" & arguments.ID & "/Recordings/" ).getResponse().output();
	}

	public any function sms( struct parameters ){
		return newRequest( "SMS/Messages", "POST", arguments.parameters).getResponse().output();
	}
}