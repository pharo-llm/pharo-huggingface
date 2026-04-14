"
Deletes a file (or a path prefix, when `isFolder` is true) from a repo.
"
Class {
	#name : 'HfCommitOperationDelete',
	#superclass : 'HfCommitOperation',
	#instVars : [
		'isFolder'
	],
	#category : 'HuggingFace-Hub-Commits',
	#package : 'HuggingFace-Hub',
	#tag : 'Commits'
}

{ #category : 'instance creation' }
HfCommitOperationDelete class >> folder: aString [

	^ self new
		  pathInRepo: aString;
		  isFolder: true;
		  yourself
]

{ #category : 'instance creation' }
HfCommitOperationDelete class >> path: aString [

	^ self new
		  pathInRepo: aString;
		  isFolder: false;
		  yourself
]

{ #category : 'converting' }
HfCommitOperationDelete >> asCommitOperationJson [

	^ Dictionary new
		  at: 'key'
		  put: (self isFolder
				   ifTrue: [ 'deletedFolder' ]
				   ifFalse: [ 'deletedFile' ]);
		  at: 'value' put: (Dictionary new
				   at: 'path' put: pathInRepo;
				   yourself);
		  yourself
]

{ #category : 'accessing' }
HfCommitOperationDelete >> isFolder [

	^ isFolder ifNil: [ false ]
]

{ #category : 'accessing' }
HfCommitOperationDelete >> isFolder: aBoolean [

	isFolder := aBoolean
]
