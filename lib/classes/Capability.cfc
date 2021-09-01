/*
* The MIT License (MIT)
* Copyright (c) 2011 Jason Fill (@jasonfill)
*
* Script conversion and updates by @giancarlogomez
*/
component accessors=true output=false {

	property name="accountSid" 			type="string";
	property name="authToken" 			type="string";
	property name="appSid" 				type="string" 	default="";
	property name="buildIncomingScope" 	type="boolean" 	default=false;
	property name="buildOutgoingScope" 	type="boolean" 	default=false;
	property name="incomingClientName" 	type="string" 	default="";
	property name="outgoingClientName" 	type="string" 	default="";
	property name="outgoingParams" 		type="struct";
	property name="scopes" 				type="string" 	default="";

	public Capability function init(
		required string accountSid,
		required string authToken
	){
		setAccountSid( arguments.accountSid );
		setAuthToken( arguments.authToken );
		setOutgoingParams( {} );
		return this;
	}

	/**
	 * If the user of this token should be allowed to accept incoming connections then configure the TwilioCapability
	 * through this method and specify the client name.
	 */
	public void function allowClientIncoming( required string clientName ){
		setBuildIncomingScope( true );
		setIncomingClientName( arguments.clientName );
	}

	/**
	 * Allow the user of this token to make outgoing connections.
	 *
	 * @appSid The application to which this token grants access
	 * @params Signed parameters that the user of this token cannot overwrite.
	 */
	public void function allowClientOutgoing(
		required string appSid,
		struct params = {}
	){
		setBuildOutgoingScope( true );
		setAppSid( arguments.AppSid );
		setOutgoingParams( arguments.Params );
	}

	/**
	 * Allow the user of this token to access their event stream.
	 *
	 * @filters key/value filters to apply to the event stream
	 */
	public void function allowEventStream( struct filters = {} ){
		var value = {
			"path" : "/2010-04-01/Events"
		};
		var paramsJoined = "";

		if ( listLen( structKeyList( arguments.filters ) ) ){
			paramsJoined 	= generateParamString( arguments.filters );
			value["params"] = paramsJoined;
		}

		setScopes( listAppend( getScopes(), buildScopeString("stream", "subscribe", value) ) );
	}

	public string function buildScopeString(
		required string service,
		required string priviledge,
		required struct params
	){
		var scope = "scope:" & trim( arguments.service ) & ":" & trim( arguments.priviledge );

		if ( listLen( structKeyList( arguments.params ) ) )
			scope &= "?" & generateParamString( arguments.params );

		return trim(scope);
	}

	/**
	 * Generates a new token based on the credentials and permissions that previously has been granted to this token.
	 */
	public string function generateToken( numeric timeout = 3600 ){
		var payload = {};

		buildIncomingScope();
		buildOutgoingScope();

		payload["iss"] 		= getAccountSid();
		// Force the exp to string and divide by 1000 otherwise the timestamp is too precise...thanks to Mario Rodrigues (@webauthor) for this find...
		payload["exp"] 		= "" & toString( ( now().getTime() / 1000 ) + val(arguments.timeout));
		payload["scope"] 	= listChangeDelims( getScopes(), " " );

		return jwtEncode( payload, getAuthToken() );
	}

	private void function buildIncomingScope(){
		var values = {};

		if ( getBuildIncomingScope() ){
			if ( len( getIncomingClientName() ) )
				values["clientName"] = getIncomingClientName();
			else
				cfthrow( message="No client name set." );

			setScopes( listAppend( getScopes(), buildScopeString("client", "incoming", values) ) );
		}
	}

	private void function buildOutgoingScope(){
		var values 			= {};
		var paramsJoined 	= "";

		if ( getBuildOutgoingScope() ){

			values["appSid"] = getAppSid();

			/*
			* Outgoing takes precedence over any incoming name which
			* takes precedence over the default client name. however,
			* we do accept a null clientName
			*/

			if ( len( getOutgoingClientName() ) )
				values["clientName"] = getOutgoingClientName();
			else if ( len( getIncomingClientName() ) )
				values["clientName"] = getIncomingClientName();

			// Build outgoing scopes
			if ( listLen( structKeyList( getOutgoingParams() ) ) ){
				paramsJoined 		= generateParamString( getOutgoingParams() );
				values["appParams"] = paramsJoined;
			}

			setScopes( listAppend( getScopes(), buildScopeString("client", "outgoing", values) ) );
		}
	}

	private string function generateParamString( required struct params ){
		var str 	= "";
		var p 		= "" ;
		var key 	= "";
		var value 	= "";

		for ( p in arguments.params ){
			key 	= toString( p.getBytes( "utf-8" ) );
			value 	= toString( arguments.params[p].getBytes("utf-8") );
			str 	= listAppend( str, key & "=" & value, "&" );
		}

		return str;
	}

	private string function encodeBase64( required any string ){
		return toBase64(arguments.String);
	}

	private string function jsonEncode( required any object ){
		return replace( serializeJSON(arguments.object), "/", "\\/", "all" );
	}

	private string function jwtEncode(
		required struct payload,
		required string key
	){
		var header 			= {
			"typ" : "JWT",
			"alg" : "HS256"
		};
		var segments 		= "";
		var signingInput 	= "";
		var signature 		= "";

		segments 		= listAppend( segments, encodeBase64( jsonEncode( header ) ), "." );
		segments 		= listAppend( segments, encodeBase64( jsonEncode( arguments.payload ) ), "." );
		signingInput 	= segments;
		signature 		= sign( signingInput, arguments.key );
		segments 		= listAppend( segments, signature, "." );

		return segments;
	}

	private string function sign(
		required string signMessage,
		required string signKey
	){
		var jMsg 	= javaCast( "string", arguments.signMessage ).getBytes( "utf-8" );
		var jKey 	= javaCast( "string", arguments.signKey ).getBytes( "utf-8" );
		var key 	= createObject( "java", "javax.crypto.spec.SecretKeySpec" );
		var mac 	= createObject( "java", "javax.crypto.Mac" );

		key 		= key.init( jKey, "HmacSHA256" );
		mac 		= mac.getInstance( key.getAlgorithm() );

		mac.init( key );
		mac.update( jMsg );

		return toBase64( mac.doFinal() );
	}
}