"
Represents a single file listed as a 'sibling' of a repository. The Hub API
returns a `siblings` array on each repo info payload describing every file
tracked by git, with optional LFS metadata when applicable.
"
Class {
	#name : 'HfRepoSibling',
	#superclass : 'Object',
	#instVars : [
		'rfilename',
		'size',
		'lfs',
		'blobId'
	],
	#category : 'LMM-HuggingFace-Hub-Model',
	#package : 'LMM-HuggingFace-Hub',
	#tag : 'Model'
}

{ #category : 'instance creation' }
HfRepoSibling class >> fromJson: aDictionary [

	^ self new
		  rfilename: (aDictionary at: 'rfilename' ifAbsent: [ nil ]);
		  size: (aDictionary at: 'size' ifAbsent: [ nil ]);
		  blobId: (aDictionary at: 'blobId' ifAbsent: [ nil ]);
		  lfs: (aDictionary at: 'lfs' ifAbsent: [ nil ]);
		  yourself
]

{ #category : 'accessing' }
HfRepoSibling >> blobId [

	^ blobId
]

{ #category : 'accessing' }
HfRepoSibling >> blobId: anObject [

	blobId := anObject
]

{ #category : 'testing' }
HfRepoSibling >> isLfs [

	^ lfs isNotNil
]

{ #category : 'accessing' }
HfRepoSibling >> lfs [

	^ lfs
]

{ #category : 'accessing' }
HfRepoSibling >> lfs: anObject [

	lfs := anObject
]

{ #category : 'printing' }
HfRepoSibling >> printOn: aStream [

	super printOn: aStream.
	aStream << '('.
	rfilename ifNotNil: [ aStream << rfilename ].
	aStream << ')'
]

{ #category : 'accessing' }
HfRepoSibling >> rfilename [

	^ rfilename
]

{ #category : 'accessing' }
HfRepoSibling >> rfilename: anObject [

	rfilename := anObject
]

{ #category : 'accessing' }
HfRepoSibling >> size [

	^ size
]

{ #category : 'accessing' }
HfRepoSibling >> size: anObject [

	size := anObject
]
