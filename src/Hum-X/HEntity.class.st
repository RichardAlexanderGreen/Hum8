"
Represent an entity instance in data.

Instance Variables:
	attributes	<Dictionary> - a dictionary of (attributeName -> attributeValue).
	history	<OrderedCollection> - a sequence of state-change records.
	title	<String>       - a locally unique noun naming this entity. (blackboard context)
	id	    <LargeInteger> - a globally unique identifier for this entity. (world-base context)
"
Class {
	#name : #HEntity,
	#superclass : #Object,
	#instVars : [
		'attributes',
		'history',
		'title',
		'id'
	],
	#category : #'Hum-X'
}

{ #category : #'instance creation' }
HEntity class >> title: aString [ 
	"Return an instance with that title/name"
	| instance |
	instance := self basicNew.
	instance title: aString.
	instance id: (HTime timeStamp).
	^instance.
]

{ #category : #accessing }
HEntity >> attribute: anAttributeName value: anAttributeValue [ 
	"Initialize entity-attribute value. (No event, no history)
	- Use '#attribute:value:event:' to record state-changes.
	"
	(self attributes) at: anAttributeName put: anAttributeValue.
]

{ #category : #accessing }
HEntity >> attribute: anAttributeType value: aValue event: anEvent [ 
	"Record a state-change associated with the given event."
	self attributes at: anAttributeType put: aValue.
	self history add: { anEvent. anAttributeType. aValue. }.
]

{ #category : #accessing }
HEntity >> attributes [
	"Return my dictionary of current attribute values."
	^ attributes ifNil: [ attributes := Dictionary new ].
]

{ #category : #accessing }
HEntity >> getAttribute: anAttributeName [ 
	"What is the value of the given attribute?"
	| result |
	result := self attributes at: anAttributeName.
	^result.
]

{ #category : #accessing }
HEntity >> history [
	"Return history of state-changes."
	^ history ifNil: [ history := OrderedCollection new].
]

{ #category : #accessing }
HEntity >> id [
	^ id
]

{ #category : #accessing }
HEntity >> id: aLargePositiveInteger [ 
	"Set unique identifier.
	- This value may be used to refer to this entity in relationships."
	id := aLargePositiveInteger.
]

{ #category : #accessing }
HEntity >> printOn: aStream [
	"Format my data for easy reading. 
	- Append lines to given stream (expecting aReadWriteStream).
	- TODO: Consider using a JSON format instead.
	"
	| |
	"Put my name/title on the stream"
	aStream << (self title) <<  ': ' << String cr.
	"Append indented list of my attribute values to stream."
	(self attributes)
		keysAndValuesDo: 
			[ :attr :value |
				aStream << '	' <<  attr << ': ' << value << String cr.
				"TODO: Handle attributes that refer to other entities."
			].
		
]

{ #category : #accessing }
HEntity >> title [
	"Entity should be given a contextually unique name (noun)"
	^ title ifNil: [ Error signal: 'unknown entity'].
]

{ #category : #associating }
HEntity >> title: aString [ 
	"Set my title - something appropriate to usage and unique within the context.
	Typically a noun (entity type or model component) within a blackboard.
	"
	title := aString
]
