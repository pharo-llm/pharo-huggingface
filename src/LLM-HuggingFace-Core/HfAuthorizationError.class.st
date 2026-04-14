"
Raised on HTTP 403 when the user is authenticated but lacks permission
for the requested action (e.g. writing to a repo they don't own).
"
Class {
	#name : 'HfAuthorizationError',
	#superclass : 'HfHttpError',
	#category : 'LLM-HuggingFace-Core-Errors',
	#package : 'LLM-HuggingFace-Core',
	#tag : 'Errors'
}
