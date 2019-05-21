"
TODO: Should parsing methods be in Ontology or Programmers Assistant?

The Programmer`s Assistant (PA) provides the Interactive Development Environment (IDE) for Hum.
While Smalltalk maintains source code in the image file, Hum maintains code in an ontology file.
Each type of frame expects a notation meant to be used in that type of frame.
See the class category 'Hum-Language' and the on-line manual for more detail.

The Assistant is a user interface (a UI model actually) constructed as a set of views on the ontology.
The ontology is the model.
A Frame Editor is a viewer and a controller that may modify ontology frames.

Diagrams provide a views of an ontology`s structure (relationships between various elements).
Diagrams are read-only, but they may support mouse (hand) actions such as mouse-over and click.
The Plan Diagram shows the precedence relationships implied by the plan frames.
The Noun Diagram shows the structure of the dictionary with attributes and supertype relations as connectors.
The Dialog Context Diagram shows the connections between dialog vignette contexts.
The Delegation Diagram shows the dependencies between roles.

The Programmers Assistant provides an intermediary between a UI implementation and the ontology object.
The programmers assistant is the model of the IDE.
See: HumProgrammersAssistantTests.

The UI interacts with the Programmers Assistant to provide a specific implementation.
See Hum-Seaside class category. (HumOntologyBrowser)

   

"
Class {
	#name : #HumProgrammersAssistant,
	#superclass : #Object,
	#instVars : [
		'ontology',
		'currentRole',
		'frame'
	],
	#category : #'Hum-IDE'
}

{ #category : #parsing }
HumProgrammersAssistant class >> getAnnotationFromSource: aSourceString [ 
	"Match '[...]' if any, and extract it from source."
	| annotation  |
	annotation := HumCalculator given: aSourceString extractIncludingMatching: '[]'. 
	^annotation.
]

{ #category : #parsing }
HumProgrammersAssistant class >> getCommentFromSource: aSourceString [ 
	"Match '(...)' if any, and extract it from source."
	| comment  |
	"Note: Following assumes there is just one comment in the source.
	If there is more than one comment, only the first one is returned."

	comment := HumCalculator given: aSourceString extractIncludingMatching: '()'. 
	^comment.
]

{ #category : #parsing }
HumProgrammersAssistant class >> getLabelFromSource: aSourceString [
	"Match 'word:' at the front of the string.
	Note: word may be hyphenated. "
	| label tokenTypePairs |
	((aSourceString isNil) or: [aSourceString trimBoth = '']) ifTrue: [^nil].
	tokenTypePairs := self parseInstructionSource: aSourceString keywords: {}.
	((( tokenTypePairs at: 1 ) key) = '.')
		ifTrue: [ tokenTypePairs removeFirst].
	"If the second token is a colon, the first token is a label."
	((tokenTypePairs size >= 2) and: [(( tokenTypePairs at: 2 ) key) = ':'])
		ifTrue: [ label := (( tokenTypePairs at: 1 ) key ).
				"Do not mistake 'Else:' for a label."
				(label asLowercase sameAs: 'else') ifTrue: [ label := nil. ].
			]
		ifFalse: [ label := nil ].
	^label.
]

{ #category : #parsing }
HumProgrammersAssistant class >> parseActionLine: source [ 
	"Parse the source -- Return a list of token-type pairs: ( token -> tokenType ).
	tokenType is one of: #word #keyword #punctuation #comment."
	| tokenTypePairs firstToken |
	tokenTypePairs := self parseInstructionSource: source keywords: #().
	firstToken := (tokenTypePairs first) key.
	( #('action' 'to') includes: (firstToken asLowercase) )
		ifTrue: [ tokenTypePairs at: 1 put: (firstToken -> #keyword) ].
	^tokenTypePairs
	
]

{ #category : #parsing }
HumProgrammersAssistant class >> parseInstructionSource: source keywords: keywords [
	"Parse the source -- Return a list of token-type pairs: ( token -> tokenType ).
	tokenType is one of: #word #keyword #punctuation #comment."
	| whitespace punctuation quote tokens tokenTypePairs tokenType i calc remainingSource |
	whitespace := String space, String tab, String crlf.
	quote := $' asString.
	punctuation := '~!@#$%^&*()_+`={}|[]\:";<>?,./', quote.
	"Note: Preserve uppercase in tokens so that first word of a sentence is capitalized."
	tokens := source  findTokens: ( punctuation, whitespace ) keep: ( punctuation, whitespace ).
	remainingSource := source.
	tokenTypePairs := OrderedCollection new.
	calc := HumCalculator new.
	i := 1.
	[ i <= tokens size ]	
		whileTrue: [ 
			| token |
			token := tokens at: i.
			tokenType := #word.
			"( self isNoun: token ) ifTrue: [ tokenType := #noun ]."
			calc cases;
				when: [ keywords include: token asLowercase  ] then: [ tokenType := #keyword ];
				when: [ ( token size = 1 ) and: [ whitespace includes: token first]  ] then:  [ tokenType := #whitespace ];
				when: [ ( token size = 1 ) and: [ punctuation includes: token first] ]
					then: [ | calc2 gatherThru append | 
						calc2 := HumCalculator new.
						tokenType := #punctuation. "Until proven otherwise."
						append := [ token := token, (tokens at: i) ].
						gatherThru := [ :stop |  [( i := i+1)<= (tokens size) and: [ ((tokens at: i ) = stop) ] ] whileFalse: [ append value ].  append value ].
						calc2 cases;
							"Does the source have a comment?"
							when: [ (token = '(') and: ['*(*)*' match: remainingSource ]  ] then: [ gatherThru value: ')'. tokenType := #comment.  ]; 
							"Does the source have annotation?"
							when: [ (token = '[') and: ['*[*]*' match: remainingSource ] ] then: [ gatherThru value: ']'. tokenType := #annotation. ];
							when: [ (token = '"') and: ['*"*"*' match: remainingSource ] ] then: [ gatherThru value: '"'. tokenType := #string. ].
					].
			( tokenType = #whitespace ) ifFalse: [tokenTypePairs add: ( token -> tokenType )].
			remainingSource := calc given: remainingSource extractAfter: token.
			i := i + 1.
			].
	^ tokenTypePairs.

]

{ #category : #parsing }
HumProgrammersAssistant class >> parseMarkupSource: source [ 
	"Parse the source -- Return a list of token-type pairs: ( token -> tokenType ).
	tokenType is one of: #word #punctuation #markup #whitespace #widget"
	| whitespace punctuation quote tokens tokenTypePairs tokenType i calc remainingSource markup addHeading |
	whitespace := String space, String tab, String crlf.
	quote := $' asString.
	punctuation := '~!@#$%^&*()_+`={}|[]\:";<>?,./', quote.
	markup := '*~_^'.
	tokenTypePairs := OrderedCollection new.
	"First handle and remove outline markup"
	calc := HumCalculator new.
	addHeading := [ :heading | tokenTypePairs add: (heading->#markup). remainingSource := calc given: source extractAfter: heading. ].
	calc cases;
		when: [ source beginsWith: '!!!!' ] then: [ addHeading value: '!!!!' ];
		when: [ source beginsWith: '!!!' ] then: [ addHeading value: '!!!' ];
		when: [ source beginsWith: '!!' ] then: [ addHeading value: '!!' ];
		when: [ source beginsWith: '!' ] then: [ addHeading value: '!' ];
		when: [ source beginsWith: '----' ] then: [ addHeading value: '----' ];
		when: [ source beginsWith: '---' ] then: [ addHeading value: '---' ];
		when: [ source beginsWith: '--' ] then: [ addHeading value: '--' ];
		when: [ source beginsWith: '-' ] then: [ addHeading value: '-' ];
		when: [ source beginsWith: '####' ] then: [ addHeading value: '####' ];
		when: [ source beginsWith: '###' ] then: [ addHeading value: '###' ];
		when: [ source beginsWith: '##' ] then: [ addHeading value: '##' ];
		when: [ source beginsWith: '#' ] then: [ addHeading value: '#' ];
		otherwise: [ remainingSource := source ].	
	"Note: Preserve uppercase in tokens so that first word of a sentence is capitalized."
	tokens := remainingSource  findTokens: ( punctuation, whitespace ) keep: ( punctuation, whitespace ).
	i := 1.
	[ i <= tokens size ]	
		whileTrue: [ 
			| token |
			token := tokens at: i.
			tokenType := #word.
			"( self isNoun: token ) ifTrue: [ tokenType := #noun ]."
			calc cases;
				when: [ ( token size = 1 ) and: [ whitespace includes: token first]  ] then:  [ tokenType := #whitespace ];
				when: [ ( token size = 1 ) and: [ markup includes: token first]  ] then:  [ tokenType := #markup ];
				when: [ ( token size = 1 ) and: [ punctuation includes: token first] ]
					then: [ | calc2 gatherThru append | 
						calc2 := HumCalculator new.
						tokenType := #punctuation. "Until proven otherwise."
						append := [ token := token, (tokens at: i) ].
						gatherThru := [ :stop |  [( i := i+1)<= (tokens size) and: [ ((tokens at: i ) = stop) ] ] whileFalse: [ append value ].  append value ].
						calc2 cases;
							"Does the source have a radio-button widget?"
							when: [ (token = '(') and: ['*(#)*' match: remainingSource ]  ] then: [ gatherThru value: ')'. tokenType := #widget.  ]; 
							"Does the source contain an action button?  Need to get this before other bracket widgets."
							when: [ (token = '[') and: ['[[*]]*' match: remainingSource ] ] 
								then: [ tokenType := #widget. 
										gatherThru value: ']'. 
										gatherThru value: ']'. 
										];
							"Does the source have a bracket-notation widget?"
							when: [ (token = '[') and: ['*[*]*' match: remainingSource ] ] then: [ gatherThru value: ']'. tokenType := #widget. ];
							when: [ (token = '"') and: ['*"*"*' match: remainingSource ] ] then: [ gatherThru value: '"'. tokenType := #string. ].
					].
			tokenTypePairs add: ( token -> tokenType ).
			remainingSource := calc given: remainingSource extractAfter: token.
			i := i + 1.
			].
	^ tokenTypePairs.

]

{ #category : #parsing }
HumProgrammersAssistant class >> removeAnnotationFromSource: aSourceString [ 
	"Return the source string with the annotation, if any, removed."
	| remainderBefore remainderAfter annotation |
	annotation := self getAnnotationFromSource: aSourceString.
	annotation ifNil: [^aSourceString trimBoth].
	remainderBefore := HumCalculator given: aSourceString extractUpto: annotation.
	remainderAfter := HumCalculator given: aSourceString extractAfter: annotation.
	^( remainderBefore, remainderAfter ) trimBoth.
]

{ #category : #parsing }
HumProgrammersAssistant class >> removeCommentFromSource: aSourceString [ 
	"Return the source string with comment, if any, removed."
	| remainderBefore remainderAfter comment |
	comment := self getCommentFromSource: aSourceString.
	comment ifNil: [^aSourceString trimBoth].
	remainderBefore := HumCalculator given: aSourceString extractUpto: comment.
	remainderAfter := HumCalculator given: aSourceString extractAfter: comment.
	^( remainderBefore, remainderAfter ) trimBoth.
]

{ #category : #parsing }
HumProgrammersAssistant class >> removeLabelFromSource: aSourceString [ 
	"If there is a label, remove it and return the remainder."
	| label remainder calc|
	label :=  self getLabelFromSource: aSourceString.
	(label isNil)
		ifTrue: [remainder := aSourceString ]
		ifFalse: [ "Return the remainder after first colon"
			calc := HumCalculator new.
			remainder := (calc given: aSourceString extractAfter: ':') trimBoth. 
			].
	^remainder.
]

{ #category : #parsing }
HumProgrammersAssistant class >> removeLeaderFromSource: aSource [
	"Strip dot-leader, if any. "
	| s |
	self assert: (aSource isKindOf: String).
	s := aSource.
	[s beginsWith: '. ']
		whileTrue: [s := s copyFrom: 3 to: s size].
	^s.
]

{ #category : #accessing }
HumProgrammersAssistant >> clearOntology [
	ontology := HumOntology new.
]

{ #category : #parsing }
HumProgrammersAssistant >> getAnnotationFromSource: aSourceString [ 
	"Match '[...]' if any, and extract it from source."
	| annotation  |
	annotation := self class getAnnotationFromSource: aSourceString.
	^annotation.
]

{ #category : #parsing }
HumProgrammersAssistant >> getCommentFromSource: aSourceString [ 
	"Match '(...)' if any, and extract it from source."
	| comment  |
	comment := self class getCommentFromSource: aSourceString.
	^comment.
]

{ #category : #parsing }
HumProgrammersAssistant >> getLabelFromSource: aSourceString [
	"Match 'word:' at the front of the string.
	Note: word may be hyphenated. "
	| label |
	label := self class getLabelFromSource: aSourceString.
	^label.
]

{ #category : #'file operations' }
HumProgrammersAssistant >> loadOntology: anOntology fromTextFileNamed: fileName [
	"Load an ontology from the given text file."
	| stream store |
	self ontology: anOntology.
	ontology file: fileName.
	ontology title: fileName.
	store := HumStore defaultStore.
	stream := store readStreamFromFileNamed: fileName.
	stream position: 0. "Just in case."
	self loadOntologyFromTextStream: stream.
	^ontology.

	
]

{ #category : #'as yet unclassified' }
HumProgrammersAssistant >> loadOntologyFromSaveFileNamed: aFileNameString [ 
	"Reload an ontology from the given save file."
	|  |
	self ontology: (HumOntology new).
	self loadOntology: (ontology) fromTextFileNamed: aFileNameString.
	^ontology.

]

{ #category : #'file operations' }
HumProgrammersAssistant >> loadOntologyFromTextFileNamed: fileName [
	"Load an ontology from the given text file."
	|  |
	ontology ifNil: [ self ontology: (HumOntology baseOntology) ].
	self loadOntology: (ontology) fromTextFileNamed: fileName.
	^ontology.

	
]

{ #category : #'file operations' }
HumProgrammersAssistant >> loadOntologyFromTextStream: aStream [ 
	"Discover frame type and store each frame in ontology."
	|  sourceLine frameUpdater  isActionSubFrameCase |
	"Use ontology provided by caller or lazy initialization."
	frameUpdater := (HumFrameUpdater new) ontology: (self ontology).
	
	"Define a function to detect action subframe case."
	sourceLine := String new. "This satisfies compiler that sourceLine is defined before lambda uses it."
	isActionSubFrameCase := [(frameUpdater frame isKindOf: HumFrame4Action) 
		                       and: [(sourceLine beginsWith: 'Action:') or: [sourceLine beginsWith: 'To:']]].
	
	"Read frames from the stream."
	[(sourceLine := aStream nextLine) notNil]
		whileTrue: ["For each line in the stream:"
			((sourceLine beginsWith: '===') or: [frameUpdater isEmpty or: [isActionSubFrameCase value]]) 
				ifTrue: [ "Store prior frame, if any. Start new frame."
					(frameUpdater isEmpty) ifFalse: [ frameUpdater storeFrameInOntology ].
					"Get a fresh frameUpdater."
					frameUpdater := (HumFrameUpdater new) ontology: ontology..
					"Get the title line and discover what kind of frame comes next."
					((sourceLine beginsWith: '===' )or: [sourceLine = '']) ifTrue: [sourceLine := aStream nextLine].
					frameUpdater frame: (self makeFramePerTitleLine: sourceLine).
					]
				ifFalse: ["self haltIf: ('*Smalltalk*' match: sourceLine asString)."
					frameUpdater appendFrameLine: sourceLine]
			].
	"Strore final frame - unless frame is empty."	
	(frameUpdater isEmpty) ifFalse: [ frameUpdater storeFrameInOntology ].
	"Index the frames and nouns."
	ontology compileAllFrames.
	
	"TODO: Syntax errors in a frame can crash the load process. << ERROR"

	^ontology.
	
]

{ #category : #parsing }
HumProgrammersAssistant >> makeFramePerTitleLine: source [ 
	"The label on the title line indicates the kind of frame."
	| label calc |
	source ifNil: [^nil].
	self assert: (source isKindOf: String).
	label := self getLabelFromSource: source.
	label ifNil: [^nil].

	calc := HumCalculator new.
	calc cases;
		when: [label sameAs: 'View'] then: [ frame := ( HumFrame4View ontology: ontology title: source ) ];
		when: [label sameAs: 'Pane'] then: [ frame := ( HumFrame4View ontology: ontology title: source ) ];
		when: [label sameAs: 'Layout'] then: [ frame := ( HumFrame4View ontology: ontology title: source ) ];
		when: [label sameAs: 'Comment'] then: [ frame := (HumFrame4Comment new) titleLine: source; ontology: ontology. ];
		when: [label sameAs: 'Questions'] then: [ frame := (HumFrame4Comment new) titleLine: source ];
	  when: [label sameAs: 'Dictionary'] then: [ frame := (HumFrame4Dictionary ontology: ontology title: source)];
		when: [label sameAs: 'Goal'] 
		      then: [ frame := HumFrame4Plan ontology: ontology 
			                                       goal: (calc given: source extractAfter: (label,':') ) ];
		when: [label sameAs: 'Role'] 
		      then: [ currentRole := (calc given: source extractBetween: (label,':') and: '.') trimBoth. 
			            frame := HumFrame4Action new. 
			       		];
		when: [(label sameAs: 'Action') and: [frame isKindOf:HumFrame4Action ]] 
		      then: [ (frame isEmpty) ifFalse: [frame compileToOntology: ontology ].
			            frame := HumFrame4Action ontology: ontology 
			                                         role: currentRole
			                                       action: (calc given: source extractAfter: (label,':')).
			            frame appendFrameLine: (HumFrameLine source: source).
			          ];
		when: [label sameAs: 'To'] 
		      then: [ (frame isEmpty) ifFalse: [frame compileToOntology: ontology ].
			            frame := HumFrame4Action ontology: ontology 
			                                         role: currentRole
			                                       action: (calc given: source extractAfter: (label,':')).
			            frame appendFrameLine: (HumFrameLine source: source).
			          ];
		when: [(label sameAs: 'Context') or: [label sameAs: 'Dialog']]
		      then: [ frame := HumFrame4Vignette ontology: ontology 
			                                vignetteContext: (calc given: source extractBetween: (label,':') and: '.') 
			                                        pattern: nil ];
	  otherwise: [Error signal: 'Fell thru cases in makeFramePerTitleLine.'].
	"Track which ontology the frame was defined in."
	frame origin: ontology title copy.
	^frame.
]

{ #category : #accessing }
HumProgrammersAssistant >> ontology [
	"Return the ontolgy. If nil initialize one."
	^ ontology ifNil: [ ontology := HumOntology new. ].
]

{ #category : #accessing }
HumProgrammersAssistant >> ontology: aHumOntology [
	ontology := aHumOntology
]

{ #category : #parsing }
HumProgrammersAssistant >> parseActionLine: source [ 
	"An action line begins with 'Action:' or 'To:' label.
	An action line may include a comment and/or annotation.
	"
	| tokenTypePairs tokenPairsWithNounsMarked     |
	tokenTypePairs := self class parseActionLine: source.
	
	"Look-up #word types to see if they are #noun types."
	tokenPairsWithNounsMarked := OrderedCollection new.
	tokenTypePairs do: [ :association |  
		| token tokenType |
		token := association key.
		tokenType := association value.
		( tokenType = #word ) 
			ifFalse: [ tokenPairsWithNounsMarked add: association ]
			ifTrue: [ "Is this word a noun?" 
				(self ontology isNoun: token)
					ifFalse:  [ tokenPairsWithNounsMarked add: association ]
					ifTrue: [  tokenPairsWithNounsMarked add: ( token -> #noun ) ].
				].
		].
	^ tokenPairsWithNounsMarked.

]

{ #category : #parsing }
HumProgrammersAssistant >> parseActionLine: aString keywords: aCollection [ 
	"An action line begins with 'Action:' or 'To:' keyword.
	It may also include a comment and/or annotation."
	self shouldBeImplemented 
]

{ #category : #parsing }
HumProgrammersAssistant >> parseInstructionSource: source keywords: keywords [
	"Parse the source -- Return a list of token-type pairs: ( token -> tokenType ).
	Parse the source -- Return a list of token-type pairs: ( token -> tokenType ).
	tokenType is one of: #word #keyword #punctuation #comment #annotation.
	"
	| tokenTypePairs tokenPairsWithNounsMarked secondToken firstToken firstTokenType calc |
	tokenTypePairs := self class parseInstructionSource: source keywords: keywords.
	
	"Look-up #word types to see if they are #noun types."
	tokenPairsWithNounsMarked := OrderedCollection new.
	tokenTypePairs do: [ :association |  
		| token tokenType |
		token := association key.
		tokenType := association value.
		( tokenType = #word ) 
			ifFalse: [ tokenPairsWithNounsMarked add: association ]
			ifTrue: [ "Is this word a noun?" 
				(self ontology isNoun: token)
					ifFalse:  [ tokenPairsWithNounsMarked add: association ]
					ifTrue: [  tokenPairsWithNounsMarked add: ( token -> #noun ) ].
				].
		].
	"If second token is colon, first token is a role."	
	firstToken := (tokenPairsWithNounsMarked at: 1) key.
	firstTokenType := (tokenPairsWithNounsMarked at: 1) value.
	secondToken := (tokenPairsWithNounsMarked at: 2) key.
	calc := HumCalculator new.
	calc cases;
		when: [ (secondToken = ':' and: [ firstTokenType = #keyword])  ] 
			then: [ "Do nothing" ];
		when: [ (secondToken = ':' and: [ firstTokenType = #word])  ] 
			then: [ tokenPairsWithNounsMarked at: 1 put: ( firstToken -> #role ).].
	^ tokenPairsWithNounsMarked.

]

{ #category : #parsing }
HumProgrammersAssistant >> parseMarkupSource: aSourceString [ 
	| result |
	result := self class parseMarkupSource: aSourceString.
	^result.
]

{ #category : #parsing }
HumProgrammersAssistant >> parseSource: source keywords: keywords [
	"Parse the source -- Return a list of token-type pairs: ( token -> tokenType ).
	Parse the source -- Return a list of token-type pairs: ( token -> tokenType ).
	tokenType is one of: #word #keyword #punctuation.
	See also: >>parseInstructionSource: keywords:
	"
	| tokenTypePairs tokenPairsWithNounsMarked     |
	self assert: ( keywords isKindOf: Collection ).
	tokenTypePairs := self class parseSource: source keywords: keywords.
	
	"Look-up #word types to see if they are #noun types."
	tokenPairsWithNounsMarked := OrderedCollection new.
	tokenTypePairs do: [ :association |  
		| token tokenType |
		token := association key.
		tokenType := association value.
		( tokenType = #word ) 
			ifFalse: [ tokenPairsWithNounsMarked add: association ]
			ifTrue: [ "Is this word a noun?" 
				(self ontology isNoun: token)
					ifFalse:  [ tokenPairsWithNounsMarked add: association ]
					ifTrue: [  tokenPairsWithNounsMarked add: ( token -> #noun ) ].
				].
		].
	^ tokenPairsWithNounsMarked.

]

{ #category : #parsing }
HumProgrammersAssistant >> removeAnnotationFromSource: aSourceString [ 
	| cleanerSource |
	cleanerSource := self class removeAnnotationFromSource: aSourceString.
	^cleanerSource. 
]

{ #category : #parsing }
HumProgrammersAssistant >> removeCommentFromSource: aSourceString [ 
	| cleanerSource |
	cleanerSource := self class removeCommentFromSource: aSourceString.
	^cleanerSource. 
]

{ #category : #parsing }
HumProgrammersAssistant >> removeLabelFromSource: aSourceString [ 
	"If there is a label, remove it and return the remainder."
	| remainder |
	remainder := self class removeLabelFromSource: aSourceString.
	^remainder.
]

{ #category : #'file operations' }
HumProgrammersAssistant >> saveOntologyOnFileNamed: aFileName [ 
	"Save my ontology on the given ReferenceStream file."
	"Note: This method  does not provide any kind of versioning."
	"ToDo: If we save ontology in a WorldBase instead, 
	       the WorldBase could provide versioning."
	| referenceStream |
	self shouldNotImplement. "This version of Smalltalk does not provide the needed ReferenceStream class."
	"Open the file for write -- clear it if necessary."
	referenceStream := nil. "ReferenceStream fileNamed: aFileName."

	"Write the various data structures to the file."
	referenceStream nextPut: ontology.
	referenceStream close.

	
]

{ #category : #'file operations' }
HumProgrammersAssistant >> writeFrame: aFrame onStream: aStream [
	"Write frame-lines to given stream in canonical format.    *** NO SENDERS ***
	- Lines have canonical format to simplify reading them back. 
	- Customize per frame-type as needed.
	See also: writeOntolgyFrame:onStream: - which appears to do the same thing."
	|  cr dotLeader |
	cr := String cr.
	dotLeader := '. '.
	aStream nextPutAll: ( '===', cr ).
	aStream nextPutAll: (( aFrame title ), cr ).
	( aFrame frameLines )
			do: [ :frameLine |
				"My indent convention involves dot leader"
				( (frameLine isKindOf: HumInstructionLine) and: [ frameLine indent > 1 ] ) 
						ifTrue: [ (1 to: frameLine indent) do: [ :i |  aStream nextPutAll: dotLeader ] ].
						
				aStream nextPutAll: ( dotLeader, (frameLine source ), cr).					 
				].
	
]

{ #category : #'file operations' }
HumProgrammersAssistant >> writeOntologyContextVignettesOnStream: aStream [
	| contexts vignettes cr |
	cr := String cr.
	contexts := ontology contexts sorted.
	contexts
		do: [ :aContext |
			aStream nextPutAll: '===', cr.
			aStream nextPutAll: 'Context: ', aContext, '.', cr.
			vignettes := (ontology vignettesForContext: aContext) sorted: [ :aFrame :bFrame | (aFrame title) < (bFrame title) ].
			vignettes
				do: [ :aVignetteFrame |
						aStream nextPutAll: cr.
						self writeOntologyVFrame: aVignetteFrame onStream: aStream.
					 ].
			 ].


]

{ #category : #'file operations' }
HumProgrammersAssistant >> writeOntologyFrame: aFrame onStream: aStream [
	"Write to given stream - customize per frame-type as needed."
	|  cr dotLeader |
	cr := String cr.
	dotLeader := '. '.
	aStream nextPutAll: ( '===', cr ).
	aStream nextPutAll: (( aFrame title ), cr ).
	( aFrame frameLines )
			do: [ :frameLine |
				"Eh? - All lines have the same dotLeader ???  What was I thinking???"
				aStream nextPutAll: dotLeader, (frameLine source ), cr.				
				"See also: writeOntologyFrameWithIndents:onStream:"	 
				].
	
]

{ #category : #'file operations' }
HumProgrammersAssistant >> writeOntologyFrameWithIndents: aSubFrame onStream: aStream [
	"Vignette and View frames use dot-leader only for instruction lines."
	|  cr dotLeader |
	cr := String cr.
	dotLeader := '. '.

	( aSubFrame frameLines )
			do: [ :frameLine |
				"My indent convention involves dot leader"
				( (frameLine isKindOf: HumInstructionLine) and: [ frameLine indent > 1 ] ) 
						ifTrue: [ (1 to: frameLine indent) do: [ :i |  aStream nextPutAll: dotLeader ] ].
				"NOTE: This assumes the source does not contain its own dot-leader."		
				aStream nextPutAll: ( (frameLine source ), cr ).					 
				].
	
]

{ #category : #'file operations' }
HumProgrammersAssistant >> writeOntologyFramesOfType: aFrameClass onStream: aStream [
	"Select frames of given class and write them on the stream."
	| selectedFrames sortedFrames dotLeader cr |
	dotLeader := '. '.
	cr := String cr.
	selectedFrames := (ontology frames) select: [ :frameX | frameX isKindOf: aFrameClass ].
	sortedFrames := selectedFrames sorted: [ :frameA :frameB | (frameA title) < (frameB title) ]. 
	sortedFrames 
		do: [ :aFrame | self writeOntologyFrame: aFrame onStream: aStream. ].

]

{ #category : #'file operations' }
HumProgrammersAssistant >> writeOntologyOnTextFileNamed: aFileName [ 
	"Save my ontology in text format on the file with the given name. "
	| stream store  |
	self assert: ( aFileName isKindOf: String ).
	self assert: ( ontology isKindOf: HumOntology ).
	store := HumStore defaultStore .
	stream := store writeStreamOnFileNamed:  aFileName. 
	"Order: Comment, Dictionary, Vignette, Role-Action, Plan, View"
	" -- NOTE: Original file order (if any) is not maintained. That means that comment frames may lack original context."
	self writeOntologyFramesOfType: HumFrame4Comment onStream: stream.
	self writeOntologyFramesOfType: HumFrame4Dictionary onStream: stream.
	"Write context vignettes in consolidated frames."
	self writeOntologyContextVignettesOnStream: stream.
	"Write role-actions in consolidated frames."
	self writeOntologyRoleActionsOnStream: stream.
	"Write the remaining frames. ( Plan, View )"
	self writeOntologyFramesOfType: HumFrame4Plan onStream: stream.
	self writeOntologyFramesOfType: HumFrame4View onStream: stream.
	
	stream nextPutAll: ( '===', String cr ).
	stream close.

]

{ #category : #'file operations' }
HumProgrammersAssistant >> writeOntologyRoleActionsOnStream: aStream [
	"Write role-action frames ordered by role and action."
	| roles  cr |
	cr := String cr.
	roles := ontology roles sorted.
	roles
		do: [ :aRole |
			| actionStatements actionStatementsSorted |
			aStream nextPutAll: '===', cr.
			aStream nextPutAll: 'Role: ', aRole, cr.
			actionStatements := (ontology actionsOf: aRole). "Returns a set of HumStatement"
			actionStatementsSorted := actionStatements sorted: [ :aStatement :bStatement | (aStatement source) < (bStatement source) ].
			actionStatementsSorted
				do: [ :anActionStatement |
						| anActionFrame |
						aStream nextPutAll: cr.
						anActionFrame := ontology getFrameForRole: aRole action: anActionStatement.
						self writeOntologyFrame: anActionFrame onStream: aStream.
					 ].
			 ].


]

{ #category : #'file operations' }
HumProgrammersAssistant >> writeOntologyVFrame: aFrame onStream: aStream [
	"Write UI frames: Vignette and View frames only use dot-leader for instruction lines."
	|  cr dotLeader |
	cr := String cr.
	dotLeader := '. '.
	( aFrame frameLines )
			do: [ :frameLine |
				"My indent convention involves dot leader"
				( frameLine isKindOf: HumInstructionLine )  
						ifTrue: [ (1 to: frameLine indent) do: [ :i |  aStream nextPutAll: dotLeader ] ].
						
				aStream nextPutAll: ( (frameLine source ), cr).					 
				].
	
]
