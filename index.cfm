<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Twilio Tests</title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css" integrity="sha256-z8OR40MowJ8GgK6P89Y+hiJK5+cclzFHzLhFQLL92bg=" crossorigin="anonymous">
	<style>
		body {
			display: flex;
			gap: 1rem;
			flex-wrap: wrap;
			max-width: 100vw;
			align-items: flex-start;
		}
		body > table {
			width: calc( 50% - 1rem );
		}
		table[class*="cfdump"] * {
			font-family: "JetBrains Mono", Consolas, monospace;
			font-size: 1rem;
			line-height: 1.42;
			vertical-align: top;
		}
	</style>
</head>
<body class="p-3">
	<div class="container-fluid">
		<cfif !application.twilioConfig.enabled>
			<div class="alert alert-danger text-center">
				<strong>You do not have Twilio enabled.</strong><br />
				Review the settings in <code>ApplicationStart()</code> and
				<a href="./?reload">click here to reload.</a>
			</div>
		<cfelseif !len(application.twilioConfig.accountSid) || !len(application.twilioConfig.fromNumber) || !len(application.twilioConfig.authToken)>
			<div class="alert alert-danger text-center">
				<strong>Please set your Twilio Config Settings</strong><br />
				Review the settings in <code>ApplicationStart()</code> and
				<a href="./?reload">click here to reload.</a>
			</div>
		<cfelse>
			<h2>Sample Requests</h2>
			<div class="mt-3">
				<a href="?AvailablePhoneNumbers" class="btn btn-primary">
					Available Phone Numbers
				</a>
				<a href="?Calls" class="btn btn-primary">
					Call
				</a>
				<a href="?IncomingPhoneNumbers" class="btn btn-primary">
					Incoming Phone Numbers
				</a>
				<a href="?Messages" class="btn btn-primary">
					SMS
				</a>
				<a href="?OutgoingCallerIds" class="btn btn-primary">
					Outgoing Caller Ids
				</a>
			</div>
			<div class="d-flex gap-3 mt-3">
				<cfscript>
					if ( application.twilioConfig.enabled ){
						try{
							// https://www.twilio.com/docs/phone-numbers/api/availablephonenumberlocal-resource#read-multiple-availablephonenumberlocal-resources
							if ( structKeyExists(url,"AvailablePhoneNumbers") ){
								writeDump(
									label 	: "Local",
									var 	: application.twilio.availablePhoneNumbers({
										"areaCode" : "415"
									})
								);
								writeDump(
									label 	: "TollFree",
									var 	: application.twilio.availablePhoneNumbers(
										parameters 	: { "contains" : "444" },
										type 		: "TollFree"
									)
								);
							}

							// https://www.twilio.com/docs/voice/make-calls#initiate-an-outbound-call-with-twilio
							if ( structKeyExists(url,"Calls") ){
								if ( !len(request.testNumber ?: "" )){
									writeOutput("<div class=""alert alert-danger w-100 text-center"">There is no number defined in <code>request.testNumber</code></div>");
								}
								else{
									writeDump(
										label 	: "Call",
										var 	: application.twilio.call({
											"from" 	: application.twilioConfig.fromNumber,
											"to" 	: request.testNumber,
											"url" 	: "http://demo.twilio.com/docs/voice.xml"
										})
									);
								}
							}

							// https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource
							if ( structKeyExists(url,"IncomingPhoneNumbers") ){
								writeDump(
									label 	: "Incoming Phone Numbers",
									var 	: application.twilio.incomingPhoneNumbers({
										"pageSize" : 100
									})
								);
							}

							// https://www.twilio.com/docs/sms/api/message-resource#create-a-message-resource
							if ( structKeyExists(url,"Messages") ){
								if ( !len(request.testNumber ?: "" )){
									writeOutput("<div class=""alert alert-danger w-100 text-center"">There is no number defined in <code>request.testNumber</code></div>");
								}
								else{
									writeDump(
										label 	: "SMS",
										var 	: application.twilio.sms({
											"from" 	: application.twilioConfig.fromNumber,
											"to" 	: request.testNumber,
											"body" 	: "This is a sample text message"
										})
									);
								}
							}

							// https://www.twilio.com/docs/voice/api/outgoing-caller-ids
							if ( structKeyExists(url,"OutgoingCallerIds") ){
								twilioRequest = application.twilio.outgoingCallerIds();

								writeDump(
									label 	: "Outgoing Caller IDs",
									var 	: twilioRequest
								);

								twilioRequest = application.twilio.outgoingCallerIdByID( twilioRequest.outgoing_caller_ids[1].sid );

								writeDump(
									label 	: "Outgoing Caller ID",
									var 	: twilioRequest
								);
							}
						}
						catch( any e ){
							writeDUmp( e );
						}
					}
				</cfscript>
			</div>
		</cfif>
	</div>
</body>
</html>