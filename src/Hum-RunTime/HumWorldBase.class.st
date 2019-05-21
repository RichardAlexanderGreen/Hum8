"
The world base is a data base for a ""world"".

Typically, a ""world"" is an enterprise.
But, it could be a game or a simulation.

A world base is a temporal database.
All stored values are versioned.

For an entity, each stored attribute has a value and a time-span.
The time-span, in turn, has two event-stamps corresponding to the event which populated or updated the value and the event which changed the value.

A world base entry is a quad (4-tuple) of pointers:
. ( entity, attribute, value, time-span ).

Entity Schema:
. Entity has attributes.
. Attribute has value and time-span.
. Time-span has start-event, stop-event.

Event Schema:
. Event has client, portal, context, date-time.
. . . . . . . who, where, why, when, (what is the data affected)
. Client has identifier, client-type, credentials, ongoing-dialog.
. Client-type categories include person, robot.
. Context has job, ontology, frame, statement.

Configuration:
- A worldbase is known to a messenger. But it does not need to know any other actors.



"
Class {
	#name : #HumWorldBase,
	#superclass : #HumActor,
	#instVars : [
		'title',
		'quads',
		'history',
		'priorID'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'accessing instances and variables' }
HumWorldBase class >> openWorldBase: aWorldBaseName [
	"Open the world base instance with the given name.
	If it does not already exist, create a new instance." 
	"TODO: Should a world base be an actor or configuration? 
	If not, how do we communicate with a remote world base?"
	| instance |
	self assert: ( aWorldBaseName isKindOf: String ).
	instance := self new.
	instance 
		title: aWorldBaseName;
		id: aWorldBaseName;
		uri: 'URI:', aWorldBaseName.
	^instance.
]

{ #category : #'accessing instances and variables' }
HumWorldBase class >> openWorldBaseFromConfiguation: aHumConfiguration [
	"Open the world base instance identified in the configuration.
	 If the instance does not already exist, something is wrong."
	| instance |
	instance := aHumConfiguration getWorldBase.
	^instance.
]

{ #category : #testing }
HumWorldBase >> checkTau: aTau [ 
	self assert: (aTau isKindOf: DateAndTime ).
]

{ #category : #accessing }
HumWorldBase >> getEntityID: entityID attribute: attributeType [ 
	" Get requested value (if any) from the world base instance "
	| valueAndTau value tau |
	self assert: (entityID isKindOf: HumIdentifier ).
	self assert: (attributeType asSymbol isKindOf: Symbol ).
	
	valueAndTau := (self quads ) at: ( entityID -> attributeType ) ifAbsent: [ ^nil ].
	value := valueAndTau at: 1.
	tau := valueAndTau at: 2.
	^ value.
]

{ #category : #accessing }
HumWorldBase >> history [
	^ history ifNil: [ history := Dictionary new. ].
]

{ #category : #accessing }
HumWorldBase >> initialize [
	priorID := #( 0 0 0 ).
]

{ #category : #accessing }
HumWorldBase >> quads [
	"For quad internal structure see 
	self setEntityID: entityID attribute: attributeType toValue: aValue"
	^ quads ifNil: [ quads := Dictionary new. ].
]

{ #category : #accessing }
HumWorldBase >> setEntityID: entityID attribute: attributeType toValue: aValue [
	"Put attribute-value (if any) into the world base instance. "
	| tau priorValueTau |
	self assert: (entityID isKindOf: HumIdentifier ).
	self assert: (attributeType asSymbol isKindOf: String ).
	self assert: ( aValue notNil ).
	tau := (self clock) now. "seconds since 00:00 on 1 Jan 1901"
	"TODO: Tau should refer to a business event."
	"If there is a different prior value, archive in history."
	priorValueTau := ( self quads ) at: ( entityID -> attributeType ) ifAbsent: [].
	(( priorValueTau notNil ) and: [ ((priorValueTau at: 1) = aValue) not ] )
		ifTrue: [ | historyKey |
			historyKey :=	{ entityID. attributeType. (priorValueTau at: 2). tau }.
			(self history) at: historyKey put: (priorValueTau at: 1).
			].
	"Put value of entity attribute and the timestamp."
	( self quads ) at: ( entityID -> attributeType ) put: { aValue. tau. }.
	"TODO: For large scale applications, 
	. persist the entity-attribute-value on an external store.
	SUGGEST: An Erlang-compatible non-SQL database. See: RIAK.
	"
	"TODO: Should (other) blackboards holding the same entityID be notified of the change? If so, how?"

]

{ #category : #accessing }
HumWorldBase >> title [
	^ title ifNil: [ Error signal: 'A world base instance must have a title.'].
]

{ #category : #accessing }
HumWorldBase >> title: aWorldBaseName [ 
	self assert: ( aWorldBaseName isKindOf: String ).
	title := aWorldBaseName.
]

{ #category : #accessing }
HumWorldBase >> whereAttribute: attributeType satisfies: aBlockClosure [
	"Return a set of entity identifiers where the attribute value satisfies the block"
	| identifierSet  |
	identifierSet := Set new.
	(self quads)
		keysAndValuesDo: [ :quadKey :quadValue | 
				| entityID attrType attrValue tau |
				entityID := quadKey key. 
				attrType := quadKey value. 
				attrValue := quadValue at: 1. 
				tau       := quadValue at: 2.
				( ( attrType sameAs: attributeType ) and: [ aBlockClosure value: attrValue ] )
					ifTrue: [ identifierSet add: entityID.
						self checkTau: tau. 
						"Tau (timestamp) is not really used. I've included it for clarity and debug."
						].
			].
	^identifierSet.
]
