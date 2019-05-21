"
A precondition line occurs in a plan frame's preconditions section.
As a matter of style, it should be stated as an assertion or declaration. (Present tense descript of the required state of the system.)
A precondition line may contain a statement with an optional comment and/or annotation.

Here is an example:
___
Post:  . . .
Pre:
. All necessary ingredients are on-hand. 	(In the local kitchen) 	[assumed]

The comment is within round parentheses.
The annotion is withing square brackets.

Instance Variables:
	statement	<HumStatement>
	comment	<ProtoObject>
	annotation	<ProtoObject>
"
Class {
	#name : #HumConditionLine,
	#superclass : #HumFrameLine,
	#instVars : [
		'statement',
		'annotation'
	],
	#category : #'Hum-Language'
}

{ #category : #comparing }
HumConditionLine >> <= aHumConditionLine [ 
	"Provide a way to order preconditions
	so that we get repeatable sequences when running a plan."
	^(self source) <= (aHumConditionLine source)
]

{ #category : #accessing }
HumConditionLine >> annotation [
	^ annotation ifNil: [ '' ].
]

{ #category : #accessing }
HumConditionLine >> annotation: aString [ 
	"Annotation may indicate that condition is 'assumed'.  Other cases are not yet defined."
	self assert: (aString sameAs: 'assumed').
	annotation := aString.
]

{ #category : #compiling }
HumConditionLine >> checkSyntaxWithOntology: aHumOntology [ 
	|  nouns errors correspondingPlanFrame |

	errors := OrderedCollection new.
	statement := HumStatement from: (self statement).
	nouns := aHumOntology nounsInStatement: statement.
	( nouns isEmpty ) 
		ifTrue: [ errors add:( 'Precondition {" ', statement source, ' "} has no known nouns!' ) ].
	
	"Is the precondition assumed?"
	( ( self annotation ) sameAs: 'assumed' ) ifTrue: [ ^errors ].
	
	"Otherwise: See if we have a plan for satisfying this precondition."
	correspondingPlanFrame := aHumOntology getPlanFrameForGoal: statement.
	"NOTE: #getPlanFrameForGoal: will return an empty plan frame  if there is none in the ontology. 
	Also, the ontology might contain an empty frame. 
	In either case, an empty frame is not a usable subplan.
	"
	( correspondingPlanFrame isNoPlan ) 
		ifTrue: [ errors add:  'Precondition {" ', statement source, ' "} has no plan.'].
	^errors.
]

{ #category : #accessing }
HumConditionLine >> comment [
	^ comment ifNil: [ '' ].
]

{ #category : #compiling }
HumConditionLine >> compileLineToOntology: aHumOntology [ 
	"compile a precondition line into the ontology.
	Update where-used.
	"
	| problems |
	problems := self checkSyntaxWithOntology: aHumOntology.
	^problems.
]

{ #category : #accessing }
HumConditionLine >> source [
	| s |
	s := self statement asString.
	(self comment isEmpty) ifFalse: [ s := s, ( self comment ) ].
	(self annotation isEmpty) ifFalse: [ s := s, ( self annotation ) ].
	^ s. 
]

{ #category : #accessing }
HumConditionLine >> source: aString [
	"DEBUG: Should not be 'Precondition' or: 'Pre'"
	self assert: (aString asLowercase beginsWith: 'pre') not.
	^super source: aString.
]

{ #category : #accessing }
HumConditionLine >> statement [
	
	^ statement ifNil: [ '' ].
]

{ #category : #accessing }
HumConditionLine >> statement: aSource [ 
	"Set my statement."
	statement := nil.
	( aSource isKindOf:  String ) ifTrue: [ statement := HumStatement from: aSource ].
	( aSource isKindOf: HumStatement ) ifTrue: [ statement := aSource ].
	self assert: ( statement isKindOf: HumStatement ).
	
]
