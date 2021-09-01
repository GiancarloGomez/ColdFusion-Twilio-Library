/*
* The MIT License (MIT)
* Copyright (c) 2011 Jason Fill (@jasonfill)
*
* Script conversion and updates by @giancarlogomez
*/
component accessors=true output=false {

	property name="response" type="array";
	property name="nestingPermissions" type="struct";

	public TwiML function init(){
		setResponse([]);
		setNestingPermissions({
			"dial" : "number,conference,client",
			"call" : "say,play,pause"
		});
		return this;
	}

	/**
	 * Say converts text to speech that is read back to the caller. Say is useful for development or saying dynamic text that is difficult to pre-record.
	 *
	 * @body The text to be converted to speech.
	 * @voice The 'voice' attribute allows you to choose a male or female voice to read text back. The default value is 'man'. Allowed Values: man, woma
	 * @language The 'language' attribute allows you pick a voice with a specific language's accent and pronunciations. Twilio currently supports languages 'en' (English), 'es' (Spanish), 'fr' (French), and 'de' (German). The default is 'en'
	 * @loop Specifies how many times you'd like the text repeated. The default is once. Specifying '0' will cause the the this text to loop until the call is hung up
	 * @childOf The verb that this verb should be nested within.
	 */
	public TwiML function say(
		required string body,
		string voice = "",
		string language = "",
		numeric loop = 1,
		string childOf = ""
	){
		// Validate the incoming arguments
		if ( len(trim(arguments.voice)) && !listFindNoCase("man,woman", arguments.voice) )
			throwException( arguments.voice & " is not a valid value for the voice attribute in say verb. Valid values are: man or woman." );

		if ( len(trim(arguments.language)) && !listFindNoCase("en,es,fr,de", arguments.language) )
			throwException( arguments.language & " is not a valid value for the language attribute in say verb. Valid values are: en,es,fr,de." );

		if ( val(arguments.loop) < 0 )
			throwException( arguments.loop & " is not a valid value for the loop attribute in say verb. Valid values must be integers greater or equal to 0." );

		var properties = {
			"voice" 	: arguments.voice,
			"language" 	: arguments.language,
			"loop" 		: arguments.loop
		};
		append( verb:"Say", body:arguments.body, properties:properties, childOf:arguments.childOf );
		return this;
	}

	/**
	 * Plays an audio file back to the caller. Twilio retrieves the file from a URL that you provide.
	 *
	 * @url The URL of an audio file that Twilio will retrieve and play to the caller
	 * @loop Specifies how many times the audio file is played. The default behavior is to play the audio once. Specifying '0' will cause the the audio file to loop until the call is hung up
	 */
	public TwiML function play(
		requires string url,
		numeric loop = 1
	){
		// Validate the incoming arguments
		if ( val(arguments.loop) < 0 )
			throwException( arguments.loop & " is not a valid value for the loop attribute in play verb. Valid values must be integers greater or equal to 0." );

		var properties = {
			"loop" : arguments.loop
		};
		append( verb:"Play", body:arguments.url, properties:properties );
		return this;
	}

	/**
	 * Collects digits that a caller enters into his or her telephone keypad. When the caller is done entering data,
	 * Twilio submits that data to the provided 'action' URL in an HTTP GET or POST request, just like a web browser
	 * submits data from an HTML form. If no input is received before timeout, the process moves through to the next
	 * verb in the TwiML document.
	 *
	 * @action The 'action' attribute takes an absolute or relative URL as a value. When the caller has finished entering digits Twilio will make a GET or POST request to this URL including the parameters below. If no 'action' is provided, Twilio will by default make a POST request to the current document's url.
	 * @method The 'method' attribute takes the value 'GET' or 'POST'. This tells Twilio whether to request the 'action' URL via HTTP GET or POST. This attribute is modeled after the HTML form 'method' attribute. 'POST' is the default value.
	 * @timeout The 'timeout' attribute sets the limit in seconds that Twilio will wait for the caller to press another digit before moving on and making a request to the 'action' url. For example, if 'timeout' is '10', Twilio will wait ten seconds for the caller to press another key before submitting the previously entered digits to the 'action' url. Twilio waits until completing the execution of all nested verbs before beginning the timeout period.
	 * @finishOnKey The 'finishOnKey' attribute lets you choose one value that submits the received data when entered.
	 * @numDigits The 'numDigits' attribute lets you set the number of digits you are expecting, and submits the data to the 'action' URL once the caller enters that number of digits. For example, one might set 'numDigits' to '5' and ask the caller to enter a 5 digit zip code. When the caller enters the fifth digit of '94117', Twilio will immediately submit the data to the 'action' url.
	 */
	public TwiML function gather(
		required string action,
		string method = "",
		string timeout = "",
		string finishOnKey = "",
		string numDigits = ""
	){
		// Validate the incoming arguments
		if ( len(trim(arguments.voice)) && !listFindNoCase("GET,POST", arguments.voice) )
			throwException( arguments.method & "is not a valid value for the method attribute in gather verb. Valid values are: GET or POST." );

		if ( len(trim(arguments.finishOnKey)) && !listFindNoCase("0,1,2,3,4,5,6,7,8,9,##,*", arguments.finishOnKey) )
			throwException( arguments.finishOnKey & "  is not a valid value for the finishOnKey attribute in gather verb. Valid values are: any digit, ## or *." );

		if ( len(trim(arguments.timeout)) && val(arguments.timeout) <= 0 )
			throwException( arguments.timeout & " is not a valid value for the timeout attribute in gather verb. Valid values must be positive integers." );

		if ( len(trim(arguments.numDigits)) && val(arguments.numDigits) < 1 )
			throwException( arguments.numDigits & " is not a valid value for the numDigits attribute in gather verb. Valid values must be integers greater or equal to 1." );

		var properties = {
			"action" 		: arguments.action,
			"method" 		: arguments.method,
			"timeout" 		: arguments.timeout,
			"finishOnKey" 	: arguments.finishOnKey,
			"numDigits" 	: arguments.numDigits
		};
		append( verb:"Gather", body:"", properties:properties );
		return this;
	}

	/**
	 * Records the caller's voice and returns to you the URL of a file containing the audio recording. You can
	 * optionally generate text transcriptions of recorded calls by setting the 'transcribe' attribute of the <Record>
	 * verb to 'true'.
	 *
	 * @action The 'action' attribute takes an absolute or relative URL as a value. When recording is finished Twilio will make a GET or POST request to this URL including the parameters below. If no 'action' is provided, <Record> will default to requesting the current document's url.
	 * @method The 'method' attribute takes the value 'GET' or 'POST'. This tells Twilio whether to request the 'action' URL via HTTP GET or POST. This attribute is modeled after the HTML form 'method' attribute. 'POST' is the default value.
	 * @timeout The 'timeout' attribute tells Twilio to end the recording after a number of seconds of silence has passed. The default is 5 seconds.
	 * @finishOnKey The 'finishOnKey' attribute lets you choose a set of digits that end the recording when entered.
	 * @maxLength The 'maxLength' attribute lets you set the maximum length for the recording in seconds. If you set 'maxLength' to '30', the recording will automatically end after 30 seconds of recorded time has elapsed. This defaults to 3600 seconds (one hour) for a normal recording and 120 seconds (two minutes) for a transcribed recording.
	 * @transcribe The 'transcribe' attribute tells Twilio that you would like a text representation of the audio of the recording. Twilio will pass this recording to our speech-to-text engine and attempt to convert the audio to human readable text.
	 * @transcribeCallback The 'transcribeCallback' attribute is used in conjunction with the 'transcribe' attribute. It allows you to specify a URL to which Twilio will make an asynchronous POST request when the transcription is complete.
	 * @playBeep The 'playBeep' attribute allows you to toggle between playing a sound before the start of a recording. If you set the value to 'false', no beep sound will be played.
	 */
	public TwiML function record(
		string action = "",
		string method = "",
		string timeout = "",
		string finishOnKey = "",
		string maxLength = "",
		string transcribe = "",
		string transcribeCallback = "",
		string playBeep = ""
	){
		// Validate the incoming arguments
		if ( len(trim(arguments.Method)) && !listFindNoCase("GET,POST", arguments.Method) )
			throwException( arguments.Method & " is not a valid value for the method attribute in record verb. Valid values are: get or post." );
		if ( len(trim(arguments.timeout)) && val(arguments.timeout) <= 0 )
			throwException( arguments.timeout & " is not a valid value for the timeout attribute in record verb. Valid values must be positive integers." );
		if ( len(trim(arguments.finishOnKey)) && !reFind("[0-9\*\##]*", arguments.finishOnKey) )
			throwException( arguments.finishOnKey & " is not a valid value for the finishOnKey attribute in record verb. Valid values are: any digit, ## or *." );
		if ( len(trim(arguments.maxLength)) && val(arguments.maxLength) <= 1 )
			throwException( arguments.maxLength & " is not a valid value for the maxLength attribute in record verb. Valid values must be integers greater than 1." );
		if ( len(trim(arguments.Transcribe)) && !listFindNoCase("true,false", arguments.Transcribe) )
			throwException( arguments.Transcribe & " is not a valid value for the transcribe attribute in record verb. Valid values are: true or false." );
		if ( len(trim(arguments.PlayBeep)) && !listFindNoCase("true,false", arguments.PlayBeep) )
			throwException( arguments.PlayBeep & " is not a valid value for the playBeep attribute in record verb. Valid values are: true or false." );

		var properties = {
			"action" 				: arguments.action,
			"method" 				: arguments.method,
			"timeout" 				: arguments.timeout,
			"finishOnKey" 			: arguments.finishOnKey,
			"maxLength" 			: arguments.maxLength,
			"transcribe" 			: arguments.transcribe,
			"transcribeCallback" 	: arguments.transcribeCallback,
			"playBeep" 				: arguments.playBeep
		};
		append( verb:"Record", body:"", properties:properties );
		return this;
	}

	/**
	 * Sends an SMS message to a phone number during a phone call.
	 *
	 * @action The 'action' attribute takes a URL as an argument. After processing the <Sms> verb, Twilio will make a GET or POST request to this URL with the form parameters 'SmsStatus' and 'SmsSid'. Using an 'action' URL, your application can receive synchronous notification that the message was successfully enqueued.
	 * @to The 'to' attribute takes a valid phone number as a value. Twilio will send an SMS message to this number. When sending an SMS during an incoming call, 'to' defaults to the caller. When sending an SMS during an outgoing call, 'to' defaults to the called party. The value of 'to' must be a valid phone number.
	 * @from The 'from' attribute takes a valid phone number as an argument. This number must be a phone number that you've purchased from or ported to Twilio. When sending an SMS during an incoming call, 'from' defaults to the called party. When sending an SMS during an outgoing call, 'from' defaults to the calling party. This number must be an SMS-capable local phone number assigned to your account.
	 * @method The 'method' attribute takes the value 'GET' or 'POST'. This tells Twilio whether to request the 'action' URL via HTTP GET or POST. This attribute is modeled after the HTML form 'method' attribute. 'POST' is the default value.
	 * @statusCallback The 'statusCallback' attribute takes a URL as an argument. When the SMS message is actually sent, or if sending fails, Twilio will make an asynchronous POST request to this URL with the parameters 'SmsStatus' and 'SmsSid'. Note, 'statusCallback' always uses HTTP POST to request the given url.
	 */
	public TwiML function sms(
		string action = "",
		string to = "",
		string from = "",
		string method = "",
		string statusCallback = ""
	){
		// Validate the incoming arguments
		if ( len(trim(arguments.to)) && !isValid("telephone", arguments.to) )
			throwException( arguments.to & " is not a valid value for the to attribute in sms verb. Values must be valid phone numbers." );
		if ( len(trim(arguments.from)) && !isValid("telephone", arguments.from) )
			throwException( arguments.from & " is not a valid value for the from attribute in sms verb. Values must be valid phone numbers." );
		if ( len(trim(arguments.Method)) && !listFindNoCase("GET,POST", arguments.Method) )
			throwException( arguments.Method & " is not a valid value for the method attribute in record verb. Valid values are: get or post." );

		var properties = {
			"action" 			: arguments.action,
			"to" 				: arguments.to,
			"from" 				: arguments.from,
			"method" 			: arguments.method,
			"statusCallback" 	: arguments.statusCallback
		};
		append( verb:"Sms", body:"", properties:properties );
		return this;
	}

	/**
	 * Connects the current caller to an another phone. If the called party picks up, the two parties are connected and
	 * can communicate until one hangs up. If the called party does not pick up, if a busy signal is received, or if the
	 * number doesn't exist, the dial verb will finish.
	 *
	 * @action The 'action' attribute takes a URL as an argument. When the dialed call ends, Twilio will make a GET or POST request to this URL including the parameters below.
	 * @number The phone number to dial.
	 * @method The 'method' attribute takes the value 'GET' or 'POST'. This tells Twilio whether to request the 'action' URL via HTTP GET or POST. This attribute is modeled after the HTML form 'method' attribute. 'POST' is the default value.
	 * @timeout The 'timeout' attribute sets the limit in seconds that is waited for the called party to answer the call. Basically, how long should Twilio let the call ring before giving up and reporting 'no-answer' as the 'DialCallStatus'.
	 * @hangupOnStar The 'hangupOnStar' attribute lets the calling party hang up on the called party by pressing the '*' key on his phone. When two parties are connected using <Dial>, Twilio blocks execution of further verbs until the caller or called party hangs up. This feature allows the calling party to hang up on the called party without having to hang up her phone and ending her TwiML processing session. When the caller presses '*' Twilio will hang up on the called party. If an 'action' URL was provided, Twilio submits 'completed' as the 'DialCallStatus' to the URL and processes the response. If no 'action' was provided Twilio will continue on to the next verb in the current TwiML document.
	 * @timeLimit The 'timeLimit' attribute sets the maximum duration of the <Dial> in seconds. For example, by setting a time limit of 120 seconds <Dial> will hang up on the called party automatically two minutes into the phone call. By default, there is a four hour time limit set on calls.
	 * @callerId The 'callerId' attribute lets you specify the caller ID that will appear to the called party when Twilio calls. By default, when you put a <Dial> in your TwiML response to Twilio's inbound call request, the caller ID that the dialed party sees is the inbound caller's caller ID.
	 */
	public TwiML function dial(
		string action = "",
		string number = "",
		string method = "",
		string timeout = "",
		string hangupOnStar = "",
		string timeLimit = "",
		string callerId = ""
	){
		// Validate the incoming arguments
		if ( len(trim(arguments.number)) && !isValid("telephone", arguments.number) )
			throwException( arguments.number & " is not a valid value for the number attribute in dial verb. Values must be valid phone numbers." );
		if ( len(trim(arguments.Method)) && !listFindNoCase("GET,POST", arguments.Method) )
			throwException( arguments.Method & " is not a valid value for the method attribute in dial verb. Valid values are: get or post." );
		if ( len(trim(arguments.timeout)) && val(arguments.timeout) <= 0 )
			throwException( arguments.timeout & " is not a valid value for the timeout attribute in dial verb. Valid values must be positive integers." );
		if ( len(trim(arguments.hangupOnStar)) && !listFindNoCase("true,false", arguments.hangupOnStar) )
			throwException( arguments.hangupOnStar & " is not a valid value for the hangupOnStar attribute in dial verb. Valid values are: true or false." );
		if ( len(trim(arguments.timeLimit)) && val(arguments.timeLimit) <= 0 )
			throwException( arguments.timeLimit & " is not a valid value for the timeLimit attribute in dial verb. Valid values must be positive integers." );
		if ( len(trim(arguments.callerId)) && !isValid("telephone", arguments.callerId) )
			throwException( arguments.callerId & " is not a valid value for the callerId attribute in dial verb. Values must be valid phone numbers." );

		var properties = {
			"action" 		: arguments.action,
			"method" 		: arguments.method,
			"timeout" 		: arguments.timeout,
			"hangupOnStar" 	: arguments.hangupOnStar,
			"timeLimit" 	: arguments.timeLimit,
			"callerId"		: arguments.callerId
		};
		append( verb:"Dial", body:arguments.number, properties:properties );
		return this;
	}

	/**
	 * The <Dial> verb's <Number> noun specifies a phone number to dial. Using the noun's attributes you can specify
	 * particular behaviors that Twilio should apply when dialing the number.
	 *
	 * @number The phone number to dial.
	 * @sendDigits The 'sendDigits' attribute tells Twilio to play DTMF tones when the call is answered. This is useful when dialing a phone number and an extension. Twilio will dial the number, and when the automated system picks up, send the DTMF tones to connect to the extension.
	 * @url The 'url' attribute allows you to specify a url for a TwiML document that will run on the called party's end, after she answers, but before the parties are connected. You can use this TwiML to privatly play or say information to the called party, or provide a chance to decline the phone call using <Gather> and <Hangup>. The current caller will continue to hear ringing while the TwiML document executes on the other end. TwiML documents executed in this manner are not allowed to contain the <Dial> verb.
	 * @childOf The verb that this verb should be nested within.
	 */
	public TwiML function number(
		string number = "",
		string sendDigits = "",
		string url = "",
		string childOf = ""
	){
		// Validate the incoming arguments
		if ( len(trim(arguments.number)) && !isValid("telephone", arguments.number) )
			throwException( arguments.number & " is not a valid value for the number attribute in number verb. Values must be valid phone numbers." );
		if ( len(trim(arguments.sendDigits)) && !isValid("telephone", arguments.sendDigits) )
			throwException( arguments.sendDigits & " is not a valid value for the sendDigits attribute in number verb. Valid values are any digits." );

			var properties = {
			"sendDigits" 	: arguments.sendDigits,
			"url" 			: arguments.url
		};
		append( verb:"Number", body:arguments.number, properties:properties, childOf:arguments.childOf );
		return this;
	}

	/**
	 * The <Dial> verb's <Client> noun allows you to connect to a conference room. Much like how the <Number> noun
	 * allows you to connect to another phone number, the <Conference> noun allows you to connect to a named conference
	 * room and talk with the other callers who have also connected to that room.
	 *
	 * @clientName Name of the client to connect to.
	 * @childOf The verb that this verb should be nested within.
	 */
	public TwiML function client(
		required string clientName,
		string childOf = "dial"
	){
		append( verb:"Client", body:arguments.clientName, properties:{}, childOf:arguments.childOf );
		return this;
	}

	/**
	 * The <Dial> verb's <Conference> noun allows you to connect to a conference room. Much like how the <Number> noun
	 * allows you to connect to another phone number, the <Conference> noun allows you to connect to a named conference
	 * room and talk with the other callers who have also connected to that room.
	 *
	 * @roomName Name of the conference room to connect to.
	 * @muted The 'muted' attribute lets you specify whether a participant can speak on the conference. If this attribute is set to 'true', the participant will only be able to listen to people on the conference. This attribute defaults to 'false'.
	 * @beep The 'beep' attribute lets you specify whether a notification beep is played to the conference when a participant joins or leaves the conference. This defaults to 'true'.
	 * @startConferenceOnEnter This attribute tells a conference to start when this participant joins the conference, if it is not already started. This is true by default. If this is false and the participant joins a conference that has not started, they are muted and hear background music until a participant joins where startConferenceOnEnter is true. This is useful for implementing moderated conferences.
	 * @endConferenceOnExit If a participant has this attribute set to 'true', then when that participant leaves, the conference ends and all other participants drop out. This defaults to 'false'. This is useful for implementing moderated conferences that bridge two calls and allow either call leg to continue executing TwiML if the other hangs up.
	 * @waitUrl The 'waitUrl' attribute lets you specify a URL for music that plays before the conference has started.
	 * @waitMethod This attribute indicates which HTTP method to use when requesting 'waitUrl'. It defaults to 'POST'. Be sure to use 'GET' if you are directly requesting static audio files such as WAV or MP3 files so that Twilio properly caches the files.
	 * @maxParticipants This attribute indicates the maximum number of participants you want to allow within a named conference room. The default maximum number of participants is 40. The value must be a positive integer less than or equal to 40.
	 * @childOf The verb that this verb should be nested within.
	 */
	public TwiML function conference(
		required string roomName,
		string muted = "",
		string beep = "",
		string startConferenceOnEnter = "",
		string endConferenceOnExit = "",
		string waitUrl = "",
		string waitMethod = "",
		string maxParticipants = "",
		string childOf = ""
	){
		// Validate the incoming arguments
		if ( len(trim(arguments.muted)) && !ListFindNoCase("true,false", arguments.muted) )
			throwException( arguments.muted & " is not a valid value for the muted attribute in conference verb. Valid values are: true or false." );
		if ( len(trim(arguments.beep)) && !ListFindNoCase("true,false", arguments.beep) )
			throwException( arguments.beep & " is not a valid value for the beep attribute in conference verb. Valid values are: true or false." );
		if ( len(trim(arguments.startConferenceOnEnter)) && !ListFindNoCase("true,false", arguments.startConferenceOnEnter) )
			throwException( arguments.startConferenceOnEnter & " is not a valid value for the startConferenceOnEnter attribute in conference verb. Valid values are: true or false." );
		if ( len(trim(arguments.endConferenceOnExit)) && !ListFindNoCase("true,false", arguments.endConferenceOnExit) )
			throwException( arguments.endConferenceOnExit & " is not a valid value for the endConferenceOnExit attribute in conference verb. Valid values are: true or false." );
		if ( len(trim(arguments.muted)) && !ListFindNoCase("true,false", arguments.muted) )
			throwException( arguments.muted & " is not a valid value for the muted attribute in conference verb. Valid values are: true or false." );
		if ( len(trim(arguments.waitMethod)) && !ListFindNoCase("GET,POST", arguments.waitMethod) )
			throwException( arguments.waitMethod & " is not a valid value for the waitMethod attribute in conference verb. Valid values are: get or post." );
		if ( len(trim(arguments.maxParticipants)) && (val(arguments.maxParticipants) LTE 0 OR val(arguments.maxParticipants) GT 40) )
			throwException( arguments.maxParticipants & " is not a valid value for the maxParticipants attribute in conference verb. Valid values must integers greater than 0 and less than or equal to 40." );

		var properties = {
			"muted" 					: arguments.muted,
			"beep" 						: arguments.beep,
			"startConferenceOnEnter" 	: arguments.startConferenceOnEnter,
			"endConferenceOnExit" 		: arguments.endConferenceOnExit,
			"waitUrl" 					: arguments.waitUrl,
			"waitMethod" 				: arguments.waitMethod,
			"maxParticipants" 			: arguments.maxParticipants
		};
		append( verb:"Conference", body:arguments.roomName, properties:properties, childOf:arguments.childOf );
		return this;
	}

	/**
	 * Ends a call. If used as the first verb in a TwiML response it does not prevent Twilio from answering the call
	 * and billing your account.
	 */
	public TwiML function hangup(){
		append( verb:"Hangup" );
		return this;
	}

	/**
	 * Transfers control of a call to the TwiML at a different url. All verbs after this method are unreachable and ignored.
	 *
	 * @url An absolute or relative URL for a different TwiML document.
	 * @method The 'method' attribute takes the value 'GET' or 'POST'. This tells Twilio whether to request the <Redirect> URL via HTTP GET or POST. 'POST' is the default.
	 */
	public TwiML function redirect(
		required string url,
		string method = ""
	){
		if ( len(trim(arguments.method)) && !listFindNoCase("GET,POST", arguments.method) )
			throwException( arguments.method &" is not a valid value for the method attribute in redirect verb. Valid values are: get or post." );

		append(verb="Redirect", body=arguments.url, properties={"method":arguments.method});
		return this;
	}

	/**
	 * Rejects an incoming call to your Twilio number without billing you. This is very useful for blocking unwanted
	 * calls.  If the first verb in a TwiML document is <Reject>, Twilio will not pick up the call. The call ends with
	 * a status of 'busy' or 'no-answer', depending on the verb's 'reason' attribute. Any verbs after <Reject> are
	 * unreachable and ignored.
	 *
	 * @reason The reason attribute takes the values 'rejected' and 'busy.' This tells Twilio what message to play when rejecting a call. Selecting 'busy' will play a busy signal to the caller, while selecting 'rejected' will play a standard not-in-service response. If this attribute's value isn't set, the default is 'rejected.'
	 */
	public TwiML function reject(
		string reason = ""
	){
		// Validate the incoming arguments
		if ( len(trim(arguments.reason)) && !listFindNoCase("rejected,busy", arguments.reason) )
			throwException( arguments.reason & " is not a valid value for the reason attribute in reject verb. Valid values are: rejected or busy." );

		append( verb:"Reject", body:"", properties:{"reason":arguments.reason} );
		return this;
	}

	/**
	 * Waits silently for a specific number of seconds. If first verb in a TwiML document, Twilio will wait the
	 * specified number of seconds before picking up the call.
	 *
	 * @length The 'length' attribute specifies how many seconds Twilio will wait silently before continuing on.
	 * @childOf The verb that this verb should be nested within.
	 */
	public TwiML function pause(
		numeric length = 1,
		string childOf = ""
	){
		// Validate the incoming arguments
		if ( len(trim(arguments.length)) && val(arguments.length) <= 0 )
			throwException( arguments.length & " is not a valid value for the length attribute in pause verb. Valid values must integers greater than 0." );

		append( verb:"Pause", body:"", properties:{"length":arguments.length}, childOf:arguments.childOf );
		return this;
	}

	public string function getResponseXml(){
		var newElement 		= "";
		var responseDoc 	= XmlNew();
		var responseRoot 	= XmlElemNew( responseDoc, "", "Response" );

		responseDoc.XmlRoot = responseRoot;

		for ( var i in getResponse() )
			buildResponse(responseDoc, responseDoc.Response, i);

		xmlString = toString(responseDoc);
		xmlString = xmlString.replaceAll("xmlns(:\w+)?=""[^""]*""","");
		xmlString = xmlString.replaceAll(" >",">");
		xmlString = xmlString.replaceAll(">#chr(10)#<","><");

		return xmlString;
	}

	private any function buildResponse( responseDoc, appendTo, Item ){
		var newElement = XmlElemNew( arguments.responseDoc, "", arguments.Item.verb );

		newElement.XmlText = arguments.Item.body;

		// Loop all the properties
		for ( var p in arguments.Item.properties ){
			if ( len(trim(arguments.Item.properties[p])) )
				newElement.XmlAttributes[p] = arguments.Item.properties[p];
		}

		// Now if there is a child, append it
		for ( var c in arguments.Item.Children )
			buildResponse(arguments.responseDoc, newElement, c);

		arrayAppend(arguments.AppendTo.XmlChildren, newElement);

		return arguments.responseDoc;
	}

	private void function append(
		required string verb,
		string body = "",
		struct properties = {},
		string childOf = ""
	){
		var verbData 	= {
			"verb" 			: arguments.verb,
			"properties" 	: arguments.properties,
			"body" 			: XmlFormat(arguments.body),
			"children" 		: []
		};
		var nestInto 	= "";
		var nestIntoIdx = 0;
		var v 			= "";

		if ( !len(trim(arguments.childOf)) ){
			getResponse().append( verbData );
		}
		else {
			// Since we are nesting this, we need to figure out which index we are nesting into
			for( v = getResponse().len(); v >= 1; v-- ){
				if ( getResponse()[v].verb == arguments.childOf ){
					nestIntoIdx = v;
					break;
				}
			}

			if ( !val(nestIntoIdx) )
				throwException( "There no #arguments.childOf# verbs to nest #arguments.verb# into.", "TwilioNestingException" );

			nestInto = getResponse()[nestIntoIdx];

			if (
				structKeyExists(getNestingPermissions(),nestInto.verb) &&
				listFindNoCase(getNestingPermissions()[nestInto.verb], arguments.Verb)
			){
				arrayAppend(getResponse()[getResponse().len()].children, verbData);
			}
			else {
				throwException( "#arguments.Verb# cannot be nested within #nestInto.verb#.", "TwilioNestingException" );
			}
		}
	}

	private void function throwException(
		required string detail,
		string type = "TwilioAttributeException"
	){
		cfthrow( type=arguments.type, detail=arguments.detail );
	}
}