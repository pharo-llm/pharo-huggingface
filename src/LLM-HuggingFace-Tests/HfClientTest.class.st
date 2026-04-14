"
Tests for the top-level `HfClient` facade.
"
Class {
	#name : 'HfClientTest',
	#superclass : 'TestCase',
	#category : 'HuggingFace-Tests-Core',
	#package : 'HuggingFace-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
HfClientTest >> testConfigurationSwap [

	| client cfg |
	client := HfClient new.
	cfg := HfConfiguration new.
	cfg endpointBaseUrl: 'https://enterprise.example'.
	client configuration: cfg.
	self
		assert: client endpoints baseUrl
		equals: 'https://enterprise.example'
]

{ #category : 'tests' }
HfClientTest >> testHttpClientReadyAfterInit [

	| client |
	client := HfClient new.
	self assert: client httpClient isNotNil.
	self assert: client httpClient configuration equals: client configuration
]

{ #category : 'tests' }
HfClientTest >> testTokenSetterFlowsToConfiguration [

	| client |
	client := HfClient new.
	client token: 'hf_test_token'.
	self assert: client configuration token equals: 'hf_test_token'.
	self assert: client configuration hasToken
]

{ #category : 'tests' }
HfClientTest >> testWithTokenFactory [

	| client |
	client := HfClient withToken: 'hf_factory'.
	self assert: client configuration token equals: 'hf_factory'
]
