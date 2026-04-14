"
Value object for an OpenAI-compatible chat message. Constructed by one of
the role-specific factory methods so call sites read naturally:

	HfChatMessage system: 'You are a helpful assistant.'
	HfChatMessage user: 'Hello there!'
	HfChatMessage assistant: 'Hi, how can I help?'
"
Class {
	#name : 'HfChatMessage',
	#superclass : 'Object',
	#instVars : [
		'role',
		'content',
		'name'
	],
	#category : 'HuggingFace-Inference-Chat',
	#package : 'HuggingFace-Inference',
	#tag : 'Chat'
}

{ #category : 'instance creation' }
HfChatMessage class >> assistant: aString [

	^ self new role: 'assistant'; content: aString; yourself
]

{ #category : 'instance creation' }
HfChatMessage class >> role: aRoleString content: aContentString [

	^ self new
		  role: aRoleString;
		  content: aContentString;
		  yourself
]

{ #category : 'instance creation' }
HfChatMessage class >> system: aString [

	^ self new role: 'system'; content: aString; yourself
]

{ #category : 'instance creation' }
HfChatMessage class >> user: aString [

	^ self new role: 'user'; content: aString; yourself
]

{ #category : 'converting' }
HfChatMessage >> asDictionary [

	| d |
	d := Dictionary new.
	d at: 'role' put: role.
	d at: 'content' put: content.
	name ifNotNil: [ d at: 'name' put: name ].
	^ d
]

{ #category : 'accessing' }
HfChatMessage >> content [

	^ content
]

{ #category : 'accessing' }
HfChatMessage >> content: anObject [

	content := anObject
]

{ #category : 'accessing' }
HfChatMessage >> name [

	^ name
]

{ #category : 'accessing' }
HfChatMessage >> name: anObject [

	name := anObject
]

{ #category : 'accessing' }
HfChatMessage >> role [

	^ role
]

{ #category : 'accessing' }
HfChatMessage >> role: anObject [

	role := anObject
]
