"
HumTestCase provides some syntax ""sugar"" on TestCase.

TODO: Write test suite for HumTextCase itself.  ;~)
"
Class {
	#name : #HumTestCase,
	#superclass : #TestCase,
	#instVars : [
		'ensureBlock',
		'eventSeen'
	],
	#category : #'Hum-Tests'
}

{ #category : #asserting }
HumTestCase >> assert: stringA sameAs: stringB [ 
	self assert: (stringA sameAs: stringB)
	     description: ( 'Expecting: ', stringA ,' sameAs: ', stringB ).
]

{ #category : #asserting }
HumTestCase >> assertPattern: stringPattern matches: string [ 
	self assert: ( stringPattern match: string ) 
		description: ( 'Result should match pattern: {',stringPattern,'}').
		
]

{ #category : #ensure }
HumTestCase >> ensure [
	"I think this belongs under HClientServerTests"
	ensureBlock ifNotNil: [ ensureBlock value ].
]

{ #category : #ensure }
HumTestCase >> ensureBlock: aBlock [
	"I think this belongs under HClientServerTests"
	
	ensureBlock := aBlock.
]

{ #category : #events }
HumTestCase >> eventSeen [
	^ eventSeen ifNil: [ eventSeen := 'No value was preset.' ]
]

{ #category : #events }
HumTestCase >> eventSeen: anObject [ 
	"Set my one-shot memory of the last event seen."
	eventSeen := anObject.
]

{ #category : #asserting }
HumTestCase >> expect: expectedValue actual: actualValue [ 
	(expectedValue isKindOf: Float)
		ifTrue: [ ^self assert: (expectedValue closeTo: actualValue) 
			description: ( 'Expected: ', expectedValue asString,' actual: ', actualValue asString ). 
			].
	(expectedValue isKindOf: String)
		ifTrue: [  | expected actual |
			expected := expectedValue trimBoth.
			actual := actualValue asString trimBoth.
			^self assert: (( expected compare: actual caseSensitive: true ) = 2)
	     			description: ( 'Expected: ', expected ,' actual: ', actual  ).
			].
	((expectedValue isKindOf: Array) and: [ (expectedValue size > 0) and: [ (expectedValue at: 1) isKindOf: Association] ])
		ifTrue: [ "If expected value is an array of associations, compare as sets"
			^self assert: (expectedValue asSet) = (actualValue asSet)
				description: 'Expecting arrays to match as sets'.
			 ].
	( expectedValue isKindOf: Point )
		ifTrue: [  "Relax equality slightly"
			^self assert: ( ( (expectedValue x) closeTo: (actualValue x) ) and: [ ( (expectedValue y) closeTo: (actualValue y) )] )
						description: 'Expecting points to coincide'.
			].
	self assert: ( expectedValue = actualValue  )
	     description: ( 'Expected: ', expectedValue asString,' actual: ', actualValue asString ).
]

{ #category : #asserting }
HumTestCase >> expect: expectedValue actual: actualValue description: aDescription [ 
	(expectedValue isKindOf: Float)
		ifTrue: [ ^self assert: (expectedValue closeTo: actualValue) 
			description: ( 'Expected: ', expectedValue asString,' close to actual: ', actualValue asString, ' - ', aDescription ).
			].
	self assert: (expectedValue = actualValue)
	     description: ( 'Expected: ', expectedValue asString,' actual: ', actualValue asString, ' - ', aDescription ).
	
]

{ #category : #asserting }
HumTestCase >> pattern: stringPattern matches: string [ 
	self assert: ( stringPattern match: string ) 
		description: ( 'Result should match pattern: {',stringPattern,'}').
		
]

{ #category : #ensure }
HumTestCase >> signal [
	"I think method this belongs under HClientServerTests"
	self ensure.
	super signal.
]

{ #category : #events }
HumTestCase >> update: anObject [
	"This is called by event handler."
	self eventSeen: anObject
]
