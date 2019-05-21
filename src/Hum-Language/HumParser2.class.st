"
This was an experiment using something resembling a BNF driven parser.
Block closures are used to represent BNF-line expresssions.

The experiment failed 
primarily because nested block closures 
became too hard to debug.

I have retained the class mostly for sentimental reasons
and to prevent me from absent-mindedly attempting to do it again.


"
Class {
	#name : #HumParser2,
	#superclass : #Object,
	#instVars : [
		'stack',
		'ignoreNext'
	],
	#category : #'Hum-Language'
}

{ #category : #evaluating }
HumParser2 >> alphanumeric: aString [ 
	"Match that part of the string that is alpha-numeric"
	| empty result |
	empty := ''.
	result := empty.
	aString
		do: [:ch |
			( ch isLetter or: [ (ch = $ ) or: [ch isDigit]  ])
				ifTrue: [ result := result, ch asString. ]
				ifFalse: [^result].
			].
	^result.
]

{ #category : #evaluating }
HumParser2 >> checkbox: aSource [
	"Does the current source start with a check box widget?"
	| empty s |
	empty := ''.
	(aSource size >= 3) ifFalse: [^empty].
	s := aSource copyFrom: 1 to: 3.
	('[#]' matches: s) 
		ifTrue: [^s]
		ifFalse: [^empty].
	
]

{ #category : #evaluating }
HumParser2 >> checkbox: aSource produce: aProductionBlock [
	"Does the current source start with a check box widget?"
	| empty s |
	empty := ''.
	(aSource size >= 3) ifFalse: [^empty].
	s := aSource copyFrom: 1 to: 3.
	('[#]' matches: s) 
		ifTrue: [ 
			| ch x |
			ch := (s at: 2).
			"A check box must contain a single letter. 
			(Otherwise the name will not be HTML/CSS compatible)"
			(ch isLetter) 
				ifFalse: [Error signal: 'A checkbox must contain a single letter.'].
			x := ch asString.
			self push: (aProductionBlock value: x ). ^s]
		ifFalse: [^empty].
	
]

{ #category : #evaluating }
HumParser2 >> digits: source [ 
	"Match leading part of source that is digits"
	| empty result |
	empty := ''.
	result := empty.
	source
		do: [:ch |
			( ch isDigit)
				ifTrue: [ result := result, ch asString. ]
				ifFalse: [^result].
			].
	^result.
	
]

{ #category : #binding }
HumParser2 >> generateChoicesFor: anAttributeName inOntology: aHumOntology [ 
	"Generate HTML choice tags"
	| html choices |
	html := String new.
	choices := aHumOntology categoriesOf: anAttributeName.
	choices
		do: [:choice |
			html := html, String cr, '  <option name="',choice,'">',choice,'</option>'.
			].
	^html.
]

{ #category : #accessing }
HumParser2 >> generatedCode [
	""
	| code |
	code := ''.
	(self stack) 
		do: [:item | code := code, item. ].
	^code.
]

{ #category : #accessing }
HumParser2 >> ignoreNext [
	^ignoreNext ifNil: [ ignoreNext := false. ].
]

{ #category : #accessing }
HumParser2 >> ignoreNext: aBoolean [ 
	ignoreNext := aBoolean
]

{ #category : #syntax }
HumParser2 >> markupSyntax [
	"Experimental BNF syntax"
	| markup heading text emphasis bold widget alphanum italic underline headingPrefix matched  pageWidget attributeWidget x ordinaryText textAreaWidget number d blank list listPrefix humNoun p t |
	
	
	markup := [:s | self match: s oneOf: { heading. list. emphasis. widget. alphanum. }  ].
	
	heading := [:s | self match: s sequence:{ headingPrefix. text. } 
		                  produce:[|n| n := p size asString. self pop:2; push: ('<h',n,'>',t,'</h',n,'>')] ].
	"x is the matched text -- see alphanum below"
	"n is the size of the match -- see _prefix below"
	headingPrefix := [ :s | p := self match: s oneOf: { '!!!!!'. '!!!!'. '!!!'.  '!!'. '!'. } ]. 
  list := [:s | self match: s sequence:{listPrefix. text.} 
	                 produce: [ |n| n := p size asString.  self pop:2; push:('<item',n,'>',t,'</item',n,'>')] ].
	listPrefix := [ :s | p := (self match: s oneOf: { '-----'. '----'. '---'. '--'. '-'. } ) ].

	text := [ :s | t := self match: s repeat: { ordinaryText. emphasis. } ].
	ordinaryText := [:s | x := self match: s repeat: { alphanum. '.'. ','. '-'. '!'. '?'. ':'. } ].
	
	alphanum := [ :s | x := self alphanumeric: s. ]. "Produces x."
	number := [:s | d := self digits: s ].  "Produces d."
	blank := [:s | self spaces: s ].
	
	emphasis := [:s | self match: s oneOf: { bold. italic. underline. } ].
	bold := [ :s | self match: s      sequence:{ '*'. alphanum. '*'.} produce:[self pop:3; push:('<b>',x,'</b>')] ].	
	italic := [ :s | self match: s    sequence:{ '~'. alphanum. '~'.} produce:[self pop:3; push:('<i>',x,'</i>')] ].	
	underline := [ :s | self match: s sequence:{ '_'. alphanum. '_'.} produce:[self pop:3; push:('<u>',x,'</u>')] ].
	
	widget := [:s | self match: s oneOf: { pageWidget. attributeWidget. textAreaWidget. } ].
	humNoun := [:s | x := (self noun: s ) ].
	pageWidget := [:s | self match: s sequence: {'[page:'. alphanum. ']'. } 
		                       produce: [self pop:3; push:('<a href="',x asCamelCase,'">',x,'</a>')] ].
	attributeWidget := [:s| self match: s sequence: {'['. humNoun. ']'.} 
														  produce: [self pop:3; push:('<input type="text" name="',x,'"></input>')]].
	textAreaWidget := [:s | self match: s sequence: { '['. humNoun. blank. number. ']'}
		                           produce: [self pop:5; push:('<textarea rows="',d,'" name="',x,'"></textarea>')] ].
	
	^markup.	

]

{ #category : #syntax }
HumParser2 >> markupSyntaxWithOntology: anOntology [
	"Experimental BNF syntax"
	| markup heading text emphasis bold widget alphanum italic underline headingPrefix matched  pageWidget attributeWidget x ordinaryText textAreaWidget number d blank list listPrefix humNoun p t viewName v paneWidget code ordinaryLine url u linkWidget entityAttributeWidget entity eName attribute aName checkboxWidget radioWidget comment category categoryWidget |
	
	markup := [:s | self match: s oneOf: { heading. list. ordinaryLine.  }  ].
	ordinaryLine := [:s | self match: s repeat: {  emphasis. widget. ordinaryText. comment. }].
	
	heading := [:s | self match: s sequence:{ headingPrefix. text. } 
		                  produce:[|n| n := p size asString. self push: ('<h',n,'>',t,'</h',n,'>')] ].
	"x is the matched text -- see alphanum below"
	"n is the size of the match -- see _prefix below"
	headingPrefix := [ :s | p := self match: s oneOf: { '!!!!!'. '!!!!'. '!!!'.  '!!'. '!'. } ]. 
	
  list := [:s | self match: s sequence:{listPrefix. text.} 
	                 produce: [:z | |n| n := p size asString. 
		                                  self pop:1; 
		                                       push:('<item',n,'>&bull; ',t,'</item',n,'>')] ].
	listPrefix := [ :s | p := (self match: s oneOf: { '-----'. '----'. '---'. '--'. '-'. } ) ].
	"TODO: FIGURE OUT HOW TO DO AN ORDERED (NUMBERED) LIST."

	text := [ :s | t := self match: s repeat: { ordinaryText. emphasis. } ].
	ordinaryText := [:s | x := self text: s "This does a push." ].
	comment := [:s | self match: s sequence: { '('. ordinaryText. ')' } produce: [:z| self pop: 1; push: z ] ].
	
	alphanum := [ :s | x := self alphanumeric: s. ]. "Produces x."
	number := [:s | d := self digits: s ].  "Produces d."
	blank := [:s | self spaces: s ].
	
	emphasis := [:s | self match: s oneOf: { bold. italic. underline. } ].
	bold := [ :s | self match: s      sequence:{'*'. alphanum. '*'.} produce:[:z| self push:('<b>',x,'</b>')] ].	
	italic := [ :s | self match: s    sequence:{'~'. alphanum. '~'.} produce:[:z| self push:('<i>',x,'</i>')] ].	
	underline := [ :s | self match: s sequence:{'_'. alphanum. '_'.} produce:[:z| self push:('<u>',x,'</u>')] ].
	
	widget := [:s | self match: s oneOf: { pageWidget. paneWidget. linkWidget. 
																		   checkboxWidget. radioWidget. categoryWidget.
																		   attributeWidget. textAreaWidget.  entityAttributeWidget. } ].
	humNoun := [:s | x := (self noun: s ) ].
	entity := [:s | eName := (self ontology: anOntology isEntity: s)].
	attribute := [:s | aName := (self ontology: anOntology isAttribute: s)].
	category := [:s | aName := (self ontology: anOntology isCategory: s)].

	attributeWidget := [:s| self match: s sequence: {'['. humNoun. ']'.} 
														  produce: [:z | self push:('<input type="text" name="',x,'" value=""/>')]].
	entityAttributeWidget := [:s| self match: s sequence: {'['. entity. blank. attribute. ']'.} 
									produce: [:z | self push:('<input type="text" name="',eName,':',aName,'" value=""/>')]].
								"Note the name='...' value must be HTML, CSS, jQuery and HumBlackboard compatible "
	textAreaWidget := [:s | self match: s sequence: { '['. humNoun. blank. number. ']'}
		                           produce: [:z |self push:('<textarea rows="',d,'" name="',x,'"></textarea>')] ].
  checkboxWidget := [:s | self checkbox: s 
	                              produce: [:z | self pushIgnore: '<input type="checkbox" name="',z,'"/>']].
  radioWidget := [:s | self radioButton: s 
	                          produce: [:z | self pushIgnore: '<input type="radio" name="',z,'"/>']].
	categoryWidget := [:s| self match: s sequence: {'['. category. ']'.} 
													 produce: [:z | "Generate the choice tag code."
																	 code := self generateChoicesFor: aName inOntology: anOntology.
															     self push:('<select name="',aName,'">',code,'</select>')]].

	pageWidget := [:s | self match: s sequence: {'[page:'. alphanum. ']'. } 
		                       produce: [:z |self push:('<a href="',x asCamelCase,'">',x,'</a>')] ].
  viewName := [:s | self ontology: anOntology isViewName: s  
															produce: [:z | v := z.]].
	paneWidget := [:s | self match: s sequence: {'[pane:'. viewName. ']'. }
													produce: [:z | self pop: 1; push: ('<div name="',v trimBoth,'">'
														                        ,(self ontology: anOntology produceView: v)
														                        ,'</div>')]].
	url := [:s | u := self url: s ].
	linkWidget := [:s | self match: s sequence: {'[link:'. alphanum. '|'. url. ']' }
													produce: [:z | self push:'<a href="',u,'">',x trimBoth,'</a>'] ].
	
	^markup.
]

{ #category : #syntax }
HumParser2 >> markupSyntaxWithOntology: anOntology blackBoard: aBlackBoard [
	"Experimental BNF syntax"
	| markup heading text emphasis bold widget alphanum italic underline headingPrefix matched  pageWidget attributeWidget x ordinaryText textAreaWidget number d blank list listPrefix humNoun p t viewName v paneWidget code ordinaryLine url u linkWidget entityAttributeWidget entity eName attribute aName checkboxWidget radioWidget comment category categoryWidget |
	
	markup := [:s | self match: s oneOf: { heading. list. ordinaryLine.  }  ].
	ordinaryLine := [:s | self match: s repeat: {  emphasis. widget. ordinaryText. comment. }].
	
	heading := [:s | self match: s sequence:{ headingPrefix. text. } 
		                  produce:[|n| n := p size asString. self push: ('<h',n,'>',t,'</h',n,'>')] ].
	"x is the matched text -- see alphanum below"
	"n is the size of the match -- see _prefix below"
	headingPrefix := [ :s | p := self match: s oneOf: { '!!!!!'. '!!!!'. '!!!'.  '!!'. '!'. } ]. 
	
  list := [:s | self match: s sequence:{listPrefix. text.} 
	                 produce: [:z | |n| n := p size asString. 
		                                  self pop:1; 
		                                       push:('<item',n,'>&bull; ',t,'</item',n,'>')] ].
	listPrefix := [ :s | p := (self match: s oneOf: { '-----'. '----'. '---'. '--'. '-'. } ) ].
	"TODO: FIGURE OUT HOW TO DO AN ORDERED (NUMBERED) LIST."

	text := [ :s | t := self match: s repeat: { ordinaryText. emphasis. } ].
	ordinaryText := [:s | x := self text: s "This does a push." ].
	comment := [:s | self match: s sequence: { '('. ordinaryText. ')' } produce: [:z| self pop: 1; push: z ] ].
	
	alphanum := [ :s | x := self alphanumeric: s. ]. "Produces x."
	number := [:s | d := self digits: s ].  "Produces d."
	blank := [:s | self spaces: s ].
	
	emphasis := [:s | self match: s oneOf: { bold. italic. underline. } ].
	bold := [ :s | self match: s      sequence:{'*'. alphanum. '*'.} produce:[:z| self push:('<b>',x,'</b>')] ].	
	italic := [ :s | self match: s    sequence:{'~'. alphanum. '~'.} produce:[:z| self push:('<i>',x,'</i>')] ].	
	underline := [ :s | self match: s sequence:{'_'. alphanum. '_'.} produce:[:z| self push:('<u>',x,'</u>')] ].
	
	widget := [:s | self match: s oneOf: { pageWidget. paneWidget. linkWidget. 
																		   checkboxWidget. radioWidget. categoryWidget.
																		   attributeWidget. textAreaWidget.  entityAttributeWidget. } ].
	"humNoun := [:s | x := (self noun: s ). self halt. ]."
	entity := [:s | eName := (self ontology: anOntology isEntity: s)].
	attribute := [:s | aName := (self ontology: anOntology isAttribute: s)].
	category := [:s | aName := (self ontology: anOntology isCategory: s)].

	attributeWidget := [:s| self match: s sequence: {'['. attribute. ']'.} 
														  produce: [:z | "Get data from black board."
															|data| data := aBlackBoard getEntityName: v attribute: aName.
															self push:('<input type="text" name="',x,'" value="',data,'"/>')]].
	entityAttributeWidget := [:s| self match: s sequence: {'['. entity. blank. attribute. ']'.} 
									produce: [:z | self push:('<input type="text" name="',eName,':',aName,'" value=""/>')]].
								"Note the name='...' value must be HTML, CSS, jQuery and HumBlackboard compatible "
	textAreaWidget := [:s | self match: s sequence: { '['. attribute. blank. number. ']'}
		                           produce: [:z |self push:('<textarea rows="',d,'" name="',x,'"></textarea>')] ].
  checkboxWidget := [:s | self checkbox: s 
	                              produce: [:z | self pushIgnore: '<input type="checkbox" name="',z,'"/>']].
  radioWidget := [:s | self radioButton: s 
	                          produce: [:z | self pushIgnore: '<input type="radio" name="',z,'"/>']].
	categoryWidget := [:s| self match: s sequence: {'['. category. ']'.} 
													 produce: [:z | "Generate the choice tag code."
																	 code := self generateChoicesFor: aName inOntology: anOntology.
															     self push:('<select name="',aName,'">',code,'</select>')]].

	pageWidget := [:s | self match: s sequence: {'[page:'. alphanum. ']'. } 
		                       produce: [:z |self push:('<a href="',x asCamelCase,'">',x,'</a>')] ].
  viewName := [:s | self ontology: anOntology isViewName: s  
															produce: [:z | v := z.]].
	paneWidget := [:s | self match: s sequence: {'[pane:'. viewName. ']'. }
													produce: [:z | self pop: 1; 
														       push: ('<div name="',v trimBoth,'">'
														             ,(self ontology: anOntology blackBoard: aBlackBoard produceView: v)
														             ,'</div>')]].
	url := [:s | u := self url: s ].
	linkWidget := [:s | self match: s sequence: {'[link:'. alphanum. '|'. url. ']' }
													produce: [:z | self push:'<a href="',u,'">',x trimBoth,'</a>'] ].
	
	^markup.
]

{ #category : #evaluating }
HumParser2 >> match: source oneOf: anArrayOfSyntaxThings [
	| result empty |
	empty := ''.
	result := empty.
	anArrayOfSyntaxThings
		do: [:syntaxThing |
			result := self match: source with: syntaxThing.
			(result = empty ) ifFalse: [^result].
			].
	^result.
]

{ #category : #evaluating }
HumParser2 >> match: source oneOf: anArrayOfSyntaxThings produce: productionBlock [
	"Does current source match array? If so, run the production."
	| result  empty |
	self assert: ( productionBlock isKindOf: BlockClosure ).
	empty := ''.
	result := self match: source oneOf: anArrayOfSyntaxThings.
	(result = empty) ifFalse: [ productionBlock value: result ].
	^result.
]

{ #category : #evaluating }
HumParser2 >> match: source repeat: anArrayOfSyntaxThings [
	"Does current source match array?"
	| empty result nextSource  calc nextResult |
	empty := ''.
	result := empty. "By default if nothing matches front of source"
	(source = empty) 
		ifTrue: [Error signal: 'Why are you calling repeat with empty source?'].
	( anArrayOfSyntaxThings isEmpty )
		ifTrue: [Error signal: 'Why are you calling repeat with empty syntax?'].
		
	anArrayOfSyntaxThings
		do: [:syntaxThing|
			result := self match: source with: syntaxThing.
			(result = empty) 
				ifFalse: ["There was a match at current front. Move along now."
					nextSource := HumCalculator substringFrom: source after: result.
					(nextSource = empty) 
						ifTrue: ["Hurray, we matched the whole source!"
							^result].
	         "Call myself recursively."
					nextResult := self match: nextSource repeat: anArrayOfSyntaxThings.
					result := result, nextResult.
					(result size > 99 ) 
						ifTrue: [Error signal: 'Result looks too long for current debug mode.'].
					^result. 
					].
			].
	"If we fall through we've matched nothing"
	self assert: ( result = empty ).
	^result.
]

{ #category : #evaluating }
HumParser2 >> match: source sequence: anArrayOfSyntaxThings [
	"Does current source match array?"
	| empty result nextSource nextArray syntaxThing calc nextResult |
	empty := ''.
	(source = empty) ifTrue: [^''].
	( anArrayOfSyntaxThings isEmpty )
		ifTrue: [^''].
	syntaxThing := anArrayOfSyntaxThings at: 1.
	result := self match: source with: syntaxThing.
	(result = empty) ifTrue: [^result].
	calc := HumCalculator new.
	nextSource := (calc given: source extractAfter: result). 
	nextArray := anArrayOfSyntaxThings copyFrom: 2 to: anArrayOfSyntaxThings size.
  (nextSource = empty) ifTrue: [^result].
  (nextArray isEmpty) ifTrue: [^result].
  nextResult := self match: nextSource sequence: nextArray.
	(nextResult = empty) ifTrue: [^empty].
	result := result, nextResult.
	result size > 99 ifTrue: [ Error signal: 'Result looks too long for current tests.'].
	^result.
]

{ #category : #evaluating }
HumParser2 >> match: source sequence: anArrayOfSyntaxThings produce: productionBlock [
	"Does current source match array? If so, run the production."
	| result  empty |
	self assert: ( productionBlock isKindOf: BlockClosure ).

	empty := ''.
	result := self match: source sequence: anArrayOfSyntaxThings.
	(result = empty) ifFalse: [ productionBlock value: result ].
	^result.
]

{ #category : #evaluating }
HumParser2 >> match: aString with: syntaxThing [ 
	"Does aString match with syntaxThing?"
	| result empty |
	empty := ''.
	result := empty. "Null result is EMPTY string"
	
	( syntaxThing isKindOf: String )
		ifTrue: [
			( (aString trimLeft) beginsWith: syntaxThing ) 
				ifTrue: [  ^ syntaxThing ]
				ifFalse: [ ^ empty ] 
			].
	( syntaxThing isKindOf: BlockClosure ) ifFalse: [Error signal: 'Should be block closure in this context'].
	result := syntaxThing value: aString.
	(result = empty) ifFalse: [ ].
	^result.
]

{ #category : #binding }
HumParser2 >> noun: source [ 
	"Match that part of the string that might name a Hum noun"
	| empty result |
	empty := ''.
	result := empty.
	source
		do: [:ch |
			( ch isLetter or: [ (ch = $- ) or: [ch isDigit]  ])
				ifTrue: [ result := result, ch asString. ]
				ifFalse: [
					"A Hum noun must start with a letter."
					((result at: 1) isLetter) 
						ifFalse: [Error signal: 'A Hum noun must start with a letter'].
					"A Hum noun must be more than a single letter."
					(result size > 1) 
						ifFalse: [Error signal: 'A Hum noun must be more than a single letter.'].
					^result
					].
			].
	^result.
]

{ #category : #binding }
HumParser2 >> ontology: aHumOntology blackBoard: aBlackBoard produceView: aViewName [ 
	"Produce the HTML for the given view frame."
	| parser syntax frame lines code |
	"Set up an indepent parser so that we don't interfere with caller."
	parser := self class new.
	frame := aHumOntology getViewFrame: aViewName.
	lines := frame frameLines.
	(lines isEmpty) ifTrue: [ Error signal: 'View is empty or name is wrong'].
	syntax := parser markupSyntaxWithOntology: aHumOntology blackBoard: aBlackBoard.
	"Pass the view name through -- is also default entity-name."
	aBlackBoard defaultEntity: aViewName trimBoth.
	lines
		do: [:frameLine |
			| s |
			s := frameLine source.
			parser push: (String cr,'<br/>&nbsp; ').
			(s trimBoth = '') 
				ifTrue: [ parser push: ('').]
				ifFalse: [parser match: s with: syntax.].
			].
	^code := parser generatedCode .
	
]

{ #category : #binding }
HumParser2 >> ontology: aHumOntology isAttribute: aSource [ 
	"Does the current source, upto some delimiter, match an ontology attribute name?"
	| parser result empty  |
	parser := self class new.
	empty := ''.
	result := empty.
	"An attribute name must be alphanumeric"
	result := parser noun: aSource.
	(result = empty)
		ifTrue: [ Error signal: 'Expected a noun, but found:"',aSource ].
	(aHumOntology isAttribute: result)
		ifTrue: [ "self push: result." ^result ]
		ifFalse: [Error signal: result,' does not name an attribute.'].
	^result.
]

{ #category : #binding }
HumParser2 >> ontology: aHumOntology isCategory: aSource [ 
	"Does the current source, upto some delimiter, match an ontology category name?"
	| parser result empty  |
	parser := self class new.
	empty := ''.
	result := empty.
	"A category name must be alphanumeric"
	result := parser noun: aSource.
	(result = empty)
		ifTrue: [ Error signal: 'Expected a noun, but found:"',aSource ].
	(aHumOntology isCategory: result)
		ifTrue: [ "self push: result." ^result ]
		ifFalse: [^empty.].
	Error signal: 'How did we get here?'.
	^result.
]

{ #category : #binding }
HumParser2 >> ontology: aHumOntology isEntity: aSource [ 
	"Does the current source, upto some delimiter, match an ontology entity name?"
	| parser result empty  |
	parser := self class new.
	empty := ''.
	result := empty.
	"An entity name must be alphanumeric"
	result := parser noun: aSource.
	(result = empty)
		ifTrue: [ Error signal: 'Expected a noun, but found:"',aSource ].
	(aHumOntology isEntity: result)
		ifTrue: [ "self push: result." ^result ]
		ifFalse: [Error signal: result,' does not name an entity.'].
	^result.
]

{ #category : #binding }
HumParser2 >> ontology: aHumOntology isViewName: aSource [ 
	"Does the current source, upto some delimiter, match an ontology view name?"
	| parser result empty alpha |
	parser := self class new.
	empty := ''.
	result := empty.
	"a view name must be alphanumeric"
	alpha := [:s | parser alphanumeric: s ].
	result := parser match: aSource repeat: { alpha. '-'.}.
	(result = empty)
		ifTrue: [ Error signal: 'Expected alphanumeric, but found:"',aSource ].
	(aHumOntology isViewName: result)
		ifTrue: [ self push: result. ^result ]
		ifFalse: [Error signal: result,' does not name a view frame.'].
	^result.
]

{ #category : #binding }
HumParser2 >> ontology: aHumOntology isViewName: aSource produce: productionBlock [ 
	"Does the current source, upto some delimiter, match an ontology view name? 
	If so, produce the given production"
	| result empty alpha |
	
	empty := ''.
	result := empty.
	"a view name must be alphanumeric"
	alpha := [:s | self alphanumeric: s ].
	result := self match: aSource repeat: { alpha. '-'.}.
	(result = empty)
		ifTrue: [ Error signal: 'Expected alphanumeric, but found:"',aSource ].
	(aHumOntology isViewName: result)
		ifTrue: [ self push: (productionBlock value: result)]
		ifFalse: [Error signal: result,' does not name a view frame.'].
	^result.
]

{ #category : #binding }
HumParser2 >> ontology: aHumOntology produceView: aViewName [ 
	"Produce the HTML for the given view frame."
	| parser syntax frame lines code |
	"Set up an indepent parser so that we don't interfere with caller."
	parser := self class new.
	frame := aHumOntology getViewFrame: aViewName.
	lines := frame frameLines.
	(lines isEmpty) ifTrue: [ Error signal: 'View is empty or name is wrong'].
	syntax := parser markupSyntaxWithOntology: aHumOntology.
	lines
		do: [:frameLine |
			| s |
			s := frameLine source.
			parser push: (String cr,'<br/>&nbsp; ').
			(s trimBoth = '') 
				ifTrue: [ parser push: ('').]
				ifFalse: [parser match: s with: syntax.].
			].
	^code := parser generatedCode .
	
]

{ #category : #accessing }
HumParser2 >> pop: aSmallInteger [ 
	(1 to: aSmallInteger)
		do: [:i | (self stack) removeLast.]
	
]

{ #category : #accessing }
HumParser2 >> push: aString [ 
	(self ignoreNext) 
		ifFalse: [(self stack) addLast: aString.]
		ifTrue: [self ignoreNext: false.].
	^aString
]

{ #category : #accessing }
HumParser2 >> pushIgnore: aString [ 
	(self stack) addLast: aString.
	self ignoreNext: true.
	^aString
]

{ #category : #evaluating }
HumParser2 >> radioButton: aSource produce: aProductionBlock [
	"Does the current source start with a radio button widget?"
	| empty s |
	empty := ''.
	(aSource size >= 3) ifFalse: [^empty].
	s := aSource copyFrom: 1 to: 3.
	('(#)' matches: s) 
		ifTrue: [ 
			| ch x |
			ch := (s at: 2).
			"A radio button must contain a single letter. 
			(Otherwise the name will not be HTML/CSS compatible)"
			(ch isLetter) 
				ifFalse: [Error signal: 'A radio button must contain a single letter.'].
			x := ch asString.
			self push: (aProductionBlock value: x ). ^s]
		ifFalse: [^empty].
	
]

{ #category : #evaluating }
HumParser2 >> spaces: source [ 
	"Match leading part of source that is digits"
	| empty result |
	empty := ''.
	result := empty.
	source
		do: [:ch |
			( ch = Character space  or: [ ch = Character tab ] )
				ifTrue: [ result := result, ch asString. ]
				ifFalse: [^result].
			].
	^result.
	
]

{ #category : #accessing }
HumParser2 >> stack [
	^stack ifNil: [ stack := OrderedCollection new.]
]

{ #category : #evaluating }
HumParser2 >> text: aString [ 
	"Return that part of string that contains no mark-up."
	| empty result |
	empty := ''.
	result := empty.
	
	aString
		do: [:ch |
			"Terminate on any character that indicates emphasis or widget."
			( '*~_[]()' includes: ch )
				ifFalse: [ result := result, ch asString. ]
				ifTrue: [^self push: result.].
			].
	^self push: result.
]

{ #category : #accessing }
HumParser2 >> top [
	| item |
	item := (self stack) last.
	^item.
]

{ #category : #syntax }
HumParser2 >> url: source [
	"Does current source match a URL pattern?"
	| alpha prefix server url result p x u nom parser |
	parser := self class new.
	alpha := [:s | parser alphanumeric: s ].
	nom := [:s | parser match: s oneOf: { alpha. '-'. '_'.} ].
	prefix := [:s | p := parser match: s oneOf: {'http://'. 'https://'. } ].
	server := [:s | x := (parser match: s repeat: { nom. '.'. '/'. }) trimBoth ].
	"Note: Calling trimBoth above might accidentally clean up a bad URL."
	url := [:s | u := parser match: s sequence: { prefix. server. } produce: [:t | parser push:(p,x)] ].
	result := parser match: source with: url.
	^result.

]
