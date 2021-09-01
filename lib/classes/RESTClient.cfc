/*
* The MIT License (MIT)
* Copyright (c) 2011 Jason Fill (@jasonfill)
*
* Script conversion and updates by @giancarlogomez
*/
component accessors=true output=false {

	property name="accountSid" 				type="string";
	property name="authToken" 				type="string";
	property name="apiVersion" 				type="string" default="2010-04-01";
	property name="apiEndPoint" 			type="string" default="api.twilio.com";
	property name="defaultResponse" 		type="string" default="json";
	property name="validResponseFormats" 	type="string" default="xml,json,csv,html";

	public RestClient function init(
		required string accountSid,
		required string authToken,
		string apiVersion,
		string apiEndPoint
	){
		setAccountSid( arguments.accountSid );
		setAuthToken( arguments.authToken );
		if ( structKeyExists( arguments, "apiVersion") )
			setApiVersion( arguments.apiVersion );
		if ( structKeyExists( arguments, "apiEndPoint") )
			setApiEndPoint( arguments.apiEndPoint );
		return this;
	}

	/**
	 * Constructs the HTTP request and sends it off to Twilio.
	 *
	 * @resource The resource that is being requested.
	 * @method The HTTP Request method, valid methods include: GET, POST, PUT, DELETE.
	 * @parameters The parameters that are to be sent with the request.
	 */
	public RESTRequest function sendRequest(
		required string resource,
		string method = "GET",
		struct parameters = {}
	){
		var requestObj 	= new RESTRequest();
		var response 	= "";

		// Make sure the method is valid
		if ( !listFindNoCase("GET,POST,PUT,DELETE", arguments.method) ){
			cfthrow(
				type 	= "TwilioRESTmethodException",
				detail 	= arguments.method & " is not a valid HTTP method for any Twilio REST resources. " &
							" Valid methods include: GET, POST, PUT, DELETE."
			);
		}
		// Build the url
		buildURL( arguments.resource, requestObj )

 		// Set the parameters and parameter type in the requestObject
 		requestObj.setParameters( arguments.parameters );
		 requestObj.setParameterType( arguments.method == "GET" ? "url" : "formfield" );

		// Send the request off to Twilio
		cfhttp(
			url 		= requestObj.getURL(),
			method 		= arguments.method,
			result 		= "response",
			username 	= variables.getAccountSid(),
			password 	= variables.getAuthToken()
		){
			for ( var key in requestObj.getParameters() ){
				cfhttpparam(
					type 	= requestObj.getParameterType(),
					name 	= verifyParameterKey( key, requestObj ),
					value 	= arguments.parameters[key]
				);
			}
		}

		// Process the response
		requestObj.handleResponse(response);

		// Return the request obj
		return requestObj;
	}

	/**
	 * Verifies the parameter key is a valid key for any Twilio REST resource and
	 * ensures that the key is in the proper case.
	 *
	 * @parameter The parameter to check.
	 * @requestObj An instance of the RESTRequest object which will be used to get the valid parameters.
	 */
	private string function verifyParameterKey(
		required string parameter,
		required RESTRequest requestObj
	){
		// Make sure the parameter exists in the list of valid parameters
		var keyIndex = arrayFindNoCase( requestObj.getValidParameterList(), arguments.Parameter );
		// throw error if invalid key
		if ( !keyIndex ){
			cfthrow(
				type 	= "TwilioRESTParameterException",
				detail 	= arguments.Parameter & " is not a valid parameter for any Twilio REST resources. " &
							"Please check the parameters and the Twilio docs for valid parameters. " &
							"If this is an error please update RestRequest.getValidParameterList()."
			);
		}
		// If the parameter was located, return the value from the list
		// as this will ensure that the value was not converted to upper case by the CFML engine
		return requestObj.getValidParameterList()[keyIndex];
	}

	/**
	 * Builds the full URL for the resource being accessed.
	 * The RESTRequest is passed in an updated by reference
	 */
	private void function buildURL(
		required string resource,
		required RESTRequest requestObj
	){
		var resourcePath 			= arguments.resource;
		var responseFormatIncluded 	= 0;
		var responseFormat 			= getDefaultResponse();
		var slashStart 				= 1;
		var apiVersion 				= "";
		// Check to see if the API version is specified in the resource
		var apiLoc = reFind( "(/?)([0-9]{4}\-[0-9]{2}-[0-9]{2})?", arguments.resource, 1, 1 );

		if ( apiLoc.len[3] && apiLoc.pos[3] )
			apiVersion = mid( arguments.resource, apiLoc.pos[3], apiLoc.len[3] );

		if ( left(arguments.resource, 1) != "/" )
			slashStart = 0;

		if ( !slashStart )
			resourcePath = "/" & arguments.resource;

		if ( !len(trim(apiVersion)) ){
			resourcePath = "/" & getApiVersion() & resourcePath;
			apiVersion   = getApiVersion();
		}

		// Replace {AccountSid} if required
		if ( findNoCase("{AccountSid}", resourcePath) )
			resourcePath = replaceNoCase( resourcePath, "{AccountSid}", getAccountSid() );

		// Now ensure the format is being specified
		for ( var f in getValidResponseFormats() ){
			if ( findNoCase( "." & f, right(resourcePath, len(f) + 1) ) ){
				responseFormat 			= f;
				responseFormatIncluded 	= 1;
				break;
			}
		}

		// If there is no response format included, go ahead and include it
		if ( !responseFormatIncluded )
			resourcePath = resourcePath & "." & responseFormat;

		resourcePath = "https://" & getApiEndPoint() & resourcePath;

		arguments.requestObj.setApiResponseFormat( responseFormat );
		arguments.requestObj.setApiVersion( apiVersion );
		arguments.requestObj.setUrl( resourcePath );
	}

}