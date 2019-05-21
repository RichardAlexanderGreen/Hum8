"
Features:
""The Simulator provides the means for 'regression testing'.
	Hum dialogs / protocols may be exercised by sending a series of messages to one or more Dialog Agents.
	Hum plans are initiated via such dialogs.
	Evidence of execution may be found via the Bookkeeper, Messenger logs, and Agent logs.
	""
""Simulations 'load' the system under test by starting dialog sequences 
	. at random intervals as seen by the simulated clock.
	==> We need a way to represent dialog sequences.
	==> We need a way to represent random intervals.
	==> We need a way to identify the number of dialogs to be run simultaneously.
	==> Ideally, we will run the dialogs in independent threads.
	""
""A simulation loads 'events' into a time-sorted queue and sends the events asynchronously.
	. Agent/Actors respond to events by adding events of their own to the queue. 
	. The timestamp on each event indicates its order, 
	. . but does not determine the real-time duration of the simulation.
	. There is no need to create real-time wait-times during the simulation.
	""
""The simulator emulates a human response rate 
	. of approximating 1 keystroke (or button press) per second of simulated clock time.
	. It is not necessary to simulate the sensor, just the time between vignette inputs.
	""
Design Questions:
""Q: Should the simulator act like a Scribe, or should it work through Scribes?
	. In a TDD context, we will sometimes need to verify Scribe features.
	. But a Simulator seems like over-kill for that purpose. (A set of Test Cases should do.)
""
	

"
Class {
	#name : #HumSimulator,
	#superclass : #HumConfiguration,
	#instVars : [
		'dialogSequence',
		'startingIntervalDistribution',
		'numberOfDialogs',
		'simulatedClockSecond',
		'queue',
		'dialogAgents',
		'log4Dialog',
		'clientScribes'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'instance creation' }
HumSimulator class >> ontology: aHumOntology [ 
	| instance |
	instance := self basicNew.
	instance ontology: aHumOntology.
	instance initialize.
	^instance.
]

{ #category : #'events-registering' }
HumSimulator >> after: aDuration sendSpeech: aString from: aClientID [ 
	"Put this event into my queue."
	| |
	(self queue) add: { aDuration. #speech. aClientID. aString. }.
	"TODO: Generalize to send string to specific actor, not just user dialog."
	
]

{ #category : #accessing }
HumSimulator >> buildDialogAgentNamed: clientID [
	"Build a dialog agent configured for our simulation."
	| clientAgent myURI clientURI aHumConfiguration |
	myURI := 'URI:DialogAgent.', clientID.
	clientURI := 'URI:client.', clientID.
	clientAgent := HumActor dialogID: clientID uri: myURI client: clientURI configuration: self.
	(self dialogAgents) at: clientID put: clientAgent.
	"Check-in with Messenger to enable communication with Dispatcher and WorldBase."
	clientAgent checkIn.
	^clientAgent. 
]

{ #category : #accessing }
HumSimulator >> clientScribes [
	^clientScribes ifNil: [ clientScribes := Dictionary new.]
]

{ #category : #accessing }
HumSimulator >> dialogAgents [
	^ dialogAgents ifNil: [ dialogAgents := Dictionary new ].
]

{ #category : #accessing }
HumSimulator >> dialogSequence: anArrayOfString [ 
	"Identify the sequence of dialog responses to be sent during this simulation."
	self assert: (anArrayOfString isKindOf: SequenceableCollection ).
	dialogSequence := anArrayOfString 
]

{ #category : #accessing }
HumSimulator >> getDialogAgentNamed: aClientID [ 
	| clientAgent |
	self assert: ( aClientID isKindOf: String ).
	clientAgent := (self dialogAgents) at: aClientID ifAbsent: [self buildDialogAgentNamed: aClientID ].
	^clientAgent.
]

{ #category : #accessing }
HumSimulator >> getScribeForClient: aClientID [ 
	"Get the Scribe instance corresponding to the client ID."
	| scribe dialogAgent |
	scribe :=	(self clientScribes) at: aClientID 
		                        ifAbsent: [ dialogAgent := HumDialogAgent dialogID: aClientID uri: (aClientID,'URI') client: 'clientURI' configuration: self.
			                                  scribe := HumScribe dialogAgent: dialogAgent.
			                                  scribe id: aClientID. 
			                                 (self clientScribes) at: aClientID put: scribe. ].
	^scribe
]

{ #category : #accessing }
HumSimulator >> initialize [
	| messenger |
	messenger := HumMessenger new.
	messenger clock: self.
	self messenger: messenger.
	"Use factory methods to build singleton accomplices"
	self messengerID: 'SimMessenger' dispatcherID: 'SimDispatcher' bookkeeperID: 'SimBookkeeper' worldbaseID: 'SimWorldBase'.
	"self dispatcher: (HumActor dispatcherID: 'SimDispatcherID' uri: 'SimDispatcherURI' configuration: self)."
  self dispatcherID: 'SimDispatcherID'.
  	"self bookkeeper: (HumActor bookkeeperID: 'SimBookkeeperID' uri: 'SimBookkeeperURI' configuration: self)."
	self bookkeeperID: 'SimBookkeeperID'.
	"self worldBase: (HumWorldBase openWorldBase: 'SimWorldBase')."
	self worldbaseID: 'SimWorldBaseID'.

]

{ #category : #accessing }
HumSimulator >> log4Dialog [
	^ log4Dialog ifNil: [ log4Dialog := OrderedCollection new. ].
]

{ #category : #logging }
HumSimulator >> logDialogWhen: aDuration who: aClientID why: clientSaid what: systemSaid [
	(self log4Dialog) add: { aDuration. aClientID. clientSaid. systemSaid. }.
]

{ #category : #accessing }
HumSimulator >> now [
	^ self simulatedClockSecond.
]

{ #category : #accessing }
HumSimulator >> now: aDuration [ 
	simulatedClockSecond := aDuration
]

{ #category : #accessing }
HumSimulator >> numberOfDialogs: aSmallInteger [ 
	"How many dialogs are to be run simulataneously?"
	numberOfDialogs := aSmallInteger 
	
]

{ #category : #accessing }
HumSimulator >> queue [
	^ queue 
			ifNil: [ queue := SortedCollection sortBlock: [:a :b | (a at: 1) < (b at: 1)] ].
]

{ #category : #accessing }
HumSimulator >> randomStartingIntervals: aDistribution [
		"Express the distribution as an S-curve in seconds."
		self assert: (aDistribution isKindOf: Dictionary).
		startingIntervalDistribution := aDistribution.
		
]

{ #category : #accessing }
HumSimulator >> simulatedClockSecond [
	^ simulatedClockSecond ifNil: [simulatedClockSecond := 0 seconds].
]

{ #category : #'events-triggering' }
HumSimulator >> step [
	"Send all events with timing that matches the top event."
	| readyEvents remainingEvents whenNow  |
	"If the queue is empty, do nothing. 
	(Prevent problem when manually stepping. See: stepUntilDone)"
	( self queue size = 0 ) ifTrue: [ ^self ].
	"Update my clock."
	whenNow := (self queue at: 1) at: 1.
	self now: whenNow.
	"Pull the events for this clock-time from the queue."
	readyEvents       := (self queue) select: [:event | (event at: 1) = whenNow ].
	remainingEvents := (self queue) reject: [:event | (event at: 1) = whenNow ].
	queue := remainingEvents.
	"Send those events"
	readyEvents do: [:event | "For each event scheduled at this time."
    | eventType clientID speechString dialogAgent  |
		eventType := event at: 2.  clientID := event at: 3.  speechString := event at: 4.
		"Someday we might do more than one type of event. But, currently, we just do speech events."
		"The *fundamental* idea is that user-gestures are translated to speech-acts 
		(represented as a String or HumStatement) before they arrive here."
		"TODO: Generalize to send event to specific actor, not just the user dialog."
		self assert: (eventType = #speech ).
		dialogAgent := self getDialogAgentNamed: clientID.
		dialogAgent clientSays: speechString.
		"The dialog agent may, in turn, trigger self-actions, plans, and/or actions. "
		].
	
]

{ #category : #'events-triggering' }
HumSimulator >> stepUntilDone [
	[ self queue notEmpty ]
		whileTrue: [ self step. ]
]
