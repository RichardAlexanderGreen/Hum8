"
see: WACanvasBrushTest for examples of how this test framework is used.

Note: the base methods are copied from Hum-Tests GivenWhenThen

Instance Variables:
	log	<OrderedCollection>
	givenBlock	<Object>
"
Class {
	#name : #GivenWhenThen4Seaside,
	#superclass : #Object,
	#instVars : [
		'log',
		'givenBlock'
	],
	#category : #'Hum-Tests'
}

{ #category : #testing }
GivenWhenThen4Seaside >> assert: aBlock match: aPatternString [ 
	"This is a utility function to improve readability."
	| html |
	html := self builder render: aBlock.
	self
		assert: ( aPatternString match: html )
		description:	'Expected: ', ( aPatternString printString ), ', Actual: ', ( html printString )
		resumable: true.
		
]

{ #category : #testing }
GivenWhenThen4Seaside >> assert: aBlock matches: aPatternString [ 
	"This is a utility function to improve readability."
	| html |
	html := self builder render: aBlock.
	self
		assert: ( aPatternString matches: html )
		description:	'Expected: ', ( aPatternString printString ), ', Actual: ', ( html printString )
		resumable: true.
		
]

{ #category : #API }
GivenWhenThen4Seaside >> assertString: stringA includesSubstring: stringB [
	 " stringB should be a substring in stringA "
	| quote x |
	quote := $' asString.
	x := stringA findString: stringB.
	self assert: (x > 0) description: 'Expecting ', quote, stringA, quote, ' contains ', quote, stringB, quote.
]

{ #category : #'as yet unclassified' }
GivenWhenThen4Seaside >> expect: expectedValue actual: actualValue [ 
	self assert: (expectedValue = actualValue)
	     description: ( 'Expected: ', expectedValue asString,' actual: ', actualValue asString ).
]

{ #category : #API }
GivenWhenThen4Seaside >> given: aDescriptionString code: aBlock [
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
GivenWhenThen4Seaside >> givenWhenThenComment [
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
GivenWhenThen4Seaside >> log [
	^ log ifNil: [ log := OrderedCollection new. ].
]

{ #category : #API }
GivenWhenThen4Seaside >> log: aString [
	| entry |
	"Prepend a CR to make inspection more readable."
	( aString beginsWith: (String cr) )
		ifTrue: [ entry := aString ] ifFalse: [ entry := String cr, aString ].
	( self log ) add: aString.
]

{ #category : #'self test' }
GivenWhenThen4Seaside >> test105GivenWhenThenSuccess [
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
GivenWhenThen4Seaside >> test106GivenWhenThenFail [
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
	self should: [test then: 'should fail' code: [ self assert: false ] ] raise: AssertionFailure.
		

]

{ #category : #'self test' }
GivenWhenThen4Seaside >> test110BasicLog [
	"Test the testcase`s own log"
	| test |
	test := HumSeasideTests new.
	test log: 'This is only a test'.
	self assert: ( (test log at: 1 ) sameAs: 'This is only a test' ).

]

{ #category : #'self test' }
GivenWhenThen4Seaside >> test120GivenWhenThenLogging [
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
GivenWhenThen4Seaside >> then: aDescriptionString code: aBlock [
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
GivenWhenThen4Seaside >> when: aDescriptionString code: whenBlock [
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
