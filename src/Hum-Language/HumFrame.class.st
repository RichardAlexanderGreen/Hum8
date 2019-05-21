"
A ""frame"" is a small amount of program code in the ontology.
Different types of frames contain different types of information and conform to different notations.
A frame has a title and contains a list of frame-lines.

Instance Variables:
	frameLines	<OrderedCollection>
	titleLine	<Object>
	ontology	<HumOntology>
	uniqueIdentifier	<UUID>
"
Class {
	#name : #HumFrame,
	#superclass : #Object,
	#instVars : [
		'frameLines',
		'titleLine',
		'ontology',
		'uniqueIdentifier',
		'debug',
		'origin'
	],
	#category : #'Hum-Language'
}

{ #category : #accessing }
HumFrame >> appendFrameLine: aFrameLine [
	"Append a line to the frame."
	(aFrameLine isKindOf: HumFrameLine ) ifFalse: [Error signal: 'not a frameLine'].
	self frameLines add: aFrameLine.
]

{ #category : #testing }
HumFrame >> checkSyntaxWithOntology: anOntology [
	| frameErrors lineErrors    |
	frameErrors := OrderedCollection new.
	"Check stand-alone syntax.
	Detect statements with no nouns.
	Detect statements that have not been defined.
	"
	(self frameLines reject: [:frameLine | (frameLine isKindOf: HumCommentLine )])
		do: [ :frameLine | 
			lineErrors := (frameLine checkSyntaxWithOntology: anOntology).
			(lineErrors isEmpty) ifFalse: [ frameErrors := frameErrors, lineErrors ].
			].
	^frameErrors.
]

{ #category : #testing }
HumFrame >> compileToOntology: aHumOntology [ 
	| problems lineProblems |
	problems := OrderedCollection new.
	self frameLines
		do: [ :frameLine |
			lineProblems := ( frameLine compileLineToOntology: aHumOntology ).
			problems := problems, lineProblems.
			].
	"Regardless of errors add frame to the ontology."	
	aHumOntology storeFrame: self.
	^problems.
]

{ #category : #debugging }
HumFrame >> debug [
	"Am I in debug mode?"
	^ debug ifNil: [debug := false].
]

{ #category : #debugging }
HumFrame >> debug: aBoolean [ 
	self assert: (aBoolean isKindOf: Boolean).
	debug := aBoolean.
]

{ #category : #debugging }
HumFrame >> delegateToTranslator [
	Error signal: 'This frame function should be delegated to HumOntologyTranslator.'
]

{ #category : #translating }
HumFrame >> delegated [
	Error signal: 'Should be implemented in Ontology Viewer (HumOntologyViewer)'.
]

{ #category : #accessing }
HumFrame >> frameLines [
	^frameLines ifNil: [ frameLines := OrderedCollection new.]
]

{ #category : #accessing }
HumFrame >> frameName [
	"The name of the frame is guaranteed to be a string.
	Generally, it is the same as the titleLine.
	"
	| frameName |
	frameName := (self titleLine) asString trimBoth.
	^ frameName.
]

{ #category : #debugging }
HumFrame >> initialize [
	"The instance should always be a subtype."

	| instance |
	instance := self.
	self assert: (instance className = 'HumFrame') not.
	
]

{ #category : #accessing }
HumFrame >> isEmpty [
	"If the frame has no title and no framelines, it is empty.."
	|   |
	((titleLine notNil) and: [titleLine > '']) ifTrue: [ ^false ].
	(self frameLines size > 0) ifTrue: [ ^false ].
	^true.	
			
]

{ #category : #rendering }
HumFrame >> linesAsHTMLwithOntology: anOntology [
	| html cr |
	cr := String cr.
	html := cr.
	self frameLines 
		do: [ :frameLine |
				html := html, '<br/>', ( frameLine asHTML5withOntology: anOntology ) ].
	^html.
]

{ #category : #accessing }
HumFrame >> ontology [
	^ ontology
]

{ #category : #accessing }
HumFrame >> ontology: anOntology [
	
	ontology := anOntology.
	self origin: anOntology title.
]

{ #category : #accessing }
HumFrame >> origin [
	"Where did this frame come from?"
	^origin ifNil: [ origin := 'unknown' ].
]

{ #category : #accessing }
HumFrame >> origin: aString [
	"Where did this frame come from?"
	origin := aString.
]

{ #category : #rendering }
HumFrame >> prettyPrintWithOntology: aHumOntology [
	"Pretty-print using HTML5 and CSS
	--  This is a read-only view for ontology code listing."
	| html calc |
	self delegated.
	calc := HumCalculator new.
	html :=
	calc xml: 'frame'
		with: [
			(calc xml: 'frameTitle' with: [  self titleLine asString ]),
			(self linesAsHTMLwithOntology: aHumOntology)
			].
	^html.
	

]

{ #category : #rendering }
HumFrame >> printOn: aStream [
	"Append to the argument, aStream, a sequence of characters that  
	identifies the receiver."

	| title |
	title := self class name.
	aStream
		"nextPutAll: (title first isVowel ifTrue: ['an '] ifFalse: ['a ']);"
		nextPutAll: title;
		nextPutAll: '( ', self frameName, ' )';
		nextPutAll: String cr.
]

{ #category : #accessing }
HumFrame >> title [
	^ self titleLine 
]

{ #category : #accessing }
HumFrame >> titleLine [
	^titleLine
			
]

{ #category : #accessing }
HumFrame >> titleLine: anObject [
	titleLine := anObject asString trimBoth.

]

{ #category : #accessing }
HumFrame >> uniqueIdentifier [
	"Note: Lazy initialization for this frame`s identifier."
	^ uniqueIdentifier 
	        ifNil: [ uniqueIdentifier := HumIdentifier createUniqueIdentifierForEntityName: (self title) inContext: ('Creating ontology ', self class asString). ].
]

{ #category : #testing }
HumFrame >> zcompileToOntology: aHumOntology [ 
	| problems lineProblems |
	"Regardless of errors add frame to the ontology."	
	aHumOntology storeFrame: self.
	"Looking for trouble!"
	problems := OrderedCollection new.
	self frameLines
		do: [ :frameLine |
			"Action, Plan, and Vignette frames all may have instruction lines."
			( frameLine isKindOf: HumInstructionLine )
				ifTrue: [ lineProblems := frameLine compileLineToOntology: aHumOntology defaultRole: 'DialogAgent'.]
				ifFalse: [lineProblems := frameLine compileLineToOntology: aHumOntology.].
			problems := problems, lineProblems.
			].
	^problems.
]
