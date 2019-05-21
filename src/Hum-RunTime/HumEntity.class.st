"
Each instance of this class representes an entity-instance data-bag, generally not an entity-type metadata.
An entity is a concept that exists in two contexts: entity-type and entity-instance.
However, we tend to use the same word regardless of context because the meaning is usually clear-enough.

1. An entity-type is a meta-data concept. It is associated with a noun in a Hum ontology.
. . An entity-type is identified with a noun (a word or a hyphenated-word).
. . In an ontology, an entity-type may have supertypes, subtypes, attributes. (See also: HumEntityAttribute)
. . In this context, the attribute-set of an entity merges its own attributes with those of its supertypes.

2. An entity-instance is an node/item in a run-time data store (Hum BlackBoard and WorldBase).
. . In a run-time context, an entity must have a unique identifier. (See HumIdentifier)
. . . The unique identifier enables references and facilitates data store operations.
. . . Entity-instances may reference each other via their unique identifiers.
. . A Hum World Base is a temporal database. 
. . . That means that entity data is time-stamped so that we can retrieve the history of an entity.
. . . An entity may be ~created~ and ~destroyed~ to correspond to events in the real-world.
. . . However, existence in the World Base may continue until the entity is ~purged~.

Q: TODO: How do we represent the ""entity destroyed"" event in data and the world-base?
A: This is relevant to how the World Base handles requests data for an entity.
   If the request`s time-window is beyond the ""destroy"" event, the entity should not be in the result.
"
Class {
	#name : #HumEntity,
	#superclass : #Object,
	#instVars : [
		'title',
		'id',
		'debug'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'as yet unclassified' }
HumEntity class >> new [
	| instance |
	Error signal: 'Why are we creating a HumEntity without a title?'.
	instance := self basicNew.
	instance title: (self class asString).
	^instance.
]

{ #category : #'as yet unclassified' }
HumEntity class >> title: aString [
	| instance |
	instance := self basicNew.
	instance title: aString.
	^instance.
]

{ #category : #accessing }
HumEntity >> asString [
	^self title.
]

{ #category : #accessing }
HumEntity >> debug [
	"Am I in debug mode?"
	^ debug ifNil: [debug := false].
]

{ #category : #accessing }
HumEntity >> id [
	"Return a unique identifier."
	| context |
	^ id ifNil: [ Error signal: 'Entity ID should be set by Blackboard or DialogAgent.'.
				context := 'Default ID for ' , (self class asString). "Convenient for DEBUG?"
				id := HumIdentifier createUniqueIdentifierForEntityName: title inContext: context 
				].
]

{ #category : #accessing }
HumEntity >> id: aString [ 
	"Set the entity`s identifier."
	id := aString
]

{ #category : #accessing }
HumEntity >> printOn: aStream [
	| myClassName |
	myClassName := self class name.
	aStream nextPutAll: ( myClassName,'(',id asString,')' ).

]

{ #category : #accessing }
HumEntity >> title [
	"a display string describing this entity" 
	^ title ifNil: [title := 'Unknown Entity'].
]

{ #category : #accessing }
HumEntity >> title: aString [
	"a display string describing this entity" 
	title := aString asString.
	self id: (HumIdentifier createUniqueIdentifierForEntityName: title inContext: title). "???"
	self id.
]
