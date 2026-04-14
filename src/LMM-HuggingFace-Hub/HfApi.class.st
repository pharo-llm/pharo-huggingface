"
High-level facade for the Hugging Face Hub. Mirrors the Python
`huggingface_hub.HfApi` surface area where possible and keeps the method
names identical (camelCased) so existing hub knowledge transfers.

Constructed off an `HfClient` (which owns the auth / HTTP / cache) and does
not own any state of its own.

Typical usage:

	| api infos |
	api := HfClient default hub.
	infos := api listModels: (Dictionary new at: 'search' put: 'llama'; yourself).
	file := api downloadFileFrom: 'bert-base-uncased' path: 'config.json'.
	api uploadFile: 'model.safetensors' toRepo: 'me/my-model'.
	api createRepo: 'me/new-model' type: #model private: true.

All methods raise subclasses of `HfError` on failure.
"
Class {
	#name : 'HfApi',
	#superclass : 'Object',
	#instVars : [
		'client'
	],
	#category : 'HuggingFace-Hub-Api',
	#package : 'HuggingFace-Hub',
	#tag : 'Api'
}

{ #category : 'instance creation' }
HfApi class >> on: anHfClient [

	^ self new client: anHfClient
]

{ #category : 'accessing' }
HfApi >> cache [

	^ HfCache on: self configuration cacheDirectory
]

{ #category : 'accessing' }
HfApi >> client [

	^ client
]

{ #category : 'accessing' }
HfApi >> client: anHfClient [

	client := anHfClient
]

{ #category : 'accessing' }
HfApi >> configuration [

	^ client configuration
]

{ #category : 'repos - commits' }
HfApi >> createCommitOn: aRepoId type: aRepoType revision: aRevision operations: aCollection message: aMessage [
	"Apply a list of commit operations atomically. Wraps the NDJSON
	 commit endpoint. Use this when you need multi-file atomicity;
	 otherwise #uploadFile: is simpler."

	| url header files payload deletes |
	url := self endpoints
		       commitOn: aRepoId
		       type: aRepoType
		       revision: (aRevision ifNil: [ 'main' ]).
	header := Dictionary new
		          at: 'key' put: 'header';
		          at: 'value' put: (Dictionary new
				           at: 'summary' put: aMessage;
				           yourself);
		          yourself.
	files := (aCollection select: [ :op | op isKindOf: HfCommitOperationAdd ])
		         collect: [ :op | op asCommitOperationJson ].
	deletes := (aCollection select: [ :op | op isKindOf: HfCommitOperationDelete ])
		           collect: [ :op | op asCommitOperationJson ].
	payload := { header } , deletes asArray , files asArray.
	^ self http postJson: url with: payload
]

{ #category : 'repos' }
HfApi >> createRepo: aRepoId type: aRepoType private: aBoolean [
	"Create a repository. `aRepoType` is one of #model #dataset #space."

	| payload |
	payload := Dictionary new
		           at: 'name' put: aRepoId;
		           at: 'type' put: aRepoType asString;
		           at: 'private' put: aBoolean;
		           yourself.
	^ self http postJson: self endpoints repoCreate with: payload
]

{ #category : 'repos' }
HfApi >> deleteRepo: aRepoId type: aRepoType [

	| payload |
	payload := Dictionary new
		           at: 'name' put: aRepoId;
		           at: 'type' put: aRepoType asString;
		           yourself.
	^ self http postJson: self endpoints repoDelete with: payload
]

{ #category : 'files' }
HfApi >> downloadFileFrom: aRepoId path: aFilePath [

	^ self
		  downloadFileFrom: aRepoId
		  type: #model
		  revision: 'main'
		  path: aFilePath
]

{ #category : 'files' }
HfApi >> downloadFileFrom: aRepoId type: aRepoType revision: aRevision path: aFilePath [
	"Download a single file, honouring the local cache. When the file is
	 already present and its ETag matches the server, the cached file is
	 returned directly. Otherwise the file is fetched, indexed into the
	 cache, and a `FileReference` to the cache snapshot is returned."

	| cached url head etag tempFile sha |
	cached := self cache
		          cachedFileFor: aRepoId
		          type: aRepoType
		          revision: aRevision
		          path: aFilePath.
	cached ifNotNil: [ ^ cached ].
	url := self endpoints
		       downloadUrl: aRepoId
		       type: aRepoType
		       revision: aRevision
		       path: aFilePath.
	head := [ self http head: url ] on: HfError do: [ :e | nil ].
	etag := head ifNotNil: [ head headers at: 'X-Repo-Commit' ifAbsent: [ nil ] ].
	sha := etag ifNil: [ aRevision ifNil: [ 'main' ] ifNotNil: [ aRevision ] ].
	tempFile := FileLocator temp asFileReference
	            / ('hf-' , UUID new asString).
	self http downloadUrl: url to: tempFile.
	^ [
	  self cache
		  recordRepoId: aRepoId
		  type: aRepoType
		  revision: aRevision
		  sha: sha
		  path: aFilePath
		  blob: tempFile ] ensure: [ tempFile exists ifTrue: [ tempFile delete ] ]
]

{ #category : 'private' }
HfApi >> endpoints [

	^ client endpoints
]

{ #category : 'private' }
HfApi >> http [

	^ client httpClient
]

{ #category : 'repos' }
HfApi >> infoFor: aRepoId type: aRepoType [

	^ self infoFor: aRepoId type: aRepoType revision: nil
]

{ #category : 'repos' }
HfApi >> infoFor: aRepoId type: aRepoType revision: aRevision [
	"Return a typed `HfRepoInfo` (subclass chosen from the repo type)."

	| url raw |
	url := self endpoints
		       repoInfo: aRepoId
		       type: aRepoType
		       revision: aRevision.
	raw := self http get: url.
	^ (self infoClassFor: aRepoType) fromJson: raw
]

{ #category : 'private' }
HfApi >> infoClassFor: aRepoType [

	aRepoType = #model ifTrue: [ ^ HfModelInfo ].
	aRepoType = #dataset ifTrue: [ ^ HfDatasetInfo ].
	aRepoType = #space ifTrue: [ ^ HfSpaceInfo ].
	HfValidationError signal: 'Unknown repo type: ' , aRepoType printString
]

{ #category : 'repos' }
HfApi >> listDatasets [

	^ self listRepos: #dataset query: Dictionary new
]

{ #category : 'repos' }
HfApi >> listDatasets: aQueryDictionary [

	^ self listRepos: #dataset query: aQueryDictionary
]

{ #category : 'files' }
HfApi >> listFilesIn: aRepoId type: aRepoType revision: aRevision path: aPath [

	^ self http
		  get: (self endpoints
				   repoTree: aRepoId
				   type: aRepoType
				   revision: (aRevision ifNil: [ 'main' ])
				   path: aPath)
]

{ #category : 'repos' }
HfApi >> listModels [

	^ self listRepos: #model query: Dictionary new
]

{ #category : 'repos' }
HfApi >> listModels: aQueryDictionary [
	"aQueryDictionary may hold keys like 'search', 'author', 'filter', 'sort',
	 'direction', 'limit', 'full', 'config' per the /api/models spec."

	^ self listRepos: #model query: aQueryDictionary
]

{ #category : 'private' }
HfApi >> listRepos: aRepoType query: aQueryDictionary [

	| url raw klass |
	url := (self endpoints listRepos: aRepoType) , (self queryString: aQueryDictionary).
	raw := self http get: url.
	klass := self infoClassFor: aRepoType.
	^ raw collect: [ :each | klass fromJson: each ]
]

{ #category : 'repos' }
HfApi >> listSpaces [

	^ self listRepos: #space query: Dictionary new
]

{ #category : 'repos' }
HfApi >> listSpaces: aQueryDictionary [

	^ self listRepos: #space query: aQueryDictionary
]

{ #category : 'repos' }
HfApi >> modelInfo: aRepoId [

	^ self infoFor: aRepoId type: #model
]

{ #category : 'private' }
HfApi >> queryString: aDictionary [

	(aDictionary isNil or: [ aDictionary isEmpty ]) ifTrue: [ ^ '' ].
	^ String streamContents: [ :s |
		  | first |
		  first := true.
		  aDictionary keysAndValuesDo: [ :k :v |
			  v ifNotNil: [
				  s nextPutAll: (first
						   ifTrue: [ first := false. '?' ]
						   ifFalse: [ '&' ]).
				  s
					  nextPutAll: (ZnPercentEncoder new encode: k asString);
					  nextPut: $=;
					  nextPutAll: (ZnPercentEncoder new encode: v asString) ] ] ]
]

{ #category : 'files' }
HfApi >> snapshotDownload: aRepoId type: aRepoType revision: aRevision [
	"Download every file in a repo into the cache. Returns the folder path
	 containing all siblings of the requested revision."

	| info folder |
	info := self infoFor: aRepoId type: aRepoType revision: aRevision.
	info siblings do: [ :sibling |
		self
			downloadFileFrom: aRepoId
			type: aRepoType
			revision: aRevision
			path: sibling rfilename ].
	folder := (self cache repoFolderFor: aRepoId type: aRepoType)
	          / 'snapshots'
	          /
	          (self cache
		           resolvedShaFor: aRevision
		           in: (self cache repoFolderFor: aRepoId type: aRepoType)).
	^ folder
]

{ #category : 'files' }
HfApi >> uploadFile: aFileReferenceOrString toRepo: aRepoId [

	^ self
		  uploadFile: aFileReferenceOrString
		  toRepo: aRepoId
		  type: #model
		  path: aFileReferenceOrString asFileReference basename
		  revision: 'main'
		  message: 'Upload ' , aFileReferenceOrString asFileReference basename
]

{ #category : 'files' }
HfApi >> uploadFile: aFileReferenceOrString toRepo: aRepoId type: aRepoType path: aPathInRepo revision: aRevision message: aMessage [
	"Upload a single file via a one-shot commit."

	| op |
	op := HfCommitOperationAdd
		      path: aPathInRepo
		      fromFile: aFileReferenceOrString.
	^ self
		  createCommitOn: aRepoId
		  type: aRepoType
		  revision: aRevision
		  operations: { op }
		  message: aMessage
]

{ #category : 'files' }
HfApi >> uploadFolder: aFolderReference toRepo: aRepoId type: aRepoType revision: aRevision message: aMessage [
	"Upload every file in a folder (recursively) in a single commit."

	| folder ops |
	folder := aFolderReference asFileReference.
	folder isDirectory ifFalse: [
		HfValidationError signal:
			'uploadFolder: expected a directory: ' , folder printString ].
	ops := OrderedCollection new.
	folder allChildren do: [ :each |
		each isFile ifTrue: [
			| relative |
			relative := each path relativeTo: folder path.
			ops add: (HfCommitOperationAdd
					 path: relative pathString
					 fromFile: each) ] ].
	^ self
		  createCommitOn: aRepoId
		  type: aRepoType
		  revision: aRevision
		  operations: ops
		  message: aMessage
]
