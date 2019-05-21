"
This is an implementation of Given-When-Then (behavior driven development) style of testing.

Note: Methods are duplicated under HumSeasideTests because I did not want to deal with Pharo ""traits"" and Smalltalk does not support multiple inheritance.
"
Class {
	#name : #GivenWhenThen,
	#superclass : #HumTestCase,
	#instVars : [
		'log',
		'givenBlock'
	],
	#category : #'Hum-Tests'
}

{ #category : #API }
GivenWhenThen >> assertString: stringA includesSubstring: stringB [
	 " stringB should be a substring in stringA "
	| quote x |
	quote := $' asString.
	x := stringA findString: stringB.
	self assert: (x > 0) description: 'Expecting ', quote, stringA, quote, ' contains ', quote, stringB, quote.
]

{ #category : #API }
GivenWhenThen >> given: aDescriptionString code: aBlock [
	"Given in a given-when-then triplet 
	-- use to setup test context (initial state).
	The code may contain asserts to self-check.
	"
	self log:  ( String cr, 'Given: ', aDescriptionString ).
	"Save the block so that multiple *when* can restore initial state before running."
	givenBlock := aBlock.
	^self.
	
]

{ #category : #API }
GivenWhenThen >> givenWhenThenComment [
	"The #given:code: and #when:code: and #then:code: methods are designed to be cascaded.
	Note that #when:code: runs the block provided in the call to #given:code: to set-up initial condition.
	That enables multiple *when-then* sequences to run even if they might interfere with each other.
	However, you still need to be careful of side-effects.
	"
	^ 'The #given:code: and #when:code: and #then:code: methods are designed to be cascaded.
	Note that #when:code: runs the block provided in the call to #given:code: to set-up initial condition.
	That enables multiple *when-then* sequences to run even if they might interfere with each other.
	However, you still need to be careful of side-effects.'

]

{ #category : #API }
GivenWhenThen >> log [
	^ log ifNil: [ log := OrderedCollection new. ].
]

{ #category : #API }
GivenWhenThen >> log: aString [
	| entry |
	"Prepend a CR to make inspection more readable."
	( aString beginsWith: (String cr) )
		ifTrue: [ entry := aString ] ifFalse: [ entry := String cr, aString ].
	( self log ) add: aString.
]

{ #category : #'self test' }
GivenWhenThen >> test105GivenWhenThenSuccess [
	"Test the test utility - In this situation the test assertion is true."
	| test x y z |
	test := self class basicNew.
	"A typical test looks like this."	
	test
		given: 'given description' code: [ x:= 'given set'];
		when: 'when description'  code: [ y := 'when set'];
		then: 'then description' code: [ z := 'then set'. self assert: (true) ].

	"Blocks should have executed."
	self assert: ( x sameAs: 'given set' ).
	self assert: ( y sameAs: 'when set' ).
	self assert: ( z sameAs: 'then set' ).
		

]

{ #category : #'self test' }
GivenWhenThen >> test106GivenWhenThenFail [
	"Test the test utility - In this situation the test assertion is true."
	| test x y z |
	test := self class basicNew.

	"Normally, this test is not needed."
	false ifFalse: [^self].
	test := self class basicNew.
	
	"A typical test looks like this."	
	test
		given: 'given description' code: [ x:= 'given set'];
		when: 'when description'  code: [ y := 'when set'];
		"Following should show assertion fails."
		then: 'then description' 
			code: [ z := 'then set'. 
							self assert: (false).
							 ].
		

]

{ #category : #'self test' }
GivenWhenThen >> test110BasicLog [
	"Test the testcase`s own log"
	| test |
	test := HumSeasideTests new.
	test log: 'This is only a test'.
	self assert: ( (test log at: 1 ) sameAs: 'This is only a test' ).

]

{ #category : #'self test' }
GivenWhenThen >> test120GivenWhenThenLogging [
	"Test the testcase`s own log"
	| test x y z |
	test := self class basicNew.

	"A typical test looks like this."	
	test
		given: 'given description' code: [ x:= 'given set'];
		when: 'when description'  code: [ y := 'when set'];
		then: 'then description' code: [ z := 'then set'. self assert: (true) ].

	"The log should contain the descriptions."
	self assertString: ( test log at: 1 ) includesSubstring: 'given description'.	
	self assertString: ( test log at: 2 ) includesSubstring: 'when description'.	
	self assertString: ( test log at: 3 ) includesSubstring: 'then description'.	
		

]

{ #category : #API }
GivenWhenThen >> then: aDescriptionString code: aBlock [
	"*Then* in a given-when-then triplet 
	-- Use to test post-condition after the given and then have run.
	The code may contain asserts to self-check.
	"
	self log:  ( 'Then: ', aDescriptionString ).
	"Run my assertions."
	aBlock value.
	^self.
	
]

{ #category : #API }
GivenWhenThen >> when: aDescriptionString code: whenBlock [
	"*When* in a given-when-then triplet 
	-- Use to trigger events or add to state.
	The code may contain asserts to self-check.
	"
	"Run the given block to reset to initial state.
	This enables a sequence such as: Given, When, Then, When, Then.
	It allows the When blocks to create contradicting states.
	"
	givenBlock value.
	"Now run my block"
	self log:  ( 'When: ', aDescriptionString, String cr ).
	whenBlock value.
	^self.
	
]
