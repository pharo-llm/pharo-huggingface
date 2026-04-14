"
Immutable-ish configuration object used to build an `HfClient`. Holds
everything the client needs to talk to the Hub:

	- `token`     : User Access Token (string, nilable for anonymous access)
	- `endpoints` : `HfEndpoints` instance (pointable at a private deployment)
	- `cacheDirectory` : local cache root (defaults to ~/.cache/huggingface)
	- `userAgent` : UA string sent with every request
	- `timeout`   : per-request timeout in seconds
	- `maxRetries`: how many times a retryable failure is re-attempted
	- `etagTimeout` : HEAD-request timeout for cache freshness checks

`HfConfiguration default` returns a sensible client with the environment
variables `HF_TOKEN` / `HUGGINGFACE_TOKEN` honoured and the standard cache
path. Every setter returns `self`, so configuration reads fluently:

	HfConfiguration new
		token: 'hf_xxx';
		endpointBaseUrl: 'https://my-enterprise.hf.co';
		timeout: 60;
		yourself.
"
Class {
	#name : 'HfConfiguration',
	#superclass : 'Object',
	#instVars : [
		'token',
		'endpoints',
		'cacheDirectory',
		'userAgent',
		'timeout',
		'maxRetries',
		'etagTimeout'
	],
	#classVariables : [
		'DefaultUserAgent'
	],
	#category : 'LLM-HuggingFace-Core-Client',
	#package : 'LLM-HuggingFace-Core',
	#tag : 'Client'
}

{ #category : 'class initialization' }
HfConfiguration class >> initialize [

	DefaultUserAgent := 'pharo-huggingface/0.1 (+https://github.com/pharo-llm/pharo-huggingface)'
]

{ #category : 'instance creation' }
HfConfiguration class >> default [

	^ self new
]

{ #category : 'accessing' }
HfConfiguration >> cacheDirectory [

	^ cacheDirectory
]

{ #category : 'accessing' }
HfConfiguration >> cacheDirectory: aFileReferenceOrString [

	cacheDirectory := aFileReferenceOrString asFileReference
]

{ #category : 'accessing' }
HfConfiguration >> endpointBaseUrl: aString [

	endpoints := HfEndpoints on: aString
]

{ #category : 'accessing' }
HfConfiguration >> endpoints [

	^ endpoints
]

{ #category : 'accessing' }
HfConfiguration >> endpoints: anHfEndpoints [

	endpoints := anHfEndpoints
]

{ #category : 'accessing' }
HfConfiguration >> etagTimeout [

	^ etagTimeout
]

{ #category : 'accessing' }
HfConfiguration >> etagTimeout: secondsInteger [

	etagTimeout := secondsInteger
]

{ #category : 'testing' }
HfConfiguration >> hasToken [

	^ token isNotNil and: [ token isNotEmpty ]
]

{ #category : 'initialization' }
HfConfiguration >> initialize [

	super initialize.
	endpoints := HfEndpoints new.
	cacheDirectory := self resolveDefaultCacheDirectory.
	userAgent := DefaultUserAgent.
	timeout := 30.
	etagTimeout := 10.
	maxRetries := 5.
	token := self resolveDefaultToken
]

{ #category : 'accessing' }
HfConfiguration >> maxRetries [

	^ maxRetries
]

{ #category : 'accessing' }
HfConfiguration >> maxRetries: anInteger [

	maxRetries := anInteger
]

{ #category : 'private' }
HfConfiguration >> resolveDefaultCacheDirectory [
	"Matches the layout used by huggingface_hub in Python: ~/.cache/huggingface/hub"

	| home env |
	env := OSEnvironment current.
	(env at: 'HF_HOME' ifAbsent: [ nil ]) ifNotNil: [ :v |
		^ v asFileReference / 'hub' ].
	(env at: 'HUGGINGFACE_HUB_CACHE' ifAbsent: [ nil ]) ifNotNil: [ :v |
		^ v asFileReference ].
	home := env at: 'HOME' ifAbsent: [ FileLocator home pathString ].
	^ home asFileReference / '.cache' / 'huggingface' / 'hub'
]

{ #category : 'private' }
HfConfiguration >> resolveDefaultToken [
	"Look in the environment first, then on disk (HF CLI login file), then give up."

	| env tokenFile |
	env := OSEnvironment current.
	#( 'HF_TOKEN' 'HUGGINGFACE_TOKEN' 'HUGGING_FACE_HUB_TOKEN' ) do: [ :key |
		(env at: key ifAbsent: [ nil ]) ifNotNil: [ :v |
			v isNotEmpty ifTrue: [ ^ v ] ] ].
	tokenFile := (env at: 'HOME' ifAbsent: [ FileLocator home pathString ])
		             asFileReference / '.cache' / 'huggingface' / 'token'.
	tokenFile exists ifTrue: [ ^ tokenFile contents trimBoth ].
	^ nil
]

{ #category : 'accessing' }
HfConfiguration >> timeout [

	^ timeout
]

{ #category : 'accessing' }
HfConfiguration >> timeout: secondsInteger [

	timeout := secondsInteger
]

{ #category : 'accessing' }
HfConfiguration >> token [

	^ token
]

{ #category : 'accessing' }
HfConfiguration >> token: aString [

	token := aString
]

{ #category : 'accessing' }
HfConfiguration >> userAgent [

	^ userAgent
]

{ #category : 'accessing' }
HfConfiguration >> userAgent: aString [

	userAgent := aString
]
