"
A markup line may occur within a view or a dialog vignette response.

In those contexts, a mark-up line is a line that does not begin with a period.
(Lines that begin with a period contain instructions to be exectuted by the dialog agent or rendering engine.)
The content of the line will be rendered when the view or response is rendered. 

Hum mark-up uses the following notations:

Outline Mark-Up:  (outlines are indicated by a line that begins with a specific special character.)

! a level one heading
!! a level two heading -- an so on up to level 5.

- a bullet at first level of outline
-- a bullet at second level of outline -- an so on up to 5 levels 
--- a bullet at third level of outline -- note that a line that begins with three underscores (___) indicates a horizontal rule (or a splitter)

# a numbered outlline - first level
## a numbered outline - second level -- and so on up to 5 levels.

Text Emphasis:

  Text substrings may be emphasized by surrounding the substring as follows:
    *bold*
    ~italic~
    _underline_

Widget Mark-Up:
 [widget] -- a widget is enclosed in square brackets. Widgets are used in interactive contexts.
 [[button]] -- a button is a widget. The dialog speech-act intended must be defined in a following instruction.
 [a] -- a widget containing a single character indicates a check-box. The intended action must be defined in a following instruction.
 (a) -- a radio button. Then intended action must be defined in a following instruction.
 [type: string ] -- The type indicates the rendering intended. 
                          Example: [range: utilization ] might render as a meter, or bar, or spinner, depending on the rendering engine and its style rules.

Widget Actions:
  [attribute] -- The widget names an attribute. The current value (if any) of the attribute is rendered.
                 The rendering engine will provide an appropriate widget depending on the type of the attribute.
                 For example, a category may be rendered with a pull-down list, text with a text-area, date with a date selector.
  [page: title] -- The internal page with the given title is linked.
  [link: blah blah | URI ] -- ""blah blah"" is displayed. The URI links to an external resource.
  [pane: title] -- The Hum view frame with the matching title will be rendered at this position. 
                        More elaborate layouts are achieved by placing panes within panes.

Tables:  (These are used to list the content of an entity's collection attributes.)

  The columns of the table are indicated by attribute names separated by pipe '|' characters.
  Here is an example where an order entity has a list attribute called order-lines.

. Table of order-lines.
| catalog-id | description | quantity | unit-price | 


%%%%%%%%%%%%%%% Summary %%%%%%%%%%%%%%%%%%%%%%%%%%
	 . Known widget types include 
	 . . [page:  TITLE ] -- Link to local page (a la wiki)
	 . . [link: TITLE | URL] -- Link to a remote page given by the URL/URI
	 . . [pane: TITLE] -- Insert given pane
	 . . [range: LB - UB ] -- Provide a slider or similar device on input; a progress bar on output.
	 . Attribute types with specific rendering should eventually 
	 . . [category] [text] [date] [email] -- HTML5 can handle directly
	 . . [measure] -- accept and validate quantity, unit-of-measure, plus-or-minus
	 . . [collection -- display a table? (default rendering or ???)

  
"
Class {
	#name : #HumMarkupLine,
	#superclass : #HumFrameLine,
	#instVars : [
		'lastLevel'
	],
	#category : #'Hum-Language'
}

{ #category : #evaluating }
HumMarkupLine class >> widgetNounIn: aWidgetString [ 
	"Find the noun in typical field widgets."
	| buttonLabel noun s |
	
	"Heuristic: If there is a colon, this is not a field widget. -- Return warning string."
	(aWidgetString includes: $: ) ifTrue: [ ^'*Not a field widget*' ].
	
	"Ignore buttons -- Return an empty string."
	buttonLabel := HumCalculator given: aWidgetString extractBetween: '[[' and: ']]'.
	(buttonLabel size > 0) ifTrue: [ ^'' ]. 
	
	"s is potential noun -- May need to remove a number-of-lines parameter"
	s := HumCalculator given: aWidgetString extractBetween: '[' and: ']'.
	(s includes: $ ) 
		ifTrue: [ noun := HumCalculator given: s extractUpto: ' ' ]
		ifFalse: [ noun := s ]. 
		
	"TODO: Refactor to deal with possessive case.  e.g. [user`s name]"
	^noun.
]

{ #category : #compiling }
HumMarkupLine >> checkSyntaxWithOntology: aHumOntology [ 
	"Syntax errors in mark-up mainly have to do with widgets that won't work.
	Other errors will simply be rendered as-is.
	"
	|  errors widgets widgetNoun |
	""
	errors := OrderedCollection new.
	widgets := self widgets.
	"Look for unknown nouns in widgets."
	widgets 
		do: [ :widget | 
			widgetNoun := HumMarkupLine widgetNounIn: widget.
			( aHumOntology isNoun: widgetNoun )
				ifFalse: [ errors add: ('In {', widget, '} the widget contains unknown noun: {', widgetNoun,'}' ) ].
			].

	"TODO: Look for unknown widget-types in markup-line widgets.
	 . Known widget types include 
	 . . [page:  TITLE ] -- Link to local page (a la wiki)
	 . . [link: TITLE | URL] -- Link to a remote page given by the URL/URI
	 . . [pane: TITLE] -- Insert given pane
	 . . [range: LB - UB ] -- Provide a slider or similar device on input; a progress bar on output.
	 . Attribute types with specific rendering should eventually include 
	 . . [category] [text] [date] [email] -- HTML5 can handle directly
	 . . [measure] -- accept and validate quantity, unit-of-measure, plus-or-minus
	 . . [collection -- display a table? (default rendering or ???)
	"
	widgets
		do: [ :widget | 
			].
	
	^errors.
]

{ #category : #compiling }
HumMarkupLine >> compileLineToOntology: aHumOntology [ 
	|  errors widgets  |
	""
	errors := OrderedCollection new.
	widgets := self widgets.
	"Look for unknown nouns in widgets."
	( widgets reject: [:widget | ('*:*') match: widget] )
		do: [ :widget | 
			| widgetNoun |
			widgetNoun := HumMarkupLine widgetNounIn: widget.
			( aHumOntology isNoun: widgetNoun )
				ifFalse: [ errors add: ('In {', widget, '} the widget contains unknown noun: {', widgetNoun,'}' ) ]
				ifTrue: [ 
					aHumOntology addNoun: widgetNoun.
					aHumOntology addNoun: widgetNoun reference: self.
					 ].
			].

	^errors.
]

{ #category : #rendering }
HumMarkupLine >> generateCodeOfType: aSymbol fromTokens: tokens at: xToken [
	"Generate code of the given type HTML/Seaside/JavaScript based on token stream."
	| currentToken code cr doubleQuote singleQuote calc |
		self delegated.

	calc := HumCalculator new.
	"Current experiment is to generate HTML5 from Hum mark-up."
	self assert: aSymbol = #HTML.
	code := String new.
	cr := String cr.
	"If we ran out of tokens, we are done?"
	( xToken > tokens size ) ifTrue: [ ^self ].
	currentToken := tokens at: xToken.
	"If we are at beginning of line, there are special rules."
	( xToken = 1 )
		ifTrue: [ "Look for heading, list, or instruction."
			(currentToken = '.') 
				ifTrue: [ "Line is instruction." "Ignore it for now. Make a comment line as a reminder."
					code := '<!-- ', source, ' -->'.  
					^ code.
					].
			(currentToken = '!') 
				ifTrue: ["Line is heading. But what level?"
					| level |
					level := 1.
					[ (level < (tokens size))  and: [ (tokens at: level + 1 ) = '!' ] ] whileTrue: [ level := level + 1 ].
					"Remainder of line is in this header"
					code := calc xml: ('h', (level asString))  with: [ self generateCodeOfType: aSymbol fromTokens: tokens at: level + 1 ] .
					^code.
					].
			(currentToken = '-' ) 
				ifTrue: ["Line is list. But what level?"
					| level |
					level := 1.
					[ (level < (tokens size))  and: [ (tokens at: level + 1 ) = '-' ] ] whileTrue: [ level := level + 1 ].
					"If level has changed, we need to output <ul> or </ul>"
					( level > indentLevel ) ifTrue: [ code := '<ul>', cr. ].
					( level < indentLevel ) ifTrue: [ code := '</ul>', cr. ].
					"Remainder of line is in this header"
					code := code, (calc xml: 'li' with: [ self generateCodeOfType: aSymbol fromTokens: tokens at: level + 1 ]) .
					^code.
					].
				"If we have come this far, the line begins with nothing special."
			     "Go on as if we were not on the first token."
			].
		"Look for quotes -- we need to remove tokens between quotes from translation."
		doubleQuote := $".
		singleQuote := $".	
		(currentToken = doubleQuote or: [ currentToken = singleQuote ] )
			ifTrue: [ | quote removal x | 
				quote := currentToken.
				removal := String new.
				x := xToken + 1.
				[ ( x < (tokens size) ) and: [ tokens at: x = quote ] ] whileFalse: [ removal := removal, (tokens at: x). x := x + 1. ].
				code := code, removal, quote, (self generateCodeOfType: aSymbol fromTokens: tokens at: ( x + 1 )   ).
				^code.
				].
		"Look for emphasis -- tokens between are in scope of  . . ."
		(currentToken = '*' or: [[ currentToken = '~' ]  or: [ currentToken = '_' ] ] )
			ifTrue: [ | emphasis removal x | 
				emphasis := currentToken.
				removal := String new.
				x := xToken + 1.
				[ ( x < (tokens size) ) and: [ tokens at: x = emphasis ] ] whileFalse: [ removal := removal, (tokens at: x). x := x + 1. ].
				code := code, removal, emphasis, (self generateCodeOfType: aSymbol fromTokens: tokens at: ( x + 1 )   ).
				"Note: Above is a bit simplistic. 
				It assumes there is nothing to be interpreted in the string between emphasis tokens.
				The following would not work properly: *~bold-italic~*  *_bold-and-underlined_*
				TODO: Make this smarter.
				"
				^code.
				].
		"Look for widgets."
		( currentToken = '[' )
			ifTrue: [ "What we do depends on the type of widget."
				| nextToken |
				nextToken := (tokens at: (xToken + 1) ).
				( nextToken = 'page' )
					ifTrue: [self generatePageWidgetFromTokens: tokens at: nextToken ].
				].
]

{ #category : #rendering }
HumMarkupLine >> generateHtmlTableFor: aNoun withOntology: anOntology [
	| singular attributes html  |
		self delegated.

	singular := anOntology singularFormOfNoun: aNoun.
	attributes := anOntology allAttributesOfEntity: singular.
	"If the entity has no attributes, generate a default table."
	( attributes size = 0 )
		ifTrue: [^'<table name="',aNoun,'"><tr><th>',aNoun,' has no attributes in current ontology.</th></tr></table>'].
  "Otherwise generate a normal table."
	html := '<table name="',aNoun,'" >'.
	html := html, '<tr>'.
	attributes do: [:attribute | html := html, '<th>', attribute, '</th>'.]. 
	html := html, '</tr>'.
	html := html, '<tr>'.
	attributes do: [:attribute | html := html, '<td>', attribute, ' value </td>'.]. "STUB"
	html := html, '</tr>'.
	html := html, '</table>'.
	^html.
]

{ #category : #widgets }
HumMarkupLine >> getWidgetArgument: aWidgetString [
	"Parse the widget string to get verb`s argument, if any."
	| argument |
	(aWidgetString includesSubString: ':')
		ifFalse: [^''].
	argument := HumCalculator given: aWidgetString extractBetween: ':' and: ']'.
	self assert: (argument size > 0).
	^argument
]

{ #category : #widgets }
HumMarkupLine >> getWidgetNoun: aWidgetString [
	"Parse the widget-string to get the widget`s noun (blackboard entity-attribute-name), if any."
	| noun |
	(aWidgetString includesSubString: ':') "[verb: argument] pattern has no blackboard noun."
		ifTrue: [^''].
	(aWidgetString beginsWith: '[[')	"[[button]] has no blackboard noun."
		ifTrue: [ ^'' ].
	noun := HumCalculator given: aWidgetString  extractBetween: '[' and: ']'.
	^noun
	
]

{ #category : #widgets }
HumMarkupLine >> getWidgetVerb: aWidgetString [
	"Parse the widget-string to get the widget`s verb, if any."
	| verb |
	(aWidgetString includesSubString: ':')
		ifFalse: [^''].
	"Parsing forms such as [link: page-name] or [page: URL | link-text] ."
	"TODO: Currently there are no senders - and no tests."
	verb := HumCalculator given: aWidgetString extractBetween: '[' and: ':'.
	self assert: (verb size > 0).
	^verb
]

{ #category : #widgets }
HumMarkupLine >> widgets [
	"Scan the source matching pairs of [. . .] or [[. . .]]."
	| widgets  s  widget |
	widgets := OrderedCollection new.
	
	s := self source.
	"Scan for widgets"		
	[ widget := HumCalculator given: s extractBetween: '[' and: ']'.
	  ( widget size > 0 ) ]
		whileTrue: [  "Watch out for [[button label]] pattern."
					( widget beginsWith: '[')
							ifTrue: [ "This widget looks like a button. Return [[button label]]."
								        widgets add: ( '[', widget, ']]' ).
								        s := HumCalculator given: s extractAfter: ']]'.
										]
							ifFalse: [ "This widget does not look like a button. Return [content]." 
								        widgets add: ( '[', widget, ']' ). 
										s := HumCalculator given: s extractAfter: ']'.
										]. "end false"
					 ]. "end while"
	"Check for unknown widget types."
	"TODO: Some widgets only make sense in a view.  In a vignette, they are a programming error. "
	"SEE ALSO: HumWidget class and subclasses in Hum-UI package."
	^widgets.

]
