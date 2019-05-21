"
A frame line conforms to a specific notation.
For example, a dictionary line conforms to dictionary syntax.

Instance Variables:
	source	<String>
"
Class {
	#name : #HumFrameLine,
	#superclass : #Object,
	#instVars : [
		'source',
		'indentLevel',
		'comment'
	],
	#category : #'Hum-Language'
}

{ #category : #'instance creation' }
HumFrameLine class >> source: aByteString [ 
     | frameLine |
	frameLine := self new.
	frameLine source: aByteString.
	^frameLine.
]

{ #category : #compiling }
HumFrameLine >> checkForAntecedantsIn: aHumStatement withOntology: aHumOntology [
	| antecedants myNouns result |
	antecedants := aHumOntology nounsInStatement: aHumStatement.
	myNouns := aHumOntology nounsInStatement: self statement.
	result := OrderedCollection new.
	(antecedants includesAll: myNouns)
		ifTrue: [ ^ result ].
	(myNouns copyWithoutAll: antecedants)
		do:
			[ :noun | result add: 'The noun: "' , noun , '" has no antecedant.' ].
	^ result
]

{ #category : #compiling }
HumFrameLine >> checkSyntaxWithOntology: aHumOntology [ 
	|  nouns errors  |
	errors := OrderedCollection new.
	nouns := aHumOntology nounsInStatement: (self statement).
	(nouns isEmpty ) 
		ifTrue: [ errors add:( 'Statement { ', self statement source ,' } has no known nouns!' ) ].
	^ errors.
]

{ #category : #accessing }
HumFrameLine >> comment [
	"Any frame line can have a comment."
	^comment ifNil: [comment := ''].
]

{ #category : #accessing }
HumFrameLine >> comment: aString [
	"Any frame line can have a comment."
	| test |
	aString ifNil: [comment := nil. ^self].
	test := HumCalculator given: aString extractIncludingMatching: '()'.
	(test isNil)
		ifTrue: [comment := aString]
		ifFalse: [comment := HumCalculator given: test extractBetween: '(' and: ')'].
		
]

{ #category : #compiling }
HumFrameLine >> compileLineToOntology: aHumOntology [ 
	"Compile this instruction line."
	| errors | 
	"Subtypes should implement."
	"Error signal: 'Subtypes should implement.'."
	errors := OrderedCollection new.
	^ errors.
]

{ #category : #parsing }
HumFrameLine >> doTokensIn: input at: x matchPatternTokensIn: patternTokens at: xPattern [
	"See if we can get any matching sequence."
	"TODO: Everything in this method category should probably be in HumOntologyTranslator."
	| pToken atParameter isMatch |
	isMatch := false.
	"If we run out of pattern, we have succeeded."
	( xPattern > (patternTokens size) ) ifTrue: [ ^true ].
	"If we run out self before we run out of pattern, we have failed."
	( x > ( input size ) ) ifTrue: [^false].
	"A pattern token that is a digit will match anything. 
	 Proceed to next token in both lists.
	 But if there is no match there, the pattern token could still match the next self token, so try that.
	"
	pToken := patternTokens at: xPattern.
	atParameter := ( ( ( pToken size = 1) and: [ pToken isAllDigits ] ) ).
	atParameter
			ifTrue: [ isMatch := (self doTokensIn: input at: (x + 1) matchPatternTokensIn: patternTokens at: (xPattern + 1) )
								      or: [self doTokensIn: input at: (x + 1) matchPatternTokensIn: patternTokens at: (xPattern + 0 ) ].
						^isMatch. 
					].
	"Remainder assumes that current pattern token is NOT a digit."				
	self assert: (  atParameter not  ).
	"If the current pattern token matches the current self token, proceed to the next token in both lists."
	( ( patternTokens at: xPattern ) sameAs: ( input at: x ) )
			ifTrue: [ "Proceed to next token in both lists"
						isMatch := self doTokensIn: input at: (x + 1) matchPatternTokensIn: patternTokens at: (xPattern + 1).
					    ^isMatch 
					]
			ifFalse: [ "See if the next token in self matches the pattern token"
						isMatch := self doTokensIn: input at: (x + 1) matchPatternTokensIn: patternTokens at: (xPattern + 0).
						^isMatch. ].		
	"At this point we have a mismatch for sure. (I think maybe.)"
	isMatch := false.			
	^isMatch.
]

{ #category : #parsing }
HumFrameLine >> extractNounsInBrackets [
	"Vignette pattern lines and response lines may contain nouns in brackets."
	| wip nounReferences calc |
	nounReferences := OrderedCollection new.
	calc := HumCalculator new.
	wip := self source.	
	[  '*[*]*' match: wip ]
		whileTrue: [ 
			| between before after | 
			between := calc given: wip extractBetween: '[' and: ']'.
			before := calc given: wip extractUpto: '['.
			after  := calc given: wip extractAfter: ']'.
			wip := after.
			( '* *' match: between )
				ifFalse: [  nounReferences add: between ]
				ifTrue: [  "Add entity and attribute separately"
					| entityNoun attributeNoun |
					entityNoun := calc given: between extractUpto: ' '.
					attributeNoun := calc given: between extractAfter: ' '.
					nounReferences add: entityNoun.
					nounReferences add: attributeNoun.
					].
			].
		"TODO: Add capability to deal with [link: page-name] and [page: URL | text] widgets."
	^nounReferences .
]

{ #category : #parsing }
HumFrameLine >> extractPatternParameters: aPatternString [ 
	"Extract parameters (tokens) from source that match the pattern."
	| parameters patternTokens selfTokens isMatch |
	
	self assert: ( aPatternString isKindOf: String ).
	patternTokens := self getTokensIn: ( aPatternString asLowercase ).  
	selfTokens := self getTokensIn: ( self source asLowercase ).
	"Search to see if a sequence in my tokens matches a sequence in pattern tokens."
	isMatch := self doTokensIn: selfTokens at: 1 matchPatternTokensIn: patternTokens at: 1.
	
	isMatch ifFalse: [ Error signal: 'Attempt to get parameters when pattern does not match.' ].

	parameters := OrderedCollection new.
	self getParametersIn: selfTokens at: 1 thatMatchParametersIn: patternTokens at: 1 accumulating: parameters.

	^ parameters reversed.
]

{ #category : #parsing }
HumFrameLine >> generateCodeFrom: aTemplateString using: parameterValues [ 
	"Generate code (string) from the template replacing parameters with values in the parameter list."
	"TODO: Does this method belong in HumOntologyTranslator ?"
	| templateTokens code  |
	self assert: ( aTemplateString isKindOf: String ).
	self assert: ( parameterValues isKindOf: OrderedCollection ).
	code := String new.
	templateTokens := self getTokensIn: aTemplateString.
	templateTokens 
		do: [ :token | "For each token:"
			| atParameter |
			atParameter := ( ( ( token size = 1 ) and: [ token isAllDigits ] ) ).
			atParameter
				ifTrue: [ code := code, ( parameterValues at:  ( token asNumber ) ).  ]
				ifFalse: [ code := code, token ].
			].
	^code.
]

{ #category : #parsing }
HumFrameLine >> getParametersIn: input at: x thatMatchParametersIn: patternTokens at: xPattern accumulating: parameters [
	"See if we can get any matching sequence."
	| pToken atParameter  isMatch parameter |
	isMatch := false.
	 parameter := nil.
	"If we run out of pattern, we have succeeded."
	( xPattern > (patternTokens size) ) ifTrue: [ ^true ].
	"If we run out self before we run out of pattern, we have failed."
	( x > ( input size ) ) ifTrue: [^false].
	"A pattern token that is a digit will match anything. 
	 Proceed to next token in both lists.
	 But if there is no match there, the pattern token could still match the next self token, so try that.
	"
	pToken := patternTokens at: xPattern.
	atParameter := ( ( ( pToken size = 1) and: [ pToken isAllDigits ] ) ).
	atParameter
			ifTrue: [ isMatch := (self getParametersIn: input at: (x + 1 ) thatMatchParametersIn: patternTokens at: (xPattern + 1 ) accumulating: parameters )
								   or: [self getParametersIn: input at: (x + 1 ) thatMatchParametersIn: patternTokens at: (xPattern + 0 ) accumulating: parameters ].
					    isMatch ifTrue: [ parameters add: ( input at: x ) ].	
					  ^isMatch.
					].
	"Remainder assumes that current pattern token is not a parameter."				
	self assert: ( atParameter not ).
	"If the current pattern token matches the current self token, proceed to the next token in both lists."
	( ( patternTokens at: xPattern ) sameAs: ( input at: x ) )
			ifTrue: [ "Proceed to next token in both lists"
						isMatch := self getParametersIn: input at: (x + 1) thatMatchParametersIn:patternTokens at: (xPattern + 1) accumulating: parameters.
					    ^isMatch 
					]
			ifFalse: [ "See if the next token in self matches the pattern token"
						isMatch := self getParametersIn: input at: (x + 1) thatMatchParametersIn:patternTokens at: (xPattern + 0) accumulating: parameters.
						^isMatch. ].		
	"At this point we have a mismatch for sure. (I think maybe.)"
	isMatch := false.			
	^isMatch.
]

{ #category : #parsing }
HumFrameLine >> getTokensIn: aString [
	"This is a helper for #matchesPattern: (). It implements a Hum-friendly tokenizer."
	"TODO: Does this method belong in HumOntologyTranslator ?  It also might be in HumCalculator."

	| punctuation whiteSpace tokens |
	"Punctuation does not include hyphen because nouns may be hypenated."
	punctuation := '~!@#$%^&*()_+`={}|[[]\:";<>?,./'. 

	"White space includes space, cr, tab."	
	whiteSpace := ' 	
		'.

	"Tokens are all lower-case and include punctuation."
	tokens := ( aString asLowercase ) findTokens: ( punctuation, whiteSpace ) keep: (punctuation, whiteSpace).
	
	^tokens.
]

{ #category : #parsing }
HumFrameLine >> matchesPattern: aPatternString [ 
	"Does some part of the frame-line match the given pattern?"
	| patternTokens selfTokens isMatch |
	self assert: ( aPatternString isKindOf: String ).
	patternTokens := self getTokensIn: ( aPatternString asLowercase ).  
	selfTokens := self getTokensIn: ( self source asLowercase ).
	"Search to see if a sequence in my tokens matches a sequence in pattern tokens."
	isMatch := self doTokensIn: selfTokens at: 1 matchPatternTokensIn: patternTokens at: 1. 
	^isMatch.
]

{ #category : #parsing }
HumFrameLine >> onMatch: aPatternString generate: aTemplateString [ 
	"When some part of the content in the current line matches the pattern,
	 - Generate code from the template.
	 - Replace parameters indicated by digits with corresponding values in the parameter array.
	"
	| code parameters |
	self assert: ( aPatternString isKindOf: String ).
	self assert: ( aTemplateString isKindOf: String ).
	"If there is no match, there is nothing to do. Return an empty string."
	code := String new.
	( self matchesPattern: aPatternString ) ifFalse: [ ^code ].
	"Otherwise, we have a match.
	Generate some code.
	"
	parameters := self extractPatternParameters: aPatternString.
	code := self generateCodeFrom: aTemplateString using: parameters.
	^code.
]

{ #category : #rendering }
HumFrameLine >> printOn: aStream [
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

{ #category : #compiling }
HumFrameLine >> sameAs: anotherFrameLine [
	(anotherFrameLine isKindOf: String)
		ifTrue: [^ (self source) sameAs: anotherFrameLine.].
	(anotherFrameLine isKindOf: HumFrameLine )
		ifTrue: [^ ( self source ) sameAs: ( anotherFrameLine source ).].
	"Eh? Why are we here?"
	Error signal: 'unexpected type'.
	
]

{ #category : #accessing }
HumFrameLine >> source [
	^ source
]

{ #category : #accessing }
HumFrameLine >> source: aString [ 
	self assert: ( aString isKindOf: String ).
	source := aString.
	"Any frame line might have a comment between ()."
	self comment: (HumCalculator given: source extractIncludingMatching: '()').
"	(self comment size > 0)
		ifTrue: [ self statement: (HumCalculator given: source extractUpto: '(' ). ]
		ifFalse: [ self statement: aString ]."
	
]
