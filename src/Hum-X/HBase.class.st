"
The World Base represents ""corporate memory"".
It records business events and entity attribute values.
Business Events:
. Plan Frame post-condition satisfied. (Plan Coordinator WIP persistence)
. Dialog context changed.
. TODO: Give some thought about relationship (associative entity) instantiation.
. . Business-Relationships are typically caused by business actions.
. . But: Where is the observer?
. . Most such business actions are transactions (buy-sell, bid, subscribe/register, assign).

Entity Attribute values:
. Dialog noun value set by input pattern. 
. Dialog noun value set by 'Ask view-name'.

Three cases are ""dialog-persistence"" - providing persistence for a dialog blackboard.

Actors that need persistent state may also use a world base component.
However, that component does not necessarily need to be the enterprise world base.
Different actors may, in effect, live in different worlds.

Other persistence mechanisms:
. Job-Ticket charges - are handled by bookkeeper - Charges have a different meaning and dynamic than world base.
. Actor`s internal state - Example: a robot may perist its internal state (blackboard) separately.
. Coordinator state - (Noun blackboard + Plan WIP state)
. Dispatcher state - (Actor available, busy) 

"
Class {
	#name : #HBase,
	#superclass : #Object,
	#instVars : [
		'events',
		'entities'
	],
	#category : #'Hum-X'
}

{ #category : #accessing }
HBase >> entities [
	"Dictionary of (id -> entity)"
	^ entities ifNil: [ entities := Dictionary new ].
]

{ #category : #accessing }
HBase >> events [
	^events ifNil: [ events := Dictionary new ].
]

{ #category : #'events-registering' }
HBase >> putEntity: anEntity attribute: anAttribute value: aValue event: anEvent [ 
	"Record entity attribute value"
	| entity |
	entity := (self entities) at: (anEntity id) 
										ifAbsent: [nil].
	entity 
		ifNil: [entity := HEntity title: (anEntity title). 
			      entity id: (anEntity id).
			].
	
	entity attribute: anAttribute value: aValue event: anEvent.
	(self entities) at: (anEntity id) put: entity.  
]

{ #category : #'events-registering' }
HBase >> putEvent: anEvent [ 
	"Record the given event in my store."
	|  |
	(self events) at: (anEvent id) put: anEvent.
	
]
