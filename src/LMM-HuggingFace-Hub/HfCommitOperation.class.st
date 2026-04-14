"
Abstract base class for git-style operations that can be grouped into a
single commit sent to `/api/{type}s/{repo}/commit/{revision}`. Two concrete
subclasses exist:

	- `HfCommitOperationAdd`    : adds or replaces a file
	- `HfCommitOperationDelete` : deletes a file or a path prefix

Each operation knows how to serialise itself into the commit's NDJSON
payload via `#asCommitOperationJson`.
"
Class {
	#name : 'HfCommitOperation',
	#superclass : 'Object',
	#instVars : [
		'pathInRepo'
	],
	#category : 'HuggingFace-Hub-Commits',
	#package : 'HuggingFace-Hub',
	#tag : 'Commits'
}

{ #category : 'converting' }
HfCommitOperation >> asCommitOperationJson [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
HfCommitOperation >> pathInRepo [

	^ pathInRepo
]

{ #category : 'accessing' }
HfCommitOperation >> pathInRepo: aString [

	pathInRepo := aString
]
