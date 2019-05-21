"
Primary Programmer Stories:
. Identifier is related to an entity and/or event. (where used)
. When an entity is created, it is given a unique identifier. (where used)

Instance Variables:
	bigNumber	<Integer | LargePositiveInteger >
	uuid	       <UUID>
	entityName	 <String>

Class Instance Variables:
	daysRegister	     <Integer>
	secondsRegister	 <Integer>
	nanosRegister	   <Integer>
	uuid	            <UUID>
		
Secondary Programmer Stories:
. Identifier sorts by time-of-creation. (system clock or simulator clock)
. Identifier has time-stamp qualities.
"
Class {
	#name : #HumIdentifier,
	#superclass : #Object,
	#instVars : [
		'bigNumber',
		'uuid',
		'entityName'
	],
	#classInstVars : [
		'daysRegister',
		'secondsRegister',
		'nanosRegister',
		'uuid'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'instance creation' }
HumIdentifier class >> createUniqueIdentifierForEntityName: entityName inContext: businessEvent [
	"There should always be a business context (not a data-context)."
	| instance |
	instance := self basicNew.
	instance generateForEntityName: entityName inContext: businessEvent. 
	^instance.
]

{ #category : #'class variables' }
HumIdentifier class >> days [
	"Fetch the prior identifier parameters."
	^ daysRegister ifNil: [ daysRegister := 0 ].
]

{ #category : #'class variables' }
HumIdentifier class >> days: nDays seconds: nSeconds nanos: nNanos [ 
	daysRegister := nDays.
	secondsRegister := nSeconds.
	nanosRegister := nNanos.
]

{ #category : #'class variables' }
HumIdentifier class >> nanos [
	"Fetch the prior identifier parameters."
	^ nanosRegister ifNil: [ nanosRegister := 0 ].
]

{ #category : #'class variables' }
HumIdentifier class >> seconds [
	"Fetch the prior identifier parameters."
	^ secondsRegister ifNil: [ secondsRegister := 0 ].
]

{ #category : #'class variables' }
HumIdentifier class >> uuid [
	"Fetch the prior identifier parameters?"
	| x |
	
	x := (((daysRegister*10e6)+secondsRegister)*10e9)+nanosRegister.
	uuid := x printStringHex.
	^ uuid
]

{ #category : #comparing }
HumIdentifier >> < aHumIdentifier [ 
	| result |
	result := ( self asString < aHumIdentifier asString ).
	^ result.
]

{ #category : #comparing }
HumIdentifier >> <= aHumIdentifier [ 
	| result |
	result := ( self asString <= aHumIdentifier asString ).
	^ result.
]

{ #category : #accessing }
HumIdentifier >> asString [
	
	(bigNumber isKindOf: Integer ) 
		ifFalse: [ Error signal: 'bigNumber should be an Integer'.
			^(entityName asString),':',(bigNumber asString)].
	^ (entityName asString),':',(bigNumber printStringHex).
]

{ #category : #accessing }
HumIdentifier >> entityName [
	"Return entity name -- force nil to string if needed."
	^ entityName asString.
]

{ #category : #accessing }
HumIdentifier >> generateForEntityName: anEntityName inContext: aBusinessEvent [
	"Make self a unique identifier for given entity context."
	| ticks days seconds nanos prior priorDays priorSeconds priorNanos priorBigNumber |
	self assert: (anEntityName isKindOf: String).
	self assert: (aBusinessEvent isKindOf: String).
	self assert: (aBusinessEvent > ' ').
	"TODO: Think: Should the business context where the entity originates be embedded in the ID somehow ???"
	entityName := anEntityName.
	ticks := DateAndTime now asUTC ticks copy.
	days := ticks at: 1.
	seconds := ticks at: 2.
	nanos := ticks at: 3.
	"Singleton holds prior values."
	prior := self class.
	priorDays := prior days.
	priorSeconds := prior seconds.
	priorNanos := prior nanos.
	( days = priorDays and: [ seconds = priorSeconds and: [ nanos <= priorNanos ] ] )
		ifTrue: [ nanos := (prior nanos) + 1. ].
	"Post Conditions:"	
	bigNumber := (((days * 86400) + seconds) * 1e9) + nanos.
	priorBigNumber := ( ((priorDays * 86400) + priorSeconds) * 1e9) + priorNanos.
	self assert: ( bigNumber > priorBigNumber ).
	"Set the singleton values."
	prior days: days seconds: seconds nanos: nanos.
	self uuid: self class uuid.
	
]

{ #category : #accessing }
HumIdentifier >> initialize [
	"This UUID represents the run-time. 
	TODO: THIS IS A STUB. 
	EVENTUALLY, THIS SHOULD BE SET FROM A CONFIGURATION FILE OR SOMETHING."
	uuid := UUID new.
]

{ #category : #private }
HumIdentifier >> printOn: aStream [
	aStream nextPutAll: (self asString).
]

{ #category : #accessing }
HumIdentifier >> uuid: aUUID [ 
	uuid := aUUID
]
