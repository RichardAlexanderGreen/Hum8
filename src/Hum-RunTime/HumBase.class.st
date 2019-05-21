"
HumBase is an code experiment - thinking out loud.
Potentially a replacement for HumWorldBase.

Instance Variables:
	entitiesOfType	<Dictionary>
	entitiesWithValue	<Dictionary>
	entityAttributeValue	<Dictionary>
	events	<Dictionary>
"
Class {
	#name : #HumBase,
	#superclass : #Object,
	#instVars : [
		'entitiesOfType',
		'entitiesWithValue',
		'entityAttributeValue',
		'events'
	],
	#category : #'Hum-RunTime'
}

{ #category : #accessing }
HumBase >> entitiesOfType [
	^ entitiesOfType ifNil: [ entitiesOfType := Dictionary new ].
]

{ #category : #accessing }
HumBase >> entitiesWithValue [
	"A dictionary of sets. The set of entities with the given { attribute value }."
	^ entitiesWithValue ifNil: [ entitiesWithValue := Dictionary new].
]

{ #category : #accessing }
HumBase >> entityAttributeValue [
	"A dictionary holding a temporal stack of {value event} for each {entity attribute}.
	 The top of the stack has the current {value event}."
	^ entityAttributeValue ifNil: [ entityAttributeValue := Dictionary new ].
]

{ #category : #accessing }
HumBase >> entityID: anID entityType: aType attribute: anAttribute value: aValue event: anEvent [
	"Create a record of entity-attribute-value from event."
	|  priorValue |
	
	"Add entity to set of that type."
	"ASSUMED: The entity does not change type over time."
	self insert: anID at: aType into: (self entitiesOfType).
	
	"Add entity to index by value."
	"TODO: entitiesWithValue is meant to be current value. We need to remove old entry, if any."
	priorValue := self getEntityID: anID attribute: anAttribute. 
	priorValue
		ifNotNil: [self remove: anID at: { anAttribute. priorValue. } from: ( self entitiesWithValue ).].
	self insert: anID at: { anAttribute. aValue. } into: ( self entitiesWithValue ).
	
	"Add record."
	self push: { aValue. anEvent. } at: { anID. anAttribute. } onto: ( self entityAttributeValue ).
	"( self entityAttributeValue ) at: { anID. anAttribute. } put: { aValue. anEvent. }."

	 
]

{ #category : #accessing }
HumBase >> eventWho: aWho what: aWhat where: aWhere why: aWhy [ 
	| stamp yyyy mo day hh mm ss nn when eventID event |
	stamp := DateAndTime current.
	yyyy := stamp year.
	mo   := stamp month.
	day  := stamp dayOfMonth.
	hh   := stamp hour.
	mm   := stamp minute.
	ss   := stamp seconds.
	nn   := stamp asNanoSeconds // 1000. "??? apparent precision is microseconds in MacOS"
	when := yyyy.
	{ mo. day. hh. mm. ss. } do: [ :x | when := (when * 100) + x ].
	when := (when * 1e6) + ( nn \\ 1e6 ).
	
	"when := yyyy*1e4+mo*1e2+day*1e2+hh*1e2+mm*1e2+ss*1e12+nn."
	..
	eventID := when.
	event := { when. aWho. aWhat. aWhere. aWhy. }.
	(self events) at: eventID put: event.
	^eventID.
	
]

{ #category : #accessing }
HumBase >> events [
	^ events ifNil: [ events := Dictionary new].
]

{ #category : #accessing }
HumBase >> findEntitiesOfType: anEntityType [ 
	| setOfEntities |
	setOfEntities := (self entitiesOfType) at: anEntityType ifAbsent: [ Set new ].
	^setOfEntities.
]

{ #category : #accessing }
HumBase >> findEntitiesWhereAttribute: anAttributeType satisfies: aBlockClosure [ 
	"Get collections of entities where current attribute value satisfies condition"
	| setOfEntities |
	setOfEntities := Set new.
	( self entityAttributeValue )
		keysAndValuesDo: [ :k :v |
			| entityID attributeType attributeValue stack tuple |
			entityID       := k at: 1.
			attributeType  := k at: 2.
			stack := v. 
			tuple := stack top.
			attributeValue := tuple at: 1.
			( attributeType = anAttributeType )
				ifTrue: [ 
					( aBlockClosure value: attributeValue ) 
						ifTrue: [ setOfEntities add: entityID ]
					]
			].
	^setOfEntities.	
]

{ #category : #accessing }
HumBase >> getEntityID: anEntityID attribute: anAttributeType [ 
	"Get the current value for given entityID attributeType"
	| result tuple stack |
	stack := ( self entityAttributeValue ) at: { anEntityID. anAttributeType } ifAbsent: [ ^nil ].
	tuple := stack top.
	result := tuple at: 1. 
	^result.
]

{ #category : #accessing }
HumBase >> insert: anItem at: aKey into: aDictionaryOfSets [
	"Insert the item into a set at the given key."
	| setOfEntities  |
	"Add entity to set associated with that key."
	setOfEntities := aDictionaryOfSets  at: aKey ifAbsent: [ Set new ].
	setOfEntities add: anItem.
	aDictionaryOfSets at: aKey put: setOfEntities.
]

{ #category : #accessing }
HumBase >> push: anItem at: aKey onto: aDictionaryOfStacks [
	"Insert the item into a list at the given key."
	| listOfEntities  |
	"Add entity to list of that type."
	listOfEntities := aDictionaryOfStacks  at: aKey ifAbsent: [ Stack new ].
	listOfEntities push: anItem.
	aDictionaryOfStacks at: aKey put: listOfEntities.
]

{ #category : #accessing }
HumBase >> remove: anEntityID at: aKey from: aDictionaryOfSets [ 
	"Remove the entityID from the set associated with the key."
	| set |
	set := aDictionaryOfSets at: aKey ifAbsent: [^self].
	set remove: anEntityID ifAbsent: [^self].
]
