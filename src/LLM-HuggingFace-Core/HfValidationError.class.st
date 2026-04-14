"
Raised on client-side validation failures: malformed repo ids, bad paths,
missing required arguments, unsupported repo types, etc. These never hit
the network.
"
Class {
	#name : 'HfValidationError',
	#superclass : 'HfError',
	#category : 'HuggingFace-Core-Errors',
	#package : 'HuggingFace-Core',
	#tag : 'Errors'
}
