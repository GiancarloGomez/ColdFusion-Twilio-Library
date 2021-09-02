/*
* The MIT License (MIT)
* Copyright (c) 2011 Jason Fill (@jasonfill)
*
* Script conversion and updates by @giancarlogomez
*/
component accessors=true output=false {

	property name="rawResponse" 	type="struct";
	property name="httpStatusCode" 	type="string" default="";
	property name="httpStatusText" 	type="string" default="";
	property name="contentLength" 	type="string" default="";
	property name="contentType" 	type="string" default="";
	property name="eTag" 			type="string" default="";
	property name="lastModified" 	type="string" default="";
	property name="responseString" 	type="string" default="";
	property name="responseContent" type="any";

	public RestResponse function init(
		required RestRequest RequestObj,
		required struct Response
	){
		setRawResponse( arguments.Response );
		setHttpStatusCode( val(arguments.Response.StatusCode) );
		setHttpStatusText( trim(replace(arguments.Response.StatusCode,getHttpStatusCode(),"")) );

		if ( structKeyExists(arguments.Response.ResponseHeader, "Last-Modified") )
			setContentLength( arguments.Response.ResponseHeader["Content-Length"] );

		setContentType( arguments.Response.ResponseHeader["Content-Type"] );
		setETag( arguments.Response.ResponseHeader.etag ?: "" );
		setLastModified( arguments.Response.ResponseHeader["Last-Modified"]  ?: "" );
		setResponseString( arguments.Response.fileContent );
		setResponseContent( arguments.Response.fileContent );

		if ( arguments.RequestObj.getApiResponseFormat() == "xml" && isXML( getResponseContent() ) )
			setResponseContent( xmlParse( getResponseContent() ) );
		else if ( arguments.RequestObj.getApiResponseFormat() == "json" && isJSON( getResponseContent() ) )
			setResponseContent( deserializeJSON( getResponseContent() ) );

		return this;
	}

	public any function output(){
		return getResponseContent();
	}

	public boolean function wasSuccessful(){
		return getHttpStatusCode() < 400 ? true : false;
	}
}