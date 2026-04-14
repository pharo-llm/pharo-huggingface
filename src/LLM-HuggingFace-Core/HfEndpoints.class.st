"
Centralises every URL the Hugging Face client can construct. Pure functions —
no I/O, no hidden state — so the routing layer is easy to test and easy to
point at a private / enterprise endpoint simply by changing the base URL.

Design notes:
	- `repoType` is one of #model #dataset #space. The REST API pluralises these
	  in the URL path (`models`, `datasets`, `spaces`).
	- `revision` defaults to `main` when not supplied.
	- Repo ids may contain a single forward slash (namespace/name). We do not
	  URL-encode the slash because the API requires it literal; other unsafe
	  characters are percent-encoded per RFC 3986.
"
Class {
	#name : 'HfEndpoints',
	#superclass : 'Object',
	#instVars : [
		'baseUrl'
	],
	#classVariables : [
		'DefaultBaseUrl',
		'InferenceBaseUrl'
	],
	#category : 'HuggingFace-Core-Http',
	#package : 'HuggingFace-Core',
	#tag : 'Http'
}

{ #category : 'class initialization' }
HfEndpoints class >> initialize [

	DefaultBaseUrl := 'https://huggingface.co'.
	InferenceBaseUrl := 'https://api-inference.huggingface.co'
]

{ #category : 'instance creation' }
HfEndpoints class >> new [

	^ self basicNew initialize
]

{ #category : 'instance creation' }
HfEndpoints class >> on: aBaseUrl [

	^ self new baseUrl: aBaseUrl
]

{ #category : 'accessing' }
HfEndpoints >> baseUrl [

	^ baseUrl
]

{ #category : 'accessing' }
HfEndpoints >> baseUrl: aString [

	baseUrl := aString.
	[ baseUrl endsWith: '/' ] whileTrue: [
		baseUrl := baseUrl copyFrom: 1 to: baseUrl size - 1 ]
]

{ #category : 'urls - commits' }
HfEndpoints >> commitOn: aRepoId type: aRepoType revision: aRevision [

	^ '{1}/api/{2}s/{3}/commit/{4}' format: {
			  self baseUrl.
			  (self pathForRepoType: aRepoType).
			  aRepoId.
			  (self encodeRevision: aRevision) }
]

{ #category : 'urls - files' }
HfEndpoints >> downloadUrl: aRepoId type: aRepoType revision: aRevision path: aPath [

	| typeSegment |
	typeSegment := aRepoType = #model
		               ifTrue: [ '' ]
		               ifFalse: [ (self pathForRepoType: aRepoType) , 's/' ].
	^ '{1}/{2}{3}/resolve/{4}/{5}' format: {
			  self baseUrl.
			  typeSegment.
			  aRepoId.
			  (self encodeRevision: aRevision).
			  (self encodePath: aPath) }
]

{ #category : 'private' }
HfEndpoints >> encodePath: aPath [
	"Percent-encode a path, preserving forward slashes."

	^ (aPath substrings: '/')
		  inject: ''
		  into: [ :acc :seg |
			  acc isEmpty
				  ifTrue: [ ZnPercentEncoder new encode: seg ]
				  ifFalse: [ acc , '/' , (ZnPercentEncoder new encode: seg) ] ]
]

{ #category : 'private' }
HfEndpoints >> encodeRevision: aRevision [

	^ ZnPercentEncoder new encode:
		  (aRevision ifNil: [ 'main' ] ifNotNil: [ aRevision ])
]

{ #category : 'initialization' }
HfEndpoints >> initialize [

	super initialize.
	baseUrl := DefaultBaseUrl
]

{ #category : 'urls - inference' }
HfEndpoints >> inferenceModelUrl: aModelId [

	^ InferenceBaseUrl , '/models/' , aModelId
]

{ #category : 'urls - root' }
HfEndpoints >> inferenceRouterUrl [

	^ 'https://router.huggingface.co/v1'
]

{ #category : 'urls - repos' }
HfEndpoints >> listRepos: aRepoType [

	^ '{1}/api/{2}s' format: {
			  self baseUrl.
			  (self pathForRepoType: aRepoType) }
]

{ #category : 'private' }
HfEndpoints >> pathForRepoType: aRepoType [

	aRepoType = #model ifTrue: [ ^ 'model' ].
	aRepoType = #dataset ifTrue: [ ^ 'dataset' ].
	aRepoType = #space ifTrue: [ ^ 'space' ].
	HfValidationError signal: 'Unknown repo type: ' , aRepoType printString
]

{ #category : 'urls - files' }
HfEndpoints >> preuploadOn: aRepoId type: aRepoType revision: aRevision [

	^ '{1}/api/{2}s/{3}/preupload/{4}' format: {
			  self baseUrl.
			  (self pathForRepoType: aRepoType).
			  aRepoId.
			  (self encodeRevision: aRevision) }
]

{ #category : 'urls - repos' }
HfEndpoints >> repoCreate [

	^ self baseUrl , '/api/repos/create'
]

{ #category : 'urls - repos' }
HfEndpoints >> repoDelete [

	^ self baseUrl , '/api/repos/delete'
]

{ #category : 'urls - repos' }
HfEndpoints >> repoInfo: aRepoId type: aRepoType revision: aRevision [

	aRevision
		ifNil: [
			^ '{1}/api/{2}s/{3}' format: {
					  self baseUrl.
					  (self pathForRepoType: aRepoType).
					  aRepoId } ]
		ifNotNil: [
			^ '{1}/api/{2}s/{3}/revision/{4}' format: {
					  self baseUrl.
					  (self pathForRepoType: aRepoType).
					  aRepoId.
					  (self encodeRevision: aRevision) } ]
]

{ #category : 'urls - repos' }
HfEndpoints >> repoTree: aRepoId type: aRepoType revision: aRevision path: aPath [

	^ '{1}/api/{2}s/{3}/tree/{4}/{5}' format: {
			  self baseUrl.
			  (self pathForRepoType: aRepoType).
			  aRepoId.
			  (self encodeRevision: aRevision).
			  (self encodePath: (aPath ifNil: [ '' ])) }
]

{ #category : 'urls - auth' }
HfEndpoints >> whoami [

	^ self baseUrl , '/api/whoami-v2'
]
