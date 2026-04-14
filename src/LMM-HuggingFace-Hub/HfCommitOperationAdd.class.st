"
Adds or replaces a file in a repository. The content can be either:

	- a `FileReference` / `String` path on disk, read lazily
	- a literal `ByteArray` supplied in-memory

For regular files the content is base64-encoded inline in the commit
payload. For large (LFS) files the `HfApi` will first negotiate an upload
with the `/preupload` endpoint and stream the bytes directly to the LFS
storage, then include an LFS pointer in the commit.
"
Class {
	#name : 'HfCommitOperationAdd',
	#superclass : 'HfCommitOperation',
	#instVars : [
		'pathOrFile',
		'cachedBytes'
	],
	#category : 'HuggingFace-Hub-Commits',
	#package : 'HuggingFace-Hub',
	#tag : 'Commits'
}

{ #category : 'instance creation' }
HfCommitOperationAdd class >> path: aStringInRepo fromBytes: aByteArray [

	^ self new
		  pathInRepo: aStringInRepo;
		  pathOrFile: nil;
		  cachedBytes: aByteArray;
		  yourself
]

{ #category : 'instance creation' }
HfCommitOperationAdd class >> path: aStringInRepo fromFile: aFileReferenceOrString [

	^ self new
		  pathInRepo: aStringInRepo;
		  pathOrFile: aFileReferenceOrString asFileReference;
		  yourself
]

{ #category : 'converting' }
HfCommitOperationAdd >> asCommitOperationJson [
	"Inline encoding suitable for regular (non-LFS) files. Callers that need
	 LFS handling should use `HfApi >> uploadFile:` / `#createCommitWith:`
	 which first inspects the payload and swaps in a pointer as needed."

	^ Dictionary new
		  at: 'key' put: 'file';
		  at: 'value'
		  put: (Dictionary new
				   at: 'path' put: pathInRepo;
				   at: 'encoding' put: 'base64';
				   at: 'content' put: (Base64MimeConverter mimeEncode: self bytes readStream) contents;
				   yourself);
		  yourself
]

{ #category : 'accessing' }
HfCommitOperationAdd >> bytes [

	^ cachedBytes ifNil: [ cachedBytes := pathOrFile binaryReadStreamDo: [ :s | s upToEnd ] ]
]

{ #category : 'accessing' }
HfCommitOperationAdd >> cachedBytes: aByteArray [

	cachedBytes := aByteArray
]

{ #category : 'testing' }
HfCommitOperationAdd >> isFromFile [

	^ pathOrFile isNotNil
]

{ #category : 'accessing' }
HfCommitOperationAdd >> pathOrFile [

	^ pathOrFile
]

{ #category : 'accessing' }
HfCommitOperationAdd >> pathOrFile: aFileReference [

	pathOrFile := aFileReference.
	cachedBytes := nil
]

{ #category : 'accessing' }
HfCommitOperationAdd >> size [

	cachedBytes ifNotNil: [ ^ cachedBytes size ].
	pathOrFile ifNotNil: [ ^ pathOrFile size ].
	^ 0
]
