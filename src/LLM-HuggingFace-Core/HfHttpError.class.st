"
Raised when the Hugging Face endpoint returns a non-success HTTP status code
that does not match a more specific subclass (auth / not found / gated / rate
limit). Carries the HTTP status, the request URL, and the raw response body
so that callers can inspect the failure in detail.
"
Class {
	#name : 'HfHttpError',
	#superclass : 'HfError',
	#instVars : [
		'statusCode',
		'responseBody',
		'requestUrl'
	],
	#category : 'HuggingFace-Core-Errors',
	#package : 'HuggingFace-Core',
	#tag : 'Errors'
}

{ #category : 'signalling' }
HfHttpError class >> status: anInteger url: aUrl body: aString [

	^ self new
		  statusCode: anInteger;
		  requestUrl: aUrl;
		  responseBody: aString;
		  messageText:
			  ('HTTP {1} for {2}: {3}' format: {
					   anInteger.
					   aUrl asString.
					   (aString ifNil: [ '' ]) });
		  signal
]

{ #category : 'accessing' }
HfHttpError >> requestUrl [

	^ requestUrl
]

{ #category : 'accessing' }
HfHttpError >> requestUrl: anObject [

	requestUrl := anObject
]

{ #category : 'accessing' }
HfHttpError >> responseBody [

	^ responseBody
]

{ #category : 'accessing' }
HfHttpError >> responseBody: anObject [

	responseBody := anObject
]

{ #category : 'accessing' }
HfHttpError >> statusCode [

	^ statusCode
]

{ #category : 'accessing' }
HfHttpError >> statusCode: anObject [

	statusCode := anObject
]
