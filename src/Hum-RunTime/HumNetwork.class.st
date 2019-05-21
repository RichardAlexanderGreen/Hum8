"
The Network wraps whatever technology is used for actor-to-actor communication.

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
- Hum Message will serialize/deserialize to/from JSON.

		

"
Class {
	#name : #HumNetwork,
	#superclass : #Object,
	#instVars : [
		'uriToNode'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'as yet unclassified' }
HumNetwork >> sendAction: anInstruction toURI: recipientURI fromURI: senderURI [ 
	"Send the (action) statement to the given actor."
	| actorInstance calc |
	self assert: (anInstruction isKindOf: HumInstructionLine).
	"Following only works when actor is local."
	"TODO: Fix so that it works when actor is remote."
	calc := HumCalculator new.
	calc cases;
		when: [recipientURI beginsWith: 'http:'] then: [self shouldBeImplemented];
		when: [recipientURI beginsWith: 'email:'] then: [self shouldBeImplemented];
	  otherwise: [	"Assume actor is local."
			actorInstance := ( self uriToNode ) at: recipientURI 
	                              ifAbsent: [ Error signal: 'Network has no actor for URI: ', recipientURI ].
			actorInstance runAction: anInstruction inRole: (anInstruction role) onJob: (anInstruction jobTicket).
		].
	
	
]

{ #category : #'URI to actor' }
HumNetwork >> uriToNode [
	"Return dictionary that maps a URI to an actual actor instance"
	"NOTE: This should only be used in test/local mode. 
	(Mode where actors are running in same VM as the messenger.)"
	^ uriToNode ifNil: [ uriToNode := Dictionary new. ].
]
