"
Deliberately removed from test sets.
"
Class {
	#name : #HEntityTests,
	#superclass : #Object,
	#category : #'Hum-X'
}

{ #category : #'as yet unclassified' }
HEntityTests >> test110EntityHasAttributes [
	"An entity has one or more attributes"
	| entity value |
	entity := HEntity new.
	"Put first name"
	entity attribute: 'first-name' value: 'Tessie'.
	value := entity getAttribute: 'first-name'.
	"Put last name"
	self expect: 'Tessie' actual: value.
		entity attribute: 'last-name' value: 'Tester'.
	value := entity getAttribute: 'last-name'.
	self expect: 'Tester' actual: value.
	"First name is still there"
	value := entity getAttribute: 'first-name'.
	self expect: 'Tessie' actual: value.

	
	
]

{ #category : #'as yet unclassified' }
HEntityTests >> test120SetAttributeValueInEvent [
	"An entity has one or more attributes"
	| entity value event |
	event := HEvent who: 'TTester' what: 'named' when: (TimeStamp now)
	              where: 'test120SetAttributeValueInEvent' 
	                why: 'test120SetAttributeValueInEvent'. 
	entity := HEntity new.
	"Put first name"
	entity attribute: 'first-name' value: 'Tessie' event: event.
	value := entity getAttribute: 'first-name'.
	"Put last name"
	self expect: 'Tessie' actual: value.
	
	entity attribute: 'last-name' value: 'Tester' event: event.
	value := entity getAttribute: 'last-name'.
	self expect: 'Tester' actual: value.
	"First name is still there"
	value := entity getAttribute: 'first-name'.
	self expect: 'Tessie' actual: value.

	
	
]

{ #category : #'as yet unclassified' }
HEntityTests >> test125EntityPrintOn [
	"An entity has one or more attributes"
	| entity event stream |
	event := HEvent who: 'TTester' what: 'named' when: (TimeStamp now)
	              where: 'test120SetAttributeValueInEvent' 
	                why: 'test120SetAttributeValueInEvent'. 
	entity := HEntity title: 'tester'.
	"Put first name"
	entity attribute: 'first-name' value: 'Tessie' event: event.	
	entity attribute: 'last-name' value: 'Tester' event: event.
	
	stream := ReadWriteStream on: ''.
	entity printOn: stream.
	self expect: 'tester: 
	first-name: Tessie
	last-name: Tester
' 
			actual: ( stream contents ).

	
	
]

{ #category : #'as yet unclassified' }
HEntityTests >> test130UpdateAttributeValueInEvent [
	"An entity has one or more attributes"
	| entity value event event2 |
	event := HEvent who: 'TTester' what: 'named' when: (TimeStamp now)
	              where: 'test130UpdateAttributeValueInEvent' 
	                why: 'testing entity-initialize attributes'. 
	entity := HEntity new.
	"Put first name"
	entity attribute: 'first-name' value: 'Tessie' event: event.
	value := entity getAttribute: 'first-name'.
	"Put last name"
	self expect: 'Tessie' actual: value.
	
	entity attribute: 'last-name' value: 'Tester' event: event.
	value := entity getAttribute: 'last-name'.
	self expect: 'Tester' actual: value.
	"First name is still there"
	value := entity getAttribute: 'first-name'.
	self expect: 'Tessie' actual: value.

	"============"
	event2 := HEvent who: 'TTester' what: 'renamed' when: (TimeStamp now)
	              where: 'test130UpdateAttributeValueInEvent-rename' 
	                why: 'testing entity-rename updates attributes'. 
	entity := HEntity new.
	"Put first name"
	entity attribute: 'first-name' value: 'Teddy' event: event2.
	value := entity getAttribute: 'first-name'.
	"Put last name"
	self expect: 'Teddy' actual: value.
	
	entity attribute: 'last-name' value: 'Tinker' event: event2.
	value := entity getAttribute: 'last-name'.
	self expect: 'Tinker' actual: value.
	"First name is still there"
	value := entity getAttribute: 'first-name'.
	self expect: 'Teddy' actual: value.

	
	
	
]
