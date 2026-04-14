"
Local tests for response parsing. The network-facing methods are exercised
integration-style when an `HF_TOKEN` is available, and skipped otherwise.
"
Class {
	#name : 'HfInferenceClientTest',
	#superclass : 'TestCase',
	#category : 'HuggingFace-Tests-Inference',
	#package : 'HuggingFace-Tests',
	#tag : 'Inference'
}

{ #category : 'tests' }
HfInferenceClientTest >> testFirstChoiceTextOfEmptyChoices [

	| client |
	client := HfInferenceClient on: HfClient default.
	self
		assert: (client firstChoiceTextOf: (Dictionary new
				  at: 'choices' put: Array new;
				  yourself))
		equals: nil
]

{ #category : 'tests' }
HfInferenceClientTest >> testFirstChoiceTextOfNilResponse [

	| client |
	client := HfInferenceClient on: HfClient default.
	self assert: (client firstChoiceTextOf: nil) equals: nil
]

{ #category : 'tests' }
HfInferenceClientTest >> testFirstChoiceTextOfStandardResponse [

	| client response |
	client := HfInferenceClient on: HfClient default.
	response := NeoJSONReader fromString:
		            '{"choices":[{"index":0,"message":{"role":"assistant","content":"Hello!"}}]}'.
	self
		assert: (client firstChoiceTextOf: response)
		equals: 'Hello!'
]

{ #category : 'tests' }
HfInferenceClientTest >> testUrlForModelUsesEndpointsByDefault [

	| client |
	client := HfInferenceClient on: HfClient default.
	self
		assert: (client urlForModel: 'gpt2')
		equals: 'https://api-inference.huggingface.co/models/gpt2'
]

{ #category : 'tests' }
HfInferenceClientTest >> testUrlForModelUsesEndpointUrlWhenSet [

	| client |
	client := HfInferenceClient on: HfClient default.
	client endpointUrl: 'https://my-endpoint.hf.cloud'.
	self
		assert: (client urlForModel: 'ignored')
		equals: 'https://my-endpoint.hf.cloud'
]
