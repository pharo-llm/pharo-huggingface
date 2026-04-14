"
Root of the HuggingFace exception hierarchy.

All errors raised by the HuggingFace client inherit from `HfError`, which
itself is a plain `Error`. That lets callers either catch a specific subclass
(e.g. `HfRepositoryNotFoundError`) or trap the whole family with

    [ ... ] on: HfError do: [ :ex | ... ].

Subclasses carry useful context (HTTP status, response body, request URL)
via `messageText` plus dedicated accessors on the HTTP-flavoured subclass.
"
Class {
	#name : 'HfError',
	#superclass : 'Error',
	#category : 'LLM-HuggingFace-Core-Errors',
	#package : 'LLM-HuggingFace-Core',
	#tag : 'Errors'
}

{ #category : 'signalling' }
HfError class >> signal: aString [

	^ self new
		  messageText: aString;
		  signal
]
