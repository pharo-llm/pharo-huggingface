"
Base class describing a Hugging Face repository (model / dataset / space).
Concrete subclasses specialise the repo type and may add type-specific
fields (`pipelineTag` on models, `cardData` on datasets, etc.).

Construct one via `fromJson:` with the payload returned by the `/api/...`
endpoints.
"
Class {
	#name : 'HfRepoInfo',
	#superclass : 'Object',
	#instVars : [
		'id',
		'author',
		'sha',
		'lastModified',
		'private',
		'gated',
		'disabled',
		'downloads',
		'likes',
		'tags',
		'siblings',
		'cardData',
		'raw'
	],
	#category : 'HuggingFace-Hub-Model',
	#package : 'HuggingFace-Hub',
	#tag : 'Model'
}

{ #category : 'instance creation' }
HfRepoInfo class >> fromJson: aDictionary [

	^ self new fromJson: aDictionary
]

{ #category : 'testing' }
HfRepoInfo class >> repoType [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
HfRepoInfo >> author [

	^ author
]

{ #category : 'accessing' }
HfRepoInfo >> cardData [

	^ cardData
]

{ #category : 'accessing' }
HfRepoInfo >> disabled [

	^ disabled ifNil: [ false ]
]

{ #category : 'accessing' }
HfRepoInfo >> downloads [

	^ downloads ifNil: [ 0 ]
]

{ #category : 'initialization' }
HfRepoInfo >> fromJson: aDictionary [

	raw := aDictionary.
	id := aDictionary at: 'id' ifAbsent: [ nil ].
	author := aDictionary at: 'author' ifAbsent: [ nil ].
	sha := aDictionary at: 'sha' ifAbsent: [ nil ].
	lastModified := aDictionary at: 'lastModified' ifAbsent: [ nil ].
	private := aDictionary at: 'private' ifAbsent: [ false ].
	gated := aDictionary at: 'gated' ifAbsent: [ false ].
	disabled := aDictionary at: 'disabled' ifAbsent: [ false ].
	downloads := aDictionary at: 'downloads' ifAbsent: [ 0 ].
	likes := aDictionary at: 'likes' ifAbsent: [ 0 ].
	tags := aDictionary at: 'tags' ifAbsent: [ #(  ) ].
	cardData := aDictionary at: 'cardData' ifAbsent: [ nil ].
	siblings := (aDictionary at: 'siblings' ifAbsent: [ #(  ) ])
		            collect: [ :each | HfRepoSibling fromJson: each ]
]

{ #category : 'accessing' }
HfRepoInfo >> gated [
	"May be false, true, or a string tag such as 'manual' / 'auto'."

	^ gated ifNil: [ false ]
]

{ #category : 'accessing' }
HfRepoInfo >> id [

	^ id
]

{ #category : 'testing' }
HfRepoInfo >> isPrivate [

	^ private = true
]

{ #category : 'accessing' }
HfRepoInfo >> lastModified [

	^ lastModified
]

{ #category : 'accessing' }
HfRepoInfo >> likes [

	^ likes ifNil: [ 0 ]
]

{ #category : 'printing' }
HfRepoInfo >> printOn: aStream [

	super printOn: aStream.
	aStream << '('.
	id ifNotNil: [ aStream << id ].
	aStream << ')'
]

{ #category : 'accessing' }
HfRepoInfo >> raw [

	^ raw
]

{ #category : 'accessing' }
HfRepoInfo >> repoType [

	^ self class repoType
]

{ #category : 'accessing' }
HfRepoInfo >> sha [

	^ sha
]

{ #category : 'accessing' }
HfRepoInfo >> siblings [

	^ siblings ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
HfRepoInfo >> tags [

	^ tags ifNil: [ #(  ) ]
]
