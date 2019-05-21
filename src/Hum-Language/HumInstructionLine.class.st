"
An instruction line may occur in 
 an action frame, 
 a plan-frame action section, 
 or in a dialog vignette as part of the response to a stimulus.

Here is a sample instruction line:
. Oven: Preheat to temperature. (The oven will emit a ding when the required temperature is reached.)  [duration: 5 minutes]

This line has a role (Oven) to which the action is delegated.
It has a statement: 'Preheat to temperature.' 
The action request with the value of the 'temperature' noun will be sent to the actor assigned to the role.
It has a comment -- within by round parentheses.
It has an annotation -- within square brackets.

Instance Variables:
	indent	<Integer>
	role	<String>
	statement	<HumStatement>
	comment	<String>
	annotation	<String>
	translation	<String>
		
	""TODO: Kludge some polymorphism.
	 TODO: Fix-up string arguments""	

"
Class {
	#name : #HumInstructionLine,
	#superclass : #HumFrameLine,
	#instVars : [
		'indent',
		'role',
		'statement',
		'annotation',
		'translation',
		'problems',
		'jobTicket'
	],
	#category : #'Hum-Language'
}

{ #category : #'Instance creation convenience' }
HumInstructionLine class >> role: aRole statement: aSourceString [  
	"Return an instance with given source, role, and comment."
	| instruction |
	instruction := self new.
	instruction 
		statement: aSourceString; 
		role: aRole.
	^instruction.
]

{ #category : #'Instance creation convenience' }
HumInstructionLine class >> role: aRole statement: aSourceString annotation: anAnnotation [
	"Return an instance with given  role, source, and annotation."
	| instruction |
	instruction := self new.
	instruction role: aRole; statement: aSourceString;  annotation: anAnnotation.
	^instruction.
]

{ #category : #'Instance creation convenience' }
HumInstructionLine class >> role: aRole statement: aSourceString  comment: aComment [
	"Return an instance with given source, role, and comment."
	| instruction |
	instruction := self new.
	instruction  role: aRole;  statement: aSourceString; comment: aComment.
	^instruction.
]

{ #category : #'instance creation' }
HumInstructionLine class >> statement: aSourceString [ 
	"Return an instance with given source."
	| instruction |
	instruction := self new.
	instruction statement: aSourceString.
	^instruction.
	
]

{ #category : #accessing }
HumInstructionLine >> = anInstruction [
	"??? Looks like bad code ???  "
	( anInstruction isKindOf: String) ifTrue: [ ^ statement = anInstruction ].
	( anInstruction isKindOf: HumInstructionLine ) ifTrue: [ ^ statement = ( anInstruction statement ) ].
	"Find out where this is used.  (2015-12-26: None of the unit tests trip over this halt.)"
	self halt.
]

{ #category : #accessing }
HumInstructionLine >> annotation [
	^ annotation ifNil: [^'' ].
]

{ #category : #accessing }
HumInstructionLine >> annotation: aString [ 
	"Annotation may indicate timing for simulations. 
	[native] indicates that the statement should be native to the agents that implement the role.
	When a statement is [native], the critique should not expect an definition in the current ontology.
	"
	annotation := aString.
]

{ #category : #compiling }
HumInstructionLine >> checkSyntaxWithOntology: aHumOntology [ 
	|  errors |
	Error signal: 'In this context, call "checkSyntaxWithOntology: aHumOntology defaultRole: aRole"  instead.'.
	errors := OrderedCollection new.
	^ errors.
]

{ #category : #compiling }
HumInstructionLine >> checkSyntaxWithOntology: aHumOntology defaultRole: aRole [
	|  nouns errors theRole |
	errors := OrderedCollection new.
	"Forgive a nil statement. Sometimes an instruction line has no statement."
	statement ifNil: [^errors].
	"Ignore empty statement"
	(statement source trimBoth  =  '' ) ifTrue: [ ^errors ].
	"Check that the nouns in the statement are known. (defined in the ontology)."
	nouns := aHumOntology nounsInStatement: statement.
	( nouns isEmpty ) 
		ifTrue: [ errors add: ( 'Statement: {', statement source ,'} has no known nouns!' ) ].
	
	"Check that a delegated action is defined in the ontology."
	theRole := self role.
	( theRole = '') ifTrue: [ theRole := aRole ].
	( aHumOntology isActionDefined: self inRole: theRole ) 
		ifFalse: [ errors add: ('Action: {', statement source, '} has not been defined.') ].
	
	^ errors.
]

{ #category : #accessing }
HumInstructionLine >> comment [
	^ comment ifNil: [''].
]

{ #category : #accessing }
HumInstructionLine >> comment: aString [ 
	"Comment is not executable. May be displayed in certain contexts."
	comment := aString.
]

{ #category : #compiling }
HumInstructionLine >> compileLineToOntology: aHumOntology [ 
	"Compile this instruction line."
	| errors | 
	"Check syntax"
	errors := self checkSyntaxWithOntology: aHumOntology defaultRole: (self role).
	"remember the errors - May show in HTML and other views"
	problems := errors.
	^ errors.
]

{ #category : #compiling }
HumInstructionLine >> compileLineToOntology: aHumOntology defaultRole: aRole [
	"Compile this instruction line."
	| errors | 
	"TODO: Kludge some polymorphism.
	 TODO: Fix-up string arguments"	

	"Check syntax"
	errors := self checkSyntaxWithOntology: aHumOntology defaultRole: aRole.
	"remember the errors - May show in HTML and other views"
	problems := errors.
	^ errors.
]

{ #category : #accessing }
HumInstructionLine >> indent [
	"How many indents (tabs) before the start of the code-text ?"
	^ indent ifNil: [ indent := 1 ].
]

{ #category : #accessing }
HumInstructionLine >> indent: aSmallInteger [
	"How many indents (tabs) before the start of the code-text ?"
	indent := aSmallInteger.
	(indent < 1 ) ifTrue: [ indent := 1].

]

{ #category : #'job ticket' }
HumInstructionLine >> jobTicket [
	"There should be a job ticket if the (run-time) caller expects one."
	^ jobTicket ifNil: [ Error signal: 'no jobTicket']
]

{ #category : #'job ticket' }
HumInstructionLine >> jobTicket: aJobTicket [
	"At run-time, a job ticket may be associated with action request."
	self assert: ( aJobTicket isKindOf: HumJobTicket ).
	jobTicket := aJobTicket.
	"TODO: This instance variable is here because the run-time needs to pass a jobTicket when delegating an instruction. (?)
			I think there is something wrong in that calling logic. See: ???"
]

{ #category : #compiling }
HumInstructionLine >> onComment: aBlockClosure [ 
	"If instruction includes a comment, execute the block."
	comment ifNil: [^self].
	(comment size > 1 ) ifTrue: aBlockClosure.
]

{ #category : #compiling }
HumInstructionLine >> onRole: aBlockClosure [ 
	"If instruction includes a role prefix, execute the block."
	role ifNil: [^self ].
	(role size > 1) ifTrue: aBlockClosure.
]

{ #category : #accessing }
HumInstructionLine >> role [
	"What role am I delegating to? If none, the instruction is to myself."
	^ role  ifNotNil: [ (role) ] ifNil: ['']. 
	"TODO: Consider returning #self instead of an empty string."
]

{ #category : #accessing }
HumInstructionLine >> role: aString [ 
	"Delegate the task (statement) to this role at run-time. "
	role := aString.
]

{ #category : #accessing }
HumInstructionLine >> source [
	"Construct a source line based on convention and content of my attributes."
	| s |
	s := self statement asString.
	(self role trimBoth isEmpty ) ifFalse: [ s :=( role,': ', s ) ].
	(self comment trimBoth isEmpty) ifFalse: [ s := s,' (', ( self comment ), ') ' ].
	(self annotation trimBoth isEmpty) ifFalse: [ s := s, ' [', ( self annotation ), '] ' ].
	source ifNil: [ source := s. ].
	^ s. 
]

{ #category : #accessing }
HumInstructionLine >> source: aString [
	"Should not be: 'Action:' block-label."
	self assert: (aString beginsWith: 'Action:') not.
	^super source: aString.
]

{ #category : #accessing }
HumInstructionLine >> statement [
	"What will be done . . . will be done at run-time."
	^ statement 
			ifNil: [ "FIX UP !!!"
				source ifNil: [Error signal: 'Blank instruction line.'].
				statement := HumStatement source: source.
				].
]

{ #category : #accessing }
HumInstructionLine >> statement: aSource [ 
	"What to do  at run-time?"
	| x |

	( aSource isKindOf: String ) 
		ifTrue: [ "Convert to HumStatement"
			| sourceString |
			sourceString := aSource.
			x := 0.
			[ sourceString beginsWith: '. ' ] 
				whileTrue: [ "Count the indents."
					x := x + 1.
					sourceString := sourceString copyFrom: 3 to: (sourceString size).
					].
			statement := HumStatement from: sourceString. 
			"Determine the indent level."
			self indent: x.
			^self.
			].
	( aSource isKindOf: HumStatement )
		ifTrue: ["Copy the Statement."
			statement := aSource copy.
			self indent: 1.
			^self. ].
	self assert: ( statement notNil ).
	
]

{ #category : #accessing }
HumInstructionLine >> title [
	^ self titleLine.
]

{ #category : #accessing }
HumInstructionLine >> titleLine [
	^ ( self role), ': ', ( self statement asString ).
]

{ #category : #accessing }
HumInstructionLine >> translation: aString [ 
	translation := aString.
]
