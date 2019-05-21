"
The dispatcher assigns actors to perform actions.
An actor registers itself with a dispatcher and identifies the roles that it knows.
When a running plan or dialog requires that an action be performed, the dispatcher finds an available actor that knows that role (has that capability) and assigns the requested action to that actor.
When the actor has completed the role, it becomes available for further assignments.

Instance Variables:
	roleActor	<Set>
	actorURI	<Dictionary>
"
Class {
	#name : #HumDispatcher,
	#superclass : #HumActor,
	#instVars : [
		'roleActor',
		'actorURI',
		'availableActors',
		'busyActors'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'events-triggering' }
HumDispatcher >> actor: anActor completedAction: aHumStatement [
	"Dispatcher is informed that the actor completed the assigned action.
	See: #assignRole: roleString action: actionStatement
	"
	| bookkeeperInstance |
	(anActor sameAs: myID)
		ifTrue: ["Dispatcher (self) cannot be busy and must always be available."]
		ifFalse: [	"Actor is no longer busy."
							( self busyActors ) remove: anActor.
							( self availableActors ) add: anActor.
							].

	"Send charges to bookkeeper."
	"For now, just call direct.
	TODO: Make asynch call to bookkeeper.
	"
	bookkeeperInstance := (self messenger) getActorInstanceFromID: (self configuration bookkeeperID).
	"TODO: Refactor this. It is by-passing the messenger."
	bookkeeperInstance recordJobTicket: ( aHumStatement jobTicket ) .
	

]

{ #category : #'events-triggering' }
HumDispatcher >> assignAction: aHumInstructionLine toRole: aByteString forJob: aHumJobTicket [ 
	self shouldBeImplemented.
]

{ #category : #'events-triggering' }
HumDispatcher >> assignRole: roleString action: actionInstruction [ 
	"Assign the given action to an actor advertising the given role."
	| actor potentialActors assignableActors  |
	self assert: ( roleString isKindOf: String ).
	self assert: ( roleString notEmpty ).
	self assert: ( actionInstruction isKindOf: HumInstructionLine ).
	potentialActors := Set new.
	"Find an actor that knows the role."
	( self roleActor ) 
		do: [ :map | 
			map key = roleString asLowercase  
				ifTrue: [ potentialActors add: map value. ].
			].
	"Filter potential actors to include only available actors."
	assignableActors := potentialActors intersection: (self availableActors).
	"Assign an actor at random."
	assignableActors ifEmpty: [Error signal: 'Set of assignableActors is empty - Now what?'].
	actor := assignableActors atRandom.
	(actor sameAs: myID)
		ifTrue: ["Manager (self) cannot be busy and must always be available."]
		ifFalse: ["Mark actor busy and not available."
							(self busyActors) add: actor.
							(self availableActors) remove: actor.
							].
		
	"Send the action to the actor."
	self sendMessage: actionInstruction to: actor.
	"Simulating asynch: 
	. The completion comes back via callback #actor: anActor completedAction: aStatement"
	
	
]

{ #category : #accessing }
HumDispatcher >> availableActors [
	^ availableActors ifNil: [ availableActors := Set new. ].
]

{ #category : #accessing }
HumDispatcher >> busyActors [
	^ busyActors ifNil: [ busyActors := Set new ].
]

{ #category : #accessing }
HumDispatcher >> checkInActor: actorID at: aURI withRoles: actorKnowsRoles [ 
	"The Dispatcher should delegate finding the URI to messenger."
	"For each actor role: 
	. Add the actor to those that know that role."
	self assert: ( actorKnowsRoles isKindOf: Array ).
	actorKnowsRoles do: [ :aRole |
		( self roleActor )  add: ( aRole -> actorID ).
		( self availableActors ) add: actorID.
		].
	
	
]

{ #category : #'events-triggering' }
HumDispatcher >> checkOutActor: anActorID at: anActorURI [ 
	"Actor is no longer available for assignments."
	| resultRoleActor |
	"Remove the actor from role->actor map."
	resultRoleActor := ( self roleActor ) copy.
	( self roleActor )  
		do: [:roleActorMap | 
			(roleActorMap value = anActorID) 
				ifTrue: [ resultRoleActor remove: roleActorMap ].
			].
	roleActor := resultRoleActor.	
	"Remove the actor from the available actor list."
	( self availableActors ) remove: anActorID.
	"Assume actor will not check-out with work in progress.
	If they do, the remove: will trigger an exception.
	TODO: In asynch environment, it is possible for assignment and check-out to cross.
	"
	^self.

]

{ #category : #accessing }
HumDispatcher >> roleActor [
	"Return the role->actor map set."
	^ roleActor ifNil: [ roleActor := Set new. ].
]

{ #category : #'events-triggering' }
HumDispatcher >> runAction: anAction inRole: aRole onJob: aHumJobTicket [
	"Dispatch the action to an actor in the given role." 
	|  |
	self assert: ( aRole isKindOf: String ).
	self assert: ( aRole notEmpty ).
	self assert: ( anAction isKindOf: HumInstructionLine ).
	( aRole = #dispatcher )
		ifTrue: ["This action is for me as dispatcher."
			self assert: (anAction statement translation notNil).
			HumCompiler evaluate: (anAction statement translation) for: self logged: false.
			^self.
			].
	"Otherwise: Assign action to an actor that has registered previously with that role."	
	anAction jobTicket: aHumJobTicket.
	self assignRole: aRole action: anAction 
	

]

{ #category : #'events-triggering' }
HumDispatcher >> sendMessage: aMessageObject to: recipientID. [
	"TODO: HumActor does not need to know that delegating a statement is a message send.
	 Replace this with something like: self delegateAction: aStatement to: aRole.
	"
	"self checkID: recipientID."
	self assert: (aMessageObject isKindOf: HumInstructionLine).
 	( self messenger ) sendAction: aMessageObject toID: recipientID fromID: myID.
	
	
]
