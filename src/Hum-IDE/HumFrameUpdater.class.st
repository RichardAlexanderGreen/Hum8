"
The frame updater is a component of the IDE -- of the Programmers Assistant.
It is a mediator between a specific UI and an ontology frame object.
It implements actions on the frame without implementing the UI.

Instance Variables:
	frame	<HumFrame>
	lines	<OrderedCollection>
	ontology	<ProtoObject | PseudoContext>
"
Class {
	#name : #HumFrameUpdater,
	#superclass : #Object,
	#instVars : [
		'frame',
		'ontology',
		'mode',
		'programmersAssistant',
		'currentRole',
		'vignetteMode',
		'vignetteContext'
	],
	#category : #'Hum-IDE'
}

{ #category : #'instance creation' }
HumFrameUpdater class >> ontology: aHumOntology commentTitle: aTitleString [ 
	"Instantiate with a new comment frame."
	| frameUpdater |
	frameUpdater := self new.
	frameUpdater ontology: aHumOntology.
	frameUpdater frame:( (HumFrame4Comment new) ontology: aHumOntology; titleLine: aTitleString ).
	
	^frameUpdater 
]

{ #category : #'instance creation' }
HumFrameUpdater class >> ontology: aHumOntology dictionaryTitle: aTitleString [ 
	"Instantiate with a new dictionary frame."
	| frameUpdater |
	frameUpdater := self new.
	frameUpdater ontology: aHumOntology.
	frameUpdater frame:( (HumFrame4Dictionary new) ontology: aHumOntology; titleLine: aTitleString ).
	
	^frameUpdater 
]

{ #category : #accessing }
HumFrameUpdater class >> ontology: aHumOntology fetchFrameByName: aString [ 
	| frame frameUpdater |
	frame := aHumOntology fetchFrameByName: aString.
	frameUpdater := self new.
	frameUpdater ontology: aHumOntology; frame: frame.
	^ frameUpdater.
]

{ #category : #'instance creation' }
HumFrameUpdater class >> ontology: aHumOntology goal: goalStatement [ 
	| frameUpdater |
	frameUpdater := self new.
	frameUpdater ontology: aHumOntology.
	frameUpdater frame:( HumFrame4Plan ontology: aHumOntology goal: goalStatement).
	^frameUpdater.
]

{ #category : #'instance creation' }
HumFrameUpdater class >> ontology: aHumOntology loadFrameByIdentifier: aPrimaryKey [ 
	
	| frameUpdater |
	frameUpdater := self new.
	frameUpdater ontology: aHumOntology.
	frameUpdater frame: ( aHumOntology fetchFrameByIdentifier:  aPrimaryKey ).
	^frameUpdater.
]

{ #category : #'instance creation' }
HumFrameUpdater class >> ontology: aHumOntology loadFrameByName: aString [ 
	| frame frameUpdater |
	frame := aHumOntology fetchFrameByName: aString.
	frameUpdater :=  self new.
	frameUpdater ontology: aHumOntology; 
	                frame: frame.
	^ frameUpdater
]

{ #category : #'instance creation' }
HumFrameUpdater class >> ontology: aHumOntology role: aRole action: anActionStatement [ 
	| frameUpdater |
	frameUpdater := self new.
	frameUpdater ontology: aHumOntology.
	frameUpdater frame: ( HumFrame4Action ontology: aHumOntology role: aRole action: anActionStatement ).
	^frameUpdater.
	
]

{ #category : #'instance creation' }
HumFrameUpdater class >> ontology: aHumOntology viewEntity: anEntity [ 
	| frameUpdater |
	frameUpdater := self new.
	frameUpdater ontology: aHumOntology.
	frameUpdater frame: (  HumFrame4View ontology: aHumOntology viewEntity: anEntity ).
	^frameUpdater.
	
	
]

{ #category : #'instance creation' }
HumFrameUpdater class >> ontology: aHumOntology vignetteContext: aContextString pattern: aPatternString [ 
	| frame  frameUpdater |
	frame := HumFrame4Vignette ontology: aHumOntology vignetteContext: aContextString pattern: aPatternString.
	frameUpdater := self new.
	frameUpdater ontology: aHumOntology; 
	                frame: frame.
	^frameUpdater. 
]

{ #category : #'add frame line' }
HumFrameUpdater >> addActionLine: aSourceString [ 
	| source calc |
	source := aSourceString.
	calc := HumCalculator new.
	calc cases;
		when: [source beginsWith: 'Action:'] 
		      then: [frame ifNotNil:[ self storeFrameInOntology ]. "Save prior frame, if any."
			          "Start a new action frame. This action is in the role`s PUBLIC API."        
                 self frame: (HumFrame4Action ontology: ontology 
			                                           role: currentRole 
			                                          action: (calc given: source extractAfter: 'Action:')) ];
		when: [source beginsWith: 'To:'] 
		      then: [frame ifNotNil:[ self storeFrameInOntology ]. "Save prior frame, if any."
			          "Start a new action frame. This action is in the role`s PRIVATE API."        
                 self frame: (HumFrame4Action ontology: ontology 
			                                           role: currentRole 
			                                          action: (calc given: source extractAfter: 'To:')) ];
		otherwise: [ | instructionLine |
								instructionLine := self parseInstruction: source.
								self frame appendFrameLine: instructionLine.
								self frame instructionLines add: instructionLine.].
		
	
]

{ #category : #'add frame line' }
HumFrameUpdater >> addDictionaryLine: aSourceString [ 
	self frame addDictionaryLine: (self stripLeaderFrom: aSourceString).
]

{ #category : #'add frame line' }
HumFrameUpdater >> addMarkUp: aSourceString [ 
	self frame addMarkUp: ( ( HumMarkupLine new ) source:  aSourceString) .
]

{ #category : #'add frame line' }
HumFrameUpdater >> addPlanLine: aSourceString [ 
	"The kind of line is modal."
	"Look for lines that reset the mode."
	( (aSourceString asLowercase beginsWith: 'precondition')
	  or: [aSourceString asLowercase beginsWith: 'pre:']
	)
		ifTrue: [mode := #preconditions.
			frame appendFrameLine: (HumFrameLine source: aSourceString).
			^self.
			].
	( (aSourceString beginsWith: 'Action:') or: [aSourceString beginsWith: 'Actions:'])
		ifTrue: [mode := #actions.
			frame appendFrameLine: (HumFrameLine source: aSourceString).
			^self.
			].
	"Process the source line according to mode set by prior source line."	
	(mode = #preconditions)
		ifTrue: [
			self appendPrecondition: aSourceString.
			^self
			].
	(mode = #actions)
		ifTrue: [ | aRole sourceMinusComment |
			sourceMinusComment := self programmersAssistant removeCommentFromSource: aSourceString.
			(sourceMinusComment sameAs: '') 
				ifTrue: [frame appendFrameLine: (HumCommentLine source: aSourceString).]
				ifFalse: [
					aRole := self programmersAssistant getLabelFromSource: aSourceString.
					aRole ifNil: [Error signal: 'Plan actions must have roles.'].
					self appendRole: aRole action: (self programmersAssistant removeLabelFromSource: aSourceString).
					].	
			^self.
			].
	(mode isNil)
		ifTrue: [ "Default mode is preconditions -- Allows 'Preconditions:' label to be omitted in source file."
			mode := #preconditions. 
			self appendPrecondition: aSourceString.
			^self
			].
	Error signal: 'How did we fall through addPlanLine: ...?'.
		 
]

{ #category : #'add vignette line' }
HumFrameUpdater >> addVignetteInstruction: anInstructionLine [ 
	( self frame ) addVignetteInstruction: anInstructionLine. 
]

{ #category : #'add vignette line' }
HumFrameUpdater >> addVignetteLine: aSourceString [ 
	| source calc |
	source := aSourceString.
	calc := HumCalculator new.
	"DEBUG
	(aSourceString endsWith: '].') 
		ifTrue: [ 
			Transcript cr; 
				show: aSourceString; 
				show: ' ';	
				show: vignetteMode;
				show: ' ';
				show: (frame patterns at: 1) asString.
			].
	"
	calc cases;
		when: [(source beginsWith: 'U:')
				and: [self vignetteMode = #pattern]]
			then: [frame addVignettePattern: (calc given: source extractAfter: 'U:')
				];
		when: [(source beginsWith: 'U:')
				and: [self vignetteMode = #response]]
			then: [| pattern |
				"Store prior vignette frame and Start a new vignette frame."
				frame patterns size > 0
					ifTrue: ["Store prior vignette frame and Start a new vignette frame."
						self storeFrameInOntology. ].
				pattern := calc given: source extractAfter: 'U:'.
				frame := HumFrame4Vignette
						ontology: self ontology
						vignetteContext: self vignetteContext
						pattern: pattern.
				self vignetteMode: #pattern.
				frame addVignettePattern: pattern
				];
		when: [source beginsWith: 'S:']
			then: ["Starting response."
				self vignetteMode: #response.
				frame addVignetteResponse: (calc given: source extractAfter: 'S:')
				];
		when: [source sameAs: '']
			then: ["Ignore blank line."
			];
		when: [ source beginsWith: ' ' ]
			then: ["Should be response line." 
				frame addVignetteResponse: source.
				];
		when: [source beginsWith: '.']
			then: ["Add instruction line."
				frame addVignetteInstruction: (calc given: source extractAfter: '.')
				];
		otherwise: [Error signal: 'Vignette line type not recognized.']
]

{ #category : #'add vignette line' }
HumFrameUpdater >> addVignetteResponse: aResponseString [ 
	(self frame) addVignetteResponse: aResponseString.
]

{ #category : #'add frame line' }
HumFrameUpdater >> appendFrameLine: aSourceString [ 
	"Create appropriate frameLine type and append to frame."
	| calc source |
	self assert: (aSourceString isKindOf: String).
	source := self stripLeaderFrom: aSourceString.
	calc := HumCalculator new.
	calc cases;
		when: [self frame isKindOf: HumFrame4Plan] then: [ self addPlanLine: source ];
		when: [self frame isKindOf: HumFrame4View] then: [ frame addMarkUp: source ];
		when: [self frame isKindOf: HumFrame4Action] then: [ self addActionLine: source ];
		when: [self frame isKindOf: HumFrame4Comment] then: [ frame appendFrameLine: (HumCommentLine source: source) ];
		when: [self frame isKindOf: HumFrame4Dictionary] then: [ frame addDictionaryLine: source ];
		"For vignette lines, we want to preserve leading dot because it identifies instruction lines."
		when: [self frame isKindOf: HumFrame4Vignette] then: [ self addVignetteLine: aSourceString ];
		otherwise: [ Error signal: 'Unknown frame type.'].
	
]

{ #category : #'add frame line' }
HumFrameUpdater >> appendInstructionRole: aRole statement: aStatement [ 
	self frame appendInstructionRole: aRole statement: aStatement.
]

{ #category : #'add frame line' }
HumFrameUpdater >> appendInstructionRole: aRole statement: aStatement comment: aComment [ 
	self frame appendInstructionRole: aRole statement: aStatement comment: aComment .
]

{ #category : #'add frame line' }
HumFrameUpdater >> appendInstructionStatement: aStatement [ 
	"Append a simple instruction (no delegation, no comment) to the frame."
	|  |
	self frame appendInstructionStatement: aStatement.
]

{ #category : #'add frame line' }
HumFrameUpdater >> appendPrecondition: aPreconditionStatement [ 
	self assert: ( self frame isKindOf: HumFrame4Plan ).
	self frame appendPrecondition: (self stripLeaderFrom: aPreconditionStatement) .
]

{ #category : #'add frame line' }
HumFrameUpdater >> appendRole: aRole action: aStatement [ 
	"Pass through to frame."
	self frame appendInstructionRole: aRole statement: aStatement.
]

{ #category : #'ontology operations' }
HumFrameUpdater >> checkFrameSyntax [
	| errors |
	errors := self frame checkSyntaxWithOntology: self ontology.
	^errors.
]

{ #category : #'ontology operations' }
HumFrameUpdater >> compileToOntology: aHumOntology [ 
	"Delegate to the frame."
	| errors |
	errors := self frame compileToOntology: aHumOntology.
	^errors.
]

{ #category : #accessing }
HumFrameUpdater >> frame [
	"If frame is not initialized before this call, we have a logic error."
	^frame ifNil: [ Error signal: 'frame has not bee initialized in FrameEditor instance.'].
]

{ #category : #accessing }
HumFrameUpdater >> frame: aFrame [ 
	"What frame am I editing ?"
	frame := aFrame
]

{ #category : #'add frame line' }
HumFrameUpdater >> getInstructionAt: aSmallInteger [ 
	^self lines at: aSmallInteger .
]

{ #category : #accessing }
HumFrameUpdater >> isEmpty [
	^ (frame isNil) or: [frame isEmpty].
]

{ #category : #accessing }
HumFrameUpdater >> lines [
	^ (self frame) lines.
]

{ #category : #'add vignette line' }
HumFrameUpdater >> nextVignetteContext: aString [ 
	frame nextVignetteContext: aString
]

{ #category : #accessing }
HumFrameUpdater >> ontology [
	^ (ontology) ifNil: [ Error signal: 'Frame Updater instance must have an ontology.']
]

{ #category : #accessing }
HumFrameUpdater >> ontology: aHumOntology [ 
	ontology := aHumOntology.
]

{ #category : #'add frame line' }
HumFrameUpdater >> parseInstruction: sourceWith [ 
	|  resultLine source comment role stmt |
	self assert: (sourceWith isKindOf: String).
	resultLine := HumInstructionLine source: sourceWith.
	source := self stripLeaderFrom: sourceWith.
	comment := HumCalculator given: source extractIncludingMatching: '()'.
	(comment isNil) 
		ifFalse: [ | beforeComment afterComment |
			beforeComment := HumCalculator given: source extractUpto: comment.
			afterComment := HumCalculator given: source extractAfter: comment.
			source := beforeComment, afterComment.
			resultLine comment: comment.
			].
	"Allow blank lines for readability."
	(source sameAs: ' ') ifTrue: [^resultLine].
	"Identify pattern and parse accordingly."
	role := HumProgrammersAssistant getLabelFromSource: source.
	stmt := HumProgrammersAssistant removeLabelFromSource: source.
	resultLine := HumInstructionLine role: role statement: stmt.
	(comment isNil) ifFalse: [resultLine comment: comment].
	^resultLine.

]

{ #category : #printing }
HumFrameUpdater >> prettyPrint [
	"Pretty print the frame content (rendering as HTML)."
	| html |
	html := ontology view renderFrame: frame withCritique: false withBase: false.
	^html
]

{ #category : #accessing }
HumFrameUpdater >> programmersAssistant [
	^ programmersAssistant ifNil: [programmersAssistant := HumProgrammersAssistant new].
]

{ #category : #'add frame line' }
HumFrameUpdater >> putInstruction: aHumInstruction at: aSmallInteger [ 
	| myLines |
	myLines :=  (self lines).
	( myLines isEmpty) 
		ifFalse: [ myLines  at: aSmallInteger put: aHumInstruction .]
		ifTrue: [ myLines add: aHumInstruction ].
		
]

{ #category : #'ontology operations' }
HumFrameUpdater >> storeFrameInOntology [
	"Store my frame in my ontology"
	| |
	"The frame must have a title."
	self assert: ( frame titleLine notNil ).
	(self ontology) storeFrame: frame.
]

{ #category : #'add frame line' }
HumFrameUpdater >> stripLeaderFrom: aLine [ 
	| stmt calc |
	(aLine = '.') ifTrue: ["Assume blank instruction line." ^''].
	stmt := aLine.
	calc := HumCalculator new.
	[stmt beginsWith: '. ']
		whileTrue: [ stmt := calc given: stmt extractAfter: '. '].
	^stmt
]

{ #category : #'add vignette line' }
HumFrameUpdater >> vignetteContext [
	| result |
	result := frame vignetteContext.
	^result.
]

{ #category : #'add vignette line' }
HumFrameUpdater >> vignetteMode [
	"What mode is the vignette parser in?"
	vignetteMode ifNil: [ vignetteMode := #pattern ].
	self assert: ( vignetteMode = #pattern or: [ vignetteMode = #response ]).
	^vignetteMode
]

{ #category : #'add vignette line' }
HumFrameUpdater >> vignetteMode: newMode [
	"What mode is the vignette parser in?"
	self assert: ( newMode = #pattern or: [ newMode = #response ]).
	vignetteMode := newMode.
]
