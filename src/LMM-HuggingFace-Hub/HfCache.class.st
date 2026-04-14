"
Local cache manager that mirrors the on-disk layout used by
`huggingface_hub` in Python:

	<cacheDir>/
	  models--<namespace>--<name>/
	    blobs/<sha>
	    refs/<revision>          (plain-text file containing the resolved commit sha)
	    snapshots/<sha>/<filename>  (symlink -> ../../blobs/<sha>)

	  datasets--<namespace>--<name>/ ...
	  spaces--<namespace>--<name>/   ...

Having the same layout means the cache is interoperable: a file downloaded
by the Python client can be served from disk by the Pharo client and vice
versa.

Windows (or sandboxed) filesystems that do not support symlinks get a
regular file copy as a fallback.
"
Class {
	#name : 'HfCache',
	#superclass : 'Object',
	#instVars : [
		'root'
	],
	#category : 'HuggingFace-Hub-Cache',
	#package : 'HuggingFace-Hub',
	#tag : 'Cache'
}

{ #category : 'instance creation' }
HfCache class >> on: aFileReference [

	^ self new root: aFileReference
]

{ #category : 'private' }
HfCache >> blobFileFor: aSha in: aRepoFolder [

	^ aRepoFolder / 'blobs' / aSha
]

{ #category : 'queries' }
HfCache >> cachedFileFor: aRepoId type: aRepoType revision: aRevision path: aPath [
	"Return a FileReference to the cached file if present, otherwise nil."

	| folder sha snap |
	folder := self repoFolderFor: aRepoId type: aRepoType.
	folder exists ifFalse: [ ^ nil ].
	sha := self resolvedShaFor: aRevision in: folder.
	sha ifNil: [ ^ nil ].
	snap := folder / 'snapshots' / sha / aPath.
	^ snap exists ifTrue: [ snap ] ifFalse: [ nil ]
]

{ #category : 'private' }
HfCache >> ensureRoot [

	root ensureCreateDirectory.
	^ root
]

{ #category : 'private' }
HfCache >> linkOrCopy: aSourceBlob to: aSnapshotFile [

	aSnapshotFile parent ensureCreateDirectory.
	aSnapshotFile exists ifTrue: [ aSnapshotFile delete ].
	[ aSnapshotFile fileSystem
		createSymlink: aSnapshotFile pathString
		withTargetPath: aSourceBlob pathString ]
		on: Error
		do: [ :e | aSourceBlob copyTo: aSnapshotFile ]
]

{ #category : 'writing' }
HfCache >> recordRepoId: aRepoId type: aRepoType revision: aRevision sha: aSha path: aPath blob: aBlobFileReference [
	"Place `aBlobFileReference` into the cache and register its snapshot
	 alias / revision pointer. Returns the final snapshot path."

	| folder blob snap refFile |
	folder := self repoFolderFor: aRepoId type: aRepoType.
	folder ensureCreateDirectory.
	(folder / 'blobs') ensureCreateDirectory.
	(folder / 'refs') ensureCreateDirectory.
	(folder / 'snapshots') ensureCreateDirectory.
	blob := self blobFileFor: aSha in: folder.
	blob exists ifFalse: [ aBlobFileReference copyTo: blob ].
	snap := folder / 'snapshots' / aSha / aPath.
	self linkOrCopy: blob to: snap.
	refFile := folder / 'refs' / (aRevision ifNil: [ 'main' ]).
	refFile writeStreamDo: [ :s | s nextPutAll: aSha ].
	^ snap
]

{ #category : 'private' }
HfCache >> repoFolderFor: aRepoId type: aRepoType [
	"Folder name mirrors the Python hub: <type>s--<namespace>--<name>."

	| safeId |
	safeId := aRepoId copyReplaceAll: '/' with: '--'.
	^ self ensureRoot
	  / (aRepoType asString , 's--' , safeId)
]

{ #category : 'private' }
HfCache >> resolvedShaFor: aRevision in: aRepoFolder [
	"Branch/tag names are stored in refs/, a 40-char hex sha is used verbatim."

	| rev refFile |
	rev := aRevision ifNil: [ 'main' ].
	(rev size = 40 and: [ rev allSatisfy: [ :c | '0123456789abcdef' includes: c asLowercase ] ])
		ifTrue: [ ^ rev ].
	refFile := aRepoFolder / 'refs' / rev.
	^ refFile exists ifTrue: [ refFile contents trimBoth ] ifFalse: [ nil ]
]

{ #category : 'accessing' }
HfCache >> root [

	^ root
]

{ #category : 'accessing' }
HfCache >> root: aFileReference [

	root := aFileReference asFileReference
]

{ #category : 'queries' }
HfCache >> scan [
	"Return a flat description of every cached repository. Useful for diagnostics
	 and for implementing a CLI `hf cache scan` analogue."

	| result |
	self ensureRoot.
	result := OrderedCollection new.
	root children do: [ :child |
		child isDirectory ifTrue: [
			| parts |
			parts := child basename substrings: '--'.
			parts size >= 3 ifTrue: [
				result add: (Dictionary new
						 at: 'type' put: (parts first copyWithout: $s);
						 at: 'repoId' put: (String streamContents: [ :s |
								  (parts allButFirst: 1) doWithIndex: [ :p :i |
									  i > 1 ifTrue: [ s nextPutAll: '/' ].
									  s nextPutAll: p ] ]);
						 at: 'path' put: child;
						 yourself) ] ] ].
	^ result
]
