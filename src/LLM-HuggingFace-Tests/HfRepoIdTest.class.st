"
Validation tests for the tiny `HfRepoId` value object.
"
Class {
	#name : 'HfRepoIdTest',
	#superclass : 'TestCase',
	#category : 'HuggingFace-Tests-Hub',
	#package : 'HuggingFace-Tests',
	#tag : 'Hub'
}

{ #category : 'tests' }
HfRepoIdTest >> testEmptyStringRejected [

	self
		should: [ HfRepoId fromString: '' ]
		raise: HfValidationError
]

{ #category : 'tests' }
HfRepoIdTest >> testNamespacedRepo [

	| id |
	id := HfRepoId fromString: 'meta-llama/Llama-3-8B'.
	self assert: id namespace equals: 'meta-llama'.
	self assert: id name equals: 'Llama-3-8B'.
	self assert: id qualifiedId equals: 'meta-llama/Llama-3-8B'.
	self assert: id hasNamespace
]

{ #category : 'tests' }
HfRepoIdTest >> testNilRejected [

	self
		should: [ HfRepoId fromString: nil ]
		raise: HfValidationError
]

{ #category : 'tests' }
HfRepoIdTest >> testSingleSegment [

	| id |
	id := HfRepoId fromString: 'bert-base-uncased'.
	self deny: id hasNamespace.
	self assert: id name equals: 'bert-base-uncased'.
	self assert: id qualifiedId equals: 'bert-base-uncased'
]

{ #category : 'tests' }
HfRepoIdTest >> testTooManySegmentsRejected [

	self
		should: [ HfRepoId fromString: 'a/b/c' ]
		raise: HfValidationError
]
