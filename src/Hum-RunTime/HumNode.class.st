"
A Hum node may send and recieve Hum messages. 

"
Class {
	#name : #HumNode,
	#superclass : #Object,
	#instVars : [
		'myURI',
		'myID',
		'clock',
		'log',
		'htmlAgent',
		'configuration',
		'stepLog'
	],
	#category : #'Hum-RunTime'
}

{ #category : #accessing }
HumNode >> asString [
	^ self id ifNil: [ 'no ID'].
]

{ #category : #node }
HumNode >> checkIn [
	| |
	"Check-in with the messenger."
	( self messenger ) registerActor: self atURI: (self uri).
]

{ #category : #accessing }
HumNode >> clock [
	^ clock ifNil: [clock := DateAndTime "class singleton"].
]

{ #category : #accessing }
HumNode >> clock: anObjectThatImplementsNow [
	clock := anObjectThatImplementsNow.
	"WARNING: #clock also appears in HumConfiguration."
]

{ #category : #node }
HumNode >> configuration [
	^ configuration ifNil: [Error signal: 'Node has not been configured.'].
]

{ #category : #node }
HumNode >> configuration: aHumConfiguration [ 
	self assert: ( aHumConfiguration isKindOf: HumConfiguration ).
	configuration := aHumConfiguration.
]

{ #category : #html }
HumNode >> htmlAgent [
	"Return http/html agent implementation.
	If none has been set, use self as mock/dummy"
	^ htmlAgent ifNil: [ htmlAgent := self ].
]

{ #category : #accessing }
HumNode >> id [
	^myID
]

{ #category : #accessing }
HumNode >> id: aString [ 
	self assert: (aString isKindOf: String ).
	myID := aString.
]

{ #category : #logging }
HumNode >> log [
	^ log ifNil: [ log := OrderedCollection new ].
]

{ #category : #node }
HumNode >> messenger [
	^self configuration messenger.
]

{ #category : #accessing }
HumNode >> printOn: aStream [
	"Append to the argument, aStream, a sequence of characters that  
	identifies the receiver."

	| title idString|
	title := self class name.
	idString := self asString.
	aStream
		nextPutAll: (title first isVowel ifTrue: ['an '] ifFalse: ['a ']);
		nextPutAll: title;
		nextPutAll: '(';
		nextPutAll: idString;
		nextPutAll: ')'.
		
]

{ #category : #html }
HumNode >> sendHTML: htmlString [ 
	"This is a dummy/mock for testing."
	self log add: 'sendHTML: {',htmlString,'}'.
	self stepLog add: ('Actor: {', (myID ifNil: ['unknown']),'} is sending html {',htmlString withBlanksCondensed truncate,'}' ).
]

{ #category : #html }
HumNode >> sendHTML: htmlString to: aURL [
	"This is a dummy/mock for testing. TODO: Make this real."
	self log add: 'sendHTML: {',htmlString,'}'.
	self stepLog add: ('Actor: {', (myID ifNil: ['unknown']),'} is sending html {',(htmlString withBlanksCondensed truncateWithElipsisTo: 400),'}' ).
]

{ #category : #logging }
HumNode >> stepLog [
	^ stepLog ifNil: [ stepLog := OrderedCollection new.].
]

{ #category : #logging }
HumNode >> stepLogDisplay [
	"Display the step log"
	Transcript cr; show: 'Step log from actor: ', (self id asString);cr.
	(self stepLog) do: [:s | Transcript show: '. ', s; cr.]
]

{ #category : #accessing }
HumNode >> uri [
	^myURI.
]

{ #category : #accessing }
HumNode >> uri: aURI [
	self assert: ( aURI isKindOf: String ).
	myURI := aURI.
	

]
