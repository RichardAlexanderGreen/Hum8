"
An actor is capable of performing one or more roles.
Some actors are part of the run-time systems and have particular configuration requirements.
In general, an actor needs a connection to a messenger in order to communicate with the system.
Most actors also need a connection to a manager so that the manager can assign actions to the actor.
Some actors also need a connection to a bookkeeper so that the actor can record utilization.

Instance Variables:
	myID		<String>
	myURI	<String>
	messengerURI	<URI>
	bookkeeperURI	<URI>
	roles				<Collection of: String>
	managerURI		<URI>
	configuration	<HumConfiguration> -- (2014-09-07 HumActor is subtype of HumConfiguration)
		
Configuration:
. An actor needs to know a messenger. (To simplify, we hide the details in a messenger proxy.)
. An actor checks-in with a manager/dispatcher.
. An actor`s action interface is defined in an ontology. (The ontology might also define an implementation.)
"
Class {
	#name : #HumActor,
	#superclass : #HumNode,
	#instVars : [
		'roles',
		'blackboard'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'instance creation' }
HumActor class >> bookkeeperID: myID uri: myURI configuration: aHumConfiguration [ 
	| instance |
	instance := HumBookkeeper configuration: aHumConfiguration.
	instance id: myID; uri: myURI.
	^instance. 
]

{ #category : #accessing }
HumActor class >> configuration: aHumConfiguration [ 
	| instance |
	instance := self basicNew.
	instance configuration: aHumConfiguration.
	instance initialize.
	^instance.
]

{ #category : #'instance creation' }
HumActor class >> coordinatorID: myID uri: myURI goal: aGoalStatementString dialog: aHumDialogAgent configuration: aHumConfiguration [ 
	| instance |

	instance := HumCoordinator configuration: aHumConfiguration.
	instance  id: myID; 
	          uri: myURI; 
					 goal: aGoalStatementString; 
	    dialogAgent: aHumDialogAgent.
	^instance.
]

{ #category : #'instance creation' }
HumActor class >> dialogID: myID uri: myURI client: clientURI configuration: aHumConfiguration [
	| instance |
	instance := HumDialogAgent configuration: aHumConfiguration.
	instance  id: myID; 
					 uri: 'URI:',myID; 
					blackboard: (HumBlackBoard worldbase: (aHumConfiguration getWorldBase));
				 client: myID.
	^instance.
	
]

{ #category : #'instance creation' }
HumActor class >> dispatcherID: myID uri: myURI configuration: aHumConfiguration [ 
	| instance |
	instance := HumDispatcher configuration: aHumConfiguration.
	instance id: myID; uri: myURI. 
	^instance. 
]

{ #category : #'instance creation' }
HumActor class >> workerID: workerID uri: workerURI roles: arrayOfRoleNames configuration: aHumConfiguration [ 
	| instance |
	instance := self configuration: aHumConfiguration.
	instance id: workerID; 
					uri: workerURI; 
					roles: arrayOfRoleNames.
	^instance.
]

{ #category : #accessing }
HumActor >> blackboard [
	^ blackboard ifNil: [ blackboard := HumBlackBoard new. ].
]

{ #category : #accessing }
HumActor >> blackboard: aHumBlackBoard [ 
	self assert: (aHumBlackBoard isKindOf: HumBlackBoard).
	blackboard := aHumBlackBoard
]

{ #category : #'events-triggering' }
HumActor >> checkIn [
	| statement quotedRoles instruction jobTicket |
	"First, check-in with the messenger."
	"TODO: REFACTOR THIS CALL.  ---  Why? Why? "
	( self messenger ) registerActor: self atURI: (self uri).
	"Don't check-in with self."
	( self isKindOf: HumDispatcher ) ifTrue: [^self.].
	"Coordinator is not dispatched by Dispatcher"
	( self isKindOf: HumCoordinator ) ifTrue: [^self.].
	"Allow Dialog Agents to be dispatched for Push messages."
	( self isKindOf: HumDialogAgent ) 
		ifTrue: ["Continue"].
	"We don't expect Scribes here. 
	A Dialog Agent should dispatch its own Scribe."
	( self isKindOf: HumScribe )	ifTrue: [ Error signal: 'We don`t expect a Scribe checkIn.'].

	"Send check-in message to my Dispatcher."
	quotedRoles := ''.
	( self roles )
		do: [ :role | quotedRoles := quotedRoles, ' ', role quoted ].
		
	statement := HumStatement source: 'Check-in actor with roles.'.
	statement role: #dispatcher;
	          noun: 'actor' value: myURI;
	          noun: 'roles' value: quotedRoles;
	   translation: ('self checkInActor: ', myID quoted, ' at: ', myURI quoted, 'withRoles: #(', quotedRoles, ')').
	
	jobTicket := HumJobTicket title: 'checkIn:',myID.
	instruction := HumInstructionLine new.
	instruction
	  role: #dispatcher;
		statement: statement;
		jobTicket: jobTicket.
	self delegateAction: instruction toRole: #dispatcher onJob: jobTicket.
	
]

{ #category : #'events-triggering' }
HumActor >> checkOut [
	"Tell the Dispather that this actor is no longer available for assignments."
	| statement jobTicket instruction |
	"Don't check-in with self."
	(self isKindOf: HumDispatcher ) ifTrue: [^self.].
	"Coordinator is not dispatched by Dispatcher"
	(self isKindOf: HumCoordinator ) ifTrue: [^self.].
	"Send check-out message to my Dispatcher."
	
	statement := HumStatement source: 'Check-out actor.'.
	statement role: #dispatcher;
	          noun: 'actor' value: myURI;
	   translation: ('self checkOutActor: ', myID quoted, ' at: ', myURI quoted).
	
	jobTicket := HumJobTicket title: 'checkOut:',myID.
	instruction := HumInstructionLine new.
	instruction
	  role: #dispatcher;
		statement: statement.
	self delegateAction: instruction toRole: #dispatcher onJob: jobTicket.
]

{ #category : #'events-triggering' }
HumActor >> completedAction: anAction inRole: aRoleString onJob: aHumJobTicket [ 
	"Following is first-cut direct call.
	When this is debugged, put an asynch wrapper on it.
	"
	| dispatcher   |
	self assert: ( anAction isKindOf: HumInstructionLine).
	dispatcher := (self messenger) getActorInstanceFromID: (self dispatcherID).
	"TODO: Refactor above - It is using the messengers back door and is only valid in test mode."
	self assert: (dispatcher isKindOf: HumDispatcher ).
	dispatcher actor: (self id) completedAction: anAction.


]

{ #category : #'events-triggering' }
HumActor >> completedInstruction: aHumInstructionLine inRole: aRoleString onJob: aHumJobTicket [ 
	"Following is first-cut direct call.
	When this is debugged, put an asynch wrapper on it.
	"
	| dispatcher   |
	self assert: ( aHumInstructionLine isKindOf: HumInstructionLine).
	dispatcher := (self messenger) getActorInstanceFromID: (self dispatcherID).
	"TODO: Refactor above - It is using the messengers back door and is only valid in test mode."
	self assert: (dispatcher isKindOf: HumDispatcher ).
	dispatcher actor: (self id) completedAction: aHumInstructionLine.


]

{ #category : #'events-triggering' }
HumActor >> delegateAction: anAction toRole: aRole onJob: aJobTicket [
	"Delegate action to another role."
	| |
	
	(self roles includes: aRole)
		ifTrue: [ "If the role is one of my own, do action myself."
			self runAction: anAction inRole: aRole onJob:  aJobTicket ]
		ifFalse: ["Otherwise have the dispatcher send it to some actor that knows the role."
			anAction jobTicket: aJobTicket.
			(self messenger) sendAction: anAction toID: (self dispatcherID) fromID: myID. "STUB"].
	
]

{ #category : #accessing }
HumActor >> dispatcherID [
	^self configuration dispatcherID.
]

{ #category : #accessing }
HumActor >> ontology [
	^self configuration ontology.
]

{ #category : #accessing }
HumActor >> roles [
	(roles isNil and: [self class = HumActor]) ifNil: [ Error signal: 'Actor {', myID,'} has no role.' ].
	^roles ifNil: [ roles := { self class name. }].
]

{ #category : #accessing }
HumActor >> roles: anArray [ 
	self assert: ( anArray isKindOf: Array ).
	roles := anArray.
]

{ #category : #'events-triggering' }
HumActor >> runAction: anAction inRole: aRole onJob: aHumJobTicket [
	"Run the action frame named ..." 
	| ontology lines |
	self assert: (anAction isKindOf: HumInstructionLine ).
	ontology := self configuration ontology.
	self assert: (ontology frames notEmpty).
	"TODO: Ontology has instruction sequence, but lacks frame lines."
	lines := ontology instructionsForRole: aRole action: anAction.
	( lines size > 0 ) 
		ifFalse: [Error signal: 'Action: {',anAction source,'} is not defined for role: {',aRole,'}.'].
	( lines select: [:line | line isKindOf: HumInstructionLine ] )
		do: [ :frameLine | 
		self runInstruction: frameLine inRole: aRole onJob: aHumJobTicket.
		].
	"Tell Dispatcher that we completed action normally."
	self completedAction: anAction inRole: aRole onJob: aHumJobTicket.

]

{ #category : #'events-triggering' }
HumActor >> runInstruction: anInstruction inRole: aRole onJob: aJobTicket [
	"Execute, simulate, or log the given statement"
	| charge aStatement |
	self assert: ( anInstruction isKindOf: HumInstructionLine ).
	aStatement := anInstruction statement.
	"If instruction role is not one of my roles, delegate the instruction."
	( anInstruction role > '' )
		ifTrue: [(self roles includes: anInstruction role) 
								ifFalse: [ ^self delegateAction: anInstruction toRole: anInstruction role onJob: aJobTicket ].
						].
	"If statement has a translation (assume Smalltalk), run the translation."		
	( aStatement translation notNil ) 
		ifTrue: ["Execute in Smalltalk -- TODO: What if translation is for Erlang/Java/...?"
			Compiler evaluate: (aStatement translation) for: self logged: false.
			"Charge to job ticket"	
			charge := HumMeasure quantity: 1 units: #step.   
			aJobTicket appendCharge: charge forAction: aStatement byActor: myID inRole: aRole onJob: aJobTicket.
			"Tell Dispatcher that we completed action normally."
			self completedInstruction: anInstruction inRole: aRole onJob: aJobTicket.
			^self.
			]
		ifFalse: [ "Simulate execution"
			"Append to log"
			| s |
			s := aStatement source trimBoth.
			( s = '' ) ifFalse: [ "Do not simulate execution of blank or comment-only statements."
				self stepLog add: ('Actor: {', myID,'} is doing: {', s, '}' ). 
				( aStatement nounValues )
					keysAndValuesDo: [ :noun :value | stepLog add: ('. with: ', noun, ' = ', value asString). ].
				"Charge to job ticket"	
				charge := HumMeasure quantity: 1 units: #step.   
				aJobTicket appendCharge: charge forAction: aStatement byActor: myID inRole: aRole onJob: aJobTicket.
				].
			^ self.
			].
	Error signal: 'Statement type not handled.'.

]

{ #category : #accessing }
HumActor >> updateBlackBoardFromBlackBoard: aHumBlackBoard [ 
	"Update my blackboard with entries from callers blackboard."
	| |
	self halt. "I want to check where this happens."
	"Delegate this to Blackboard. Note: Subtypes might want to override."
	( self blackboard ) updateBlackBoardFromBlackBoard: aHumBlackBoard. 
]

{ #category : #'events-triggering' }
HumActor >> zrunInstruction: anInstruction inRole: aRole onJob: aJobTicket [
	"Execute, simulate, or log the given statement"
	| charge aStatement |
	self assert: ( anInstruction isKindOf: HumInstructionLine ).
	aStatement := anInstruction statement.
	"If instruction role is not one of my roles, delegate the instruction."
	( anInstruction role > '' )
		ifTrue: [(self roles includes: anInstruction role) 
								ifFalse: [ ^self delegateAction: anInstruction toRole: anInstruction role onJob: aJobTicket ].
						].
	"If statement has a translation (assume Smalltalk), run the translation."		
	( aStatement translation notNil ) 
		ifTrue: ["Execute in Smalltalk -- TODO: What if translation is for Erlang/Java/...?"
			Compiler evaluate: (aStatement translation) for: self logged: false.
			"Charge to job ticket"	
			charge := HumMeasure quantity: 1 units: #step.   
			aJobTicket appendCharge: charge forAction: aStatement byActor: myID inRole: aRole onJob: aJobTicket.
			"Tell Dispatcher that we completed action normally."
			self completedInstruction: anInstruction inRole: aRole onJob: aJobTicket.
			^self.
			]
		ifFalse: [ "Simulate execution"
			"Append to log"
			self stepLog add: ('Actor: {', myID,'} is doing: {',aStatement source,'}' ).
			( aStatement nounValues )
				keysAndValuesDo: [ :noun :value | stepLog add: ('. with: ', noun, ' = ', value asString). ].
			"Charge to job ticket"	
			charge := HumMeasure quantity: 1 units: #step.   
			aJobTicket appendCharge: charge forAction: aStatement byActor: myID inRole: aRole onJob: aJobTicket.
			^ self.
			].
	Error signal: 'Statement type not handled.'.

]
