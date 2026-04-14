"
Exercises the on-disk cache layout using a temporary directory. No network.
"
Class {
	#name : 'HfCacheTest',
	#superclass : 'TestCase',
	#instVars : [
		'cache',
		'tempRoot'
	],
	#category : 'HuggingFace-Tests-Hub',
	#package : 'HuggingFace-Tests',
	#tag : 'Hub'
}

{ #category : 'running' }
HfCacheTest >> setUp [

	super setUp.
	tempRoot := FileLocator temp asFileReference
	            / ('hf-cache-test-' , UUID new asString).
	tempRoot ensureCreateDirectory.
	cache := HfCache on: tempRoot
]

{ #category : 'running' }
HfCacheTest >> tearDown [

	tempRoot exists ifTrue: [ tempRoot deleteAll ].
	super tearDown
]

{ #category : 'tests' }
HfCacheTest >> testCachedFileReturnedAfterRecording [

	| blob path |
	blob := tempRoot / 'blob.bin'.
	blob writeStreamDo: [ :s | s nextPutAll: 'payload' ].
	cache
		recordRepoId: 'me/my-model'
		type: #model
		revision: 'main'
		sha: (String new: 40 withAll: $a)
		path: 'config.json'
		blob: blob.
	path := cache
		        cachedFileFor: 'me/my-model'
		        type: #model
		        revision: 'main'
		        path: 'config.json'.
	self assert: path isNotNil.
	self assert: path exists
]

{ #category : 'tests' }
HfCacheTest >> testMissingFileReturnsNil [

	self assert: (cache
			 cachedFileFor: 'does/not-exist'
			 type: #model
			 revision: 'main'
			 path: 'nope') isNil
]

{ #category : 'tests' }
HfCacheTest >> testRepoFolderLayout [

	| folder |
	folder := cache repoFolderFor: 'me/thing' type: #model.
	self
		assert: folder basename
		equals: 'models--me--thing'
]

{ #category : 'tests' }
HfCacheTest >> testShaRevisionReturnedVerbatim [

	| sha |
	sha := String new: 40 withAll: $a.
	self
		assert: (cache
				 resolvedShaFor: sha
				 in: (cache repoFolderFor: 'x/y' type: #model))
		equals: sha
]
