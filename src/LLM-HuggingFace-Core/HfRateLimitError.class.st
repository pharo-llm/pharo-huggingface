"
Raised on HTTP 429 when the client is being throttled by the Hugging Face
infrastructure. The `HfHttpClient` retry logic honours this and applies
exponential backoff.
"
Class {
	#name : 'HfRateLimitError',
	#superclass : 'HfHttpError',
	#category : 'HuggingFace-Core-Errors',
	#package : 'HuggingFace-Core',
	#tag : 'Errors'
}
