"
The communication-bus provides a message store-and-forward service with optional logging.
If an actor is temporarily not available, a message will be held for some (TBD) time.
The messages to a role may be replayed later.

instanceVariableNames: 
- uriActor 		dictionary maps URI to actor instance (assumes actor is running in local VM)
- actorURI 		dictionary maps ID to URI
- uriActorID 	dictionary maps URI to ID
- playbackLog  logs messages to enable playback and debug

Separation of function -- Messenger versus Network:
  
- The Messenger keeps track of which actors are online and where.
- The Messenger also provides logging for playback and debug.

- The Network wraps whatever technology is used for actor-to-actor communication.
- If an actor is running in test mode, the convention is to start the URI with 'mock:'
- The Network will skip the socket business when the URI starts with 'mock:'.

- We will probably use Jabber technology for the network. 
  It provides a number of built-in operators including 'presence' that should come in handy.

Configuration:
. The messenger needs a place to write persistant logs (to support replay and debug).
. The logs could be on the worldbase, but what if the worldbase is down?

		

"
Class {
	#name : #HumMessenger,
	#superclass : #HumNode,
	#instVars : [
		'playbackLog',
		'uriToNodeID',
		'nodeIDtoURI',
		'network'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'instance creation' }
HumMessenger class >> uri: aString [ 
	| instance |
	instance := self basicNew.
	instance uri: aString.
	^instance.
]

{ #category : #'URI to actor' }
HumMessenger >> getActorInstanceFromID: actorID [
	"*** Backdoor *** during debug to bypass the messenger"
	| actorInstance someURI |
	self assert: (actorID notNil).
	someURI := (self nodeIDtoURI) at: actorID ifAbsent: [Error signal: 'Trouble getting actorURI for: ', actorID ].
	actorInstance := (self network uriToNode) at: someURI ifAbsent: [Error signal: 'Trouble getting actorInstance for: ', actorID ].
	^actorInstance.
]

{ #category : #'events-registering' }
HumMessenger >> logInstruction: aHumStatement sentFrom: senderURI to: recipientURI [ 
	| timeNow logEntry |
	"Get the clock time - may be a simulator clock"
	timeNow := ( self clock ) now.
	logEntry := (self playbackLog) at: senderURI ifAbsent: [ logEntry := OrderedCollection new. ].
	logEntry add: { senderURI.  recipientURI. aHumStatement. timeNow. }.
	playbackLog at: senderURI put: logEntry.

]

{ #category : #accessing }
HumMessenger >> network [
	"Return the chosen physical implementation of network service."
	^ network ifNil: [ network := HumNetwork new].
]

{ #category : #accessing }
HumMessenger >> nodeIDtoURI [
	"actorURI contains (actor->URI) maps"
	^ nodeIDtoURI ifNil: [ nodeIDtoURI := Dictionary new ].
]

{ #category : #'events-triggering' }
HumMessenger >> ping: aURI [
	"MOCK: Return the ID of the given URI"
	^ ( self uriToNodeID ) at: aURI ifAbsent: [ Error signal: 'Messenger has no ID entry for URI: ', aURI ].
]

{ #category : #accessing }
HumMessenger >> playbackLog [
	^playbackLog ifNil: [ playbackLog := Dictionary new].
]

{ #category : #accessing }
HumMessenger >> playbackLogFromActor: aHumActor [ 
	"Extract/Get log entries sent to/from a specific actor.
	TODO: Should this be a URI instead of an Actor instance?"
	| result |
	(aHumActor isKindOf: HumActor)
		ifTrue: [ result := self playbackLogFromURI: (aHumActor uri) ].
	(aHumActor isKindOf: String )
		ifTrue: [
			(aHumActor beginsWith: 'URI:') 
				ifTrue: [ result := self playbackLogFromURI: aHumActor] 
				ifFalse:[
					| actor |
					actor := self getActorInstanceFromID: aHumActor.
					result := (self playbackLog) at: (actor uri) ifAbsent: [ OrderedCollection new].
					].
			].
	self assert: (result notNil).
	(result isEmpty) ifTrue: [self halt.].
	"TODO: Add timestamp feature. 
	 Someday, we may want to roll-forward from a given timestamp.
	 Note: timestamps may be from simulated clock rather than system clock."
	^result.
	
]

{ #category : #accessing }
HumMessenger >> playbackLogFromURI: aURI [ 
	"Extract/Get log entries sent to/from a specific actor.
	TODO: Should this be a URI instead of an Actor instance?"
	| result |
	result := (self playbackLog) at: (aURI) ifAbsent: [ OrderedCollection new].
	"TODO: Add timestamp feature. 
	 Someday, we may want to roll-forward from a given timestamp.
	 Note: timestamps may be from simulated clock rather than system clock."
	^result.
	
]

{ #category : #accessing }
HumMessenger >> playbackLogToURI: aURI [ 
	"Extract/Get log entries sent to/from a specific actor.
	TODO: Should this be a URI instead of an Actor instance?"
	| result |
	result := OrderedCollection new.
	(self playbackLog) 
		keysAndValuesDo: [:key :value |
			| actorLog |
			actorLog := value.
			actorLog do: [ :record |
				| toURI |
				toURI := record at: 2.
				(toURI = aURI)
					ifTrue: [ result add: record ].
				].
			].
	"TODO: Add timestamp feature. 
	 Someday, we may want to roll-forward from a given timestamp.
	 Note: timestamps may be from simulated clock rather than system clock."
	^result.
	
]

{ #category : #'events-triggering' }
HumMessenger >> registerActor: anActor atURI: aURI [ 
	"Track actor."
	self assert: ( anActor isKindOf: HumActor ).
	self assert: ( aURI isKindOf: String ).
	"Track URI->actor association."
	self registerNode: anActor atURI: aURI.

]

{ #category : #'events-triggering' }
HumMessenger >> registerNode: aNode atURI: aURI [ 
	"Track actor."
	self assert: ( aNode isKindOf: HumNode ).
	self assert: ( aURI isKindOf: String ).
	"Track URI->actor association."
	(self network uriToNode) at: aURI put: aNode.
	(self uriToNodeID) at: aURI put: (aNode id).
	(self nodeIDtoURI) at: (aNode id) put: aURI.

]

{ #category : #'events-triggering' }
HumMessenger >> sendAction: anInstructionLine toID: recipientID fromID: senderID [ 
	"Transmit action request between actors."
		| recipientURI senderURI|
	self assert: (anInstructionLine isKindOf: HumInstructionLine).
	self assert: (recipientID isKindOf:String).
	self assert: (senderID isKindOf:String).
	
	"Translate ID to URI."
	recipientURI := ( self nodeIDtoURI ) at: recipientID 
														ifAbsent: [Error signal: 'Messenger has no URI for recipient ID: ', recipientID].												
	senderURI := ( self nodeIDtoURI ) at: senderID 
														ifAbsent: [Error signal: 'Messenger has no URI for sender ID: ', senderID].
	"Send  . . ."
	self sendAction: anInstructionLine toURI: recipientURI fromURI: senderURI.
	
]

{ #category : #'events-triggering' }
HumMessenger >> sendAction: anInstruction toURI: recipientURI fromURI: senderURI [ 
	"Send the (action) statement to the given actor."
	| |
	self assert: (anInstruction isKindOf: HumInstructionLine).
	self logInstruction: anInstruction sentFrom: senderURI to: recipientURI. 
	"Delegate implementation to HumNetwork"
	self network sendAction: anInstruction toURI: recipientURI fromURI: senderURI. 
	
	
]

{ #category : #'events-triggering' }
HumMessenger >> sendInstruction: anInstruction toURI: recipientURI fromURI: senderURI [
	"Send the (action) statement to the given actor."
	"TODO: REFACTOR so that this pushes to a network. 
	And so the network becomes the mock instead of the messenger.
	This moves us toward using an actual network. (Likely a jabber network.)"
	| actorInstance |
	self assert: (anInstruction isKindOf: HumInstructionLine).
	"Following only works when actor is local."
	"TODO: Fix so that it works when actor is remote."
	actorInstance := ( self uriToNode ) at: recipientURI 
	                              ifAbsent: [ Error signal: 'Messenger has no actor for URI: ', recipientURI ].
	self logInstruction: anInstruction sentFrom: senderURI to: recipientURI. 
	actorInstance runInstruction: anInstruction inRole: (anInstruction role) onJob: (anInstruction jobTicket).
	"TODO: Need a better simulation of async."
	"========================================"
	
	
]

{ #category : #accessing }
HumMessenger >> uriToNodeID [
	"What actor ID is associated with URI?"
	^ uriToNodeID ifNil: [ uriToNodeID := Dictionary new]
]
