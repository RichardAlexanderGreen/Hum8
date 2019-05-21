"
A configuration holds the information about how agents are connected to other agents.

A typical running application needs the following actors/components:
. Dialog Agent to communicate with the client
. Coordinator to operate plans
. Dispatcher to assign actors to actions
. Bookkeeper to record resource untilization
. Messenger to enable communication between these actors

. A Dialog Agent uses one or more Scribes to decouple dialogs from specific user interface frameworks.
. Actors have Blackboards to hold and organize their entity-attribute data.
. Blackboards have World Bases to persist and archive their data.
. Actors will generally share a common World Base because they are all operating in the same ""world.""

Q: Should a configuration also hold actual objects? 
A: No. The configuration holds the unique names. 
   The messenger maps those names to network addresses and sends messages over the network.

Q: How do we mock/proxy actors so that we can test without a network?
A: (Eventually) The network is mocked in test mode. 
   Everything else should work the same in test and production modes.

 
"
Class {
	#name : #HumConfiguration,
	#superclass : #Object,
	#instVars : [
		'messengerID',
		'managerID',
		'bookkeeperID',
		'worldbaseID',
		'ontology',
		'messengerProxy',
		'isTest',
		'clock',
		'dispatcherID',
		'debug'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'instance creation' }
HumConfiguration class >> configuration: aHumConfiguration [
	"Create an instance with the same configuration as the given configuration."
	 | c instance |
	 c := aHumConfiguration.
   instance := self messengerID: c messengerID 
                      dispatcherID: c dispatcherID 
                   bookkeeperID: c bookkeeperID 
                    worldbaseID: c worldbaseID. 
  instance messenger: c messenger.
	instance ontology: c ontology.
	^ instance.

]

{ #category : #'instance creation' }
HumConfiguration class >> messengerID: idMessenger dispatcherID: idDispatcher bookkeeperID: idBookkeeper worldbaseID: idWorldbase [ 
	| instance |
	instance := self basicNew.
	instance messengerID: idMessenger dispatcherID: idDispatcher bookkeeperID: idBookkeeper worldbaseID: idWorldbase.
	instance ontology ifNil: [instance ontology: HumOntology baseOntology].
	^instance.
]

{ #category : #accessing }
HumConfiguration >> bookkeeperID [
	^ bookkeeperID
]

{ #category : #accessing }
HumConfiguration >> bookkeeperID: anObject [
	bookkeeperID := anObject
]

{ #category : #accessing }
HumConfiguration >> clock [
	"What object is providing time-keeping?"
	^ clock ifNil: [clock := HTime "class singleton"].
]

{ #category : #accessing }
HumConfiguration >> clock: anObjectThatImplementsNow [
	"Clock must be an object that imlements >>now as a number of seconds (an Integer)."
	self assert: ( anObjectThatImplementsNow respondsTo: #now ).
	clock := anObjectThatImplementsNow.
]

{ #category : #accessing }
HumConfiguration >> configuration: aHumConfiguration [ 
	"Copy configuration."
	self assert: (aHumConfiguration isKindOf: HumConfiguration ).
	self copyFrom: aHumConfiguration.
]

{ #category : #accessing }
HumConfiguration >> debug [
	"Am I in debug mode?"
	^ debug ifNil: [debug := false].
]

{ #category : #accessing }
HumConfiguration >> dispatcherID [
	^ dispatcherID ifNil: [ Error signal: 'A configuration must have a Dispatcher.' ].
]

{ #category : #accessing }
HumConfiguration >> dispatcherID: anObject [
	dispatcherID := anObject
]

{ #category : #accessing }
HumConfiguration >> getWorldBase [
	"Get this configuration`s worldbase instance."
	| worldbaseInstance |
	worldbaseInstance := (self messenger) getActorInstanceFromID: (self worldbaseID).
	^worldbaseInstance.
	
]

{ #category : #accessing }
HumConfiguration >> isTest [
  "Are we running in TEST mode?"
	^isTest ifNil: [ isTest := true. ].
	
]

{ #category : #accessing }
HumConfiguration >> isTest: aBoolean [
	"Are we running in TEST mode?"
	isTest := aBoolean
	
]

{ #category : #accessing }
HumConfiguration >> messenger [
	^ messengerProxy 
			ifNil: [ "Set up messenger with my clock."
				messengerProxy := HumMessenger new.
				messengerProxy clock: self. 
				messengerProxy. "return"
				].
]

{ #category : #accessing }
HumConfiguration >> messenger: aHumMessenger [
	"Set the messenger -- Use to configure mocks when needed."
	self assert: (aHumMessenger isKindOf: HumMessenger).
  messengerProxy := aHumMessenger.

]

{ #category : #accessing }
HumConfiguration >> messengerID [
	^ messengerID
]

{ #category : #accessing }
HumConfiguration >> messengerID: aString [
	messengerID := aString.
	('*URL*' match: aString) ifTrue: [self halt].
	('*ID' match: aString ) ifFalse: [ Error signal: 'ID is not in expected (MOCK) format.' ].
]

{ #category : #accessing }
HumConfiguration >> messengerID: idMessenger dispatcherID: idDispatcher bookkeeperID: idBookkeeper worldbaseID: idWorldbase [

	messengerID := idMessenger.
	dispatcherID := idDispatcher.
  bookkeeperID := idBookkeeper. 
  worldbaseID := idWorldbase.

	"WARNING: I am not sure this is a good idea."
  ontology ifNil: [self ontology: HumOntology baseOntology].
	


]

{ #category : #accessing }
HumConfiguration >> now [
	"What time is it in configured world (may be simulation)?"
	^ clock now.
]

{ #category : #accessing }
HumConfiguration >> ontology [
	^ ontology ifNil: [ Error signal: 'ontology is missing from configuration'].
	"TODO: Perhaps we should return HumOntology baseOntology instead."
]

{ #category : #accessing }
HumConfiguration >> ontology: aHumOntology [ 
	ontology := aHumOntology.
]

{ #category : #accessing }
HumConfiguration >> openWorldBase [
	"Create world base instance and register with messenger."
	| worldbaseInstance |
	worldbaseInstance := HumWorldBase openWorldBase: (self worldbaseID).
	(self messenger) registerActor: worldbaseInstance atURI: (worldbaseInstance uri). 
	^worldbaseInstance.
]

{ #category : #accessing }
HumConfiguration >> worldbaseID [
	^ worldbaseID
]

{ #category : #accessing }
HumConfiguration >> worldbaseID: anObject [
	worldbaseID := anObject
]
