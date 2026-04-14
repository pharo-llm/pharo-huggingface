"
Model-specific metadata: pipeline tag, library name, and the model index
appear on model repos but not on datasets or spaces.
"
Class {
	#name : 'HfModelInfo',
	#superclass : 'HfRepoInfo',
	#instVars : [
		'pipelineTag',
		'libraryName',
		'modelIndex'
	],
	#category : 'HuggingFace-Hub-Model',
	#package : 'HuggingFace-Hub',
	#tag : 'Model'
}

{ #category : 'accessing' }
HfModelInfo class >> repoType [

	^ #model
]

{ #category : 'initialization' }
HfModelInfo >> fromJson: aDictionary [

	super fromJson: aDictionary.
	pipelineTag := aDictionary at: 'pipeline_tag' ifAbsent: [ nil ].
	libraryName := aDictionary at: 'library_name' ifAbsent: [ nil ].
	modelIndex := aDictionary at: 'model-index' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
HfModelInfo >> libraryName [

	^ libraryName
]

{ #category : 'accessing' }
HfModelInfo >> modelIndex [

	^ modelIndex
]

{ #category : 'accessing' }
HfModelInfo >> pipelineTag [

	^ pipelineTag
]
