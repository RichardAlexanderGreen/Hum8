Class {
	#name : #HBlackboardTests,
	#superclass : #Object,
	#category : #'Hum-X'
}

{ #category : #'as yet unclassified' }
HBlackboardTests >> test140BlackboardSaveFetch [
	"A blackboard records events, noun values"
	| value event blackboard |
	blackboard := HBlackboard new.
	event := HEvent who: 'TTester' what: 'named' when: (HTime now)
	              where: 'test140BlackboardSaveFetch' 
	                why: 'intialize blackboard nouns'. 
	blackboard putEvent: event.
	
	"Put first name"
	blackboard putEntity: 'tester' attribute: 'first-name' value: 'Tessie' event: event.
	value := blackboard getEntity: 'tester' attribute: 'first-name'.
	"Put last name"
	self expect: 'Tessie' actual: value.
	
	blackboard putEntity: 'tester' attribute: 'last-name' value: 'Tester' event: event.
	value := blackboard getEntity: 'tester' attribute: 'last-name'.
	self expect: 'Tester' actual: value.
	"First name is still there"
	value := blackboard getEntity: 'tester' attribute: 'first-name'.
	self expect: 'Tessie' actual: value.

	
	
]

{ #category : #'as yet unclassified' }
HBlackboardTests >> test145BlackboardSaveFetchNouns [
	"A blackboard records events, noun values"
	| value event blackboard nounValue |
	blackboard := HBlackboard new.
	event := HEvent who: 'TTester' what: 'named' when: (HTime now)
	              where: 'test140BlackboardSaveFetch' 
	                why: 'intialize blackboard nouns'. 
	blackboard putEvent: event.
	
	"Put first name"
	blackboard putEntity: 'tester' attribute: 'first-name' value: 'Tessie' event: event.
	value := blackboard getEntity: 'tester' attribute: 'first-name'.
	"Put last name"
	self expect: 'Tessie' actual: value.
	nounValue := blackboard getNoun: {'tester'. 'first-name'.}.
	self expect: value actual: nounValue.
	
	blackboard putEntity: 'tester' attribute: 'last-name' value: 'Tester' event: event.
	value := blackboard getEntity: 'tester' attribute: 'last-name'.
	self expect: 'Tester' actual: value.
	"First name is still there"
	value := blackboard getEntity: 'tester' attribute: 'first-name'.
	self expect: 'Tessie' actual: value.

	
	
]

{ #category : #'as yet unclassified' }
HBlackboardTests >> test150BlackboardSaveFetchUpdate [
	"A blackboard records events, noun values"
	| value event1 blackboard event2 |
	blackboard := HBlackboard new.
	event1 := HEvent who: 'TTester' what: 'named' when: (HTime now)
	              where: 'test150BlackboardSaveFetchUpdate' 
	                why: 'intialize blackboard nouns'. 
	blackboard putEvent: event1.
	blackboard putEntityNamed: 'tester'.
	"Put first name"
	blackboard putEntity: 'tester' attribute: 'first-name' value: 'Tessie' event: event1.
	value := blackboard getEntity: 'tester' attribute: 'first-name'.
	"Put last name"
	self expect: 'Tessie' actual: value.
	
	blackboard putEntity: 'tester' attribute: 'last-name' value: 'Tester' event: event1.
	value := blackboard getEntity: 'tester' attribute: 'last-name'.
	self expect: 'Tester' actual: value.
	"First name is still there"
	value := blackboard getEntity: 'tester' attribute: 'first-name'.
	self expect: 'Tessie' actual: value.

	"==========="
	event2 := HEvent who: 'TTester' what: 'named' when: (HTime now)
	              where: 'test150BlackboardSaveFetchUpdate' 
	                why: 'update blackboard nouns'.
	self assert: ( event2 > event1 ). 
	blackboard putEvent: event2.
	blackboard putEntityNamed: 'tester'.
	"Put first name"
	blackboard putEntity: 'tester' attribute: 'first-name' value: 'Teddy' event: event2.
	value := blackboard getEntity: 'tester' attribute: 'first-name'.
	"Put last name"
	self expect: 'Teddy' actual: value.
	
	blackboard putEntity: 'tester' attribute: 'last-name' value: 'Tinker' event: event2.
	value := blackboard getEntity: 'tester' attribute: 'last-name'.
	self expect: 'Tinker' actual: value.
	"First name is still there"
	value := blackboard getEntity: 'tester' attribute: 'first-name'.
	self expect: 'Teddy' actual: value.


	
	
]

{ #category : #'as yet unclassified' }
HBlackboardTests >> test160BlackboardToStream [
	"A blackboard records events, noun values"
	| event blackboard |
	blackboard := HBlackboard new.
	event := HEvent who: 'TTester' what: 'named' when: (HTime now)
	              where: 'test140BlackboardSaveFetch' 
	                why: 'intialize blackboard nouns'. 
	blackboard putEvent: event.
	
	"Put first name"
	blackboard putEntity: 'tester' attribute: 'first-name' value: 'Tessie' event: event.
	
	blackboard putEntity: 'tester' attribute: 'last-name' value: 'Tester' event: event.
	
	self expect: 'tester: 
	first-name: Tessie
	last-name: Tester
' 
			actual: ( blackboard asStream contents ).


	
	
]
