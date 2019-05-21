"
The World Base represents ""corporate memory"".
It records business events and entity attribute values.

Use Cases: (There should be at least one test for each use case.)
==========
Business Events:
. Plan Frame post-condition satisfied.
. Dialog context changed.
Entity Attribute values:
. Dialog noun value set by input pattern.
. Dialog noun values set by 'Ask view-name'.




"
Class {
	#name : #HBaseTests,
	#superclass : #Object,
	#category : #'Hum-X'
}

{ #category : #'as yet unclassified' }
HBaseTests >> test240WorldBaseBacksBlackBoard [
	"Blackboard calls on World Base to persist events, state-changes."
	| event blackboard |
	
	blackboard := HBlackboard new.
	blackboard worldBase: HBase new.
	
	event := HEvent who: 'TTester' what: 'named' when: (HTime now)
	              where: 'test240WorldBaseBacksBlackBoard' 
	                why: 'intialize blackboard nouns'. 
	
	blackboard putEvent: event.
	
	"Put first name, last name"
	blackboard putEntity: 'tester' attribute: 'first-name' value: 'Tessie' event: event.
	
	blackboard putEntity: 'tester' attribute: 'last-name' value: 'Tester' event: event.

	
	
]
