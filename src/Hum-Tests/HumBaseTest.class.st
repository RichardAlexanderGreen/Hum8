"
This class is the TestCase for HumBase.
HumBase is an code experiment - thinking out loud.
Potentially a replacement for HumWorldBase.
"
Class {
	#name : #HumBaseTest,
	#superclass : #HumTestCase,
	#category : #'Hum-Tests'
}

{ #category : #'as yet unclassified' }
HumBaseTest >> test110putGetValue [
	"Save entity-attribute-value and fetch."
	|  id type event value wb n |
	n := 9.
	wb := HumBase new.
	( 1 to: n )
		do: [ :i |
			id := i.
			type := #entityType.
			event := i * 11.
			value := i * 111.
			wb entityID: id entityType: type attribute: #attributeType value: value event: event.
			].
	
	self expect: n actual: (wb entitiesOfType at: type) size.
	self expect: 0 actual: (wb entitiesOfType at: #noneSuch ifAbsent: [Set new]) size.
	
	( 1 to: n )
		do: [ :j |
			self expect: 1 actual: ( wb entitiesWithValue at: { #attributeType. j*111. } ) size.
			self expect: {{ j*111. j*11. } } actual: ( wb entityAttributeValue at: { j. #attributeType. } ) asArray.
			].
	
	( 1 to: n )
		do: [ :k |
			self expect: k*111 actual: ( wb getEntityID: k attribute: #attributeType ).
			self expect: { k. } actual: ( wb findEntitiesWhereAttribute: #attributeType satisfies: [:x | x = (k * 111)]) asArray.
			].
	
]

{ #category : #'as yet unclassified' }
HumBaseTest >> test120updateGetValue [
	"Save entity-attribute-value and fetch."
	|  id type event value wb n |
	n := 9.
	wb := HumBase new.
	"Set initial value"
	( 1 to: n )
		do: [ :i |
			id := i.
			type := #entityType.
			event := i * 11.
			value := i * 111.
			wb entityID: id entityType: type attribute: #attributeType value: value event: event.
			].
	"Update value"
	( 1 to: n )
		do: [ :i |
			id := i.
			type := #entityType.
			event := i * 111.
			value := i * 1111.
			wb entityID: id entityType: type attribute: #attributeType value: value event: event.
			].
	
	self expect: n actual: (wb entitiesOfType at: type) size.
	self expect: 0 actual: (wb entitiesOfType at: #noneSuch ifAbsent: [Set new]) size.
	self expect: n actual: ( wb findEntitiesOfType: type ) size.
	self expect: 0 actual: ( wb findEntitiesOfType: #noneSuch ) size.
	
	( 1 to: n )
		do: [ :j |
			self expect: 0 actual: ( wb entitiesWithValue at: { #attributeType. j*111. } ) size.
			self expect: { j*1111. j*111. } actual: ( wb entityAttributeValue at: { j. #attributeType. } ) top.
			].
	
	( 1 to: n )
		do: [ :k |
			self expect: k*1111 actual: ( wb getEntityID: k attribute: #attributeType ).
			self expect: { k. } 
			     actual: ( wb findEntitiesWhereAttribute: #attributeType satisfies: [:x | x = ( k * 1111)] ) asArray.
			].
	
]

{ #category : #'as yet unclassified' }
HumBaseTest >> test130putGetEvent [
	"put get event"
	| wb eventID |
	wb := HumBase new.
	eventID := wb eventWho: 'who' what: 'what' where: 'where' why: 'why not'.
	self assert: (eventID isKindOf: LargePositiveInteger ).
]
