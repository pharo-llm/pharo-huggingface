"
Tiny value object: parses and validates a repository id in the canonical
`namespace/name` form. Use it to reject malformed inputs client-side rather
than sending them over the wire.
"
Class {
	#name : 'HfRepoId',
	#superclass : 'Object',
	#instVars : [
		'namespace',
		'name'
	],
	#category : 'LLM-HuggingFace-Hub-Model',
	#package : 'LLM-HuggingFace-Hub',
	#tag : 'Model'
}

{ #category : 'parsing' }
HfRepoId class >> fromString: aString [

	| parts |
	(aString isNil or: [ aString isEmpty ]) ifTrue: [
		HfValidationError signal: 'Empty repo id' ].
	parts := aString substrings: '/'.
	parts size = 1 ifTrue: [
		^ self new
			  namespace: nil;
			  name: parts first;
			  yourself ].
	parts size = 2 ifTrue: [
		^ self new
			  namespace: parts first;
			  name: parts second;
			  yourself ].
	HfValidationError signal:
		'Repo id must be of the form "namespace/name": ' , aString printString
]

{ #category : 'testing' }
HfRepoId >> hasNamespace [

	^ namespace isNotNil and: [ namespace isNotEmpty ]
]

{ #category : 'accessing' }
HfRepoId >> name [

	^ name
]

{ #category : 'accessing' }
HfRepoId >> name: aString [

	name := aString
]

{ #category : 'accessing' }
HfRepoId >> namespace [

	^ namespace
]

{ #category : 'accessing' }
HfRepoId >> namespace: aString [

	namespace := aString
]

{ #category : 'printing' }
HfRepoId >> printOn: aStream [

	super printOn: aStream.
	aStream << '('.
	aStream << self qualifiedId.
	aStream << ')'
]

{ #category : 'accessing' }
HfRepoId >> qualifiedId [

	^ self hasNamespace
		  ifTrue: [ namespace , '/' , name ]
		  ifFalse: [ name ]
]
