"
Thin wrapper around `ZnClient` that centralises every HTTP concern unique
to the Hugging Face API:

	- Injects `Authorization: Bearer <token>` when a token is configured.
	- Sets the `User-Agent` and default `Accept` headers.
	- Maps HTTP status codes onto the typed exception hierarchy
	  (`HfAuthenticationError`, `HfRepositoryNotFoundError`, ...).
	- Retries transient failures (5xx / 429 / network) with exponential backoff
	  up to `configuration maxRetries`.
	- Returns the decoded JSON body for `get:` / `postJson:with:` and leaves
	  `downloadUrl:to:` to stream straight to disk for large LFS files.

The client is *stateless* beyond its configuration: every call creates a
fresh `ZnClient`, which matches Zinc's intended usage pattern and keeps
concurrent calls safe.
"
Class {
	#name : 'HfHttpClient',
	#superclass : 'Object',
	#instVars : [
		'configuration'
	],
	#category : 'LLM-HuggingFace-Core-Http',
	#package : 'LLM-HuggingFace-Core',
	#tag : 'Http'
}

{ #category : 'instance creation' }
HfHttpClient class >> on: anHfConfiguration [

	^ self new configuration: anHfConfiguration
]

{ #category : 'private' }
HfHttpClient >> checkStatus: aZnResponse url: aUrl [
	"Raise a typed exception when the response is not a success."

	| status body |
	status := aZnResponse code.
	(status between: 200 and: 299) ifTrue: [ ^ self ].
	body := [ aZnResponse contents asString ]
		        on: Error
		        do: [ :e | '<unreadable body: ' , e messageText , '>' ].
	status = 401 ifTrue: [
		^ HfAuthenticationError status: status url: aUrl body: body ].
	status = 403 ifTrue: [
		((body asLowercase includesSubstring: 'gated')
			 or: [ body asLowercase includesSubstring: 'access' ])
			ifTrue: [ ^ HfGatedRepoError status: status url: aUrl body: body ].
		^ HfAuthorizationError status: status url: aUrl body: body ].
	status = 404 ifTrue: [
		^ HfRepositoryNotFoundError status: status url: aUrl body: body ].
	status = 429 ifTrue: [
		^ HfRateLimitError status: status url: aUrl body: body ].
	^ HfHttpError status: status url: aUrl body: body
]

{ #category : 'accessing' }
HfHttpClient >> configuration [

	^ configuration
]

{ #category : 'accessing' }
HfHttpClient >> configuration: anHfConfiguration [

	configuration := anHfConfiguration
]

{ #category : 'requests' }
HfHttpClient >> delete: aUrl [

	^ self withRetryOn: aUrl do: [ :client |
		  client url: aUrl.
		  client delete.
		  self checkStatus: client response url: aUrl.
		  self parseJsonFrom: client response ]
]

{ #category : 'requests' }
HfHttpClient >> downloadUrl: aUrl to: aFileReference [
	"Stream a URL to disk. Follows redirects; creates parent directories."

	^ self withRetryOn: aUrl do: [ :client |
		  | target |
		  target := aFileReference asFileReference.
		  target parent ensureCreateDirectory.
		  client url: aUrl.
		  client signalProgress: false.
		  client downloadTo: target.
		  self checkStatus: client response url: aUrl.
		  target ]
]

{ #category : 'requests' }
HfHttpClient >> get: aUrl [
	"Perform a GET returning the JSON-decoded body."

	^ self withRetryOn: aUrl do: [ :client |
		  client url: aUrl.
		  client get.
		  self checkStatus: client response url: aUrl.
		  self parseJsonFrom: client response ]
]

{ #category : 'requests' }
HfHttpClient >> head: aUrl [
	"Perform a HEAD returning the response object so callers can read headers."

	^ self withRetryOn: aUrl do: [ :client |
		  client url: aUrl.
		  client head.
		  self checkStatus: client response url: aUrl.
		  client response ]
]

{ #category : 'private' }
HfHttpClient >> newZnClient [

	| client |
	client := ZnClient new.
	client
		beOneShot;
		enforceHttpSuccess: false;
		signalProgress: false;
		timeout: configuration timeout;
		userAgent: configuration userAgent;
		setAcceptEncodingGzip;
		accept: 'application/json'.
	configuration hasToken ifTrue: [
		client headerAt: 'Authorization' put: 'Bearer ' , configuration token ].
	^ client
]

{ #category : 'private' }
HfHttpClient >> parseJsonFrom: aZnResponse [

	| contents |
	contents := aZnResponse contents.
	(contents isNil or: [ contents isEmpty ]) ifTrue: [ ^ nil ].
	^ [ NeoJSONReader fromString: contents asString ]
		  on: Error
		  do: [ :e | contents asString ]
]

{ #category : 'requests' }
HfHttpClient >> postForm: aUrl with: aDictionary [
	"Submit a form-encoded POST. Used e.g. for the repo create endpoint."

	^ self withRetryOn: aUrl do: [ :client |
		  client url: aUrl.
		  aDictionary keysAndValuesDo: [ :k :v | client formAt: k put: v ].
		  client post.
		  self checkStatus: client response url: aUrl.
		  self parseJsonFrom: client response ]
]

{ #category : 'requests' }
HfHttpClient >> postJson: aUrl with: aDataStructure [
	"POST a JSON body (encoded with NeoJSONWriter) and return the JSON-decoded response."

	^ self withRetryOn: aUrl do: [ :client |
		  | body |
		  body := NeoJSONWriter toString: aDataStructure.
		  client url: aUrl.
		  client entity:
			  (ZnEntity json: body).
		  client post.
		  self checkStatus: client response url: aUrl.
		  self parseJsonFrom: client response ]
]

{ #category : 'requests' }
HfHttpClient >> putBytes: aUrl bytes: aByteArray headers: aDictionary [
	"Raw PUT for LFS uploads. Returns the response object."

	^ self withRetryOn: aUrl do: [ :client |
		  client url: aUrl.
		  aDictionary keysAndValuesDo: [ :k :v |
			  client headerAt: k put: v ].
		  client entity: (ZnEntity bytes: aByteArray).
		  client put.
		  self checkStatus: client response url: aUrl.
		  client response ]
]

{ #category : 'private' }
HfHttpClient >> shouldRetry: anException [

	(anException isKindOf: HfRateLimitError) ifTrue: [ ^ true ].
	((anException isKindOf: HfHttpError) and: [
		 anException statusCode >= 500 ]) ifTrue: [ ^ true ].
	(anException isKindOf: ConnectionTimedOut) ifTrue: [ ^ true ].
	(anException isKindOf: NetworkError) ifTrue: [ ^ true ].
	^ false
]

{ #category : 'private' }
HfHttpClient >> withRetryOn: aUrl do: aBlock [
	"Execute aBlock (which receives a fresh ZnClient) with retry-with-backoff on
	 transient failures."

	| attempts lastError delay |
	attempts := 0.
	delay := 1.
	[
	attempts := attempts + 1.
	[
	| client result |
	client := self newZnClient.
	result := aBlock value: client.
	^ result ]
		on: Error
		do: [ :e |
			lastError := e.
			(attempts < configuration maxRetries and: [
				 self shouldRetry: e ])
				ifTrue: [
					(Delay forSeconds: delay) wait.
					delay := (delay * 2) min: 30 ]
				ifFalse: [ e pass ] ] ] repeat
]
