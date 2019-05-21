"
This class provides a wrapper around the HTTP implementation.
The idea is that we could switch between Zinc or Seaside or our own implementation
with minimal changes to run-time code.
The ideal result would enable such changes to be merely a matter of run-time configuration.

"
Class {
	#name : #HumHttpRequest,
	#superclass : #Object,
	#instVars : [
		'myFields'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'as yet unclassified' }
HumHttpRequest >> atField: aKey put: aValue [
	"The Http Request form included this input name:value pair."
	(self fields) at: aKey put: aValue.
]

{ #category : #accessing }
HumHttpRequest >> fields [
	|  |
	^myFields ifNil: [myFields := Dictionary new.].
]
