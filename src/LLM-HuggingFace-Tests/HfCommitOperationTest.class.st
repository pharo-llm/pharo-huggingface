"
Round-trips commit operations through their JSON representation so we catch
payload regressions that would only otherwise surface against a live API.
"
Class {
	#name : 'HfCommitOperationTest',
	#superclass : 'TestCase',
	#category : 'LLM-HuggingFace-Tests-Hub',
	#package : 'LLM-HuggingFace-Tests',
	#tag : 'Hub'
}

{ #category : 'tests' }
HfCommitOperationTest >> testAddFromBytesProducesBase64Payload [

	| op json |
	op := HfCommitOperationAdd
		      path: 'README.md'
		      fromBytes: 'hello' asByteArray.
	json := op asCommitOperationJson.
	self assert: (json at: 'key') equals: 'file'.
	self assert: ((json at: 'value') at: 'path') equals: 'README.md'.
	self assert: ((json at: 'value') at: 'encoding') equals: 'base64'.
	self
		assert: ((json at: 'value') at: 'content')
		equals: (Base64MimeConverter mimeEncode: 'hello' readStream) contents
]

{ #category : 'tests' }
HfCommitOperationTest >> testDeleteFilePayload [

	| op json |
	op := HfCommitOperationDelete path: 'old.bin'.
	json := op asCommitOperationJson.
	self assert: (json at: 'key') equals: 'deletedFile'.
	self assert: ((json at: 'value') at: 'path') equals: 'old.bin'
]

{ #category : 'tests' }
HfCommitOperationTest >> testDeleteFolderPayload [

	| op json |
	op := HfCommitOperationDelete folder: 'checkpoints/'.
	json := op asCommitOperationJson.
	self assert: (json at: 'key') equals: 'deletedFolder'.
	self assert: ((json at: 'value') at: 'path') equals: 'checkpoints/'
]
