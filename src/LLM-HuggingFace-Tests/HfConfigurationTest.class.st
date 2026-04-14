"
Smoke tests for configuration defaults and fluent setters.
"
Class {
	#name : 'HfConfigurationTest',
	#superclass : 'TestCase',
	#category : 'LLM-HuggingFace-Tests-Core',
	#package : 'LLM-HuggingFace-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
HfConfigurationTest >> testDefaultsAreNonNil [

	| c |
	c := HfConfiguration new.
	self assert: c endpoints isNotNil.
	self assert: c userAgent isNotNil.
	self assert: c timeout > 0.
	self assert: c maxRetries >= 0
]

{ #category : 'tests' }
HfConfigurationTest >> testEndpointBaseUrlSetter [

	| c |
	c := HfConfiguration new.
	c endpointBaseUrl: 'https://example.com'.
	self assert: c endpoints baseUrl equals: 'https://example.com'
]

{ #category : 'tests' }
HfConfigurationTest >> testHasTokenFalseWhenNil [

	| c |
	c := HfConfiguration new.
	c token: nil.
	self deny: c hasToken
]

{ #category : 'tests' }
HfConfigurationTest >> testHasTokenTrueWhenSet [

	| c |
	c := HfConfiguration new.
	c token: 'hf_abc'.
	self assert: c hasToken
]
