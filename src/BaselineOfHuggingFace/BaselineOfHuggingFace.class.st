"
Metacello baseline for the HuggingFace client for Pharo.

Loads the full stack in a single command:

	Metacello new
		baseline: 'HuggingFace';
		repository: 'github://pharo-llm/pharo-huggingface:main/src';
		load.

Groups:
	- default : Core + Hub + Inference
	- Core    : HTTP, auth, config, errors
	- Hub     : repositories, files, commits, cache
	- Inference : chat / text generation / embeddings / images
	- Tests   : SUnit tests for the full stack
"
Class {
	#name : 'BaselineOfHuggingFace',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHuggingFace',
	#package : 'BaselineOfHuggingFace'
}

{ #category : 'baselines' }
BaselineOfHuggingFace >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			package: 'LLM-HuggingFace-Core';
			package: 'LMM-HuggingFace-Hub'
				with: [ spec requires: #( 'LLM-HuggingFace-Core' ) ];
			package: 'LLM-HuggingFace-Inference'
				with: [ spec requires: #( 'LLM-HuggingFace-Core' ) ];
			package: 'LLM-HuggingFace-Tests'
				with: [
					spec requires:
						#( 'LLM-HuggingFace-Hub' 'LLM-HuggingFace-Inference' ) ].
]
