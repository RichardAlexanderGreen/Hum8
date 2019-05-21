"
A Hum Message handles data in-transit between Hum Actors.
The Message class will serialize/deserialize messages to/from JSON or XML.
For clarity, all Hum Messages represent Hum Action Statements sent between Hum Actors. 
The components of a message include sender, receiver, when sent, statement, and noun-values. 

Separation of function -- Messenger / Network / Message:
  
- The Messenger keeps track of which actors are online and where.
- The Messenger also provides logging for playback and debug.

- The Network wraps whatever technology is used for actor-to-actor communication.
- If an actor is running in test mode, the convention is to start the URI with 'mock:'
- The Network will skip the socket business when the URI starts with 'mock:'.

- We will probably use Jabber technology for the network. 
  It provides a number of built-in operators including 'presence' that should come in handy.

- The Network will send Hum Messages formatted as JSON objects
  so that actors may use a number of different technologies.
  (JSON is supported in almost all frameworks.)
- In mock (test) mode, the Network will skip translation to/from JSON.
- Hum Message will serialize/deserialize to/from JSON or XML. (as needed)

		

"
Class {
	#name : #HumMessage,
	#superclass : #HumDataFrame,
	#instVars : [
		'sender',
		'receiver',
		'whenSent',
		'statement',
		'nounValues'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'as yet unclassified' }
HumMessage class >> to: recipientURI from: senderURI statement: aStatement nounValues: aDictionary [
	"Create an instance with this data."
	| instance |
	instance := self basicNew.
	instance
		sender: senderURI;
		receiver: recipientURI;
		statement: aStatement;
		nounValues: aDictionary;
		whenSent: (TimeStamp now). "TODO: Do we need a HumTimeStamp? (Enable simulated time and clear sequence.)"
	^instance.
	
]

{ #category : #accessing }
HumMessage >> nounValues: associations [ 
	"TODO: Consider: a HumStatement also has nounValues. Which noun values are which?"
	nounValues := associations
]

{ #category : #accessing }
HumMessage >> receiver: aString [ 
	receiver := aString 
]

{ #category : #accessing }
HumMessage >> sender: aString [ 
	sender := aString.
]

{ #category : #accessing }
HumMessage >> statement: aHumStatement [ 
	statement := aHumStatement 
]

{ #category : #accessing }
HumMessage >> whenSent: aTimeStamp [ 
	" "
	self assert: (( aTimeStamp isKindOf: TimeStamp ) or: [ aTimeStamp isKindOf: Duration ]).
	whenSent := aTimeStamp 
]
