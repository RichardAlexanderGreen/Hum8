"
A Blackboard stores entity data in memory.
It persists data via a world base (HBase).

"
Class {
	#name : #HBlackboard,
	#superclass : #Object,
	#instVars : [
		'events',
		'nouns',
		'clock',
		'worldBaseProxy'
	],
	#category : #'Hum-X'
}

{ #category : #'user interface' }
HBlackboard >> asStream [
	"Show the values in the blackboard on a stream."
	| stream |
	stream := ReadWriteStream on: ''.
	nouns 
		keysAndValuesDo: [ :k :v |
			(v isKindOf: HEntity)  ifTrue: [ v printOn: stream. ] 			
			].
	^stream.
	
	
]

{ #category : #accessing }
HBlackboard >> events [
	^ events ifNil: [ events := OrderedCollection new.]
]

{ #category : #accessing }
HBlackboard >> getEntity: anEntity attribute: anAttribute [ 
	| result entity |
	entity := self getEntityNamed: anEntity.
	result := entity getAttribute: anAttribute.
	^result.
]

{ #category : #accessing }
HBlackboard >> getEntityNamed: aNoun [ 
	| entity |
	entity := self nouns at: aNoun ifAbsent: [ self putEntityNamed: aNoun ].
	self assert: (entity isKindOf: HEntity).
	^ entity.
]

{ #category : #accessing }
HBlackboard >> getNoun: aNoun [ 
	| value |
	value := self nouns at: aNoun.
	^value.
]

{ #category : #accessing }
HBlackboard >> nouns [
	^ nouns ifNil: [ nouns := Dictionary new ].
]

{ #category : #accessing }
HBlackboard >> putEntity: anEntity attribute: anAttribute value: aValue event: anEvent [ 
	| entity |
	entity := self getEntityNamed: anEntity.
	entity attribute: anAttribute value: aValue event: anEvent.
	self nouns at: {anEntity. anAttribute.} put: aValue.
	worldBaseProxy 
		ifNotNil: [ worldBaseProxy putEntity: entity attribute: anAttribute value: aValue event: anEvent ].
]

{ #category : #accessing }
HBlackboard >> putEntityNamed: aNoun [ 
	| entity |
	entity := HEntity title: aNoun.
	self nouns at: aNoun put: entity.
	^entity.
]

{ #category : #accessing }
HBlackboard >> putEvent: anEvent [ 
	self assert: (anEvent isKindOf: HEvent).
	self events add: anEvent.
	worldBaseProxy 
		ifNotNil: [ worldBaseProxy putEvent: anEvent ].
]

{ #category : #accessing }
HBlackboard >> worldBase: aWorldBase [ 
	"MOCK: Pretend we are persisting values on world base.
	"
	worldBaseProxy := aWorldBase.
]
