"
Dataset-specific metadata.
"
Class {
	#name : 'HfDatasetInfo',
	#superclass : 'HfRepoInfo',
	#instVars : [
		'citation',
		'description'
	],
	#category : 'LLM-HuggingFace-Hub-Model',
	#package : 'LLM-HuggingFace-Hub',
	#tag : 'Model'
}

{ #category : 'accessing' }
HfDatasetInfo class >> repoType [

	^ #dataset
]

{ #category : 'accessing' }
HfDatasetInfo >> citation [

	^ citation
]

{ #category : 'accessing' }
HfDatasetInfo >> description [

	^ description
]

{ #category : 'initialization' }
HfDatasetInfo >> fromJson: aDictionary [

	super fromJson: aDictionary.
	citation := aDictionary at: 'citation' ifAbsent: [ nil ].
	description := aDictionary at: 'description' ifAbsent: [ nil ]
]
