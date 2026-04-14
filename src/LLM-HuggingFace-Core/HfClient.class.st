"
Top-level entry point for the Hugging Face client. One `HfClient` instance
owns a configuration and the low-level HTTP plumbing, and provides access
to the high-level APIs:

	| client |
	client := HfClient default.
	client hub listModels.
	client inference chatCompletion: 'meta-llama/Llama-3-8B-Instruct' messages: { ... }.

Most users will never talk to `HfHttpClient` directly; they work through
`HfApi` (hub) and `HfInferenceClient` (inference) which both layer on top
of this client.

The `hub` and `inference` accessors return lazily-built facades that share
the underlying HTTP client so a single token / endpoint / cache are reused
across the whole stack.
"
Class {
	#name : 'HfClient',
	#superclass : 'Object',
	#instVars : [
		'configuration',
		'httpClient',
		'hub',
		'inference'
	],
	#classVariables : [
		'Default'
	],
	#category : 'LLM-HuggingFace-Core-Client',
	#package : 'LLM-HuggingFace-Core',
	#tag : 'Client'
}

{ #category : 'accessing' }
HfClient class >> default [

	^ Default ifNil: [ Default := self new ]
]

{ #category : 'accessing' }
HfClient class >> resetDefault [

	Default := nil
]

{ #category : 'instance creation' }
HfClient class >> withToken: aString [

	^ self new
		  token: aString;
		  yourself
]

{ #category : 'accessing' }
HfClient >> configuration [

	^ configuration
]

{ #category : 'accessing' }
HfClient >> configuration: anHfConfiguration [

	configuration := anHfConfiguration.
	httpClient := HfHttpClient on: configuration.
	hub := nil.
	inference := nil
]

{ #category : 'accessing' }
HfClient >> endpoints [

	^ configuration endpoints
]

{ #category : 'accessing' }
HfClient >> httpClient [

	^ httpClient
]

{ #category : 'accessing - facades' }
HfClient >> hub [
	"Lazily-built high-level hub API. The class is resolved by name to avoid a
	 hard cross-package dependency (Core must load without Hub)."

	^ hub ifNil: [
		  hub := (Smalltalk globals classNamed: #HfApi)
			         ifNil: [
				         HfError signal:
						         'HuggingFace-Hub is not loaded. Load the Hub group first.' ]
			         ifNotNil: [ :cls | cls on: self ] ]
]

{ #category : 'accessing - facades' }
HfClient >> inference [
	"Lazily-built high-level inference API; see #hub for the loading strategy."

	^ inference ifNil: [
		  inference := (Smalltalk globals classNamed: #HfInferenceClient)
			               ifNil: [
				               HfError signal:
						               'HuggingFace-Inference is not loaded. Load the Inference group first.' ]
			               ifNotNil: [ :cls | cls on: self ] ]
]

{ #category : 'initialization' }
HfClient >> initialize [

	super initialize.
	self configuration: HfConfiguration default
]

{ #category : 'authentication' }
HfClient >> token: aString [

	configuration token: aString
]

{ #category : 'authentication' }
HfClient >> whoami [
	"Return the JSON description of the authenticated user.
	 Raises HfAuthenticationError when no valid token is configured."

	^ httpClient get: configuration endpoints whoami
]
