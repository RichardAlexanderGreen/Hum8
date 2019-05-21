"
The Ontology Viewer renders views of the ontology frames in HTML.

The Ontology Translator is a code generator that translates frames into some executable language.

The Programmers Assistant provides an interactive viewer and editor.

This architecture separates rendering and translating logic from the ontology itself.
Hopefully, this will make the code easier to maintain.


"
Class {
	#name : #HumOntologyViewer,
	#superclass : #Object,
	#instVars : [
		'ontology',
		'lastLevel',
		'modeStack',
		'priorCaseIsTrue',
		'generatedMarkupCode',
		'calc'
	],
	#category : #'Hum-Language'
}

{ #category : #'instance creation' }
HumOntologyViewer class >> ontology: aHumOntology [ 
	| instance |
	instance := self basicNew.
	instance initialize.
	instance ontology: aHumOntology.
	^instance.
]

{ #category : #'render all frames' }
HumOntologyViewer >> asHTML5 [
	"Render the ontology as an HTML5 page.
	. No critique.
	. No base frames.
	"
	| html    |
	html := self asHTML5withCritique: false withBase: false.
	^html
]

{ #category : #'render all frames' }
HumOntologyViewer >> asHTML5withCritique [
	"Render the ontology as an HTML5 page.
	. Include critique.
	. Do not expand base frames.
	"
	| html    |
	html := self asHTML5withCritique: true withBase: false.
	^html
]

{ #category : #'render all frames' }
HumOntologyViewer >> asHTML5withCritique: withCritique withBase: withBase [
	"Render the ontology as an HTML5 page.
	. Since HTML is based on XML, we create XML elements.
	"
	| html heading   |
	"Creating a fresh calculator initializes XML indent."
	calc := HumCalculator new.
	html := calc xml: 'html' 
				with: [ "Build the HTML header"
					      ( calc xml: 'head' 
							with: [ (calc xml: 'title' 
										with: [ (ontology title) asString ]),
									self css.
								   ]),
						"Build the HTML body"	
						(calc xml: 'body'
							with: [ | bodyLines | 
									bodyLines := ''.
									"Render the ontology fiilename, if any, as an HTML5 heading element."
									heading := calc xml: 'heading' with: [  'Ontology: ',(ontology title asString) ].
									(ontology framesByName keysSortedSafely) 
										do: [ :frameName  | 
											| frame |
											frame := ontology framesByName at: frameName.
											"Delegate rendering of the frames to the frames."
											 bodyLines := bodyLines, 
																	( self renderFrame: frame withCritique: withCritique withBase: withBase ).
											"The <hr/> seems to be needed. I cannot figure out how to do that with CSS."
											] .
									heading, bodyLines, String cr, '<hr/>'.
									"The <hr/> also seems to be needed. I cannot figure out how to do that in CSS either."
								   ] )
						].
	"TODO: Add plan-tree rendering.  Render plan-tree for each goal that is invoked in a vignette."
	"See: renderPlanTreeForGoal: aGoal"
	"TODO: Add noun-tree rendeing. Render a noun-tree for each entity."
	"See: renderNounTreeForNoun: aNoun"
	"TODO: Add role-dependency rendering. Render a dependency tree for each role."
	"TODO: Add context-path rendering.  Render the context path diagram starting with 'Start' context. "
	^html.    
]

{ #category : #'render all frames' }
HumOntologyViewer >> asHTML5withCritiqueSkippingBaseOntology [
	"Render the ontology as an HTML5 page.
	. Since HTML is based on XML, we create XML elements.
	"
	| html    |
	html := self asHTML5withCritique: true  withBase: false.
	^html.
]

{ #category : #diagrams }
HumOntologyViewer >> buildDiagramForNoun: aNoun onDiagram: aDiagram [
	"Add the noun`s relationships to that diagram."
	| attributes supertypes |
	attributes := ontology immediateAttributesOfEntity: aNoun.
	attributes do: [ :attribute | aDiagram addConnection:  ( aNoun -> attribute ) label: #attribute ].
	supertypes := ontology allSupertypesOf: aNoun.
	supertypes do: [ :supertype | aDiagram addConnection: ( aNoun -> supertype ) label: #supertype ].
	supertypes do: [ :supertype | self buildDiagramForNoun: supertype onDiagram:  aDiagram ]

	
	
]

{ #category : #diagrams }
HumOntologyViewer >> buildNounTreeForNoun: aNoun indent: anIndentLevel [ 
	""
	|  nounTree subTree singular supertypes properties attributes |
	self assert: (anIndentLevel < 5).
	nounTree := OrderedCollection new.
	attributes := ontology immediateAttributesOfEntity: aNoun.
	supertypes := ontology allSupertypesOf: aNoun.
	properties := attributes, supertypes.
	(properties sorted)
		do: [ :property  |
			nounTree add: ( aNoun -> { anIndentLevel. property.} ).
			singular := ontology singularFormOfNoun: property.
			subTree := self buildNounTreeForNoun: singular indent: (anIndentLevel + 1).
			nounTree := nounTree, subTree.
			"Detect a cycle in the tree."
			( nounTree anySatisfy: [ :map |  (map value at: 2) = aNoun ] ) 
				ifTrue: [ Error signal: 'cycle detected in noun tree' ].
			].	
	^nounTree.	

]

{ #category : #'render all frames' }
HumOntologyViewer >> css [
	"generate HTML Cascading Style Sheet (CSS) code segment"
	| html  |
	calc := HumCalculator new.
	html := calc xml: 'style' 
			with: [' 
				body {font-family: MONOSPACE;}
				heading {font-size: X-LARGE; }			
				title1, title2, title3, title4, title5 {font-weight: BOLD;}
				title1 {font-size: 200%;}
				title2 {font-size: 150%;}
				title3 {font-size: 125%;}
				title4 {font-size: 100%;}

				frameTitle {color: BLUE; font-size: LARGER; font-weight: BOLD;}
				
				n, noun {color: PURPLE;}
				k, keyword {font-weight: BOLD;}
				r, role {font-style: ITALIC;font-weight: BOLD;}
				
				statement {color: BLUE;}
				c, comment {color: GREEN;}
				annotation {}
				
				pattern {}
				markup {font-family: MONOSPACE;}
				widget {color: RED;}		
						
				HumFrame {}
				frameLine, CommentLine, DictionaryLine, PreconditionLine  {margin-left: 1em;}
				InstructionLine {margin-left: 1em; color: BLUE;}	
				InstructionLine.indent1 {margin-left: 1em;}		
				InstructionLine.indent2 {margin-left: 2em;}		
				InstructionLine.indent3 {margin-left: 3em;}		
				InstructionLine.indent4 {margin-left: 4em;}		
					
				textarea {vertical-align: top;}	
				form {border-style: outset; padding: 1em;}
				table {}
				th {background: CYAN;}
				td {background: LIGHTGREY;}
				errorNote { color: DARKRED; }
				critiqueLine { color: DARKRED; margin-left: 1em; }
				commentLine { color: DARKGREEN; margin-left: 1em; }
				' ].
	"TODO: Consider using class='indentN' to control indent in action frames.
	 That would enable multi-level indent in Action Frames.
	"
	^html.
]

{ #category : #'render widgets' }
HumOntologyViewer >> generateCategoryPullDownFor: aNoun [ 
	"Render category noun as a pull-down selection."
	| html categoryList|
	categoryList := ontology categoriesOf: aNoun.
	self assert: (categoryList size > 0).
	"Use global HumCalculator to generate XML "
	html := calc xml: 'select' dictionary: { 'name'->aNoun }
								with: [ calc xml: 'option' list: (categoryList sorted) ].
	^html.
]

{ #category : #'render frame line' }
HumOntologyViewer >> generateHtmlTableFor: anEntity [
	"Generate a dummy table showing the attributes for this entity-name." 
	| singular attributes html  |

	singular := ontology singularFormOfNoun: anEntity.
	attributes := ontology allAttributesOfEntity: singular.
	"If the entity has no attributes, generate a default table."
	( attributes size = 0 )
		ifTrue: [^'<table name="',anEntity,'"><tr><th>',anEntity,' has no attributes in current ontology.</th></tr></table>'].
  "Otherwise generate a normal table."
	html := '<table name="',anEntity,'" >'.
	html := html, '<tr>'.
	attributes do: [:attribute | html := html, '<th>', attribute, '</th>'.]. 
	html := html, '</tr>'.
	html := html, '<tr>'.
	attributes do: [:attribute | html := html, '<td>', attribute, ' value </td>'.]. 
	html := html, '</tr>'.
	html := html, '</table>'.
	^html.
]

{ #category : #accessing }
HumOntologyViewer >> initialize [
	calc := HumCalculator new.
]

{ #category : #'render frame line' }
HumOntologyViewer >> modeStack [
	"Stack to track list-type modes."
	^ modeStack ifNil: [ modeStack := Stack new.]
]

{ #category : #accessing }
HumOntologyViewer >> ontology: aHumOntology [ 
	ontology := aHumOntology.
]

{ #category : #'render all frames' }
HumOntologyViewer >> render: asSymbol onFileNamed: aNewFile [
	| string file |
	string := self renderAs: asSymbol.
	file := StandardFileStream forceNewFileNamed: aNewFile. 
	file nextPutAll: string.
	file close.
	^string.
]

{ #category : #'render frame' }
HumOntologyViewer >> renderActionFrame: aHumFrame4Action [ 
	"Render action frame with indentation.
	--  This is a read-only view for ontology code listing."
	| html  innerHTML frameLines statementIndent  titleHtml |
	calc := HumCalculator new. "By-Product: Initializes XML indent"
	innerHTML := ''.
	statementIndent := 1.
	frameLines := aHumFrame4Action frameLines.
	( frameLines reject: [:aFrameLine | |s| s := aFrameLine source. (s beginsWith: 'Action:') or: [s beginsWith: 'To:']] )
		do: [ :frameLine |
			| s |
			s := frameLine statement source trimBoth.
			"Else: reduces indent for self."
			( s asLowercase beginsWith: 'else') ifTrue: [ statementIndent := statementIndent - 1 ].
			(frameLine isKindOf: HumInstructionLine) ifTrue: [ frameLine indent: statementIndent ].
			innerHTML := innerHTML,'<br/>', String cr, (self renderFrameLine: frameLine ).
			"If, Else, for-each, all increase indent."
			(s endsWith: ':') ifTrue:  [ statementIndent := statementIndent + 1 ]. 
			].
	titleHtml := calc xml: 'frameTitle' with: [  aHumFrame4Action titleLine asString ].
	html := calc xml: 'ActionFrame' with: [
		  titleHtml,
			'<br/><b>Role: </b>',
			(calc xml: 'role' with: [ (aHumFrame4Action role capitalized),'.' ]),
			'<br/><b>Action: </b>',
			(calc xml: 'action' with: [ self renderInstruction: ( aHumFrame4Action actionStatement ) ]), innerHTML.		
			].
	^html.
]

{ #category : #'render frame' }
HumOntologyViewer >> renderActionFrame: aHumFrame4Action withCritique: aBoolean [
	"Render source code. 
	--  This is a read-only view for ontology code listing."
	| html  innerHTML frameLines statementIndent  titleHtml |
	calc := HumCalculator new. "By-Product: Initializes XML indent"
	innerHTML := ''.
	statementIndent := 1.
	frameLines := aHumFrame4Action frameLines.
	( frameLines reject: [:aFrameLine | |s| s := aFrameLine source. (s beginsWith: 'Action:') or: [s beginsWith: 'To:']] )
		do: [ :frameLine |
			| s |
			s := frameLine statement source trimBoth.
			"Else: reduces indent for self."
			( s asLowercase beginsWith: 'else') ifTrue: [ statementIndent := statementIndent - 1 ].
			(frameLine isKindOf: HumInstructionLine) ifTrue: [ frameLine indent: statementIndent ].
			innerHTML := innerHTML,'<br/>', String cr, (self renderFrameLine: frameLine ).
			"If, Else, for-each, all increase indent."
			(s endsWith: ':') ifTrue:  [ statementIndent := statementIndent + 1 ]. 
			].
	titleHtml := calc xml: 'frameTitle' with: [  aHumFrame4Action titleLine asString ].
	html := calc xml: 'HumFrame' with: [
		  titleHtml,
			'<br/><b>Role: </b>',
			(calc xml: 'role' with: [ (aHumFrame4Action role capitalized),'.' ]),
			'<br/><b>Action: </b>',
			(calc xml: 'action' with: [ self renderInstruction: ( aHumFrame4Action actionStatement ) ]), innerHTML.		
			].
	^html.
]

{ #category : #'render all frames' }
HumOntologyViewer >> renderAs: aSymbol [ 
	"FUTURE: Render as X -- Currently not needed."
	self shouldBeImplemented.
	self assert: ( aSymbol isKindOf: Symbol ).
	self log: 'Ontology: Document ontology as: ', ( aSymbol asString ). 
	"Call the HTML rendering code."
	(aSymbol = #HTML or: [ aSymbol = #HTML5 ])
		ifTrue: [ self renderAsHTMLonFileNamed: ( (self file), '.html') ]
		ifFalse: [ self shouldBeImplemented ].
	
]

{ #category : #'render all frames' }
HumOntologyViewer >> renderAsHTMLonFileNamed: aNewFile [ 
	"Render as HTML5 and echo on given file."
	| html store stream  |
	html := self asHTML5.
	store := HumStore defaultStore. "The default should be set by an external script.".
	stream := store writeStreamOnFileNamed: aNewFile.
	stream nextPutAll: html.
	stream close.
	^html.
]

{ #category : #'render all frames' }
HumOntologyViewer >> renderAsHTMLwithCritique: withCritique withBase: withBase onFileNamed: aNewFile [ 
	"Render as HTML5 and echo on given file."
	| html store stream  |
	html := self asHTML5withCritique: withCritique withBase: withBase. 
	store := HumStore defaultStore .
	stream := store writeStreamOnFileNamed:  aNewFile. 
	stream nextPutAll: html.
	stream close.
	^html.
]

{ #category : #'render all frames' }
HumOntologyViewer >> renderAsHTMLwithCritiqueOnFileNamed: aNewFile [ 
	"Render as HTML5 and echo on given file."
	| html store stream  |
	html := self asHTML5withCritique: true withBase: false. 
	store := HumStore defaultStore .
	stream := store writeStreamOnFileNamed:  aNewFile. 
	stream nextPutAll: html.
	stream close.
	^html.
]

{ #category : #'render frame line' }
HumOntologyViewer >> renderCommentIn: aFrameLine [ 
	"Render comment (if any) as HTML"
	| html commentString |
	html := ''.
	commentString := aFrameLine comment.
	( commentString notEmpty)
		ifTrue: ["Remove extra parentheses"
			| s |
			(commentString beginsWith: '(' )
				ifFalse: [  s := commentString ]
				ifTrue: [  s := commentString copyFrom: 2 to: (commentString size - 1) ].
			 html := calc xml: 'comment' with: [ '(', s, ')' ] ].
 	^html.
]

{ #category : #'render frame line' }
HumOntologyViewer >> renderConditionLine: aHumConditionLine [  
	| html xmlStatement xmlComment xmlAnnotation assembly  |
	"Avoid empty statement element."	
	xmlStatement := (aHumConditionLine statement source isEmpty ) 
		ifTrue: [''] 
		ifFalse: [( calc xml: 'statement' with: [self renderInstruction: (aHumConditionLine statement) ] ) ].
	"Avoid empty comment element.
	Note that parends are added for Hum consistency."
	xmlComment := ( aHumConditionLine comment trimBoth isEmpty ) 
		ifTrue: [''] 
		ifFalse: [ self renderCommentIn: aHumConditionLine  ].
	"Render the annotation."	
	xmlAnnotation := ( aHumConditionLine annotation trimBoth isEmpty ) 
		ifTrue: [''] 
		ifFalse: [ (  calc xml: 'annotation' with: [ '[ ', (aHumConditionLine annotation), ' ]' ]   ) ].
	"Assemble it without any line breaks."	
	assembly := xmlStatement, xmlComment, xmlAnnotation.
	html := (calc xml: 'PreconditionLine' with: [ assembly ]).
	"TODO: Add hyperlink to frame (if any) that has goal matching this precondition."
	^html.
]

{ #category : #'render frame' }
HumOntologyViewer >> renderCritiqueForFrame: aHumFrame [ 
	"Return (HTML5) rendering of the frame`s critique"
	| html problems myCalc  |
	problems := aHumFrame compileToOntology: ontology.
	problems isEmpty ifTrue: [^''].
	myCalc := HumCalculator new.
	html := (myCalc xml: 'critiqueLine' with: [ '<br/><br/><u style="color: DARKRED">Critique:</u>' ]).
	problems 
		do: [ :critiqueText |
			 html := html, (myCalc xml: 'critiqueLine' with: [ '<br/>&nbsp; ', critiqueText ]).
			 ].
	^html.
]

{ #category : #'render frame line' }
HumOntologyViewer >> renderDictionaryLine: aHumDictionaryLine [ 
	|  |
				
	^ calc xml: 'DictionaryLine' 
			with: [
				(calc xml: 'statement' 
					 with: [(self renderStatement: (aHumDictionaryLine statement ) keywords: #('is' 'a' 'attributes' 'include' 'categories' 'list' 'set' 'subtypes' 'abbreviation' 'shorthand' 'synonym' 'for' ) )
						    , (self renderCommentIn: aHumDictionaryLine)  ]
					 
					)
				  ]. 
]

{ #category : #'render frame' }
HumOntologyViewer >> renderFrame: aHumFrame  withCritique: withCritique [
	"Render (pretty print) source code. 
	--  This is a read-only view for ontology code listing."
	| html |
	html := self renderFrame: aHumFrame withCritique: withCritique withBase: false.
	^html.

]

{ #category : #'render frame' }
HumOntologyViewer >> renderFrame: aHumFrame  withCritique: withCritique withBase: withBaseOntology [
	"Render (pretty print) source code. 
	--  This is a read-only view for ontology code listing."
	| html |
	html := String new.
		"Abbreviate the frame if we are skipping base ontology frames."
	((withBaseOntology = false) and: [aHumFrame origin = 'BaseOntology.txt'])
		ifTrue: [ 
				"html := calc xml: 'commentLine' with: [ (aHumFrame titleLine), ' -- See base ontology.'  ]. "
				^html.
			 ].
	"Wrap the lines with a HumFrame tag."
	"Note: <frame> has semantics in HTML, so we use <HumFrame> tag instead."
	html :=
		calc xml: 'HumFrame'
				with: [ | frameHTML titleHTML subHTML|
					calc cases;
						when: [ aHumFrame isKindOf: HumFrame4Action ] 
							then: [ frameHTML := self renderActionFrame: aHumFrame ];
						when: [ aHumFrame isKindOf: HumFrame4Plan ] 
							then: [ frameHTML := self renderPlanFrame: aHumFrame ];
						otherwise: [ "Tag the title line."
												titleHTML := (calc xml: 'frameTitle' with: [  aHumFrame titleLine asString ]).
												subHTML := self renderFrameLinesIn: aHumFrame.
												frameHTML := titleHTML, subHTML. ].
					withCritique ifTrue: [ frameHTML := frameHTML, (self renderCritiqueForFrame: aHumFrame ) ].
					"Return"
					frameHTML.
					].
	^'<hr/>',String cr,html.

]

{ #category : #'render frame line' }
HumOntologyViewer >> renderFrameLine: frameLine [  
	"Dispatch frameLine to rendering specialist."
	| class |
	self assert: (frameLine isKindOf: HumFrameLine).
	class := frameLine class.
	(class = HumConditionLine ) ifTrue: [^ self renderConditionLine: frameLine ]. 
	(class = HumDictionaryLine ) ifTrue: [^ self renderDictionaryLine: frameLine ]. 
	(class = HumInstructionLine ) ifTrue: [^ self renderInstructionLine: frameLine ].

	"(class = HumCommentLine)          ifTrue: [^ calc xml: 'commentLine' with: [ frameLine source ]]."
	(class = HumCommentLine)          ifTrue: [^ self renderCommentIn: frameLine ].
	(class = HumVignettePatternLine)  ifTrue: [^ calc xml: 'patternLine' with: [ frameLine source] ]. 
	(class = HumVignetteResponseLine) ifTrue: [^ calc xml: 'responseLine' with: [ frameLine source] ]. 
		
	Error signal: 'FrameLine  subclass not handled: ', (class asString).
]

{ #category : #'render frame' }
HumOntologyViewer >> renderFrameLinesIn: aHumFrame [ 
	"Iterate throught the frame lines" 
	| html cr class |
	"View frames are rendered as HTML forms with widgets."
	class := aHumFrame class.
	(class = HumFrame4View ) ifTrue: [^ self renderView: aHumFrame ].
	"Plan frames are rendered with Precondition and Action sections"
	(class = HumFrame4Plan ) ifTrue: [^ self renderPlanFrame: aHumFrame ].
	"Action frames are rendered with Role: and Action: labels."
	(class = HumFrame4Action ) ifTrue: [^ self renderActionFrame: aHumFrame ].
	
	"Other frame types are just pretty-printed?"
	cr := String cr.
	html := cr.
	aHumFrame frameLines 
		do: [ :frameLine |
				html := html, '<br/>', ( self renderFrameLine: frameLine  ) ].
	^html.
]

{ #category : #'render statement' }
HumOntologyViewer >> renderInstruction: aHumStatement [ 
  "Pretty-print statement as HTML"
	| triggerWords keywords |
	triggerWords := 'if else for-each for' findTokens: ' '.
	 keywords := #('giving').
	^self renderStatement: aHumStatement triggerWords: triggerWords keywords: keywords.
	 
]

{ #category : #'render frame line' }
HumOntologyViewer >> renderInstructionLine: aHumInstructionLine [  
	"Pretty-print using HTML5 tags and CSS."
	| html xmlRole xmlStatement xmlComment xmlAnnotation assembly  attr |
	"Avoid an empty role element.
	Note that colon may be  inserted for HTML readability."
	xmlRole :=  ( aHumInstructionLine role sameAs: '' )  
		ifTrue: [''] 
		ifFalse: [ (( calc xml: 'role' with: [ (aHumInstructionLine role) ] ), ':' )].
	"Avoid empty statement element."	
	xmlStatement := (aHumInstructionLine statement source isEmpty ) 
		ifTrue: [''] 
		ifFalse: [( calc xml: 'statement' with: [self renderInstruction: (aHumInstructionLine statement)  ] ) ].
	"Avoid empty comment element.
	Note that parends are added for Hum consistency."
	xmlComment := ( aHumInstructionLine comment trimBoth isEmpty ) 
		ifTrue: [''] 
		ifFalse: [ self renderCommentIn: aHumInstructionLine ].
	"Render the annotation."	
	xmlAnnotation := ( aHumInstructionLine annotation trimBoth isEmpty ) 
		ifTrue: [''] 
		ifFalse: [ (  calc xml: 'annotation' with: [ ' [ ', (aHumInstructionLine annotation), ' ]' ]   ) ].
	"Assemble it without any line breaks."	
	assembly := xmlRole, xmlStatement, xmlComment, xmlAnnotation.
	attr := (Dictionary new) at: 'class' put: ('indent',(aHumInstructionLine indent asString)); yourself.
	html := (calc xml: 'InstructionLine' dictionary: attr with: [ assembly ]).
	^html.
]

{ #category : #'render frame line' }
HumOntologyViewer >> renderMarkupAsHTML5: markupSource [
	"Render the given mark-up text as HTML headings, lists, emphasis."
	"TODO: REFACTOR this with call to HumOntologyTranslator." 
	| html heading marker remainder level aString |
	self assert: (markupSource isKindOf: String ).
	"Maintain spacing."
	aString := calc given: markupSource replaceAll: '  ' with: '&nbsp;&nbsp;'.
	
	"Is this markup line a heading?"
	heading := 'none'.
	(1 to: 5)
		do: [ :i |
			marker := '!!!!!' copyFrom: 1 to: i.
			( aString beginsWith: marker ) 
				ifTrue: [ "Set the heading type and extract the remainder."
					heading := 'title', (marker size) asString. 
					remainder := (calc given: aString extractAfter: marker ) ]. 
			].
	"If this is a heading, render the whole line as a heading. "	
	"Call self recursively to catch any additional emphasis (e.g. italics)"
	( heading = 'none'	) ifFalse: [ ^html := calc xml: heading with: (self renderMarkupAsHTML5: remainder).].

	"Is this markup line a bullet/numbered list item."	
	#( '-----' '#####')
		do: [ :leaderType |
				level := 0.
		(1 to: 5 )
			do: [ :i |
				marker := leaderType copyFrom: 1 to: i.
				( aString beginsWith: marker ) 
					ifTrue: [ "Set the heading type and extract the remainder."
						level := (marker size). 
						remainder := (calc given: aString extractAfter: marker ) ]. 
				].
		( level > 0 )
			ifTrue: [
				html := ''.
				( (lastLevel isNil ) or: [ level > lastLevel ] ) 
					ifTrue:[ 
						(marker beginsWith: '-') ifTrue: [ self modeStack push: 'ul'].
						(marker beginsWith: '#') ifTrue: [ self modeStack push: 'ol'].
						html := '<',(self modeStack top),'>'.
						].
				"TODO: Figure out how to emit '</ul>' and '</ol>.' -- Might need MODES. (heavens)"
				( (lastLevel notNil ) and: [ level < lastLevel ] ) 
					ifTrue:[ 
						html := '</',(self modeStack top),'>'. 
						].
				lastLevel := level.

				html := html, (calc xml: 'li' with: (self renderMarkupAsHTML5: remainder )).
				^html.	
				].
			].	
	"None of the above"
	"Delegate emphasis"
	html := self renderMarkupEmphasisAsHTML5: aString.
	html := self renderWidgetsInMarkup: html.
	^html.
		
	
]

{ #category : #'render frame line' }
HumOntologyViewer >> renderMarkupEmphasisAsHTML5: aString [ 
	"Render bold, italic, underscore emphasis."
	"TODO: DOES THIS FUNCTIONALITY BELONG IN HumOntologyTranslator ???."
	| wip between before after |
  self assert: ( aString isKindOf: String ).
	(( aString includes: $*) or: [ (aString includes: $~) or: [ aString includes: $_]])
		ifFalse: [^aString].
	"Initialize work-in-progress."
	wip := aString.
	('*_*_*' match: wip )
		ifTrue: [ "become *<u>*</u>*"
			between := calc given: wip extractBetween: '_' and: '_'. 
			before  := calc given: wip extractUpto: '_'.
			after   := calc given: wip extractAfterSecond: '_'.
			wip := before, '<u>', between, '</u>', after.
			].
	('*~*~*' match: wip )
		ifTrue: [ "become *<i>*</i>*"
			between := calc given: wip extractBetween: '~' and: '~'. 
			before  := calc given: wip extractUpto: '~'.
			after   := calc given: wip extractAfterSecond: '~'.
			wip := before, '<i>', between, '</i>', after.
			].
	"Cannot use #match: for asterisk case. So we use this trick:"
	((HumCalculator given: wip extractBetween: '*' and: '*') = '')
		ifFalse: [
			between := HumCalculator given: wip extractBetween: '*' and: '*'.
			before := calc given: wip extractUpto: '*'.
			after   := calc given: wip extractAfterSecond: '*'.
			wip := before, '<b>', between, '</b>', after.
			].
	
	^wip.
]

{ #category : #'render all frames' }
HumOntologyViewer >> renderNounTreeForNoun: aNoun [ 
	"Render a noun-tree rooted at the given noun (entity)."
	| cr string indentedNounTree priorIndent priorNoun |
	self assert: (aNoun isKindOf: String).

	cr := String cr.
	string := cr, 'Noun Tree:', cr.
	indentedNounTree := self buildNounTreeForNoun: aNoun indent: 0.
	priorIndent := 999.
	priorNoun := aNoun.
	indentedNounTree 
		do: [ :mapPostPre |
				| value indent property pad supertypes |
				value := ( mapPostPre value ).  "= { indent. attribute. }"
				indent := value at: 1.
				property := value at: 2.
				pad := String new: 3 + (indent * 5) withAll: (Character space).
				( priorIndent = 999 ) 
					ifTrue: [ string := string, pad, aNoun, cr ].
				supertypes := ontology immediateSupertypesOf: priorNoun.
				( supertypes includes: property )
					ifTrue:  [string := string, pad, ' |=> ', property, cr.]
					ifFalse: [string := string, pad, ' |-> ', property, cr.].
				priorIndent := indent.
				priorNoun := property.
				].
	^ string.
	
]

{ #category : #'render all frames' }
HumOntologyViewer >> renderNounTreeForNounAsHTML: aNoun [ 
	"Render a noun-tree rooted at the given noun (entity)."
	| string html |
	string := self renderNounTreeForNoun: aNoun.
	html := HumCalculator given: string  replaceAll: '>' with: '&gt;'.
	^html
]

{ #category : #'render frame' }
HumOntologyViewer >> renderPlanActionsIn: aHumFrame4Plan [ 
	"Render plan frame action lines"
	| html cr |
	cr := String cr.
	html := '<br/><b>Actions:</b>', cr.
	(aHumFrame4Plan actionStatements)
		do: [ :actionLine |
			self assert: ( actionLine isKindOf: HumInstructionLine ).
			html := html, '<br/>', (self renderInstructionLine: actionLine).
			"html := html, '<br/>', ( self renderStatement: actionLine ), cr."
			].
	^ html
]

{ #category : #'render frame' }
HumOntologyViewer >> renderPlanFrame: aHumFrame4Plan [ 
	"Render source code. 
	--  This is a read-only view for ontology code listing."
	| html  |
	calc := HumCalculator new. "Initialize indent"
	html :=
	calc xml: 'HumFrame'
		with: [
			(calc xml: 'frameTitle' with: [  'Goal: ', ( self renderInstruction: (aHumFrame4Plan goal ) )]),
			( self renderPlanPreconditionsIn: aHumFrame4Plan ),
			( self renderPlanActionsIn: aHumFrame4Plan )		
			].
	^html.
]

{ #category : #'render frame' }
HumOntologyViewer >> renderPlanPreconditionsIn: aHumFrame4Plan [ 
	"Render plan frame precondition lines"
	| html br|
	"Always include this subheading."
	html := '<br/><b>Preconditions:</b>'.
	br := String cr, '<br/>'.
	(aHumFrame4Plan preconditions)
		do: [ :preconditionLine |
			self assert: (preconditionLine isKindOf: HumFrameLine ).
			html := html, br, (self renderFrameLine: preconditionLine ).
			].
	^ html
]

{ #category : #'render all frames' }
HumOntologyViewer >> renderPlanTreeForGoal: aGoal [
	"Render HTML for a previous created planTree (generated by  buildPlanTreeForGoal: )"
	| string cr indentedPlanTree priorIndent goalHTML |
	"NOTE: The goals that are most relevant are those found in dialog vignettes."
	"See: HumOntologyTests>>test540GetPlanTree 
	-- Call to this method is commented out.
	See also: HumOntology>>buildPlanTreeForGoal:
	"
	cr := String cr.
	string := cr, 'Plan Tree:', cr.
	indentedPlanTree := ontology buildPlanTreeForGoal: aGoal indent: 0.
	priorIndent := 999.
	goalHTML := self renderInstruction: (HumStatement source: ( ( indentedPlanTree at: 1 ) key )).
	indentedPlanTree 
		do: [ :mapPostPre |
				| value indent precondition pad |
				value := ( mapPostPre value ).  "= { indent. precondition. }"
				indent := value at: 1.
				precondition := value at: 2.
				pad := String new: 2 + (indent * 5) withAll: (Character space).
				( priorIndent = 999 ) 
					ifTrue: [ string := string, pad, goalHTML, cr ].
				string := string, pad, ' |-> ', (self renderInstruction: precondition ), cr.
				priorIndent := indent.
				].
	^ string.
]

{ #category : #'render statement' }
HumOntologyViewer >> renderStatement: aHumStatement keywords: keywords [ 
	| tokenTypes html token type fragment |
	html := ''.
	tokenTypes := ontology parseStatement: aHumStatement triggerWords: #() keywords: keywords.
	tokenTypes
		do: [ :tokenType |   "For each token-type:"
			token := tokenType key.
			type := tokenType value.
			fragment := ''.
			"Assign a tag that the CSS can then style."
			( type = #word ) ifTrue: [ fragment := ' ', token ].
			( type = #noun ) ifTrue: [ fragment := ' <n>', token, '</n>' ].
			( type = #keyword ) ifTrue: [ fragment := ' <k>', token, '</k>' ].
			( type = #role ) ifTrue: [ fragment := ' <r>', token, '</r>' ].
			"Just another token with no particular type."
			( fragment = '' ) ifTrue: [ fragment := token ].
			html := html, fragment.
			].
	^html
]

{ #category : #'render statement' }
HumOntologyViewer >> renderStatement: aHumStatement triggerWords: triggerWords keywords: keywords [ 
	| tokenTypes html token type fragment |
	html := ''.
	tokenTypes := ontology parseStatement: aHumStatement triggerWords: triggerWords keywords: keywords.
	tokenTypes
		do: [ :tokenType |   "For each token-type:"
			token := tokenType key.
			type := tokenType value.
			fragment := ''.
			"Assign a tag that the CSS can then style."
			( type = #word ) ifTrue: [ fragment := ' ', token ].
			( type = #noun ) ifTrue: [ fragment := ' <n>', token, '</n>' ].
			( type = #keyword ) ifTrue: [ fragment := ' <k>', token, '</k>' ].
			( type = #role ) ifTrue: [ fragment := ' <r>', token, '</r>' ].
			"Just another token with no particular type."
			( fragment = '' ) ifTrue: [ fragment := token ].

			html := html, fragment.
			].
	^html
]

{ #category : #'render frame' }
HumOntologyViewer >> renderView: aHumViewFrame [ 
	"Views are rendered as HTML forms -- which is different from other frames."
	| html cr br innerHTML |
	cr := String cr.
	br := cr, '<br/>'.
	innerHTML := cr.
	html := cr, (calc xml:'form' with: [
		aHumViewFrame frameLines 
		do: [ :frameLine |
				"Markup lines will control line-breaks without my help."
				"Future: View might have instruction-lines for tables."
				(frameLine isKindOf: HumMarkupLine)
					ifTrue: [innerHTML := innerHTML, br, ( self renderMarkupAsHTML5: frameLine source )]
					ifFalse:[innerHTML := innerHTML, br, ( self renderInstructionLine: frameLine source )
						].
				 ].
		"Block returns "
		innerHTML.
		]
	).
	^html.
]

{ #category : #'render widgets' }
HumOntologyViewer >> renderWidgetsInMarkup: aSourceString [ 
	"Return HTML5 equivalent of the widgets found in this mark-up line."
	|  between before after wip |
	"TODO: Perhaps the parsing should be elsewhere and just the rendering here."
	"TODO: REFACTOR - Widgets are sufficiently complicated that they deserve a class."
	wip := aSourceString.
	"Match button."
	( '*[[*]]*' match: wip )
		ifTrue: [
			between := calc given: wip extractBetween: '[[' and: ']]'.
			before := calc given: wip extractUpto: '[['.
			after  := calc given: wip extractAfter: ']]'.
			wip := before,'<button name="',between,'" />',after.
			"Get all the buttons before we go on."
			wip := self renderWidgetsInMarkup: wip.
			].
	"Match check-box" 
	( '*[#]*' match: wip )
		ifTrue: [ 
			between := calc given: wip extractBetween: '[' and: ']'.
			before := calc given: wip extractUpto: '['.
			after  := calc given: wip extractAfter: ']'.
			wip := before,'<input name="',between,'" type="checkbox"/>',after.
			"Get all the check-boxes before we go on."
			wip := self renderWidgetsInMarkup: wip.
			].
	"Match other widgets."
	( '*[*]*' match: wip )
		ifTrue: [ 
			between := calc given: wip extractBetween: '[' and: ']'.
			before := calc given: wip extractUpto: '['.
			after  := calc given: wip extractAfter: ']'.
			
       "Name followed by space and digit means multi-line text box"
			( between matchesRegex: '^.*\b\d$'  )
				ifTrue: [ | name d |
					name := calc given: between extractUpto: ' '.
					d := calc given: between extractAfter: ' '.
					wip := before,'<textarea name="',name,'" rows=',d,' cols=60 /></textarea>',after.]
				ifFalse: ["Not a textarea . . ."
					"TODO: If the attribute-name is plural, render as a table."
					| noun calc2 |
					noun := between.
					calc2 := HumCalculator new.
					calc2 cases;
						when: [ ontology isPluralNoun: noun ] 
							then: [wip := before, (self generateHtmlTableFor: noun ), after.  ];
						when: [ ontology isCategory: noun ]
							then: [ wip := before, (self generateCategoryPullDownFor: noun ), after. ];
						otherwise: 
							[ wip := before, '<input name="', noun, '" />', after ].
					].
			"TODO: Special handling for other types: category, date-time, measure."
			].
	"Match radio-button"	
	( '*(#)*' match: wip )
			ifTrue: [ 
			between := calc given: wip extractBetween: '(' and: ')'.
			self assert: ((between size) = 1).
			before := calc given: wip extractUpto: '('.
			after  := calc given: wip extractAfter: ')'.
			wip := before,'<input name="',between,'" type="radio"/>',after.
			"TODO: Need <group> tags. HOW ARE WE GOING TO DO THAT?"
			].
		
	"If no widgets were found in this pass: Return;  Otherwise: Iterate."
	( wip = aSourceString ) 
		ifTrue: [ ^aSourceString.]
		ifFalse: [ ^ self renderWidgetsInMarkup: wip ].
	
]

{ #category : #'render frame' }
HumOntologyViewer >> showPlanTree: aPlanTree [
	"Display a previous created planTree (generated by  buildPlanTreeForGoal: )"
	| string cr |
	"See: HumOntologyTests>>test540GetPlanTree 
	-- Call to this method is commented out.
	See also: HumOntology>>buildPlanTreeForGoal:
	"
	cr := String cr.
	 string := cr, 'Plan Tree:', cr.
	aPlanTree 
		do: [ :mapPostPre |
				string := string, ( mapPostPre key ) asString, ' -> ', ( mapPostPre value ) asString, cr.
				].
		"TODO: What does this produce?  It looks like a simple rendering with no indentation."
	^ string.
]

{ #category : #'render all frames' }
HumOntologyViewer >> showPlanTreeForGoal: aGoal [
	"Display a previous created planTree (generated by  buildPlanTreeForGoal: )"
	| string cr indentedPlanTree priorIndent |
	"See: HumOntologyTests>>test540GetPlanTree 
	-- Call to this method is commented out.
	See also: HumOntology>>buildPlanTreeForGoal:
	"
	cr := String cr.
	string := cr, 'Plan Tree:', cr.
	indentedPlanTree := ontology buildPlanTreeForGoal: aGoal indent: 0.
	priorIndent := 999.
	indentedPlanTree 
		do: [ :mapPostPre |
				| value indent precondition pad |
				value := ( mapPostPre value ).  "= { indent. precondition. }"
				indent := value at: 1.
				precondition := value at: 2.
				pad := String new: 1 + (indent * 2) withAll: (Character space).
				( priorIndent = 999 ) 
					ifTrue: [ string := string, pad, ( mapPostPre key ) asString, cr ].
				string := string, pad, ' -> ', precondition asString, cr.
				priorIndent := indent.
				].
	^ string.
]
