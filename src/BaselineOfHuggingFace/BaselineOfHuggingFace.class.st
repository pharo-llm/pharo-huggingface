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
			package: 'HuggingFace-Core';
			package: 'HuggingFace-Hub'
				with: [ spec requires: #( 'HuggingFace-Core' ) ];
			package: 'HuggingFace-Inference'
				with: [ spec requires: #( 'HuggingFace-Core' ) ];
			package: 'HuggingFace-Tests'
				with: [
					spec requires:
						#( 'HuggingFace-Hub' 'HuggingFace-Inference' ) ].

		spec
			group: 'Core' with: #( 'HuggingFace-Core' );
			group: 'Hub' with: #( 'HuggingFace-Hub' );
			group: 'Inference' with: #( 'HuggingFace-Inference' );
			group: 'Tests' with: #( 'HuggingFace-Tests' );
			group: 'default' with: #( 'Core' 'Hub' 'Inference' );
			group: 'all' with: #( 'default' 'Tests' ) ]
]
