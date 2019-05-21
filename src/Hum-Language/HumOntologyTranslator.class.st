"
This class provides tools used to generate code from Hum frames.

Strategies vary a little depending on the target language and framework.

This is crude version - oriented toward Smalltalk and other object-oriented frameworks.
	- Roles become classes.
	- Entity-Attribute relations become class accessors. { but in what class ??? }
	- Noun datatypes are one of: ( Entity Category Enumeration String Measure TimeStamp ).
	- Dialogs become method calls with blocks.
	- Views are translated to some Web Server framework { Seaside when target is Smalltalk }.
	
I am thinking that something like Erlang or Scala might be the best target framework
because those frameworks support ""actors"", distribution, and parallel processing
in relatively natural ways.

In any case, the original Hum code will be included as comments in the generated code.
This can assure that translations to less readable languages (Javascript, Erlang)
will still be maintainable in those languages (not recommended)
should the user-programmer decide to go that way.


"
Class {
	#name : #HumOntologyTranslator,
	#superclass : #Object,
	#instVars : [
		'methodsForClasses',
		'prologues',
		'ontology',
		'contextEntity',
		'html'
	],
	#category : #'Hum-Language'
}

{ #category : #'instance creation' }
HumOntologyTranslator class >> ontology: aHumOntology [ 
	"Create an instance"
	| instance |
	instance := self basicNew.
	instance ontology: aHumOntology.
	^instance
]

{ #category : #'translate to Java' }
HumOntologyTranslator >> asJava [
	"This is crude version.
	Futures:
	- Roles become classes.
	- Entity-Attribute relations become classes with get/set methods.
	- Noun types are one of: ( Entity Category Enumeration String Measure TimeStamp ).
	- Dialogs are become method calls with blocks.
	- Views are still interpreted.
	"

	| code nounCode actionCode |
	code := ''.
	nounCode := self nounsAsJava.
	code := code, nounCode.
	actionCode := self rolesAsJava.
	code := code, actionCode.
	^ code.
]

{ #category : #'Generate OO Modules' }
HumOntologyTranslator >> attachAction: aMethodName toActorClass: aClassName fromSource: aSource [
	"Attach the given method source 
		to the given class 
			under the given method name."
	| methods |
	methods := self getMethodsForClass: aClassName.
	self assert: (methods isKindOf: Dictionary ).
	methods at: aMethodName put: aSource.
	  
]

{ #category : #'Generate OO Modules' }
HumOntologyTranslator >> attachPrologToActorClass: aClassName fromSource: aSourceString [ 
	"Attach the given prologue source code to the named class."
	| |
	"Note: There can be only one prologue for each actor class"
	( self prologues ) at: aClassName put: aSourceString.
]

{ #category : #accessing }
HumOntologyTranslator >> contextEntity: aString [ 
	contextEntity := aString
]

{ #category : #'translate to HTML' }
HumOntologyTranslator >> countLeading: aCharacter inString: line [
	"Count leading"
	| n ch |
	( aCharacter isKindOf: Character ) ifTrue: [ ch := aCharacter ].
	( aCharacter isKindOf: String ) ifTrue: [ ch := aCharacter at: 1 ].
	self assert: ( ch isKindOf: Character ).

	self assert: ( (line at: 1) = ch ).
	n := 1.
	[ (line at: n) = ch ] whileTrue: [n := n+1].
  ^n-1.
]

{ #category : #'translate to HTML' }
HumOntologyTranslator >> genHTML: generatedCodeString [
	"Append generated code to 'html' instance variable. (YIKES!)"
	| |
	
	"If code begins with a tag, insert cr to improve readability."
	( generatedCodeString beginsWith: '<' )
	  ifTrue: [(self html) nextPutAll: (String cr, generatedCodeString).]
	  ifFalse: ["Otherwise, it is caller`s responsibility to prepend cr <br/>"
		         (self html) nextPutAll: generatedCodeString.
		         ].
  "TODO: REFACTOR this HTML generator to eliminate this side-effect stuff."

	
]

{ #category : #'translate to Erlang' }
HumOntologyTranslator >> generateErlangDocumentation [
	| translationStrategy runTimeStrategy |
	translationStrategy := 'Erlang Translation Strategy
	Each Hum role is translated into Erlang module.
	Hum Instructions become Erlang patterns - that match on the HumStatement source.
	The Hum statement source becomes an Erlang atom for matching purposes.
	Delegation becomes an Erlang message.
	'.
	runTimeStrategy := 'Erlang Run-Time Strategy
	The Hum run-time will be implemented in Erlang.
	The Hum-Erlang run-time actors include: Coordinator, Dispatcher, Messenger, BlackBoard, WorldBase, Bookkeeper.
	It also seems likely that the Hum-Erlang run-time will also include DialogAgent, and Scribe actors.
	However, it may make more sense to implement those actors in JavaScript. (TBD).
	'.
	"2015-12-26: I wrote some experimental versions of an Erlang Messenger some time ago.
	I think (but may mis-remember) that I also wrote an experimental Erlang WorldBase. 
	"
	^translationStrategy, runTimeStrategy.
]

{ #category : #'translate to Erlang' }
HumOntologyTranslator >> generateErlangForActionCall: aString [
	"Translate a Hum Action call into an Erlang OTP call."
	| erlang colon quote comma roleAtom statementString  statementAtom nounValues |
	self assert: (aString isKindOf: String).
	"Extract the statement string from the Instruction Line."
	"TODO: HumStatement knows how to parse better than HumCalculator. It knows about comments and annotations."	
	colon := $: asString.
	quote := $' asString.
	comma := $, asString.
	roleAtom := (HumCalculator given: aString extractUpto: colon) asLowercase.
	statementString := (HumCalculator given: aString extractAfter: colon) trimBoth.
	statementAtom := quote, statementString, quote.
	nounValues := self generateErlangNounValuesForStatement: statementString.
	erlang := '?CALL( ', roleAtom, comma, statementAtom, ', [ ', nounValues, ' ] )', comma, String cr.
	^erlang
	

]

{ #category : #'translate to Erlang' }
HumOntologyTranslator >> generateErlangForActionHeader: aString [ 
	"Then: The do header looks like 'do( { action-statement, noun-values } )' "
	| erlang quote statementString    nounValues |
	quote := $' asString.
	(aString beginsWith: 'Action:')
		ifTrue: [ statementString := (HumCalculator given: aString extractAfter: 'Action:') trimBoth. ]
		ifFalse: [ statementString := aString ].
	"TODO: Fix case where statementString contains single quote/s."
	nounValues := self generateErlangNounValuesForStatement: statementString.	
	erlang := 'do( { ', quote, statementString, quote, ', [ ', nounValues, ' ] } ) ->', String cr.
	^ erlang.
]

{ #category : #'translate to Erlang' }
HumOntologyTranslator >> generateErlangForEntity: anEntity [
	"Translate entity into an Erlang record data structure. <<< OBSOLETE
	-record( entity, { attribute, attribute, attribute } ).	
	"
	| erlangCode comma attributes separator supertypes |
	
	Error signal: 'Decided after giving it more thought that this translation concept is a bad idea'.
	"After all, action call will be ?CALL({',roleAtom,',"',statementString,'",NounValues}). where NounValues is a list of {noun, noun-value} tuples."
	
	self assert: (anEntity isKindOf: String).
	comma := ', '.
	separator := ' '.
	"Generate the preamble."
	erlangCode := '-record( ', (self nounAsCamelCase: anEntity) uncapitalized, comma, '{'.
	"Generate the tuple elements."
	attributes := (ontology immediateAttributesOfEntity: anEntity) asArray.  "Note: Attributes that are also entities imply nested records."
	self assert: ( (attributes at: 1) isKindOf: String).  "Assume a collection of String"
	attributes 
		do: [ :attribute | 
			erlangCode := erlangCode, separator, (self nounAsCamelCase: attribute) uncapitalized.  
			separator := comma. "Remaining attributes will be separated by a comma."
			].
		
	supertypes := (ontology immediateSupertypesOf: anEntity) asArray.  "Note: Attributes that are also entities imply nested records."
	self assert: ( (attributes at: 1) isKindOf: String).  "Assume a collection of String"
	supertypes 
		do: [ :supertype | 
			erlangCode := erlangCode, separator, (self nounAsCamelCase: supertype) uncapitalized.  
			separator := comma. "Remaining attributes will be separated by a comma."
			].

	erlangCode := erlangCode, ' }  ).' .
	^erlangCode.	
]

{ #category : #'translate to Erlang' }
HumOntologyTranslator >> generateErlangForInstruction: aHumInstructionLine [ 
	"Generate self-call or RPC for given instruction."
	| role statement comment erlangCode cr indent quote statementAtom |
	role := aHumInstructionLine role.
	statement := aHumInstructionLine statement.
	comment := aHumInstructionLine comment.
	erlangCode := ReadWriteStream on: ''.
	cr := String cr.
	indent := '  '.
	quote := $' asString.
	statementAtom := quote, statement source, quote.
	"Insert comment, if any, before the Erlang translation of the statement."
	(comment > ' ') 
		ifTrue: [ erlangCode <<  indent << '% ' << comment << cr ]. 
	"If a role-label is present, the action is delegated to another role; otherwise calling self."
	(role > ' ')
		ifTrue: [ | rpc |  
			rpc := self generateErlangForActionCall: aHumInstructionLine source. 
			erlangCode << indent << rpc.
			]
		ifFalse: [ erlangCode << indent << (self generateErlangForSelfCall: statement source) << cr].
	^erlangCode contents.
]

{ #category : #'translate to Erlang' }
HumOntologyTranslator >> generateErlangForPlanFrame: aHumFrame4Plan [ 
	"Translate the plan frame into an Erlang data structure.
	planFrame = { goal, [ precondition, precondition ] , [ action, action ] }
	"
	| erlangCode goalStatement quote indent comma |
	quote := $' asString.
	comma := ', '.
	indent := '  '.
	erlangCode := 'planFrame = { '.  "Start tuple."
	goalStatement := aHumFrame4Plan goal source.
	erlangCode := erlangCode, quote, goalStatement, quote, comma. "Goal-statement is first element of tuple"
	erlangCode := erlangCode, String cr, indent, ' [  '.  "Start list of preconditions."
	aHumFrame4Plan preconditions do: [  :precondition |
		erlangCode := erlangCode, String cr, indent, quote, precondition source, quote.
		indent := '  , '.
		 ].
	indent := '  '.
	erlangCode := erlangCode, String cr, indent, ' ], '.  "End list of preconditions."
	erlangCode := erlangCode, String cr, indent, ' ['.  "Start list of actions."
	aHumFrame4Plan planActions do: [  :action |
		erlangCode := erlangCode, String cr, indent, quote, action source, quote.
		indent := '  , '.  "Separate list items with a comma."
		 ].
	indent := '  '.
	erlangCode := erlangCode, String cr, indent, ' ] '. "End list of actions."
	erlangCode := erlangCode, String cr,  ' }'.
	
	^erlangCode.
]

{ #category : #'translate to Erlang' }
HumOntologyTranslator >> generateErlangForRole: aRoleName [
	"Generate Erlang code for the given role-name."
	| moduleDeclarationCode moduleLogicCode cr actionStatements quote |
	"Generate the module`s declarations."
	cr := String cr.
	quote := $' asString.
	moduleDeclarationCode := ReadWriteStream on: ''.
	moduleDeclarationCode << '-module(' << aRoleName << ').' << cr.
	moduleDeclarationCode << '-export([do/1]).' << cr.
	moduleDeclarationCode << '-define( CALL( Role, Statement, NounValues ), ?TBD( Role, Statement, NounValues ).' << cr.
	"TODO: Define TBD string (see above) - Call is routed to appropriate Hum Dispatcher via Hum Messenger."
	"Following causes compiler to show macro expansion. "
	moduleDeclarationCode << '-compile:file( File, [' <<quote << 'P' << quote << ']).' << cr.
	
	"Generate the logic for each action frame."
	moduleLogicCode := ReadWriteStream on: ''.
	actionStatements := self ontology actionsOf: aRoleName.
	self assert: (actionStatements size > 0).
	actionStatements 
		do: [ :actionStatement | 
			| actionHeader frame frameLines |
			actionHeader := self generateErlangForActionHeader: actionStatement source.
			moduleLogicCode << actionHeader.
			frame := self ontology getFrameForRole: aRoleName capitalized  action: actionStatement.
			frameLines := frame frameLines.
			self assert: (frameLines size > 0).
			frameLines do: [ :frameLine |  
					| erlangInstruction |
					erlangInstruction := self generateErlangForInstruction: frameLine. "Already contains needed cr."
					moduleLogicCode << erlangInstruction.
					].
			moduleLogicCode << '  okay.' << cr << cr.	"Final line of function -- returns okay."
			].
	
	^moduleDeclarationCode contents, moduleLogicCode contents.
	
	
]

{ #category : #'translate to Erlang' }
HumOntologyTranslator >> generateErlangForRoles [
	"Generate a Erlang module file for each Hum role."
]

{ #category : #'translate to Erlang' }
HumOntologyTranslator >> generateErlangForSelfCall: aString [
	"Translate a Hum Self call into an Erlang self call."
	| erlang statementString nounValues quote |
	self assert: (aString isKindOf: String).
	self assert: ( '*:*' match: aString ) not.
	statementString := aString trimBoth.
	[ statementString beginsWith: '. '] 
		whileTrue: [ statementString := statementString copyFrom: 3 to: (statementString size) ].
	"TODO: HumStatement knows how to parse better than above. It knows about comments and annotations."
	nounValues := self generateErlangNounValuesForStatement: statementString.
	quote := $' asString.
	erlang := 'do( { ', quote, statementString, quote, ', [ ', nounValues, ' ] } ),'.
	^erlang
	

]

{ #category : #'translate to Erlang' }
HumOntologyTranslator >> generateErlangNounValuesForStatement: aStatementString [
	|  statementNouns nounValueTuples firstNoun quote |
	"Get statement nouns."
	statementNouns := self ontology nounsInStatement: aStatementString.
	self assert: ( statementNouns size > 0 ). 
	quote := $' asString.
	nounValueTuples := ReadWriteStream on: ''.
	firstNoun := true.
	statementNouns do: [ :noun |
		(firstNoun) ifFalse: [ nounValueTuples << ', ' ].  "After the first noun, we need a comma separator."
		firstNoun := false.
		nounValueTuples << '{' << quote << noun << quote.
		nounValueTuples << ', ' << ( (self ontology nounAsCamelCase: noun ) capitalized ) << '}'.
		].	
	^ nounValueTuples contents.

]

{ #category : #'translate to HTML' }
HumOntologyTranslator >> generateHTMLforMarkupLines: aListOfFrameLines blackboard: aBlackboard [
	"Build HTML for the given list of frame-lines"
	|  remainder calc source translator2 cr |
	cr := String cr.
	calc := HumCalculator new.
	"My code produces side-effect in instance-variable 'html', (shame on me)
	 so I need another instance as helper.
	TODO: Refactor this generator to make it properly recursive without side-effects.
	"
	translator2 := HumOntologyTranslator new.
	
	aListOfFrameLines
		do: [:frameLine | 
			source := frameLine source.
			calc cases; "Start case block"
			   when: [source = ''] 
			   then:["blank line indicates paragraph break"
					     self genHTML: '<br/>'
					    ];
				 when: [source beginsWith: '!']
				 then: [ "Generate heading"
							| level n |
							level := self countLeading: '!' inString: source.
							remainder := source copyFrom: level+1 to: source size.
							n := level asString.
							self genHTML: '<h',n,'>'
							            , ([translator2 generateHTMLforMarkupString: remainder blackboard: aBlackboard.
								              translator2 html contents.] value)
							            , '</h',n,'>',cr.
							];
				 when: [source beginsWith: '-']
				 then: [ "Generate list item. Let CSS do the indent."
							| level n |
							level := self countLeading: '-' inString: source.
							remainder := source copyFrom: level+1 to: source size.
							n := level asString.
							self genHTML: '<item',n,'> &bull; '
							            , ([translator2 generateHTMLforMarkupString: remainder blackboard: aBlackboard.
								              translator2 html contents.] value)
							            , '</item',n,'>'.
							];
				when: [ source beginsWith: '|']
				then: [ | columns |
					      columns := source findTokens: '|'.
					      self genHTML: '<tr>'.
							  columns do: [:column |
								  translator2 := HumOntologyTranslator ontology: (self ontology).
								  translator2 generateHTMLforMarkupString: column blackboard: aBlackboard.
								  self genHTML: '<td>',(translator2 html contents),'</td>'.
								  ].
					      self genHTML: '</tr>'.
					    ];		
				otherwise: [
					remainder := self generateHTMLforMarkupString: source blackboard: aBlackboard. 
					"There should be no remainder"
					self assert: (remainder = '').
					].
			].
    ^self html contents.
]

{ #category : #'translate to HTML' }
HumOntologyTranslator >> generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard [
	"Build output until we see a substring matching aStopString."
	"When we need to recurse, 
	  we pass the remainder of line.
	WARNING: Results are appended to 'html' instance-variable.
	"
	|  remainder |
	remainder := aMarkupString. 
	
	"Emphasis patterns.  (bold, italic, underline, superscript)"
	remainder := self when: remainder matchesPattern: '*1*' produce: [:x | self genHTML: '<b>',x,'</b>'].
	remainder := self when: remainder matchesPattern: '~1~' produce: [:x | self genHTML: '<i>',x,'</i>'].
	remainder := self when: remainder matchesPattern: '_1_' produce: [:x | self genHTML: '<u>',x,'</u>'].
	remainder := self when: remainder matchesPattern: '^1^' produce: [:x | self genHTML: '<sup>',x,'</sup>'].

	"Hypertext"
	remainder := self when: remainder matchesPattern: '[link:1|2]' 
	               produce: [:x :url |  self genHTML: '<a href="',url trimBoth,'">',x trimBoth,'</a>'].

	remainder := self when: remainder matchesPattern: '[image:1|2]' 
	               produce: [:x :url |  self genHTML: '<img src="',url trimBoth,'" alt="',x trimBoth,'"/>'].
	
	remainder := self when: remainder matchesPattern: '[page:1]' 
								produce: [:x | 
									| filename |
									filename := (x asCamelCase),'.html'.   "Should work in most file systems"
									self genHTML: '<a href="',filename,'">',x,'</a>'].
	
	"Delegate to another pane."
	remainder := self when: remainder matchesPattern: '[pane:1]' 
								produce: [:x | 
									(ontology isViewName: x) 
										ifFalse: [ self humParserError: ('Expected view name but found: ', x)  inCodeFragment: remainder]
										ifTrue: [ | frame frameLines |
											frame := ontology fetchFrameByName: x.
											frameLines := frame frameLines.
											self generateHTMLforMarkupLines: frameLines blackboard: aBlackBoard.
											]. 
										].
	"Button"
	"Treat button as a special case?"
	remainder := self when: remainder matchesPattern: '[[1]]' 
	               produce: [ :x | 
		                       | buttonLabel buttonType |
		                       buttonLabel := x trimBoth.
		                       buttonType := buttonLabel asLowercase.
                           ( #('submit' 'reset' ) includes: (buttonType) ) ifFalse: [buttonType := 'button'].		
		                       self genHTML: '<button name="',buttonLabel,'" type="',buttonType,'">',buttonLabel,'</button>'.
		                      ].
	
	"Radio Button or Comment"
	remainder := self when: remainder matchesPattern: '(1)'
		               produce: [:x | 
									"Is a radio button intended?"
									(x size = 1 ) 
									   ifTrue: [ self genHTML: '<input name="',x,'" type="radio"/>']
									  ifFalse: [ "Parse the interior of the comment -- It might contain links, etc."
										  self genHTML: (self generateHTMLforMarkupString: x blackboard: aBlackBoard).	
										  ]
									].

	"Input widgets"
	"TODO: When view is invoked with 'Show:' rather than 'Ask:', the input fields should be disabled."
	remainder := self when: remainder matchesPattern: '[1`s 2]'  "[entity`s attribute]"
								produce: [:entity :attribute | 
									( ontology isAttribute: attribute )
										ifFalse: [ self humParserError: ('Expected attribute name but found: ', attribute) inCodeFragment: remainder]
										ifTrue: [| value |
											value := aBlackBoard getEntityName: entity attribute: attribute.
											self genHTML: '<input type="text" name="', entity,':',attribute, 
											              '" value="',(value ifNil: ''),'"/>'.
											"TODO: Adapt input to datatype." 
											].
									].
	
	remainder := self when: remainder matchesPattern: '[1 2]'   "text widget"
								produce: [:textAttribute :rows | 
									( ontology isAttribute: textAttribute )
										ifFalse: [ self humParserError: 'Expected attribute name but found: ', textAttribute ]
										ifTrue: [| value |
											value := aBlackBoard getEntityName: contextEntity attribute: textAttribute.
											self genHTML: '<textarea type="text" name="', textAttribute,'" rows="',rows,'">'
											           ,(value ifNil: ['']),'</textarea>'. 
											].
									].
								
	remainder := self when: remainder matchesPattern: '[1]'    "attribute widget" 
								produce: [:attribute | 
									"Catch checkbox case"
									( attribute size = 1 )
										ifTrue:["Generate checkbox widget."
											self genHTML: '<input type="checkbox" name="', attribute,'"/>'.
											]
                     ifFalse: ["Generate attribute input widget."
	                     ( ontology isAttribute: attribute )
										    ifFalse: [ self humParserError: ('Expected attribute name but found: ', attribute) inCodeFragment: remainder ]
										    ifTrue: [| value |
									     		value := (aBlackBoard getEntityName: contextEntity attribute: attribute) ifNil: [''].
											    self genHTML: '<input type="text" name="', contextEntity,':',attribute, '" value="',value,'"/>'.
											    "TODO: Adapt input to datatype.
											     . Category should be drop-down or small radio group.
												. Measure should be number plus drop-down.
												. Date should be . . .
												. Money should be . . .
												. Duration should be . . .
											    " 
											    ].
                       ].
									].
	
	
	"table row -- Should be implemented elsewhere."
	self assert: ( remainder beginsWith: '|' ) not.
  "Just ordinary text."
  ( (remainder findTokens: '*~_^[]|()' keep: '*~_^[]|()') size <= 1 )
		ifTrue: [ "Consume remainder"
			self genHTML: remainder.
			^remainder := ''.			
			].
  "Recurse"
	self assert: (remainder beginsWith: ']' ) not.
	^self generateHTMLforMarkupString: remainder blackboard: aBlackBoard.
	
]

{ #category : #'translate to HTML' }
HumOntologyTranslator >> generateHTMLforViewFrame: aHumFrame4View blackboard: aHumBlackBoard [ 
	"Wrap viewframe lines with  HTML form and submit logic."
	| calc formHTML innerHTML formAttributes |
	"Translate the Hum markup"
	self contextEntity: aHumFrame4View entity.
	innerHTML := self generateHTMLforMarkupLines: (aHumFrame4View frameLines) blackboard: aHumBlackBoard.
	"Add a submit button"
	innerHTML := innerHTML, String cr, ' <input type="submit" value="Go!"   style="color:WHITE; background:GREEN"/>'.
	"The user might not be ready to fill-in-the-blanks. Give user a way to decline."
	innerHTML := innerHTML, String cr, ' <input type="submit" value="NoGo!" style="color:WHITE; background:RED"/>'.
	"TODO: The Scribe must interpret 'Go!' versus 'NoGo!' -- to invoke appropriate dialog vignette."

	"Wrap in a form."
	formAttributes := Dictionary new.
	formAttributes
		at: 'id'     put: aHumFrame4View title;
		at: 'action' put: aHumFrame4View title;
		at: 'method' put: 'POST';
		at: 'enctype' put: 'application/x-www-form-urlencoded'; "Is this really needed? Is is correct for my intent?"
		at: 'class' put: 'Ask'.
	calc := HumCalculator new.
	formHTML := calc xml: 'form' dictionary: formAttributes with: innerHTML.
	^formHTML.
]

{ #category : #'translate to Java' }
HumOntologyTranslator >> generateJavaCallForFrameLine: aHumInstructionLine [ 
	| instructionCode statementCode roleCode commentCode cr documentation tab indentation  |
	self assert: (aHumInstructionLine isKindOf: HumInstructionLine).
self halt.
	roleCode := 'this'.
	commentCode := ''.
	cr := String cr.
	"space := Character space asString."
	tab := Character tab asString.
	indentation := (1 to: (aHumInstructionLine indent)) inject: '' into: [:s :next | s, tab ]. 

	documentation := '/** ', (aHumInstructionLine source ), ' */', cr.

	statementCode := self generateJavaCallForStatement: (aHumInstructionLine statement ).
	"Generate optional code if role or comment is present."
	aHumInstructionLine onRole: [ roleCode := ' a', (aHumInstructionLine role capitalized) ].
	aHumInstructionLine onComment: [ commentCode := ('/* ', (aHumInstructionLine comment ), ' */'). ].
	"Generate Java code -- depending on type of statement."
	(aHumInstructionLine statement isConditional ) "Does the statement begin with For/If/Else ???"
		ifTrue: [ instructionCode := indentation, documentation, indentation, statementCode, commentCode. ]
		ifFalse: [instructionCode := indentation, documentation, indentation, roleCode,'.', statementCode, '; ', commentCode. ].
	^instructionCode.
]

{ #category : #'translate to Java' }
HumOntologyTranslator >> generateJavaCallForStatement: aHumStatement [ 
	| nouns code comma space parend |

	code := ''.
	space := ' '.
	comma := ','.
	parend := ' )'.
	code := code, (aHumStatement asCamelCaseWithOntology: ontology),'('.
	nouns := ontology nounsInStatement: aHumStatement.
	nouns
		do: [ :aNoun | 
				| javaNoun |
				javaNoun := aHumStatement nounAsCamelCase: aNoun.
				code := code, space, 'a', javaNoun capitalized, comma.
				].
	code := code, parend.
	( code endsWith: (comma, parend ) ) 
		ifTrue: [ code := (code copyFrom: 1 to: (code findString: (comma, parend))-1), parend ].
	self assert: ( code endsWith: parend ).
	self assert: (( code endsWith: (comma, parend) ) not).			
	self assert: ( '*, )*' match: code ) not.
	^code.
]

{ #category : #'translate to Java' }
HumOntologyTranslator >> generateJavaConditionalForStatement: aHumStatement [ 
	| code source |
	code := ''.
	source := aHumStatement source.
	(source beginsWith: 'For ' )
		ifTrue: [ code := self generateJavaIterationForStatement: aHumStatement ].
	( source beginsWith: 'If ')
		ifTrue: [ code := self generateJavaIfForStatement: aHumStatement ].
	( source beginsWith: 'Else:')
		ifTrue: [ code := self generateJavaElseForStatement: aHumStatement ].		
	self assert: ( code = '' ) not.
	^code.
]

{ #category : #'translate to Java' }
HumOntologyTranslator >> generateJavaForFrame: aHumFrame4Action [ 
	"Translate frame to Java using the nouns given in the ontology."
	| selectorCode frameCode cr indentation priorIndent space tab javaDoc |
	cr := String cr.
	space := $   asString.
	tab := String tab.
	indentation := tab.
	javaDoc := '/** ', aHumFrame4Action actionStatement asString,' */'.
	selectorCode := self generateJavaMethodDeclarationForStatement: aHumFrame4Action actionStatement.
	frameCode := ''.
	priorIndent := 0.
	( aHumFrame4Action frameLines ) 
		do: [ :frameLine |
			(frameLine indent < priorIndent ) 
				ifTrue: [ "Insert a block-end bracket with appropriate indent."
					indentation := (1 to: priorIndent) inject: '' into: [:s :next | s, tab ]. 
					frameCode := frameCode, cr, indentation, '}'.
				].
			frameCode := frameCode, cr, (self generateJavaForFrameLine: frameLine).
			"TODO: Translate if/else/for"
			priorIndent := frameLine indent.
			].
	^ javaDoc, cr, selectorCode, space, '{', frameCode, cr, '}' .
]

{ #category : #'translate to Java' }
HumOntologyTranslator >> generateJavaForFrameLine: aHumInstructionLine [ 
	| instructionCode statementCode roleCode commentCode cr documentation tab indentation  |
	roleCode := 'this'.
	commentCode := ''.
	cr := String cr.
	"space := Character space asString."
	tab := Character tab asString.
	indentation := (1 to: (aHumInstructionLine indent)) inject: '' into: [:s :next | s, tab ]. 

	documentation := '/** ', (aHumInstructionLine source ), ' */', cr.

	statementCode := self generateJavaForStatement: (aHumInstructionLine statement ).
	"Generate optional code if role or comment is present."
	aHumInstructionLine onRole: [ roleCode := ' a', (aHumInstructionLine role capitalized) ].
	aHumInstructionLine onComment: [ commentCode := ('/* ', (aHumInstructionLine comment ), ' */'). ].
	"Generate Java code -- depending on type of statement."
	(aHumInstructionLine statement isConditional ) "Does the statement begin with For/If/Else ???"
		ifTrue: [ instructionCode := indentation, documentation, indentation, statementCode, commentCode. ]
		ifFalse: [instructionCode := indentation, documentation, indentation, roleCode,'.', statementCode, '; ', commentCode. ].
	^instructionCode.
]

{ #category : #'translate to Java' }
HumOntologyTranslator >> generateJavaForPlanFrame: aHumFrame4Plan [ 
	"The plan is data, so translation involves translating each goal frame into a series of Java setters.
	/* prologue */
	public HumPlan plan = new HumPlan();
	public HumPlanFrame frame = new HumPlanFrame();
	/* for each goal frame in the ontology */
	frame.setGoal('...')
		.addPrecondition('...')
		.addPrecondition('...')
		.addAction('...');
	plan.addGoalFrame(frame);	
	"
	| javaCode goalStatement indent |
	javaCode := String new.
	indent := '  '.
	goalStatement := aHumFrame4Plan goal source.
	javaCode := indent, 'planFrame.setGoal("', goalStatement, '")'.
	aHumFrame4Plan preconditions do: [  :precondition |
		javaCode := javaCode, String cr, indent, indent, '.addPrecondition("', precondition source, '")'].
	aHumFrame4Plan planActions do: [  :action |
		javaCode := javaCode, String cr, indent, indent, '.addAction("', action source, '")' ].
	^javaCode.
]

{ #category : #'translate to Java' }
HumOntologyTranslator >> generateJavaForStatement: aHumStatement [ 
	| code  |

	"TODO -- This will fail if there is a comment appended to the statement."
	( aHumStatement isConditional ) 
		ifTrue: [ code := self generateJavaConditionalForStatement: aHumStatement ]
		ifFalse: [code := self generateJavaCallForStatement: aHumStatement . ].		
	^code
]

{ #category : #'translate to Java' }
HumOntologyTranslator >> generateJavaIterationForStatement: aHumStatement [ 
	"Given a Hum for-statement, generate a Java for-statement."
	| code |
	"TODO: Refactor this to use a template. (Should be cleaner code.)"

	aHumStatement onMatch:  'For each 1 in the 2:' do: [ :item :container |
	code := 'for ( ', (aHumStatement nounAsCamelCase: item) capitalized
				, ' ', (aHumStatement nounAsCamelCase: item) 
		           , ' : ', (aHumStatement nounAsCamelCase: container ),'.',(aHumStatement nounAsCamelCase: item),'s' 
		           , ' )  {' ].
	^code.
]

{ #category : #'translate to Java' }
HumOntologyTranslator >> generateJavaMethodDeclarationForStatement: aHumStatement [ 
	| nouns code comma space parend |

	code := ''.
	space := ' '.
	comma := ', '.
	parend := ' )'.
	code := code,'public void ', (aHumStatement asCamelCaseWithOntology: ontology),'( '.
	nouns := ontology nounsInStatement: aHumStatement.
	nouns
		do: [ :aNoun | 
			| javaNoun |
			javaNoun := aHumStatement nounAsCamelCase: aNoun.
			code := code, javaNoun capitalized , space, 'a', javaNoun capitalized, comma.
			].
	code := code, parend.
	( code endsWith: (comma, parend ) ) 
		ifTrue: [ code := (code copyFrom: 1 to: (code findString: (comma, parend))-1), parend ].
	self assert: ( code endsWith: parend ).
	self assert: (( code endsWith: (comma, parend) ) not).			
	self assert: ( '*, )*' match: code ) not.
	^code.
]

{ #category : #'translate to JavaScript Angular' }
HumOntologyTranslator >> generateJavaScriptAngularReadMe [
	"Angular is a JavaScript user interface framework."
	"Angular-Bootstrap simplifies the programming of layouts and rich interface effects."
	self shouldNotImplement.
]

{ #category : #'translate to Smalltalk Seaside' }
HumOntologyTranslator >> generateSeasideForView: aHumFrame4View [ 
	"Implement the view frame via Seaside components.
	This is a code generator.
	"
	| tab cr frameCode |
	
	self moveCodeGenerator.
	
	cr := String cr.
	tab := String tab.
	frameCode := String new.
	frameCode := frameCode, tab, 'html form with: [ ', cr.
	aHumFrame4View frameLines
		do: [ :line |
			| lineCode |
			"Generate Seaside code for each line in the view frame"
			lineCode := self generateSeasideForViewMarkup: line.
			frameCode := frameCode, tab, tab, lineCode, cr.
			"TODO: SUSPECT THERE SHOULD BE A COMMA IN GENERATED CODE ABOVE."
			].
	frameCode := frameCode, tab, tab,  ']', cr.
	^frameCode.
]

{ #category : #'translate to Smalltalk Seaside' }
HumOntologyTranslator >> generateSeasideForViewMarkup: aHumMarkupLine [ 
	"Generate Seaside code to implement a view mark-up line."
	| lineCode  fieldName source|
	
	self moveCodeGenerator.

	"Parse into tokens"
	source := aHumMarkupLine source.
	lineCode := String new.
	lineCode := lineCode, 'html break. '.

	"Generate for heading"
	(source beginsWith: '!' ) 
		ifTrue: [ lineCode := lineCode, (self generateSeasideHeadingFor: source )]. 
	
	"Generate input fields."
	fieldName := ( HumCalculator given: source extractBetween: '[' and: ']' ).
	fieldName ifNotNil: [ lineCode := lineCode, (self generateSeasideWidgetForField: fieldName )].
	
	^lineCode. 
]

{ #category : #'translate to Smalltalk Seaside' }
HumOntologyTranslator >> generateSeasideHeadingFor: source [
	"Generate Seaside heading code for the given heading line."
	| headingString end outlineCode  quote period|
		
	self moveCodeGenerator.

	self assert: (source beginsWith: '!' ).
	quote := $' asString.
	period := $. asString. 
  headingString := source. 
	end := headingString size.						
						
	(source beginsWith: '!' ) 
		ifTrue: [ outlineCode := 'html heading level: 1; with: ',
			                        quote, (headingString copyFrom: 1+1 to: end), quote, period. ].
	(source beginsWith: '!!' ) 
		ifTrue: [ outlineCode := 'html heading level: 2; with: ',
			                        quote, (headingString copyFrom: 2+1 to: end), quote, period. ].
	(source beginsWith: '!!!' ) 
		ifTrue: [ outlineCode := 'html heading level: 3; with: ',
			                        quote, (headingString copyFrom: 3+1 to: end), quote, period. ].
	(source beginsWith: '!!!!' ) 
		ifTrue: [ outlineCode := 'html heading level: 4; with: ',
			                        quote, (headingString copyFrom: 4+1 to: end), quote, period. ].
	(source beginsWith: '!!!!!' ) 
		ifTrue: [ outlineCode := 'html heading level: 5; with: ',
			                        quote, (headingString copyFrom: 5+1 to: end), quote, period. ].
	^outlineCode.
]

{ #category : #'translate to Smalltalk Seaside' }
HumOntologyTranslator >> generateSeasideWidgetForField: fieldName [
	| widgetCode commentCode semicolon period|
	
	self moveCodeGenerator.

  self assert: ( fieldName notNil ).
 	semicolon := $; asString.
	period := $. asString.

	"This is the default to cover when we fall through the cases."
	commentCode := ' "*** Widget not handled [', fieldName,'] ***" '.

	"Does widget contain a colon. If not, we have a simple attribute."
	( fieldName includesSubString: ':' ) 
		ifFalse: [ 
					commentCode := '"*** Update attribute [',fieldName,'] ***"'.
					widgetCode := 'html textInput'
					  ,' callback: [:datum | self blackBoard setEntityID: entityID attribute: #', fieldName
						,' toValue: datum ]'
					  , semicolon
					  ,' name: ', (fieldName surroundedBySingleQuotes)
					  , semicolon
					  ,' value: ',(fieldName surroundedBySingleQuotes)
						, period. 
					( fieldName size = 1 )  "Over-ride and invoke a Seaside checkbox instead."
						ifTrue: [ commentCode := '"*** TODO: Generate code for check-box: [',fieldName,'] ***' ].	
					].
	"TODO: REFACTOR above so that it is more sensitive to the attribute`s data-type. 
	Text should render as text-area.
	A category should render as a select or radio group.
	A date-time as a date-picker.
	A set or list should render as a table.
	Perhaps a measure should render as text (validated to numeric) plus a select (of unit-of-measure).
	"

	( fieldName beginsWith: 'page:')
		ifTrue: [ | pageName | "[page: local page reference]"
					pageName := ( HumCalculator given: fieldName extractAfter: 'page:' ).
					commentCode := ' "*** Generate code for page: ', pageName ,'****" '.
					widgetCode := widgetCode, 'html anchor '
											,'url: ', (('./',(pageName asCamelCase)) surroundedBySingleQuotes)
											, semicolon
											,'with: ', (pageName surroundedBySingleQuotes )
											, period.
					].
	( fieldName beginsWith: 'link:')
		ifTrue: [  "[link: text | uri ]"
				| linkName linkURL |
				linkName := ( HumCalculator given: fieldName extractBetween: 'link:' and: '|' ).
				linkURL := ( HumCalculator given: fieldName extractAfter: '|').
				commentCode := ' "*** Generate code for link: ', linkName ,'****" '.
				widgetCode := widgetCode, 'html anchor '
											,'url: ', ( linkURL surroundedBySingleQuotes )
											, semicolon
											,'with: ', ( linkName surroundedBySingleQuotes )
											, period.
					].
	( fieldName beginsWith: 'pane:')
		ifTrue: [ | paneName | "[pane: name of a Hum view]"
					paneName := ( HumCalculator given: fieldName extractAfter: 'pane:' ).
					commentCode := ' "*** Generate code for pane: ', paneName, '****" '.
					
					widgetCode := '(self ontology fetchFrameByName: ', paneName
											,') asSeasideWithOntology: (self ontology)', period.
					].
	"TODO: Hum panes need to be enclosed in table <td> or perhaps <div> 
	 . . . so that they can be placed side-by-side.
	 . . . (The alternative using CSS {position: ABSOLUTE} is much more difficult.)
	PERHAPS: We might require that the author indicate the table like this:
	| [pane: left-navigation] | [pane: content] | 
	That would simplify the code generation, 
	  but it leaks HTML constraints to the view code.
	In any case, this code-block needs to 'call' the view-code.
	"
					
	^ commentCode, String cr, widgetCode.

]

{ #category : #'translate to Smalltalk Seaside' }
HumOntologyTranslator >> generateSeasideWidgetsForSource: aSourceString [
	"Generate Seaside calls for the widgets found in this mark-up line."
	| calc between before after wip |
	
	self moveCodeGenerator.

	"*** CALLER MUST REPLACE ALL [] WITH {} BECAUSE WE GENERATE [] IN SEASIDE CODE. ***"
	wip := aSourceString.
	
	"Match button."
	( '*{{*}}*' match: wip )
		ifTrue: [ calc := HumCalculator new.
			between := calc given: wip extractBetween: '{{' and: '}}'.
			before := calc given: wip extractUpto: '{{'.
			after  := calc given: wip extractAfter: '}}'.
			wip := before,'<button name="',between,'" />'.
			"Get all the buttons before we go on."
			wip := wip, (self generateSeasideWidgetsForSource: after).
			].
	"Match check-box" 
	( '*{#}*' match: wip )
		ifTrue: [ calc := HumCalculator new.
			between := calc given: wip extractBetween: '{' and: '}'.
			before := calc given: wip extractUpto: '{'.
			after  := calc given: wip extractAfter: '}'.
			wip := before,'<input name="',between,'" type="checkbox"/>'.
			"Get all the check-boxes before we go on."
			wip := wip, (self generateSeasideWidgetsForSource: after).
			].
	"Match other widgets."
	( '*{*}*' match: wip )
		ifTrue: [ calc := HumCalculator new.
			between := calc given: wip extractBetween: '{' and: '}'.
			before := calc given: wip extractUpto: '{'.
			after  := calc given: wip extractAfter: '}'.
			
       "Name followed by space and digit means multi-line text box"
			( between matchesRegex: '^.*\b\d$'  )
				ifTrue: [ | name d |
					name := calc given: between extractUpto: ' '.
					d := calc given: between extractAfter: ' '.
					wip := before,'<textarea name="',name,'" rows=',d,' cols=60 /></textarea>'.
					wip := wip, (self generateSeasideWidgetsForSource: after).
					]
				ifFalse: ["Not a textarea . . ."
					"TODO: If the attribute-name is plural, render as a table."
					| noun |
					noun := between.
					(ontology isPluralNoun: noun)
						ifFalse: [wip := before,'<input name="',between,'" />',after.]
						ifTrue:  [wip := before, (self generateSeasideTableFor: noun ), after.].
					].
			"TODO: Special handling for other types: category, date-time, measure."
			].
	"Match radio-button -- TODO: THIS RADIO BUTTON STRATEGY WILL FAIL."	
	( '*(#)*' match: wip )
			ifTrue: [ calc := HumCalculator new.
			between := calc given: wip extractBetween: '(' and: ')'.
			self assert: (between size = 1).
			before := calc given: wip extractUpto: '('.
			after  := calc given: wip extractAfter: ')'.
			"Call myself recursively"
			wip := before,'<input name="',between,'" type="radio"/>'.
			wip := wip, (self generateSeasideWidgetsForSource: after).
			"TODO: Need <group> tags."
			].
		
	^wip.	

]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslator >> generateSmalltalk [
	"This is crude version.
	Futures:
	- Roles become classes.
	- Entity-Attribute relations become class accessors.
	- Noun types are one of: ( Entity Category Enumeration String Measure TimeStamp ).
	- Dialogs are become method calls with blocks.
	- Views are still interpreted.
	"
	| code |
	code := ''.
	ontology framesByName
		keysAndValuesDo: [  :frameName :frame |
			| frameCode |
			frameCode := self generateSmalltalkForFrame: frame.
			code := code, frameCode.
			].
	^ code.
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslator >> generateSmalltalkActionFor: aHumFrame4Action [ 
	"Translate frame to Smalltalk using the nouns given in the ontology."
	| selectorCode frameCode priorIndent cr tab indentation |
	cr := String cr.
	tab := String tab.
	selectorCode := self generateSmalltalkForStatement: aHumFrame4Action actionStatement.
	"Translate the lines. Adding block ends when indent is reduced."
	frameCode := ''.
	priorIndent := 0.
	aHumFrame4Action frameLines
		do: [ :line |
			| lineCode |
			(line indent < priorIndent ) 
				ifTrue: [ "Insert a block-end bracket with appropriate indent."
					indentation := (1 to: priorIndent) inject: '' into: [:s :next | s, tab ]. 
					frameCode := frameCode, indentation, '].', cr.
				].
			lineCode := self generateSmalltalkForFrameLine: line.
			frameCode := frameCode, lineCode,  cr.
			priorIndent := line indent.
			].
	^ selectorCode, String cr, frameCode .

]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslator >> generateSmalltalkForConditional: aHumStatement [ 
	| code source|
	code := ''.
	source := aHumStatement source.
	(source beginsWith: 'For ' )
		ifTrue: [ code := self generateSmalltalkIterationFor: aHumStatement ].
	( source beginsWith: 'If ')
		ifTrue: [ code := self generateSmalltalkIfFor: aHumStatement ].
	( source beginsWith: 'Else:')
		ifTrue: [ code := self asSmalltalkElse ].		
	self assert: ( code = '' ) not.
	^code.
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslator >> generateSmalltalkForFrame: aHumFrame [
	"Translate frame to Smalltalk using the nouns given in the ontology."
	| frameCode |
	(aHumFrame isKindOf: HumFrame4Action) ifTrue: [ ^self generateSmalltalkActionFor: aHumFrame ].
	frameCode := ''.
	aHumFrame frameLines
		do: [ :line |
			| lineCode |
			lineCode := self generateSmalltalkForFrameLine: line.
			frameCode := frameCode, lineCode, String cr.
			].
	^frameCode.
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslator >> generateSmalltalkForFrameLine: anInstructionLine [ 
	| instructionCode statementCode roleCode commentCode quote cr documentation tab indentation  |
	self assert: (anInstructionLine isKindOf: HumInstructionLine).
	roleCode := ' self'.
	commentCode := ''.
	quote := $" asString.
	cr := String cr.
	"space := Character space asString."
	tab := Character tab asString.
	indentation := (1 to: (anInstructionLine indent)) inject: '' into: [:s :next | s, tab ]. 

	documentation := quote, (anInstructionLine source ), quote, cr.

	statementCode := self generateSmalltalkForStatement: (anInstructionLine statement ).
	anInstructionLine onRole: [ roleCode := ' a', (anInstructionLine role capitalized) ].
	anInstructionLine onComment: [ commentCode := (quote, (anInstructionLine comment ), quote). ].
	(anInstructionLine statement isConditional ) 
		ifTrue: [ instructionCode := indentation, documentation, indentation, statementCode, commentCode. ]
		ifFalse: [instructionCode := indentation, documentation, indentation, roleCode, ' ', statementCode, '. ', commentCode. ].
	^instructionCode.
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslator >> generateSmalltalkForStatement: aHumStatement [ 
	| nouns code  colon space |
	"TODO -- This will fail if there is a comment appended to the statement."
	( aHumStatement isConditional ) 
		ifTrue: [ code := self generateSmalltalkForConditional: aHumStatement. 
			^code ].
	code := ''.
	colon := ':'.
	space := ' '.
	code := code, ( aHumStatement asCamelCase ), 'Q'.
	nouns := ontology nounsInStatement: aHumStatement.
	nouns
		do: [ :aNoun | 
			| camelCase |
			camelCase := aHumStatement nounAsCamelCase: aNoun.
			code := code, camelCase, colon, space, 'a', camelCase capitalized, space.
			].		
	^code
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslator >> generateSmalltalkIfFor: aHumStatement [ 
	"Translate a Hum if-statement into a Smalltalk (  ) ifTrue: [] expression."
	| code  statement smalltalkIf |
	statement := aHumStatement.
	code := ''.
	"TODO: Refactor this to use a template. (Should be cleaner code.)"
	"TODO: Refactor to make the operator an argument."
	smalltalkIf := [:entity1 :attribute2 :entity3 :attribute4 :op |
		'(  ( blackboard entity: ',(statement nounAsCamelCase: entity1 ) quoted
					            , ' attribute: ',  (statement nounAsCamelCase: attribute2 ) quoted
							, ' ) ',op,' ( blackboard entity: ', (statement nounAsCamelCase: entity3 ) quoted
							, ' attribute: ', ( statement nounAsCamelCase: attribute4 ) quoted
							, ' ) )  ifTrue: ['
		].
	statement onMatch: 'If 1 2 is greater than 3 4 :'
				do: [ :entity1 :attribute2 :entity3 :attribute4 |
					^code := smalltalkIf valueWithArguments: { entity1. attribute2. entity3. attribute4. '>'.}
					].
	statement onMatch: 'If 1 2 > 3 4 :'
				do: [ :entity1 :attribute2 :entity3 :attribute4 |
					^code := smalltalkIf valueWithArguments: { entity1. attribute2. entity3. attribute4. '>'.}
					].
	statement onMatch: 'If 1 2 is less than 3 4 :'
				do: [ :entity1 :attribute2 :entity3 :attribute4 |
					^code := smalltalkIf valueWithArguments: { entity1. attribute2. entity3. attribute4. '<'.}
					].
	statement onMatch: 'If 1 2 < 3 4 :'
				do: [ :entity1 :attribute2 :entity3 :attribute4 |
					^code := smalltalkIf valueWithArguments: { entity1. attribute2. entity3. attribute4. '<'.}
					].
	statement onMatch: 'If 1 2 = 3 4 :'
				do: [ :entity1 :attribute2 :entity3 :attribute4 |
					^code := smalltalkIf valueWithArguments: { entity1. attribute2. entity3. attribute4. '='.}
					].
	statement onMatch: 'If 1 2 is equal to 3 4 :'
				do: [ :entity1 :attribute2 :entity3 :attribute4 |
					^code := smalltalkIf valueWithArguments: { entity1. attribute2. entity3. attribute4. '='.}
					].
		
	self assert: ( code = '' ) not.
	^code.
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslator >> generateSmalltalkIterationFor: aHumStatement [ 
	|     code statement |
  statement := aHumStatement.
	code := ''.
	statement onMatch:  'For each 1 in the 2:' 
	          do: [ :item :container |
		code := '( self blackboard entity: ', (statement nounAsCamelCase: container) quoted
		           , ' attribute: ', (statement nounAsCamelCase: item ) quoted
		           , ' ) do: [ :', (statement nounAsCamelCase: item), ' | '
			         , String cr
			         , '     | a', (statement nounAsCamelCase: item) capitalized, ' |'
			         , String cr
							 , '     a', (statement nounAsCamelCase: item) capitalized, ' := ', (statement nounAsCamelCase: item), '.'
		]. 
	"TODO: Refactor this to use a template. (Should be cleaner code.)"
	^code.
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslator >> generateSmalltalkOnFile: aFileName [
	"Open file and produce File-Out / File-In format."
     "Following is template for file-out / file-in format."
"
@@Superclass subclass: #@@ClassName
	instanceVariableNames: '@@InstanceVariables'
	classVariableNames: ''
	poolDictionaries: ''
	category: '@@ClassCategory'!
!@@ClassName commentStamp: '@@Stamp' prior: 0!
@@ClassComment!


!@@ClassName methodsFor: '@@MethodCategory' stamp: '@@Stamp'!
@@MethodSelector
	""@@MethodComment""
	| @@LocalVariables |
	@@MethodCode
	!!
"		
	| code |
	self shouldBeImplemented.
	code := ''.
	"This is crude version.
	Futures:
	- Roles become classes.
	- Entity-Attribute relations become class accessors.
	- Noun types are one of: ( Entity Category Enumeration String Measure TimeStamp ).
	- Dialogs become method calls with blocks.
	- Views are translated to Seaside html onRender: methods.
	"
	self framesByName
		keysAndValuesDo: [  :frameName :frame |
			| frameCode |
			frameCode := frame asSmalltalkWithOntology: self.
			code := code, frameCode.
			].

]

{ #category : #'translate to Xamarin C-Sharp' }
HumOntologyTranslator >> generateXamarinReadMe [
	"Xamarin runs on Windows, iOS, and Android devices.  (client side)
	However, some components are platform-specific."
	"See XamarinHQ on YouTube for tutorials."
	self shouldNotImplement.
	
]

{ #category : #'Generate OO Modules' }
HumOntologyTranslator >> getMethodsForClass: aClassName [
	"Get the methods colletion (a Dictionary) for the given Class"
	| methods |
	methods := ( self methodsForClasses ) at: aClassName ifAbsent: [ nil ].
	methods 
		ifNil: [ methods := Dictionary new. 
						( self methodsForClasses ) at: aClassName put: methods.
						].
	^methods.
]

{ #category : #'translate to HTML' }
HumOntologyTranslator >> html [
	^html ifNil: [html := ReadWriteStream on: ''.].
]

{ #category : #debugging }
HumOntologyTranslator >> humParserError: aComplaint inCodeFragment: aCodeFragment [
	|  complaintHTML errorMessage |
	"TODO: In the future, we might not want this to stop execution."
	errorMessage := aComplaint, ' in {',aCodeFragment,'}'.
	Error signal: errorMessage.
	"Generate HTML to embed critique near problem"
	complaintHTML := HumCalculator xml: 'errorNote' with: [ errorMessage ].
	^complaintHTML.
]

{ #category : #'Generate OO Modules' }
HumOntologyTranslator >> methodsForClasses [
	^ methodsForClasses ifNil: [ methodsForClasses := Dictionary new ].
]

{ #category : #'translate to Smalltalk Seaside' }
HumOntologyTranslator >> moveCodeGenerator [
	(self isKindOf: HumOntologyTranslator)
		ifFalse: [Error signal: 'Move this code generator to HumOntologyTranslator'].
]

{ #category : #utility }
HumOntologyTranslator >> nounAsCamelCase: aNoun [ 
	"Generate camel-case string the the given noun."
	| camelCase tokens |
	camelCase := String new.
	tokens := (aNoun trimBoth) findTokens: '-'. 
	tokens do: [  :token | camelCase := camelCase, (token asLowercase capitalized) ].
	"Note: First letter is also capitalized. 
	Caller must decide if this is appropriate to translation."
	^camelCase.
]

{ #category : #'translate to Java' }
HumOntologyTranslator >> nounsAsJava [
	"Emit java code that implements noun relations."
	"Currently this emits all classes into a single code stream. 
	In the future, we might want to find a way to map the stream into separate '.java' files.
	"
	| code entities cr tab semicolon space fnToGetSupertype |
	code := ''.
	cr := String cr.
	tab := String tab.
	semicolon := ';'.
	space := String space.

	"Get a list of the entities."
	entities := Set new.
	( ontology entityAttributes ) do: [ :eachMap |  entities add: (eachMap key) ].

	"Define a private function that determines the correct supertype for a given noun."
	fnToGetSupertype := [ :noun :default | 
			|  typeName supertypes |
			supertypes := ontology immediateSupertypesOf: noun.
			( supertypes size = 0 ) ifTrue: [ typeName := default ].
			( supertypes size > 0 ) ifTrue: [ typeName :=  ( HumOntology nounAsCamelCase:  ( supertypes asSortedCollection at: 1 ) ) capitalized ].
			( supertypes size > 1 ) ifTrue: [Error signal: '// WARNING: Cannot correctly translate ', noun, ' to Java because it has more than one supertype.', cr. ].
			"TODO: Fix this up so that multiple inheritance is correctly handled."
			"Function returns the discovered supertype or the default supertype"
			typeName.
		].

	"Emit a class for each entity."
	( entities asSortedCollection ) do: [ :entity | 
		| attributes extendsSupertype  |
		"Everything extends Entity class -- which provides toHTML(), toXML(), and persistence methods (TBD)."
		extendsSupertype := fnToGetSupertype value:  entity value: 'Entity'.
		"TODO: If the entity has a single superclass, override the extendsSuperType value with that superclass name."
		code := code, cr, 'public class ', (HumOntology nounAsCamelCase:  entity) capitalized , ' extends ', extendsSupertype, ' {', cr.
		"Get the entity's attributes."
		attributes := ontology immediateAttributesOfEntity: entity.
		"Emit instance variable declarations for each attribute. -- Default type is String."
		( attributes asSortedCollection ) do: [ :attribute |
			|  typeName |
			typeName := fnToGetSupertype value: attribute value: 'String'.
			( entities include:  attribute ) ifTrue: [ typeName :=  ( HumOntology nounAsCamelCase:  attribute ) capitalized ].
			"If noun is plural, make the type Bag<Entity>"
			( ontology isPluralNoun: attribute ) 
				ifTrue: [ 
					| singular |
					singular := ontology singularFormOfNoun: attribute.
					typeName := 'Bag<',(HumOntology nounAsCamelCase: singular),'>'  ].
			code := code, tab, 'public ', typeName, space, ( HumOntology nounAsCamelCase: attribute), semicolon, cr.
			].
		"Class ends with closing brace and a comment."
		code := code, '} // Entity: ', (HumOntology nounAsCamelCase:  entity) capitalized, cr.
		].
	"Comment: This demonstrates that entities can be translated to java classes.
	                   It also demonstrates that Hum is ~type-safe~."
	^code.
]

{ #category : #accessing }
HumOntologyTranslator >> ontology [
	^ ontology ifNil: [ontology := HumOntology new.]

]

{ #category : #accessing }
HumOntologyTranslator >> ontology: aHumOntology [ 
	ontology := aHumOntology.
]

{ #category : #accessing }
HumOntologyTranslator >> prologues [
	^ prologues ifNil: [ prologues := Dictionary new ].
]

{ #category : #'translate to Java' }
HumOntologyTranslator >> rolesAsJava [
	| code cr |
	code := ''.
	cr := String cr.
	( ontology roles asSortedCollection   )
		do: [ :role | 
			| actions |
			code := code, cr, '/** Actor: ', role capitalized, 
			             cr, ' * Generated from Hum ontology: ', (ontology fromFile) asString, 
			             cr, ' */'.
			code := code, cr, 'public class ', role capitalized, ' extends Actor { ', cr, cr.
			actions := ontology actionsOf: role.
			
			( actions asSortedCollection )
				do: [ :actionStatement |
					| frame frameCode frameName |
					frameName := 'Role: ', role capitalized, ' -- ', actionStatement source.
					frame := ontology fetchFrameByName: frameName.
					frameCode := self generateJavaForFrame: frame.
					code := code, frameCode.
					].
			code := code, cr, cr, '} // Actor: ', role capitalized, cr.
			].

	^code.
]

{ #category : #'translate to HTML' }
HumOntologyTranslator >> when: aSource matchesPattern: aPattern produce: aBlock [
	| patternStream sourceStream arguments remainder sourceCharacter patternCharacter s uptoMark markupCharacters |
  
	(aSource = '') ifTrue: [ ^aSource ].
	"Convertstrings to streams."
	patternStream := ReadStream on: aPattern.
	sourceStream := ReadStream on: aSource.
	
	"Does source begin with markup?"
	markupCharacters := '~^*_[]()|'.
	uptoMark := String new.
	[ sourceStream atEnd or: [ markupCharacters includes: (sourceStream peek)] ]
		whileFalse:["Output ordinary text until a markup character is seen"
			uptoMark := uptoMark, (sourceStream next asString). 
			].
	( uptoMark size > 0 ) 
	   ifTrue: [ self genHTML: uptoMark.
		   remainder := HumCalculator given: aSource extractAfter: uptoMark.  
		   ^remainder.
		   ].


  "The source must begin with a markup character."
	self assert: ( markupCharacters includes: (sourceStream peek) ).
	
	"If the pattern does not match, 
	  return the source 
	  so that the caller can try another pattern."
	(( patternStream peek ) = ( sourceStream peek )) ifFalse: [^aSource].

  "If there is a match, build the argument list."
	arguments := OrderedCollection new.
	[ patternStream atEnd or: [ sourceStream atEnd ]]
		whileFalse: [ 
				patternCharacter := patternStream next.
				sourceCharacter := sourceStream next.
				( patternCharacter isDigit )
				  ifFalse: ["Compare pattern character to source character."
					  "Does the pattern match the source? 
					   If not, return the source so that caller can try another pattern."
					  ( patternCharacter = sourceCharacter ) ifFalse: [ ^aSource ].
					  ]
					ifTrue: ["Accumulate upto next delimiter or end"
						| nextPatternCharacter |
						nextPatternCharacter := patternStream next.
						s := String new.
						[ sourceStream atEnd or: [ sourceCharacter == nextPatternCharacter ]] 	
							whileFalse: [
								(markupCharacters includes: sourceCharacter) ifTrue: [^aSource].
								s := s, sourceCharacter asString.
								sourceCharacter := sourceStream next.
								].
						arguments add: s.
						].
			].

	"If we matched, run the production block"
	( patternStream atEnd and: [arguments notEmpty] ) 
		ifTrue: [ aBlock valueWithArguments: arguments ]
		ifFalse: [^aSource].

	"Return the remainder of the source."
	remainder := String new.
	[ sourceStream atEnd ] 
		whileFalse: [ remainder := remainder, (sourceStream next asString). ].
  ^remainder.
]
