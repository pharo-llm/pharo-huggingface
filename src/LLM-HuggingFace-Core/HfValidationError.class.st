"
Raised on client-side validation failures: malformed repo ids, bad paths,
missing required arguments, unsupported repo types, etc. These never hit
the network.
"
Class {
	#name : 'HfValidationError',
	#superclass : 'HfError',
	#category : 'LLM-HuggingFace-Core-Errors',
	#package : 'LLM-HuggingFace-Core',
	#tag : 'Errors'
}
