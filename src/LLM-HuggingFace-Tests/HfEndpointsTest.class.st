"
Pure-function tests for URL construction. Runs without network access.
"
Class {
	#name : 'HfEndpointsTest',
	#superclass : 'TestCase',
	#category : 'HuggingFace-Tests-Core',
	#package : 'HuggingFace-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
HfEndpointsTest >> testBaseUrlStripsTrailingSlashes [

	| e |
	e := HfEndpoints on: 'https://my.hf.co///'.
	self assert: e baseUrl equals: 'https://my.hf.co'
]

{ #category : 'tests' }
HfEndpointsTest >> testDatasetListUrl [

	| e |
	e := HfEndpoints new.
	self
		assert: (e listRepos: #dataset)
		equals: 'https://huggingface.co/api/datasets'
]

{ #category : 'tests' }
HfEndpointsTest >> testDownloadUrlForDataset [

	| e |
	e := HfEndpoints new.
	self
		assert:
		(e
			 downloadUrl: 'squad/plain_text'
			 type: #dataset
			 revision: 'main'
			 path: 'train.json')
		equals: 'https://huggingface.co/datasets/squad/plain_text/resolve/main/train.json'
]

{ #category : 'tests' }
HfEndpointsTest >> testDownloadUrlForModel [

	| e |
	e := HfEndpoints new.
	self
		assert: (e
				 downloadUrl: 'bert-base-uncased'
				 type: #model
				 revision: 'main'
				 path: 'config.json')
		equals: 'https://huggingface.co/bert-base-uncased/resolve/main/config.json'
]

{ #category : 'tests' }
HfEndpointsTest >> testDownloadUrlPercentEncodesPathSegments [

	| e |
	e := HfEndpoints new.
	self
		assert: (e
				 downloadUrl: 'org/repo'
				 type: #model
				 revision: 'main'
				 path: 'sub dir/weights.bin')
		equals: 'https://huggingface.co/org/repo/resolve/main/sub%20dir/weights.bin'
]

{ #category : 'tests' }
HfEndpointsTest >> testRejectsUnknownRepoType [

	self
		should: [ HfEndpoints new listRepos: #bogus ]
		raise: HfValidationError
]

{ #category : 'tests' }
HfEndpointsTest >> testRepoInfoAtRevision [

	| e |
	e := HfEndpoints new.
	self
		assert: (e
				 repoInfo: 'bert-base-uncased'
				 type: #model
				 revision: 'abc123')
		equals: 'https://huggingface.co/api/models/bert-base-uncased/revision/abc123'
]

{ #category : 'tests' }
HfEndpointsTest >> testRepoInfoWithoutRevision [

	| e |
	e := HfEndpoints new.
	self
		assert: (e
				 repoInfo: 'bert-base-uncased'
				 type: #model
				 revision: nil)
		equals: 'https://huggingface.co/api/models/bert-base-uncased'
]

{ #category : 'tests' }
HfEndpointsTest >> testWhoamiUrl [

	| e |
	e := HfEndpoints new.
	self
		assert: e whoami
		equals: 'https://huggingface.co/api/whoami-v2'
]
