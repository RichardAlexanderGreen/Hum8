"
HumNumberParser is wrapper on NumberParser.
It exposes some instance variables for the convenience
of HumDecimal fromString: method.

"
Class {
	#name : #HumNumberParser,
	#superclass : #NumberParser,
	#category : #'Hum-RunTime'
}

{ #category : #'as yet unclassified' }
HumNumberParser >> nDigits [
	^nDigits.
]
