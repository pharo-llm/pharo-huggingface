"
Exercises JSON mapping onto the `HfRepoInfo` hierarchy with representative
fixtures from the public Hub API.
"
Class {
	#name : 'HfRepoInfoTest',
	#superclass : 'TestCase',
	#category : 'HuggingFace-Tests-Hub',
	#package : 'HuggingFace-Tests',
	#tag : 'Hub'
}

{ #category : 'fixtures' }
HfRepoInfoTest >> modelFixture [

	^ NeoJSONReader fromString:
		  '{"id":"bert-base-uncased","author":"google","sha":"abc123",
	      "pipeline_tag":"fill-mask","library_name":"transformers",
	      "private":false,"gated":false,"downloads":1000,"likes":42,
	      "tags":["pytorch","bert"],
	      "siblings":[{"rfilename":"config.json","size":500},
	                  {"rfilename":"pytorch_model.bin","lfs":{"size":440000000}}]}'
]

{ #category : 'tests' }
HfRepoInfoTest >> testDatasetInfoParsesDescription [

	| info |
	info := HfDatasetInfo fromJson: (NeoJSONReader fromString:
			         '{"id":"squad","description":"Stanford QA","tags":["nlp"]}').
	self assert: info id equals: 'squad'.
	self assert: info description equals: 'Stanford QA'.
	self assert: info repoType equals: #dataset
]

{ #category : 'tests' }
HfRepoInfoTest >> testLfsSiblingDetected [

	| info lfsFile |
	info := HfModelInfo fromJson: self modelFixture.
	lfsFile := info siblings detect: [ :s | s rfilename endsWith: '.bin' ].
	self assert: lfsFile isLfs.
	self deny: (info siblings first isLfs)
]

{ #category : 'tests' }
HfRepoInfoTest >> testModelInfoParsesCoreFields [

	| info |
	info := HfModelInfo fromJson: self modelFixture.
	self assert: info id equals: 'bert-base-uncased'.
	self assert: info author equals: 'google'.
	self assert: info sha equals: 'abc123'.
	self assert: info pipelineTag equals: 'fill-mask'.
	self assert: info libraryName equals: 'transformers'.
	self assert: info downloads equals: 1000.
	self assert: info repoType equals: #model.
	self deny: info isPrivate.
	self assert: info siblings size equals: 2
]

{ #category : 'tests' }
HfRepoInfoTest >> testSpaceInfoParsesRuntime [

	| info |
	info := HfSpaceInfo fromJson: (NeoJSONReader fromString:
			         '{"id":"u/s","sdk":"gradio","runtime":{"stage":"RUNNING","hardware":"cpu-basic"}}').
	self assert: info sdk equals: 'gradio'.
	self assert: info stage equals: 'RUNNING'.
	self assert: info hardware equals: 'cpu-basic'.
	self assert: info repoType equals: #space
]
