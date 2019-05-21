"
A HumView operates a MVC (model-view-controller) 
  where the model values are in a Blackboard. (See: HumBlackBoard).
A Hum Ontology provides the metadata that is used to interpret views.

A typical view shows the data for a single object instance.
However, an object may have component/related objects and collections of component/related objects.

A view contains a collection of widgets. (See: HumWidget and HumMarkupLine)
View content and layout may be specified by a Hum View Frame. (See: HumFrame4View)

Instance Variables:
	entityName 	- an entity-type-name.
	entityID 		- an entity-identifier known to blackboard
	blackboard	 	- aHumBlackboard
	ontology 		- aHumOntology ... provides view-frame and informs the interpretation of attributes
	viewFrame 		- fetched from ontology . . . contains markup lines
	formWidget 	- The formWidget provides run-time interpretation of the view via Seaside - see >>renderContentOn:
	lastLevel		- Tracks the nesting of lists.
		
TODO: Perhaps this should be a HumWidget and inherit from WAComponent.
  OR: We could use WAFormTag as a component?
  OR: Define a HumForm widget which is informed by a HumView and an Ontology.
TODO: Should some Hum-Thing should correspond/subclass WAApplication? (WAApplication defines libraries.)
"
Class {
	#name : #HumView,
	#superclass : #HumPane,
	#instVars : [
		'entityID',
		'entityName',
		'blackboard',
		'ontology',
		'viewFrame',
		'formWidget',
		'lastLevel',
		'calc'
	],
	#category : #'Hum-UI'
}

{ #category : #'user interface' }
HumView >> asWidget [
	"Initialize a HumFormWidget for this view"
	^formWidget ifNil: [ formWidget := HumFormWidget onView: self]
]

{ #category : #accessing }
HumView >> blackboard [
	^ blackboard ifNil: [ Error signal: 'No blackboard has been assigned to this view.'].
]

{ #category : #accessing }
HumView >> blackboard: aHumBlackBoard [
	self assert: ( aHumBlackBoard isKindOf: HumBlackBoard ).
	blackboard := aHumBlackBoard.
]

{ #category : #accessing }
HumView >> calc [
	"Create a calculator to be shared . . ."
	^ calc ifNil: [ calc := HumCalculator new ].
]

{ #category : #accessing }
HumView >> entityName [
	"get"
	^entityName ifNil: [Error signal: 'No entity name has been set for this view.']
]

{ #category : #accessing }
HumView >> entityName: aString [
	"Set"
	entityName := aString.
]

{ #category : #'user interface' }
HumView >> interpretEmphasisIn: aString on: aWAHtmlCanvas [ 
	"TODO: THIS IS A STUB - Expect aString contains Hum Markup."
	"See: HumMarkupLine >>generateCodeOfType: aSymbol fromTokens: tokens at: xToken"
	"See: HumOntologyViewer >>renderMarkupAsHTML5: markupSource"
	"See: HumOntologyViewer >>renderMarkupEmphasisAsHTML5: aString "
	"TODO: REFACTOR."
	"TODO: Markup rendering seems to be missing tests."
	aWAHtmlCanvas text: aString.
]

{ #category : #accessing }
HumView >> ontology: aHumOntology [ 
	ontology := aHumOntology. 
]

{ #category : #'user interface' }
HumView >> renderFrameLine: aHumMarkupLine viaSeasideCanvas: aWAHtmlCanvas [ 
	| html heading marker remainder level aString markupSource entity |
	Error signal: 'The code in this method is internally inconsistent.'.
	markupSource := aHumMarkupLine source.
	aWAHtmlCanvas break.
	self calc.
	"Maintain spacing."
	aString := calc given: markupSource replaceAll: '  ' with: '&nbsp;&nbsp;'.
	
	"Is this markup line a heading?"
	heading := 'none'.
	(1 to: 5)
		do: [ :i |
			marker := '!!!!!' copyFrom: 1 to: i.
			( aString beginsWith: marker ) 
				ifTrue: [ "Set the heading type and extract the remainder."
					heading := 'h', (marker size) asString. 
					remainder := (calc given: aString extractAfter: marker ) ]. 
			].
	"If this is a heading, render the whole line as a heading. "	
	"Call self recursively to catch any additional emphasis (e.g. italics)"
	( heading = 'none'	) ifFalse: [ aWAHtmlCanvas heading level: (heading size); with: remainder. ^self ].

	"Is this markup line a bullet/numbered list item."	
	#( '-----' '#####') "If so, compute the indent level."
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

				html := html, (calc xml: 'li' 
											with: [ 
												[ remainder > '' ] 
													whileTrue: [ remainder := self renderUpToNextWidget: remainder on: aWAHtmlCanvas ]  
													]
												).
				^html.	
				].
			].	
	"TODO: AT THIS POINT - OUTPUT UP TO NEXT MARK-UP"
	remainder := self renderUpToNextWidget: aString on: aWAHtmlCanvas.
	aString := remainder.
	['*[*]*' match: aString]
		whileTrue: [ "Interpret by calling a HumWidget"
			| between widget |
			between := calc given: aString extractBetween: '[' and: ']'.
			remainder := calc given: aString extractAfter: ']'.
			entity := (self entityName).
			((between at: (between size)) isDigit)
				ifTrue: ["Update text"
					| attributeName rows |
					attributeName := calc given: between extractUpto: ' '.
					rows := calc given: between extractAfter: ' '.
					widget := HumTextWidget onEntity: entity attribute: between blackboard: blackboard.
					widget rows: (rows asNumber).
					]
				ifFalse: ["Update . . ."
					| supertypes |
					"Default type is a simple string"
					widget := HumStringWidget onEntity: entity attribute: between blackboard: blackboard.
					"Check for special types"
					supertypes := ontology allSupertypesOf: between.
					(supertypes include: 'date')
							ifTrue: [ widget := HumDateWidget onEntity: entity attribute: between blackboard: blackboard ].
					(supertypes include: 'measure')
							ifTrue: [ widget := HumMeasureWidget onEntity: entity attribute: between blackboard: blackboard ].
					(supertypes include: 'collection')
							ifTrue: [ widget := HumCollectionWidget onEntity: entity attribute: between blackboard: blackboard ].
					(supertypes include: 'category')
							ifTrue: [widget := HumCategoryWidget onEntity: entity attribute: between blackboard: blackboard.
								widget categories: (ontology categoriesOf: between).
								].
					].
			remainder := self renderUpToNextWidget: aString on: aWAHtmlCanvas.	
			widget renderContentOn: aWAHtmlCanvas.
			aString := remainder.
			]. 
	
]

{ #category : #'user interface' }
HumView >> renderMarkupLinesViaSeasideOn: aWAHtmlCanvas [ 
	"Render the ontology view frame lines via Seaside"
	| |
	"self assert: ( aWAHtmlCanvas isKindOf: WAHtmlCanvas )."
	Error signal: 'This code has not been tested.'.
	(self view) frameLines
		do: [:frameLine | self renderFrameLine: frameLine viaSeasideCanvas: aWAHtmlCanvas.].
]

{ #category : #'user interface' }
HumView >> renderUpToNextWidget: aMarkupString on: html [
	"Render mark-up that does not involve heading/list/widget"
	| wip remainder |
	
	"Precondition: Caller has already handled and removed markup for header or list."
	#( '!' '-' '#' ) do: [:mark | self assert: (aMarkupString beginsWith: mark) not ].
	
	"Break up the line. We will only render non-widget stuff."
	self calc.
	wip := calc given: aMarkupString extractUpto: '['.
	remainder := calc given: aMarkupString extractAfter: wip.
	
	"TODO: Interpret emphasis -- if any"
	self interpretEmphasisIn: wip on: html.
	
	^remainder. "TODO: Should this method call itself recursively -- or leave that loop to the caller?"
]

{ #category : #accessing }
HumView >> view [
	^ viewFrame ifNil: [Error signal: (self class asString),' not initialized']
]

{ #category : #accessing }
HumView >> view: aViewNameString [ 
	"Fetch the view frame of that name."
	viewFrame :=  ontology fetchFrameByName: ('View: ',aViewNameString,'.').
	self entityName: aViewNameString.
	self id: aViewNameString.
	
]
