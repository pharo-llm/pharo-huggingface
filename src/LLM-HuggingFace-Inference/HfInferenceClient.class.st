"
High-level client for Hugging Face inference endpoints. Built on top of an
`HfClient` so token / retry / timeouts are reused.

Covers the four tasks most people actually reach for:

	- chat completion  : `chatCompletion:messages:` (OpenAI-compatible router)
	- text generation  : `textGeneration:prompt:` / `...options:`
	- embeddings       : `featureExtraction:input:`
	- image generation : `textToImage:prompt:` (returns a `ByteArray` of image bytes)

All calls can target either a model id on the public inference API or a
dedicated inference endpoint URL via `endpointUrl:`.
"
Class {
	#name : 'HfInferenceClient',
	#superclass : 'Object',
	#instVars : [
		'client',
		'endpointUrl'
	],
	#category : 'LLM-HuggingFace-Inference-Client',
	#package : 'LLM-HuggingFace-Inference',
	#tag : 'Client'
}

{ #category : 'instance creation' }
HfInferenceClient class >> on: anHfClient [

	^ self new client: anHfClient
]

{ #category : 'inference - chat' }
HfInferenceClient >> chatCompletion: aModelId messages: aCollectionOfMessages [

	^ self
		  chatCompletion: aModelId
		  messages: aCollectionOfMessages
		  options: Dictionary new
]

{ #category : 'inference - chat' }
HfInferenceClient >> chatCompletion: aModelId messages: aCollectionOfMessages options: aDictionary [
	"Send an OpenAI-compatible chat completion through the HF router.
	 Returns the decoded JSON response; the assistant text can be pulled
	 via `#assistantMessageOf:` for convenience."

	| url payload |
	url := client endpoints inferenceRouterUrl , '/chat/completions'.
	payload := Dictionary new.
	payload at: 'model' put: aModelId.
	payload at: 'messages' put: (aCollectionOfMessages collect: [ :m |
			 (m isKindOf: HfChatMessage)
				 ifTrue: [ m asDictionary ]
				 ifFalse: [ m ] ]) asArray.
	aDictionary keysAndValuesDo: [ :k :v | payload at: k put: v ].
	^ client httpClient postJson: url with: payload
]

{ #category : 'accessing' }
HfInferenceClient >> client [

	^ client
]

{ #category : 'accessing' }
HfInferenceClient >> client: anHfClient [

	client := anHfClient
]

{ #category : 'accessing' }
HfInferenceClient >> endpointUrl [

	^ endpointUrl
]

{ #category : 'accessing' }
HfInferenceClient >> endpointUrl: aString [
	"Target a dedicated inference endpoint instead of the public one."

	endpointUrl := aString
]

{ #category : 'inference - embeddings' }
HfInferenceClient >> featureExtraction: aModelId input: aStringOrCollection [
	"Compute embeddings; `aStringOrCollection` may be a single string or a
	 collection of strings for batched embedding."

	| url payload |
	url := self urlForModel: aModelId.
	payload := Dictionary new.
	payload at: 'inputs' put: aStringOrCollection.
	^ client httpClient postJson: url with: payload
]

{ #category : 'response parsing' }
HfInferenceClient >> firstChoiceTextOf: aChatResponse [
	"Pull out the assistant message from a chat completion response."

	| choices message |
	aChatResponse ifNil: [ ^ nil ].
	choices := aChatResponse at: 'choices' ifAbsent: [ ^ nil ].
	choices isEmpty ifTrue: [ ^ nil ].
	message := choices first at: 'message' ifAbsent: [ ^ nil ].
	^ message at: 'content' ifAbsent: [ nil ]
]

{ #category : 'inference - tasks' }
HfInferenceClient >> task: aModelId payload: aDictionary [
	"Generic hook for any HF pipeline task (summarization, translation,
	 fill-mask, ...). Lets callers extend support without subclassing."

	^ client httpClient
		  postJson: (self urlForModel: aModelId)
		  with: aDictionary
]

{ #category : 'inference - text' }
HfInferenceClient >> textGeneration: aModelId prompt: aString [

	^ self
		  textGeneration: aModelId
		  prompt: aString
		  options: Dictionary new
]

{ #category : 'inference - text' }
HfInferenceClient >> textGeneration: aModelId prompt: aString options: aDictionary [

	| payload |
	payload := Dictionary new.
	payload at: 'inputs' put: aString.
	aDictionary isEmpty ifFalse: [ payload at: 'parameters' put: aDictionary ].
	^ client httpClient
		  postJson: (self urlForModel: aModelId)
		  with: payload
]

{ #category : 'inference - image' }
HfInferenceClient >> textToImage: aModelId prompt: aString [
	"Generate an image and return the raw bytes (PNG/JPEG) from the response."

	| url znClient response |
	url := self urlForModel: aModelId.
	znClient := ZnClient new
		            beOneShot;
		            enforceHttpSuccess: false;
		            url: url;
		            timeout: client configuration timeout;
		            userAgent: client configuration userAgent;
		            headerAt: 'Accept' put: 'image/png';
		            entity: (ZnEntity json:
				             (NeoJSONWriter toString:
					              (Dictionary new at: 'inputs' put: aString; yourself))).
	client configuration hasToken ifTrue: [
		znClient
			headerAt: 'Authorization'
			put: 'Bearer ' , client configuration token ].
	znClient post.
	response := znClient response.
	(response code between: 200 and: 299) ifFalse: [
		HfHttpError
			status: response code
			url: url
			body: response contents asString ].
	^ response contents
]

{ #category : 'private' }
HfInferenceClient >> urlForModel: aModelId [

	^ endpointUrl ifNil: [ client endpoints inferenceModelUrl: aModelId ]
]
