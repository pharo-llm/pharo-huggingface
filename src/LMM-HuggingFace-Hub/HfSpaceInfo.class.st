"
Space-specific metadata: SDK, stage (runtime status), hardware.
"
Class {
	#name : 'HfSpaceInfo',
	#superclass : 'HfRepoInfo',
	#instVars : [
		'sdk',
		'stage',
		'hardware'
	],
	#category : 'HuggingFace-Hub-Model',
	#package : 'HuggingFace-Hub',
	#tag : 'Model'
}

{ #category : 'accessing' }
HfSpaceInfo class >> repoType [

	^ #space
]

{ #category : 'initialization' }
HfSpaceInfo >> fromJson: aDictionary [

	| runtime |
	super fromJson: aDictionary.
	sdk := aDictionary at: 'sdk' ifAbsent: [ nil ].
	runtime := aDictionary at: 'runtime' ifAbsent: [ nil ].
	runtime isDictionary ifTrue: [
		stage := runtime at: 'stage' ifAbsent: [ nil ].
		hardware := runtime at: 'hardware' ifAbsent: [ nil ] ]
]

{ #category : 'accessing' }
HfSpaceInfo >> hardware [

	^ hardware
]

{ #category : 'accessing' }
HfSpaceInfo >> sdk [

	^ sdk
]

{ #category : 'accessing' }
HfSpaceInfo >> stage [

	^ stage
]
