"
Some types of frame lines will contain a statement as part or all of their content.
For example, an instruction line might contain a role prefix, a statement, a comment, and a annotation.

This statement class is meant to provide a set of services for interpreting and analyzing statements.

A statement is simply a sequence of tokens. 
Some of those tokens *must* be nouns. [a]
Otherwise the statement has no data to give it meaning at run-time
  and there is no way for the compiler to check for data continuity.

The requirement that a statement contain at least one noun
creates a hurdle when you want to implement something like:
. Atavar: Smile.   (Compiler will probably flag as having no known nouns)

Here is how to solve that kind of thing:
===
Dictionary: Avatar vocabulary. 
Avatar is a virtual-object. 
Avatar attributes include face, torso, voice. 
Face attributes include eyes, nose, eye-brows, lips, gesture. 
Gesture categories include smile, shrug, frown, surprise.
===
Role: Avatar.

Action: Show gesture.
. (Show smile/frown/shrug/surprise via facial and/or body language.)
===
"
Class {
	#name : #HumStatement,
	#superclass : #Object,
	#instVars : [
		'source',
		'errors',
		'nounValues',
		'jobTicket',
		'role',
		'translation',
		'isSatisfied'
	],
	#category : #'Hum-Language'
}

{ #category : #'instance creation' }
HumStatement class >> from: aSource [
	| newStatement |
	newStatement := self basicNew.
	newStatement source: aSource.
	^newStatement.
]

{ #category : #comparing }
HumStatement class >> isKeyWord: aString [
	| keyWordList answer |
	keyWordList := #( 'if' 'else' 'for' 'each' 'in' 'giving' ).
	answer := ( keyWordList includes: aString ).
	^answer.
]

{ #category : #'instance creation' }
HumStatement class >> source: aSource [
	| |
	^ self from: aSource.
]

{ #category : #comparing }
HumStatement >> = aStatement [ 
	( aStatement isKindOf: String )  ifTrue: [ ^source sameAs: aStatement ].
	( aStatement isKindOf: HumStatement ) ifTrue: [ ^ source sameAs: aStatement source ].
	Error signal: 'HumStatement equality only works for strings and statements.'.
]

{ #category : #translate }
HumStatement >> asCamelCase [ 
	"Convert this statement to camelCase."
	| tokens code   first |
	code := ''.
	first := true.
	tokens := (self source) findTokens: ' ,.-'.
  "Do not inlude articles in the camel case."
	(tokens reject: [:token | #( 'a' 'an' 'the' ) includes: (token asLowercase) ])
		do: [ :token |
				first ifTrue: [ code := code, token asLowercase .
						            first := false.]
					   ifFalse: [ code := code, (token capitalized) ].
			].
	
	^code
]

{ #category : #translate }
HumStatement >> asCamelCaseWithOntology: aHumOntology [ 
	"Convert this statement to camelCase."
	| tokens code   first |
	
	code := ''.
	first := true.
	tokens := (self source) findTokens: ' ,.-'.

	(tokens reject: [:token | #('a' 'an' 'the') includes: token ] )
		do: [ :token |
				first ifTrue: [ code := code, token asLowercase .
						first := false.]
					ifFalse: [ code := code, (token capitalized) ].
			].
	"TODO: Deal with polymorphism by looking up the proper definition.
	Can borrow algorithm from prior version of SimpleEnglish ?
	However, by removing nouns from the camelCase, I could just let Java do the work.
	BAD IDEA: Depending on Java would make the semantics target-language-dependent.
	"
	^code
]

{ #category : #accessing }
HumStatement >> asString [
	^ self source asString.
]

{ #category : #translate }
HumStatement >> delegateToTranslator [
	Error signal: 'This statement function should be delegated to Ontology Translator (HumOntologyTranslator).'


]

{ #category : #accessing }
HumStatement >> errors [
	"SEE >>syntaxError: aString "
	^errors ifNil: [ errors := Set new.].
]

{ #category : #comparing }
HumStatement >> hash [ 
	"This HACK (which may be a bad idea) makes HumStatement hash the same as a matching string.
	It makes set lookup work.
	But maybe it makes some coding error too forgiven.
	"
	^ ( source hash ).
]

{ #category : #accessing }
HumStatement >> isConditional [
	(source beginsWith: 'For ' ) ifTrue: [ ^true ].
	( source beginsWith: 'If ')   ifTrue: [ ^true ].
	( source beginsWith: 'ElseIf ')   ifTrue: [ ^true ].
	( source beginsWith: 'Else:') ifTrue: [ ^true ].
	^false.	
]

{ #category : #'run-time' }
HumStatement >> isSatisfied: aBoolean [ 
	self assert: (aBoolean isKindOf: Boolean ).
	isSatisfied := aBoolean.
]

{ #category : #comparing }
HumStatement >> matchesCandidateStatement: aCandidate inOntology: aHumOntology [
	"Does the candidate match me? (Candidate nouns might be subtypes of my nouns.)"
	| statement candidateTokens myTokens calc |
	calc := HumCalculator new.
	calc cases;
		when: [aCandidate isKindOf: HumStatement] then: [statement := aCandidate ];
		when: [aCandidate isKindOf: String ] then: [ statement := HumStatement from: aCandidate. ];
		otherwise: [ Error signal: 'expecting a statement type'].

	(self source sameAs: statement source ) ifTrue: [^true]. "shortcut"

	"Get tokens minus articles."
	candidateTokens := ( statement tokens ) reject: [ :token | #('a' 'an' 'the') includes: token ] .
	myTokens := ( self tokens ) reject: [ :token | #('a' 'an' 'the') includes: token ] .
	"TODO: Parse allowing for quoted strings."
	( myTokens size = candidateTokens size ) ifFalse: [ ^false ].

	"Is my noun a supertype of the argument`s noun?"
	( 1 to: (myTokens size) )
		do: [ :x |
			| myToken candidateToken |
			myToken := myTokens at: x.
			candidateToken := candidateTokens at: x.
			( myToken sameAs: candidateToken )
				ifTrue: ["continue"]
				ifFalse: [ "Is myToken a noun? If so, see if my token is a supertype"
					( aHumOntology yesNoun: candidateToken isAKindOf: myToken  )
						ifTrue: ["continue"]
						ifFalse: [ ^false ].
						"TODO: A series of nouns (example: entity attribute attribute) matches a single noun. "	
					].
			].
	^ true.	
	
]

{ #category : #comparing }
HumStatement >> matchesTemplateStatement: aStatementTemplate inOntology: aHumOntology [ 
	"Do I match the given template? (My nouns may be subtypes of template nouns)"
	| templateTokens myTokens |
	self assert: ( aStatementTemplate isKindOf: HumStatement ).

	"First try a shortcut."
	( self source sameAs: aStatementTemplate source) ifTrue: [^true].
	"Get tokens minus articles."
	myTokens := ( self tokens ) difference: #('a' 'an' 'the').
	templateTokens := ( aStatementTemplate tokens ) difference: #('a' 'an' 'the').
	( templateTokens size <= myTokens size ) ifFalse: [ ^false ].
	"TODO: Parse statements containing quoted strings."	

	"Is each template noun a supertype of my noun?"
	( 1 to: (templateTokens size) )
		do: [ :x |
			| templateToken myToken |
			templateToken := templateTokens at: x.
			myToken := myTokens at: x.
			( templateToken sameAs: myToken )
				ifTrue: ["continue"]
				ifFalse: [ "Is myToken a noun? If so, see if my token is a supertype"
					( aHumOntology yesNoun: myToken isAKindOf: templateToken  )
						ifTrue: ["continue"]
						ifFalse: [ ^false ].
						"TODO: A series of nouns (example: entity attribute attribute) matches a single noun. "	
					].
			].
	^ true.	
	
]

{ #category : #'run-time' }
HumStatement >> noun: aNoun value: aValueObject [ 
	"Noun values are set at run-time just prior to executing the statement.
	Record the name value pair for this noun.
	(The noun is assumed to be one that appears in the statement source.)
	
	Comment: The noun value is also on the actor`s blackboard. So this might be redundant.
	On the other hand, in any other run-time, the noun would be populated via the calling mechanism. 
	So this is a reasonable simulation.
	
	TODO: Decide how to handle a noun that is an entity. (What does the valueObject argument look like?)
	It could be an identifier. The local blackboard could supply attribute values as needed - with WorldBase as collaborator.
	
	Comment: If an entity is updated after the original job ticket is sent, 
	  it is not obvious whether we should use the old values or the new.
	In general, I think that the new values would be the correct choice.
	However, this may be very situation dependent.
	
	We could move the question to the coder by having exposing 'Blackboard: Synchronize entity.' (API).
	I don't particularly like that solution because the philosophy of Hum is that persistence mechanisms should be transparent.
	However, it does solve the problem.
	"
	self assert: ( aNoun isKindOf: String ).
	self assert: ( aValueObject notNil ).
	( self nounValues ) at: aNoun put: aValueObject.
]

{ #category : #translate }
HumStatement >> nounAsCamelCase: aString [ 
	"Delegate to ontology class"
	^ HumOntology nounAsCamelCase: aString.
]

{ #category : #accessing }
HumStatement >> nounValues [
	"Noun values are set at run-time. 
	Typically, they are found on a blackboard and transcribed as needed.
	Noun values are transcribed to action-call from Agent`s blackboard.
	Noun values are transcribed to goal-call from Dialog blackboard.
	Noun values are transcribed to view-call from Dialog blackboard.
	Noun values are transcribed to view-return message from Scribe blackboard.
	"
	^ nounValues ifNil: [ nounValues := Dictionary new.].
]

{ #category : #translate }
HumStatement >> onMatch: aPatternString do: aBlockClosure [ 
	"When my source matches pattern, execute the block with matching arguments.
	 Use this to parse lines, interpret lines, generate code."
	HumCalculator given: (self source) onMatch: aPatternString do: aBlockClosure.
]

{ #category : #accessing }
HumStatement >> printOn: aStream [
	"Append to the argument, aStream, a sequence of characters that  
	identifies the receiver."

	| title |
	title := self class name.
	aStream
		"nextPutAll: (title first isVowel ifTrue: ['an '] ifFalse: ['a ']);"
		nextPutAll: title;
		nextPutAll: '( ', self source, ' )';
		nextPutAll: String cr.
]

{ #category : #accessing }
HumStatement >> role [
	^role ifNil: [ Error signal: 'role was not set in HumStatement']
]

{ #category : #accessing }
HumStatement >> role: aString [
	"What role is meant to execute this statement?
	If this is an action statement, 
	the Dispatcher will assign execution 
	to an available actor that claims the role at run-time.
	"
	role := aString.
]

{ #category : #comparing }
HumStatement >> sameAs: aHumStatement [ 
	"Return true if receiver is semantically equivalent to (argument) aHumStatement."
	(aHumStatement isKindOf: String)
		ifTrue: [^ (self source) sameAs: aHumStatement ].
	(aHumStatement isKindOf: HumStatement)
		ifTrue: [^ (self source) sameAs: (aHumStatement source) ].
	"TODO: Allow variations in use of 'a' 'an' 'the'.   "	
	"TODO: Allow a cascade of nouns. (example: entity attribute-entity attribute-entity attribute)"
	Error signal: 'argument not of expected type'
]

{ #category : #accessing }
HumStatement >> source [
	^ source ifNil: [ source := '' ].
]

{ #category : #accessing }
HumStatement >> source: aSource [
      "Set and check the source string."
	|  lastCharacter |
	
	"Remember my source string."
	source := '*** SOURCE IS NOT VALID ***'.
	( aSource isKindOf:  String )       ifTrue: [ source := aSource trimBoth.].
	( aSource isKindOf:  HumStatement ) ifTrue: [ source := aSource source.].
	( aSource isKindOf: HumConditionLine ) ifTrue: [ source := aSource source.].	
	self assert:	( source = '*** SOURCE IS NOT VALID ***' ) not.
	source := HumProgrammersAssistant removeCommentFromSource: source.
	"Reset errors."
	errors := Set new. 
	
	"self stripLeader." "Leader is a UI artifact. Not really part of the source."
	source := HumProgrammersAssistant removeLeaderFromSource: source.
	self stripRole. "Check: Source should not contain a role prefix in this context."
	
	(source sameAs: '') 
	   ifTrue: ["Statement may be empty after comment and leader is removed." ^self].
	"Syntax check: A statement ends with a period or a colon."
	lastCharacter :=  ( source at: ( source size )). 
	( lastCharacter = $. ) ifTrue: [^self].
	( lastCharacter = $: ) ifTrue: [^self].
	"Last character was not a period or colon."
	 self syntaxError: 'Statement must end with a period or colon.'.
	
]

{ #category : #parsing }
HumStatement >> stripRole [
	"Source should not contain a role prefix in this context.
	 Signal an error if caller has sent source with role prefix."
	| tokens quote punctuation whitespace |
	whitespace := ' 	
		'.
	whitespace := Character separators.
	quote := $' asString.
	punctuation := '~!@#$%^&*()_+`={}|[]\:";<>?,./', quote.
	"Note: Preserve uppercase in tokens so that first word of a sentence is capitalized."
	tokens := source  findTokens: ( punctuation, whitespace ) keep: punctuation.
	((tokens size > 2) and: [(tokens at: 2) = ':'])
			ifTrue: [ "Found a role label in the source"
				Error signal: 'Found role label in source.'.
				"role := tokens at: 1.
				source := HumCalculator given: source extractAfter: ':'" ].

]

{ #category : #logging }
HumStatement >> syntaxError: anErrorMessage [ 
	"Error signal: anErrorMessage."
	"TODO: Consider this kind of backdoor error logging for Frame Line syntax checking."
	"While it is generally a bad idea to pass data via instance variables, it can simplify some of the parsing code."
	(self errors) add: anErrorMessage.
]

{ #category : #accessing }
HumStatement >> tokens [
	"Return the tokens in the statement as an array of strings."
	|  tokens |

	tokens := HumOntology tokensInString: (self source).
	"WARNING: Hum has a quirk: Accent (`) is used as apostrophe. 
	                    Avoid complication distinguishing uses of single-quote."

	^tokens.
]

{ #category : #accessing }
HumStatement >> translation [
	"How might the statement be translated into another programming language?"
	^translation
]

{ #category : #accessing }
HumStatement >> translation: aString [ 
	"How might the statement be translated into another programming language?"
	translation := aString
]
