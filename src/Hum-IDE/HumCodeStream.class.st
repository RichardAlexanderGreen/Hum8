"
HumCodeStream is a wrapper on a ReadWriteStream. 
It adds a limit to catch looping code generator logic.

Instance Variables:
	stream	<Stream>
	limit	<Integer>
"
Class {
	#name : #HumCodeStream,
	#superclass : #Object,
	#instVars : [
		'stream',
		'limit'
	],
	#category : #'Hum-IDE'
}

{ #category : #'as yet unclassified' }
HumCodeStream class >> limit: aSmallInteger [ 
	| instance |
	instance := self basicNew.
	instance limit: aSmallInteger.
	^instance.
]

{ #category : #'instance creation' }
HumCodeStream class >> on: aString [ 
	| instance |
	instance := self basicNew.
	instance << aString.
	^instance.
]

{ #category : #accessing }
HumCodeStream >> << aString [ 
	self assert: (aString isKindOf: String).
	(self stream) << aString.
	
]

{ #category : #accessing }
HumCodeStream >> asString [
	^self printString.
]

{ #category : #accessing }
HumCodeStream >> contents [
	^(self stream) contents.
]

{ #category : #accessing }
HumCodeStream >> limit [
	"At what point do we assume code generation has run amock?"
	^ limit ifNil: [ limit := 200 ].
]

{ #category : #accessing }
HumCodeStream >> limit: aSmallInteger [ 
	limit := aSmallInteger
]

{ #category : #accessing }
HumCodeStream >> printString [
	^(self stream) contents.
]

{ #category : #accessing }
HumCodeStream >> stream [
	stream ifNil: [ stream := ReadWriteStream on: ''].
	((stream contents) size > (self limit))
		ifTrue: [Error signal: 'Code stream limit exceeded.'].
	^stream.
]
