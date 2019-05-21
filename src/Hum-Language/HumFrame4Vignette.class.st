"
A dialog contains a set of contexts.
A context contains a set of vignettes.
A vignette defines a stimulus and a response.
The stimulus is a prioritized set of patterns which will be matched against client statements.
When a pattern is matched the response is executed.
The response may include a speech and/or a short set of instructions.

Dialog instructions are addressed to the dialog-agent unless specified otherwise with a role-prefix.
The role/label ""Goal:"" invokes a Coordinator with the indicated plan goal.
The prefix: ""Avatar:"" sends an action via the Scribe to an avatar, if any.
Delegating a Goal is not blocking, but all other actions are assumed to be blocking. (The Dialog Agent and/or scribe mediates delegated actions - so this is under programmer control.)

The dialog agent maintains a 'stack' of contexts.
The contexts nearest the top of the stack have priority when attempting to match client statements.
The stack is generally ordered with the most recently used contexts nearest the top.
A dialog vignette may command that another context be placed at the top in order to switch contexts.

In general, dialogs are organized by the same principles as ALICE chat bots.

Instance Variables:
	vignetteContext	<Collection | UndefinedObject>
	responseLines	<OrderedCollection>
	instructionLines	<OrderedCollection>
	nextContext	<Collection | UndefinedObject>
	pattern	<Collection | UndefinedObject>
"
Class {
	#name : #HumFrame4Vignette,
	#superclass : #HumFrame,
	#instVars : [
		'vignetteContext',
		'responseLines',
		'instructionLines',
		'nextContext',
		'patterns'
	],
	#category : #'Hum-Language'
}

{ #category : #'instance creation' }
HumFrame4Vignette class >> ontology: aHumOntology vignetteContext: aContextString pattern: aPatternString [ 
	| frame |
	self assert: ( (aPatternString isKindOf: String) or: [ aPatternString isNil ]  ).
	frame := self new.
	frame ontology: aHumOntology;
        vignetteContext: aContextString;
        addPattern: aPatternString.
	frame titleLine: 'Context: ', aContextString, ' Pattern: ', aPatternString asString.
	^frame. 
		
]

{ #category : #accessing }
HumFrame4Vignette >> addPattern: aPatternString [ 
	"Enter a pattern -- What pattern will the vignette respond to?"
	"Nil is ignored when parser is running."
	aPatternString ifNil: [^self].
	
	(self patterns) add: aPatternString trimBoth.
]

{ #category : #accessing }
HumFrame4Vignette >> addVignetteInstruction: anInstructionLine [ 
	"Append an instruction to be executed in response to the user / client."
	| instruction |
	( anInstructionLine isKindOf: HumInstructionLine )
		ifTrue: [ instruction := anInstructionLine ]
		ifFalse: [ | role stmt |
			"check for role"
			role := HumProgrammersAssistant getLabelFromSource: anInstructionLine.
			stmt := HumProgrammersAssistant removeLabelFromSource: anInstructionLine.
			instruction := ( HumInstructionLine role: role statement: stmt).].
	
	(self instructionLines ) add: instruction.
	(self frameLines ) add: instruction.
]

{ #category : #accessing }
HumFrame4Vignette >> addVignettePattern: patternString [ 
	"Append an Pattern to be matched in response to the user / client."
	|  |
	(self patterns ) add: patternString.
	(self frameLines ) add: (HumVignettePatternLine source: ('U: ',patternString)).
]

{ #category : #accessing }
HumFrame4Vignette >> addVignetteResponse: aResponseString [ 
	"Append a verbal response line."
	| markup |
	markup :=  ( HumMarkupLine source: aResponseString ).
	self responseLines add: markup.
	self frameLines add: (HumVignetteResponseLine source: ('S: ', aResponseString)).
]

{ #category : #testing }
HumFrame4Vignette >> checkSyntaxWithOntology: anOntology [
	"Check the vignette for syntax problems."
	| critique patternCritique nouns |
	"First get the critique of the frame lines."
	critique := OrderedCollection new.
	( self frameLines )
		do: [ :frameLine | 
			| lineErrors |
			( frameLine isKindOf: HumInstructionLine )
				ifTrue: [lineErrors := (frameLine checkSyntaxWithOntology: anOntology defaultRole: 'DialogAgent').]
				ifFalse: [lineErrors := (frameLine checkSyntaxWithOntology: anOntology).].
			(lineErrors isEmpty) ifFalse: [ critique := critique, lineErrors ].
			].
	patternCritique := OrderedCollection new.
	
	"The vignette must have a context and a pattern."
	( vignetteContext isEmptyOrNil  ) ifTrue: [ critique add: 'Vignette has no context!' ].
	( patterns isEmptyOrNil ) ifTrue: [ critique add: 'Vignette has no pattern!' ].	
		
	"The nextContext should be known to the ontology.
	NOTE: This assumes that a Frame4Vignette contains a single vignette.
	"
	(( anOntology vignettesForContext: ( self nextVignetteContext ) ) isEmpty )
		 ifTrue: [ critique add: 'Vignette`s next context {',( self nextVignetteContext ),'} is unknown in ontology. ' ].
	
	"Each [noun] field  in the pattern should reference known nouns."
	nouns := self patternNouns.
	nouns 
		do: [ :noun | 
			(anOntology isNoun: noun) 
				ifFalse: [ patternCritique add: 'Vignette pattern references unknown noun: ', noun.]  
			].
	
	critique := critique, patternCritique.
	
	^critique.
]

{ #category : #testing }
HumFrame4Vignette >> compileToOntology: anOntology [
	"Update the ontology with this vignette."
	| |
	"Make sure frame is stored."		"<<< TODO: why is this needed?"
	anOntology storeFrame: self.
	
	anOntology addVignette: self toContext: (self vignetteContext trimBoth ).
	
	"Index any external action calls."
	( self instructionLines )
		do: [ :instructionLine |
			( instructionLine role = '' )
				ifFalse: [ "(ontology frameRelations) add: { (self title). #invokesAction. ( instructionLine title ).}. "
						ontology indexFrame: self relation: #invokesAction object: (instructionLine title)]
				ifTrue: ["Index 'Show view' and 'Ask view' cases."
					| sourceString |
					sourceString := instructionLine statement source.
					(sourceString beginsWith: 'Ask') "Ask for attribute values via the given view."
						ifTrue: [ |viewName|
							viewName := (HumCalculator given: sourceString extractBetween: 'Ask' and: '.') trimBoth asLowercase.
							ontology indexFrame: self relation: #invokesView object: viewName. 
							].
					(sourceString beginsWith: 'Show') "Show (read-only) attribute values via the given view."
						ifTrue: [ |viewName|
							viewName := (HumCalculator given: sourceString extractBetween: 'Show' and: '.') trimBoth asLowercase.
							ontology indexFrame: self relation: #invokesView object: viewName. 
							].
					(sourceString beginsWith: 'New') "Create a new entity in the dialog blackboard."
						ifTrue: [ |entityName|
							entityName := (HumCalculator given: sourceString extractBetween: 'New' and: '.') trimBoth asLowercase.
							ontology indexFrame: self relation: #creates object: entityName. 
							].
						
					(sourceString beginsWith: 'Push context') "Place given context on top of context-stack."
						ifTrue: [ |contextName|
							contextName := (HumCalculator given: sourceString extractBetween: 'Push context' and: '.') trimBoth asLowercase.
							ontology indexFrame: self relation: #invokesContext object: contextName. 
							].
					].
			].
	
	^ ( self checkSyntaxWithOntology: anOntology ) .
]

{ #category : #parsing }
HumFrame4Vignette >> inputToken: inputToken isEquivalentTo: patternToken [
	"Is the input equivalent to the pattern?
	Allow for common synonyms.
	" 
	| calc patternLC inputLC |
	"Simple case."
	(inputToken sameAs: patternToken) ifTrue: [^true].
	
	"Handle tricky pattern tokens."
	
	calc := HumCalculator new.
	patternLC := patternToken asLowercase.
	inputLC := inputToken asLowercase.
	calc cases;
		when: [ patternLC = '.' ]    then: [ ^(inputLC = '!') ];
		when: [ patternLC = 'hello'] then: [ ^(#('hi' 'hey' 'howdy') includes: inputLC) ];
		otherwise: [^false].
]

{ #category : #parsing }
HumFrame4Vignette >> inputTokensIn: aString [
	"Return the pattern tokens in the given string."
	| tokens |
	tokens := HumCalculator findTokensInString: aString.
	tokens := HumCalculator removeNoiseWordTokensFrom: tokens.
	
	"Extract strings in the input as separate tokens."
	"TODO: Numbers followed by measurement units should be treated as a single token."
	(tokens include: '"')
		ifTrue: [| correctedTokens collecting string |
			correctedTokens := OrderedCollection new.
			string := String new.
			collecting := false.
			tokens do: [:token |
				 ( collecting or: [token = '"']) 
						ifFalse: [ correctedTokens add: token ]
						ifTrue: [
							string := string, token.
							(collecting and: [token = '"'] ) 
								ifTrue: [ correctedTokens add: string. collecting := false. ]
								ifFalse: [collecting := true.]
							]
				].
			tokens := correctedTokens.
			].
	^tokens. 
	
]

{ #category : #accessing }
HumFrame4Vignette >> instructionLines [
	"Return the vignette's instruction lines. "
	^ instructionLines ifNil: [ instructionLines := OrderedCollection new. ].
]

{ #category : #accessing }
HumFrame4Vignette >> nextVignetteContext [
	"By default, the next context is the current context."
	( nextContext isEmptyOrNil )  ifTrue: [ nextContext := vignetteContext ].
	^ nextContext.
]

{ #category : #accessing }
HumFrame4Vignette >> nextVignetteContext: aContextName [ 
	"What will be the context after the response is rendered?
	The context stack prioritizes responses to otherwise identical user patterns.
	NOTE: This assumes that vignette frame contains a single set of patterns and a single response.
	"
	nextContext := aContextName.
]

{ #category : #accessing }
HumFrame4Vignette >> patternFields: pattern [
	"Parse the pattern and return the [noun] fields - including the brackets.
	TODO: DOES THIS BELONG IN HumVignettePatternLine"
	| fields s field |
	fields := OrderedCollection new.
	s := self pattern.
	self assert: ( s isKindOf: String ).

	[ field := HumCalculator given: s extractBetween: '[' and: ']'.  ( field size > 0 )  ]
		whileTrue: [  fields add: ( '[', field, ']' ). 
						s := HumCalculator given: s extractAfter: ']'.
					 ].

	^fields.
	
]

{ #category : #evaluating }
HumFrame4Vignette >> patternMatchScore: aString [
	"How well does the string (from client) match the pattern int this vignette?
	Score a point for each token matched in order.
	TODO: DOES THIS BELONG IN HumPatternLine?
	"
	| points bestPatternPoints calc |
	
	calc := HumCalculator new.

	points := 0.
	bestPatternPoints := 0.
	
	"But first, one pattern has to match. Then we score it."
	( self patterns )
		do: [:pattern |
			| patternTokens inputTokens  xInput xPattern |
			self assert: [ pattern isKindOf: String ].
			
			"These parsers remove noise words (a, an, the)."
			patternTokens := (self patternTokensIn: pattern).
			inputTokens   := (self inputTokensIn: aString).
			
			"Attempt to match input to pattern."
			xInput := 1.
			xPattern := 1.
			points := 0.
			[ (xPattern <= patternTokens size ) and: [xInput < (inputTokens size)] ]
				whileTrue: [ "For each pattern token"
						|  patternToken inputToken |
						patternToken := patternTokens at: xPattern.
						inputToken := inputTokens at: xInput.
						calc cases;
						when: [patternToken = '*']
						then: ["Match everything upto next pattern token"
								| nextPatternToken xNextInput  |
								nextPatternToken := patternTokens at: (xPattern + 1).
								"Does the remaining input have the next pattern token?
								If not, we are done scoring. 
								"
								"xNextInput := inputTokens indexOf: nextPatternToken startingAt: xInput ifAbsent: [ -1 ]."
								xNextInput := 0.
								(1 to: inputTokens size) 
									do: [:i | ( (i >= xInput)  
										          and: [ self inputToken: (inputTokens at: i) isEquivalentTo: nextPatternToken]) 
															ifTrue: [xNextInput := i]
									 		].
								( xNextInput = 0 )
									ifTrue: ["Match fails. Force to next pattern."
										points := 0.  "TODO:  No credit for partial match?"
										xPattern := 9999.
										]
									ifFalse: ["Matching so far. Continue to next pattern token."
										xInput := xNextInput.
										xPattern := xPattern + 1.
										points := points + 1.
										].
								
								];
						when: [ patternToken = '[' ]
						then: ["Assign the next inputToken to the noun named between [...]"
								| xNextPattern | 
								
								
								"For now, assume the next input token matches the bracket expression."
								points := points + 1.
								
								"Advance the pattern token index to the closing bracket."
								"A missing bracket should have been caught at compile-time."
								xNextPattern := patternTokens indexOf: ']' startingAt: xPattern 
							                                               ifAbsent: [Error signal: 'no closing bracket?'].
								xPattern := xNextPattern + 1.
								patternToken := patternTokens at: xPattern.
								"Advance the input to the next pattern token."
								xInput := inputTokens indexOf: patternToken ifAbsent: [ inputTokens size + 1 ].
								(xInput <= inputTokens size) ifTrue: [points := points + 1 ].
							  
								];
						when: [self inputToken: inputToken isEquivalentTo: patternToken]
						then:["Increment the score"
								points := points + 1.
								];
						otherwise: ["The input token does not match the pattern."
								"Force out to the next pattern."
								points := 0.
								xPattern := 9999.
								].
						xInput := xInput + 1.	
						xPattern := xPattern + 1.	
						((xInput > inputTokens size) and: [ xPattern <= patternTokens size ])
							ifTrue: ["We ran out of input before we ran out of pattern."
								"Partial match does not score."
								points := 0.
								"Force out to the next pattern."
								xPattern := 9999.
								].	
					]. "Each token"
				 ( points > bestPatternPoints ) ifTrue: [ bestPatternPoints := points ].
			]. "Each pattern"
	^ bestPatternPoints.
]

{ #category : #evaluating }
HumFrame4Vignette >> patternNouns [
	"TODO: DOES THIS BELONG IN HumVignettePatternLine ?"
	| nouns |
	nouns := Set new.
	( self patterns )
		do: [ :pattern |
			nouns := nouns addAll: (self patternNouns: pattern ).
			].
	^ nouns.
]

{ #category : #accessing }
HumFrame4Vignette >> patternNouns: pattern [
	"Parse the pattern and return the nouns referenced in [noun] fields. 
	When the pattern is recognized, the noun value will be placed on the dialog's blackboard.'
	TODO: DOES THIS BELONG IN HumVignettePatternLine?
	"
	| fields s field |
	fields := OrderedCollection new.
	s := pattern.
	self assert: ( s isKindOf: String ).

	[ field := HumCalculator given: s extractBetween: '[' and: ']'.  ( field size > 0 )  ]
		whileTrue: [  fields add: (  field ). 
						s := HumCalculator given: s extractAfter: ']'.
					 ].

	^fields.
	
]

{ #category : #parsing }
HumFrame4Vignette >> patternTokensIn: aString [ 
	"Return the pattern tokens in the given string.
	WARNING: Uppercase is preserved.
	TODO: DOES THIS BELONG IN HumVignettePatternLine?
	"
	| tokens |
	tokens := HumCalculator findTokensInString: aString.
	tokens := HumCalculator removeNoiseWordTokensFrom: tokens.
	^tokens.

]

{ #category : #accessing }
HumFrame4Vignette >> patterns [
	^ patterns ifNil: [ patterns := OrderedCollection new ].
]

{ #category : #accessing }
HumFrame4Vignette >> responseLines [
	"What will be the verbal response? "
	^ responseLines ifNil: [ responseLines := OrderedCollection new. ].
]

{ #category : #accessing }
HumFrame4Vignette >> titleLine [
	| s |
	self patterns isEmpty
		ifTrue: [s := 'Context: "', ( vignetteContext asString), '" pattern: "nil"'.]
		ifFalse: [s := 'Context: "', ( vignetteContext asString), '" pattern: "', ( (patterns at: 1) asString ),'"'.].
	
	^s.
]

{ #category : #accessing }
HumFrame4Vignette >> vignetteContext [
	"The context is used to prioritize responses when two or more patterns match a user input.
	It also provides a category seen when viewing the collection of vignettes.
	"
	( vignetteContext isEmptyOrNil ) ifTrue: [ Error signal: 'A vignette context is missing.'].
	^ vignetteContext
]

{ #category : #accessing }
HumFrame4Vignette >> vignetteContext: aContextString [ 
	"The context is used to prioritize responses when two or more patterns match a user input.
	It also provides a category seen when viewing the collection of vignettes.
	"
	vignetteContext := aContextString. 
]

{ #category : #evaluating }
HumFrame4Vignette >> zpatternMatchScore: aString [
	"How well does the string (from client) match the pattern int this vignette?
	Score a point for each token matched in order.
	"
	| points bestPatternPoints  |

	points := 0.
	bestPatternPoints := 0.
	
	"(aString beginsWith: 'My name is') ifTrue: [self halt]." "DEBUG"
	
	"But first, one pattern has to match. Then we score it."
	( self patterns )
		do: [:pattern |
			| patternTokens inputTokens  xInput xPattern |
			self assert: [ pattern isKindOf: String ].
			
			"Remove noise words and punctuation"
			patternTokens := (self patternTokensIn: pattern).
			inputTokens   := (self inputTokensIn: aString).
			
			"Attempt to match input to pattern."
			xInput := 1.
			xPattern := 1.
			points := 0.
			[ xPattern <= patternTokens size ]
				whileTrue: [ "For each pattern token"
						| continue patternToken inputToken |
						continue := true.
						patternToken := patternTokens at: xPattern.
						(patternToken = '*') 
							ifTrue: ["Match everything upto next pattern token"
								| nextPatternToken xNextInput  |
								nextPatternToken := patternTokens at: (xPattern + 1).
								"Does the remaining input have the next pattern token?
								If not, we are done scoring. 
								"
								xNextInput := inputTokens indexOf: nextPatternToken startingAt: xInput ifAbsent: [ -1 ].
								( xNextInput < 0 )
									ifTrue: ["Match fails. Force to next pattern."
										points := 0.  "TODO:  No credit for partial match?"
										xPattern := 9999.
										continue := false.
										]
									ifFalse: ["Matching so far. Continue to next pattern token."
										xInput := xNextInput.
										xPattern := xPattern + 1.
										points := points + 1.
										].
								
								continue := false.
								].
						(continue and: [ patternToken = '[' ])
							ifTrue: ["Assign the next inputToken to the noun named between [...]"
								| xNextPattern | 
								
								"TODO: HOW SHOULD WE INTERPRET THIS?
								Will we assign the next input to the noun value
								or require the next input to match the noun value?
								TODO: HOW SHOULD WE SCORE THIS?
								"
								"For now, assume the next input token matches the bracket expression."
								"Advance the pattern token index to the closing bracket."
								xNextPattern := patternTokens indexOf: ']' startingAt: xPattern ifAbsent: [Error signal: 'no closing bracket?'].
								xPattern := xNextPattern.
								points := points + 1.
								continue := false.
								].
						inputToken := inputTokens at: xInput.
						
						(continue and: [self inputToken: inputToken isEquivalentTo: patternToken])
							ifTrue: ["Increment the score"
								points := points + 1.
								continue := false.
								].	
						(continue)
							ifTrue: ["The input token does not match the pattern."
								"Force out to the next pattern."
								points := 0.
								xPattern := 9999.
								].
						xInput := xInput + 1.	
						xPattern := xPattern + 1.	
						((xInput > inputTokens size) and: [ xPattern <= patternTokens size ])
							ifTrue: ["We ran out of input before we ran out of pattern."
								"Force out to the next pattern."
								points := 0.
								xPattern := 9999.
								].	
					]. "Each token"
				 ( points > bestPatternPoints ) ifTrue: [ bestPatternPoints := points ].
			]. "Each pattern"
	^ bestPatternPoints.
]
