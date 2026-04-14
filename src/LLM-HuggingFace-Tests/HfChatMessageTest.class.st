"
Tests for the chat message value object and its JSON shape.
"
Class {
	#name : 'HfChatMessageTest',
	#superclass : 'TestCase',
	#category : 'HuggingFace-Tests-Inference',
	#package : 'HuggingFace-Tests',
	#tag : 'Inference'
}

{ #category : 'tests' }
HfChatMessageTest >> testAsDictionaryIncludesRoleAndContent [

	| d |
	d := (HfChatMessage user: 'hi') asDictionary.
	self assert: (d at: 'role') equals: 'user'.
	self assert: (d at: 'content') equals: 'hi'.
	self deny: (d includesKey: 'name')
]

{ #category : 'tests' }
HfChatMessageTest >> testNameIncludedWhenSet [

	| m d |
	m := (HfChatMessage user: 'hi') name: 'alice'; yourself.
	d := m asDictionary.
	self assert: (d at: 'name') equals: 'alice'
]

{ #category : 'tests' }
HfChatMessageTest >> testRoleConstructors [

	self assert: (HfChatMessage system: 'x') role equals: 'system'.
	self assert: (HfChatMessage user: 'x') role equals: 'user'.
	self assert: (HfChatMessage assistant: 'x') role equals: 'assistant'
]
