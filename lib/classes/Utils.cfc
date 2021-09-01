/*
* The MIT License (MIT)
* Copyright (c) 2011 Jason Fill (@jasonfill)
*
* Script conversion and updates by @giancarlogomez
*/
component accessors=true output=false {

	property name="authToken" type="string";

	public RestClient function init(
		required string authToken

	){
		setAuthToken( arguments.authToken );
		return this;
	}

	public boolean function validateRequest(
		struct cgiInfo = cgi,
		struct httpResponseInfo = GetHttpRequestData()
	){
		var protocol 			= arguments.cgiInfo.server_port_secure ? "https://" : "http://";
		var postVars 			= "";
		var qString 			= arguments.cgiInfo.query_string;
		var headers 			= arguments.httpResponseInfo.headers;
		var method 				= arguments.httpResponseInfo.method;
		var uri 				= "";
		var expectedSignature 	= "";
		var sentSignature 		= "";

		if ( len(trim(qString)) )
			qString = "?" & qString;

		if ( method == "POST" )
			postVars = preparePostVars( urlDecode(arguments.httpResponseInfo.content, "utf-8") );

		uri = protocol & arguments.cgiInfo.server_name & arguments.cgiInfo.script_name & qString & postVars;

		expectedSignature = generateSignature( getAuthToken(), uri );

		if ( structKeyExists(headers, "X-Twilio-Signature") )
			sentSignature = headers["X-Twilio-Signature"];

		return expectedSignature == sentSignature;
	}

	private string function preparePostVars( required string qString ){
		var x 			= "" ;
		var str 		= "" ;
		var sortedList 	= "" ;
		var temp 		= {};

		for ( x in listToArray(arguments.qString,"&") )
			temp[listFirst(x,"=")] = listLast(x, "=");

		sortedList = listSort(structKeyList(temp), "text") ;

		for ( x in sortedList )
			str &= x & temp[x];

		return str;
	}

	private string function generateSignature(
		required string signKey,
		required string signMessage
	){
		var jMsg 	= javaCast("string",arguments.signMessage).getBytes("utf-8");
		var jKey 	= javaCast("string",arguments.signKey).getBytes("utf-8");
		var key 	= createObject("java","javax.crypto.spec.SecretKeySpec");
		var mac 	= createObject("java","javax.crypto.Mac");

		key = key.init(jKey,"HmacSHA1");
		mac = mac.getInstance(key.getAlgorithm());
		mac.init(key);
		mac.update(jMsg);
		return ToBase64(mac.doFinal());
	}
}