"
The Calculator role (agent) provides 
- base level arithmetic (using measures)
- string utilities used to parse Hum source code.

The Calculator provides compute operations.
When a Hum procedure (or Hum Run-Time) 
needs an interface to the host computer, 
the Calculator provides it.

See also: HumMeasure. 
-- In the Hum framework, all numbers are measures.

See also: HumFuzzy.
-- HumFuzzy provides arithmetic on S-curve distributions.

TODO: Integrate HumMeasure and HumCalculator.

"
Class {
	#name : #HumCalculator,
	#superclass : #Object,
	#instVars : [
		'priorCaseIsTrue',
		'indentString',
		'testValue',
		'priorIndent'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'string utilities' }
HumCalculator class >> camelCase: aString [ 
	| words result |
	result := String new.
	words := self justTheWordsIn: aString.
	words do: [ :word | result := result, word capitalized. ].
	^result.
]

{ #category : #'string utilities' }
HumCalculator class >> diffCandidate: stringA againstIdeal: stringB showing: nTokens [
	"Find the first token that is different, ignoring differences in whitespace.
	Show nTokens on each side of first difference to provide context.
	"
	| tokensA tokensB whitespace i tokenA diffA diffB |
	whitespace := Character separators.
	tokensA := stringA findTokens: whitespace "keep: whitespace".
	tokensB := stringB findTokens: whitespace "keep: whitespace".
	
	"Drive with the ideal string."
	i := 1.
	tokensB detect: [ :tokenB |
		tokenA := tokensA at: i.
		i := i + 1.
		( tokenA sameAs: tokenB ) not.
		]
		ifNone: [^'no difference'].
	
	"Come here with i set to place where first difference is seen."
	diffA := ''.
	(tokensA copyFrom: (i-nTokens max: 1) to: (i+nTokens min: (tokensA size))) 
		do: [:token | diffA := diffA, token, ' ' ].
	
	diffB := ''.
	(tokensB copyFrom: (i-nTokens max: 1) to: (i+nTokens min: (tokensB size))) 
		do: [:token | diffB := diffB, token, ' ' ].
	
	HumTestCase new expect: diffB actual: diffA.
	
	
]

{ #category : #parsing }
HumCalculator class >> doTokensIn: input at: xInput matchPatternTokensIn: pattern at: xPattern [
	"See if we can get any matching sequence."
	| pToken atParameter isMatch |
	isMatch := false.
	"If we run out of pattern, we have succeeded."
	( xPattern > (pattern size) ) ifTrue: [ ^true ].
	"If we run out self before we run out of pattern, we have failed."
	( xInput > ( input size ) ) ifTrue: [^false].
	"A pattern token that is a digit will match anything. 
	 Proceed to next token in both lists.
	 But if there is no match there, the pattern token could still match the next self token, so try that.
	"
	pToken := pattern at: xPattern.
	atParameter := ( ( ( pToken size = 1) and: [ pToken isAllDigits ] ) ).
	atParameter
			ifTrue: [ isMatch := (self doTokensIn: input at: (xInput + 1) matchPatternTokensIn: pattern at: (xPattern + 1))
								   or: [self doTokensIn: input at: (xInput + 1) matchPatternTokensIn: pattern at: (xPattern + 0 ) ].
						^isMatch. 
					].
	"Remainder assumes that current pattern token is NOT a digit."				
	self assert: (  atParameter not  ).
	"If the current pattern token matches the current self token, proceed to the next token in both lists."
	( ( pattern at: xPattern ) sameAs: ( input at: xInput ) )
			ifTrue: [ "Proceed to next token in both lists"
						isMatch := self doTokensIn: input at: (xInput + 1) matchPatternTokensIn: pattern at: (xPattern + 1).
					    ^isMatch 
					]
			ifFalse: [ "See if the next token in self matches the pattern token"
						isMatch := self doTokensIn: input at: (xInput + 1) matchPatternTokensIn: pattern at: (xPattern + 0).
						^isMatch. ].		
	"At this point we have a mismatch for sure. (I think maybe.)"
	isMatch := false.			
	^isMatch.
]

{ #category : #parsing }
HumCalculator class >> doesString: aString matchPattern: aPattern [
	"Match the string against the pattern, return true/false"
	| inputTokens patternTokens result |
	inputTokens := self findTokensInString: aString.
	patternTokens := self findTokensInString: aPattern.
	result := self doTokensIn: inputTokens at: 1 matchPatternTokensIn: patternTokens at: 1.
	^result.
]

{ #category : #parsing }
HumCalculator class >> findTokensAndConstantsInString: aString [
	"CODE EXPERIMENT - Where a string-delimiter is seen, consolidate quoted-string into a single token.
	See also: HumCalculatorTests>>test310parse"
	| tokenList resultingTokens mode doubleQuote calc whitespace singleQuote quoteDelimiter punctuation |
	"TODO: TEST as is."
	"TODO: Parse statements containing numbers for measurements, money, counts."
	"CONVENTION: measurement := number, space, unit-of-measure."
	"CONVENTION: count := number, space, plural-noun."
	"TODO: Decide if language should include proper nouns (i.e. names) (as a type or kind of constant)."
	resultingTokens := OrderedCollection new.
	calc := self new.
	doubleQuote := $" asString.
	singleQuote := $' asString.
	quoteDelimiter := singleQuote.
	whitespace := Character separators.
	punctuation := '~!@#$%^&*()_+`={}|[]\:";<>?,./', singleQuote.
	mode := #normal.
	tokenList := aString  findTokens: ( punctuation, whitespace ) keep: (punctuation, whitespace).
	tokenList do: [ :tokenIn |
		| tokenOut |
		calc cases;
			when: [ mode = #normal and: [tokenIn = quoteDelimiter ] ] 
				then: [ mode := #string. tokenOut := quoteDelimiter. ];
			when: [ mode = #string and: [tokenIn = quoteDelimiter ] ] 
				then: [ mode := #normal. tokenOut := tokenOut, quoteDelimiter. resultingTokens add: tokenOut ];
			when: [ mode = #string ] 
				then: [ tokenOut := tokenOut, tokenIn ];
			when: [ mode = #normal ] 
				then: [ resultingTokens add: tokenIn ];
			otherwise: [  Error signal: 'Logic error'. ].
		 ].
	( mode = #string ) ifTrue: [ Error signal: 'String started but not terminated.' ].
	"WARNING: resultingTokens may include whitespace."
	^resultingTokens.
]

{ #category : #parsing }
HumCalculator class >> findTokensInString: aString [
	"Parse the given string to return lexical units (words and punctuation).
	Note: Upper Case is preserved."
	| whitespace quote punctuation tokens apostrophe |
	whitespace := ' 	
		'.
	quote := $' asString.
	apostrophe := $` asString.
	punctuation := '~!@#$%^&*()_+={}|[]\:";<>?,./', quote. ", apostrophe."
	"Note: Hyphen is not considered punctuation. Enable hyphenated nouns."
	"Note: Apostrophe is included in tokens so that possessive form of noun (recipe`s) and contraction (can`t)  are treated as a single word. "
	"WARNING: Hum has a quirk: Accent (`) is used as apostrophe. Avoid complication distinguishing uses of single-quote."
	
	tokens := aString  findTokens: ( punctuation, whitespace ) keep: punctuation.
	^tokens.

]

{ #category : #'string utilities' }
HumCalculator class >> given: stringIn extractAfter: stringA [ 
	"Get the substring that is between the two given."
	| x1 stringOut s |
	s := stringIn.
	stringOut := ''.
	x1 := s findString: stringA startingAt: 1.
	(x1 > 0 ) 
		ifTrue: [ stringOut := stringIn copyFrom: (x1 + stringA size) to: (stringIn size). 
			 ].
	^stringOut.
]

{ #category : #'string utilities' }
HumCalculator class >> given: stringIn extractBetween: stringA and: stringB [
	"Get the substring that is between A and B."
	| temp result |
  temp := HumCalculator given: stringIn extractAfter: stringA.
	result := HumCalculator given: temp extractUpto: stringB.
	^result.
]

{ #category : #'string utilities' }
HumCalculator class >> given: aString extractIncludingMatching: pairString [
	"Return substring between balanced pair -- or nil if there is no such pattern.
	s = 'this is before [[blah]] this is after'.
	self assert: ( HumCalculator given: s betweenMatching: '[]' ) = '[[blah]]'.
	 "
	| startPos pos nestLevel pairStart pairStop |
	pairStart := pairString at: 1.
	pairStop  := pairString at: 2.
	self assert: (pairStart isKindOf: Character ).
	self assert: (pairStop isKindOf: Character ).
	"Find the start of the substring."
	startPos := aString indexOf: pairStart.
	"TODO: If there is no starting character, what should we return?"
	(startPos > 0 ) 
		ifFalse: [ ^nil ].
	"Following assumes we have found the starting position."
	self assert: startPos > 0.
	pos := startPos + 1.
	nestLevel := 1.
	[ pos <= aString size ] whileTrue: [
		| aCharacter |
		aCharacter := aString at: pos.
		( aCharacter = pairStart ) 
			ifTrue: [ nestLevel := nestLevel + 1 ].
		( aCharacter = pairStop )  
			ifTrue: [ nestLevel := nestLevel - 1 ].
		(nestLevel = 0) 
			ifTrue: [ |result| result := ( aString copyFrom:startPos to: pos ). ^result. ].
		pos := pos + 1.
	].
	"If we come here, the matching closing character is missing."
	Error signal: 'String does not contain a balanced pair: ', pairString.
	^nil.
]

{ #category : #'string utilities' }
HumCalculator class >> given: stringIn extractUpto: stringA [ 
	"Get the substring that is between the two given."
	| x1 stringOut s |
	self assert: (stringA isKindOf: String).
	self assert: (stringIn isKindOf: String).
	s := stringIn.
	stringOut := ''.
	x1 := s findString: stringA startingAt: 1.
	(x1 > 0 ) ifTrue: [ stringOut := stringIn copyFrom: 1 to: (x1-1).  ].
	^stringOut.
]

{ #category : #parsing }
HumCalculator class >> given: inputString onMatch: aPatternString do: aBlockClosure [ 
	"When the inputString matches pattern, execute the block with matching arguments.
	 Use this to parse lines, interpret lines, generate code."
	| match whitespace punctuation quote myTokens patternTokens xMe xPattern arguments myToken patternToken list |
	"Parse me and the pattern."
	whitespace := Character separators.
	quote := $' asString.
	punctuation := '~!@#$%^&*()_+`={}|[]\:";<>?,./', quote.
	
	myTokens := inputString asLowercase  findTokens: ( punctuation, whitespace ) keep: punctuation.
	patternTokens := aPatternString asLowercase  findTokens: ( punctuation, whitespace ) keep: punctuation.
	"Quick test: Exit if the first token does not match."
	myToken := myTokens at: 1.
	patternToken := patternTokens at: 1.
	(            ( myToken sameAs: patternToken ) 
	or: [ '123456789*' includesSubString: patternToken ] ) "TODO: Match measurement pattern."
		ifFalse: [^self ].
	"Looks like the first word matches, go on."
	xMe := 1.
	xPattern := 0.
	arguments := OrderedCollection new.
	match := false.
	patternTokens 
		do: [ :token | "For each pattern token:"
			patternToken := token.
			match := false.
			xPattern := xPattern + 1.
			( '123456789' includesSubString: patternToken )
				ifTrue: [ "Current token is an argument"
					arguments add: (myTokens at: xMe). 
					match := true.
					].
			( patternToken = '*' )
				ifTrue: ["This only works when the next pattern token is also downstream in myTokens"
					((myTokens copyFrom: xMe+1 to: myTokens size ) includes: ( patternTokens at: xPattern + 1))
						ifFalse: [ ^self ]
						ifTrue: ["Next argument is a list"
							| stopper |
							stopper := ( patternTokens at: xPattern + 1).
							list := OrderedCollection new.
							[ (myTokens at: xMe) sameAs: stopper ] 
								whileFalse: [ 
									( #( ',' 'and' ) includes: (myTokens at: xMe)  )
									 	ifFalse: [list add: (myTokens at: xMe).].
					 
									xMe := xMe + 1. 
									].
							arguments add: list.
							"At this point we have to jump to the conclusion and exit the outer-do."
							"*** TODO *** This logic will only work for lists that are at the end of the statement, but not in the middle."
							aBlockClosure valueWithArguments: arguments.
							^self.
							].
						].
			( patternToken sameAs: ( myTokens at: xMe ) )	
					ifTrue: ["myToken matches a keyword. Proceed to next token."
						match := true.].		
			match ifTrue: [ xMe := xMe + 1 ] 
					ifFalse: ["Got to here with no match. But allow for dropped 'a', 'an', 'the', 'this', 'that'. "				
							    ( #('a' 'an' 'the' 'this' 'that' ) includes: patternToken )	
					                        ifFalse: [^self]
					              ].		
			].
	"If we've gotten this far, the pattern matched and we have zero or more arguments."	
	( arguments size = 0 )
		ifTrue: [ aBlockClosure value ]
		ifFalse: [ aBlockClosure valueWithArguments: arguments ].
	^self.
	
]

{ #category : #'string utilities' }
HumCalculator class >> given: input replaceAll: old with: new [ 
	| s before after|
	s := input.
	[ ('*',old,'*') match: s ]
		whileTrue: ["Replace old with new"
			before := self given: s extractUpto: old.
			after  := self given: s extractAfter: old.
			s := before,new,after.
			].
	^s.
]

{ #category : #'string utilities' }
HumCalculator class >> justTheWordsIn: aString [
	"Return just the words.
	Simplify an English string by removing the words 'the', 'a', 'an'.
	Also, remove puncturation.
	Note: Returns lowercase tokens.
	"
	| tokens words delimiters whiteSpace |
	whiteSpace := String space, String tab, String cr.
	delimiters := whiteSpace, '~!@#$%^&*()_+`={}|[]\:";<>?,./', ($' asString).
	tokens := (aString asLowercase) findTokens: delimiters.
	"Filter out 'the' 'a' 'an' 
	(punctuation is already filtered by findTokens)"
	words := OrderedCollection new.
	tokens
		do: [:token |
			| skipWord |
			skipWord := false.
			skipWord := (token = 'the') | (token = 'a') | (token = 'an'). 
			skipWord
				ifFalse: [ words add: token ].
			].
	^ words.
]

{ #category : #parsing }
HumCalculator class >> parse: aString [
	"Parse into { token. type. start. stop. }"
	| sequence |
	sequence := OrderedCollection new.
	self parse: aString startingAt: 1 appendTokenTo: sequence.
	^sequence.
	
]

{ #category : #parsing }
HumCalculator class >> parse: aString startingAt: start appendTokenTo: sequence [
	"Parse into { token. type. start. stop. }"
	|  whitespace separators quotes quote doubleQuote isWhiteSpace isSeparator tests type isQuote priorQuote alphabet isAlphabet isQuotedText mode currentCharacter stop lex |
	self assert: (sequence isKindOf: OrderedCollection).
	self assert: (start > 0).
	"Terminate if start is greater than aString."
	(start > aString size) ifTrue: [^self].
	"Set up terminal token definitions."
	whitespace := ' 	
		'.
	quote := ($' asString).
	doubleQuote := ($" asString).
	quotes := quote, doubleQuote.
	priorQuote := quote.
	separators := '~!@#$%^&*()_+`={}|[]\:;<>?,./'.
	alphabet := 'qwertyuiopasdfghjklzxcvbnm1234567890-'.
	
	"Side-effect sets type in detect:[]"
	isWhiteSpace := [ :ch | type := #whitespace. whitespace includes: ch ].
	isSeparator  := [ :ch | type := #separator.  separators includes: ch ].
	isAlphabet   := [ :ch | type := #word.       alphabet includes: (ch asLowercase)].
	isQuote      := [ :ch | type := #quote.      quotes includes: ch ].
	isQuotedText := [ :ch | type := #string.    ( priorQuote = ch ) not ].	
		
	tests := { isWhiteSpace. isSeparator. isAlphabet. isQuote. isQuotedText. }.
	"mode is determined by the starting character"
	currentCharacter := aString at: start.
	mode := tests detect: [ :test | test value: currentCharacter.].
	( type = #quote ) 
		ifTrue: [ mode := isQuotedText. priorQuote := currentCharacter. ].
	"The next lex is string starting with current character that matches mode test."
	(start = aString size) 
		ifTrue:  [stop := start ]
		ifFalse: [ |x|
			x := ( (start+1) to: (aString size) ) 
								detect: [ :iCharacter | (mode value: (aString at: iCharacter)) not ].
			(mode = isQuotedText) ifTrue: [ stop := x ] ifFalse: [ stop := x - 1 ].			 
			].
	lex := aString copyFrom: start to: stop .
	sequence add: { lex. type. start. stop. }.
	"Call self recursively"
	self parse: aString startingAt: (stop + 1) appendTokenTo: sequence.
	

]

{ #category : #parsing }
HumCalculator class >> removeNoiseWordTokensFrom: inputTokens [
	| outputTokens |
	outputTokens := inputTokens reject: [:token | #('a' 'an' 'the') includes: token].
	^outputTokens. 
	
]

{ #category : #'string utilities' }
HumCalculator class >> string: stringA isLike: stringB [ 
	"Compare ignoring differences in whitespace."
	| result |
	result := self string: stringA isLike: stringB ignore: (Character separators).
	^result.
]

{ #category : #'string utilities' }
HumCalculator class >> string: stringA isLike: stringB ignore: charactersToIgnore [
	"Compare ignoring differences in whitespace."
	| result compactA compactB|
	compactA := stringA asLowercase  reject: [:ch | (charactersToIgnore includes: ch ) ].
	compactB := stringB asLowercase  reject: [:ch | (charactersToIgnore includes: ch ) ].
	result := compactA sameAs: compactB.
	^result.
]

{ #category : #'string utilities' }
HumCalculator class >> writeString: aString toFileNamed: aFileName [
	"Write the given string to given file - overwrite the previous content."
	| store stream |
	store := HumStore defaultStore .
	stream := store writeStreamOnFileNamed:  aFileName. 
	stream nextPutAll: aString.
	stream close.
]

{ #category : #'case statement cascade' }
HumCalculator >> cases [
	"Initialize case cascade.
	Usage:
	calculator cases;
		 when: [ block returning boolean] then: [ some action];
		 when: [ block returning boolean] then: [ some action];
		 otherwise: [ action if all the when-blocks are false ].
	See also:
		object caseOf: {value->block. value->block.} otherwise: [action if no value matches]
		"
	priorCaseIsTrue := false.
	
]

{ #category : #parsing }
HumCalculator >> doTokensIn: input at: xInput matchPatternTokensIn: pattern at: xPattern [
	| result |
	result := self class doTokensIn: input at: xInput matchPatternTokensIn: pattern at: xPattern.
	^result.
]

{ #category : #xml }
HumCalculator >> exdent [
	"Remove a tab from the global indent string."
	indentString := priorIndent ifNil: [ Error signal: 'priorIndent not set' ].
	
]

{ #category : #'string utilities' }
HumCalculator >> fillTemplate: template fromDictionary: dictionary [
	"Create a String based on the given template and parameters."
	| result |
	result := template.
	[ result includesSubString: '@']
		whileTrue: ["Replace the first parameter with its value"
			| front back name value delimiters |	
			front := self given: result extractUpto: '@'.
			back := self given: result extractAfter: '@'.
			"Get and remove the name of the parameter"
			delimiters := '	
				 ~!@#$%^&*()_+`-=[]\{}|:";<>?,./'''.
			name := (back substrings: delimiters ) at: 1.
			"Insert the value of the parameter"
			value := dictionary at: name.
			self assert: (value isKindOf: String ).
			back := self given: back extractAfter: name.
			result := front, value, back.
			].
	^result.
]

{ #category : #'string utilities' }
HumCalculator >> given: sourceString extractAfter: stringA [ 
	"Return the substring in the sourceString between the two."
	| result |
	result := HumCalculator given: sourceString extractAfter: stringA.
	^result.

]

{ #category : #'string utilities' }
HumCalculator >> given: input extractAfterSecond: marker [ 
	"Parse cases like matching quotes or markup emphasis."
	| wip result |
	wip := self given: input extractAfter: marker.
	result := self given: wip extractAfter: marker.
	^result.
]

{ #category : #'string utilities' }
HumCalculator >> given: sourceString extractBetween: stringA and: stringB [
	"Return the substring in the sourceString between the two."
	| result |
	result := HumCalculator given: sourceString extractBetween: stringA and: stringB.
	^result.

]

{ #category : #'string utilities' }
HumCalculator >> given: sourceString extractUpto: stringA [ 
	"Return the substring in the sourceString between the two."
	|   result |
	result := HumCalculator given: sourceString extractUpto: stringA.
	^result.

]

{ #category : #'string utilities' }
HumCalculator >> given: inputString onMatch: aPatternString do: aBlockClosure [ 
	"When the inputString matches pattern, execute the block with matching arguments.
	 Use this to parse lines, interpret lines, generate code."
	self class given: inputString onMatch: aPatternString do: aBlockClosure 
]

{ #category : #'string utilities' }
HumCalculator >> given: input replaceAll: old with: new [ 
	|result|
	result := self class given: input replaceAll: old with: new.
	^result. 
]

{ #category : #'string utilities' }
HumCalculator >> given: s topic: aTopic doOnce: aBlock [
	"Use this to produce subheadings."
	(s = (self topicDictionary at: aTopic ifAbsent: '') ) 
		ifFalse: [ aBlock value: aTopic value: s.
			self topicDictionary at: aTopic put: aTopic.
			].

	
]

{ #category : #xml }
HumCalculator >> indent [
	"Append a tab to the global indent string."
	priorIndent := indentString ifNil: [''].
	indentString := indentString, String tab.
	
]

{ #category : #'string utilities' }
HumCalculator >> indentLevel: n [ 
	"Reset the indent level. Produce indent string (tabs)."
	self assert: (n isKindOf: Integer ).
	indentString := String new.
	(1 to: n) do: [:i | indentString := indentString, String tab.].

]

{ #category : #accessing }
HumCalculator >> initialize [
	indentString := String new.
]

{ #category : #parsing }
HumCalculator >> justTheWordsIn: aString [
	^self class justTheWordsIn: aString.
]

{ #category : #'case statement cascade' }
HumCalculator >> on: aValue do: aBlockClosure [ 
	( testValue = aValue ) 
		ifTrue: [ priorCaseIsTrue := true. 
			aBlockClosure value ].
]

{ #category : #'case statement cascade' }
HumCalculator >> otherwise: thenBlock [
	"If a prior case was true, ignore this case. 
	 Otherwise, execute this block."	
	( self priorCaseIsTrue ) ifTrue: [ ^self ].
	"otherwise"
	thenBlock value.
	^self.
	
]

{ #category : #parsing }
HumCalculator >> parse: aString [
	"Parse into { token. type. start. stop. }"
	| sequence |
	sequence := self class parse: aString.
	^sequence.
	
	
	
]

{ #category : #'case statement cascade' }
HumCalculator >> priorCaseIsTrue [
	^ priorCaseIsTrue ifNil: [priorCaseIsTrue := false ].
]

{ #category : #parsing }
HumCalculator >> scoreCandidate: candidateString againstPattern: patternString [
	"Return a score indicating the number of tokens that match." 
	| candidateTokens patternTokens commonTokens |
	self assert: (candidateString isKindOf: String).
	self assert: (patternString isKindOf: String).
	
	"Parse."
	candidateTokens := HumCalculator justTheWordsIn: candidateString.
	patternTokens := HumCalculator justTheWordsIn: patternString.
	commonTokens := candidateTokens intersection: patternTokens.
	^commonTokens size.
	
	
]

{ #category : #'string utilities' }
HumCalculator >> string: stringA isLike: stringB [ 
	"Compare ignoring differences in whitespace."
	^self class string: stringA isLike: stringB. 

]

{ #category : #'string utilities' }
HumCalculator >> string: aString isLike: aString2 ignore: aString3 [ 
	^self class string: aString isLike: aString2 ignore: aString3.
]

{ #category : #'case statement cascade' }
HumCalculator >> switch: aCharacter [ 
	self testValue: aCharacter.
]

{ #category : #'case statement cascade' }
HumCalculator >> testValue: anObject [ 
	testValue := anObject
]

{ #category : #'case statement cascade' }
HumCalculator >> when: whenBlock then: thenBlock [
	"If the whenBlock evaluated to true, execute the thenBlock."
	| |
	"If a prior case was true, ignore this case."	
	( self priorCaseIsTrue ) ifTrue: [ ^self ].
	"If the when block is true"
	( whenBlock value ) 
		ifTrue: [ 
			priorCaseIsTrue := true. 
			thenBlock value ].
	^self.
	
]

{ #category : #xml }
HumCalculator >> xml: aTagString dictionary: aDictionaryOrList [ 
	"Create a stand-alone tag (ending with '/>') with the given attribute values."
	| xml space equals quote dictionary |
	dictionary := aDictionaryOrList asDictionary.
  space := String space.
	equals := '='.
	quote := $" asString.
	"Don not mess with indent here. Caller should handle."
	xml := '<', aTagString.
	dictionary keysSortedSafely 
		do: [ :key  |
			| value |
			value := dictionary at: key. 
			xml := xml, space, key asString, equals, quote, value asString, quote.
			].
	xml := xml, ' />', String cr.
	^xml.
]

{ #category : #xml }
HumCalculator >> xml: aTagString dictionary: aDictionary with: aBlockClosure [ 
	"Generate the front tag and the end tag with block to produce the middle"
	| frontTag xml cr dictionary |
	dictionary := aDictionary asDictionary.
	cr := String cr.
	self indent.
	frontTag :=  self xmlOpen: aTagString dictionary: dictionary.
	xml := indentString, frontTag, cr, 
	       indentString, ( aBlockClosure value ), cr,
			   indentString, '</', aTagString, '>', cr.
	"Restore prior indent"
	self exdent.
	^xml.
]

{ #category : #xml }
HumCalculator >> xml: tagString list: anArray [ 
	"Iterate: Enclose each item with given tagString"
	| result |
	self indent.
	result := String new.
	anArray 
		do: [ :each | |s|
			s := '<',tagString,'>',each,'</',tagString,'>'.
			result := result, String cr, indentString, s.
			].
	self exdent.
	^result.
]

{ #category : #xml }
HumCalculator >> xml: aTag with: aBlock [ 
	"Fix up the indent after we get this working."
	| xml cr  insert |
	insert := aBlock value.
	self assert: ( insert isKindOf: String ).
	cr := String cr.
	self indent.
	xml  := indentString,'<', aTag, '>', cr
			 , indentString, insert, cr
			 , indentString, '</', aTag, '>', cr.
	"Restore prior indent."
	self exdent.
	^xml.
]

{ #category : #xml }
HumCalculator >> xmlOpen: aTagString dictionary: aDictionary [ 
	"Create an opening tag ( NOT ending with '/>' ) with the given attribute values."
	| xml space equals quote |
	self assert: ( aDictionary isKindOf: Dictionary ).
	space := String space.
	equals := '='.
	quote := $" asString.
  "Do no mess with indent here. Caller should handle."
	xml := '<', aTagString.

	aDictionary keysSortedSafely 
		do: [ :key  |
			| value |
			value := aDictionary at: key. 
			value ifNil: [  Error signal: 'Nil passed where xml attribute was expected.'].
			xml := xml, space,  key, equals, quote,  value, quote.
			].	
	xml := xml, ' >', String cr.
	^xml.
]
