"
A HumEditor is attached to HumText.
The editor provides the means to modify the text. 
(text is model, editor is controller - but not a viewer)
(See also HumWidget, HumCanvas, )
The editor has a cursorPosition 
 which defines where a cursor might be rendered 
 and where character inserts and deletes may occur.
The editor has a 'selection' which defines a part of the text that might be highlighted and processed.
---
Editor Actions
   1. Usual text edit actions:
      a) cursor moves: (up, down, left, right, top, bottom, . . .)
      b) selection moves: (shift-up, shift-down, shift-right, shift-left)
      c) commands: (copy, cut, paste)
      d) undo? 
   2. PA-specific actions:
      a) [Line updated] event causes the logical-line and frame to be checked.
         (1) The logical-line is rendered. 
	           Keywords and nouns are emphasized. Nouns have links. 
         (2) If the logical-line is not understood (no definition in ontology or DSL), 
               the line is flagged (with a question-mark).
         (3) If a noun lacks an antecedent in the frame, the noun is flagged (color code).
      b) [Insert/Append Instruction] - Instructions are indented.
         (1) In an action frame, 
               the automatic indent matches the preceding statement’s indent 
               unless it was a control statement (ending with a colon). 
                  And then, the indentation is increased by one.
         (2) In plan and dialog frames, 
               instructions have only one level of indent 
               because control statements are not allowed in those contexts.
         (3) In dialog frames, 
               the user indicates an instruction by starting the line with dot [tab].
---

"
Class {
	#name : #HumEditor,
	#superclass : #Object,
	#instVars : [
		'lineIndex',
		'characterIndex',
		'text',
		'keyboardActions',
		'selectionStart',
		'selectionEnd',
		'selectionAnchor',
		'undoStack',
		'redoStack'
	],
	#category : #'Hum-UI'
}

{ #category : #accessing }
HumEditor >> addLine: aString [ 
	"Delegate to HumText instance."
	(self text) addLine: aString
]

{ #category : #'user interface' }
HumEditor >> beep [
	"If sound is enabled, beep."			
	Beeper beep.
]

{ #category : #accessing }
HumEditor >> characterIndex [
	"Character index is equal to the number of charactes to the left of the cursor."
	^ characterIndex ifNil: [ characterIndex := 0 ].
]

{ #category : #accessing }
HumEditor >> characterIndex: aSmallInteger [ 
	"character index ranges from 0 (left of line) to ()"
	| n |
	characterIndex := aSmallInteger.
	
	(characterIndex < 0 ) 
		ifTrue: [ characterIndex := 0.
			self beep.
			].	
	n := ( text lines at: lineIndex	) size.	
	(characterIndex > n ) 
		ifTrue: [ characterIndex := n.
			self beep.
			]. 
]

{ #category : #accessing }
HumEditor >> currentLine [
	| result |
	result := ( self lines ) at: ( self lineIndex ).
	^result.
]

{ #category : #accessing }
HumEditor >> deletePriorCharacter [
	"Insert a character into the text at the current (cursor) position"
	| humTextLine currentLine stringUpto stringAfter newLine currentIndex  |
	"If cursor is at the front of the line, delete is a no op."
	currentIndex := (self characterIndex).
	( currentIndex = 0 ) ifTrue: [ Beeper beep. ^self ].
	"Otherwise . . ."
	humTextLine := (self lines) at: (self lineIndex).
	currentLine := humTextLine string.
	( currentIndex >= currentLine size )
				ifTrue: [ 	"Delete the last character in the line."
						stringUpto := currentLine copyFrom: 1 to: (currentLine size - 1).
			       stringAfter := ''. 
					]
				ifFalse: [	 "Delete the character left of the cursor."
						 stringUpto := currentLine copyFrom: 1 to: (currentIndex - 1).
					   stringAfter := currentLine copyFrom: (currentIndex+1) to: (currentLine size).
					].
	
	newLine := stringUpto,  stringAfter.
	humTextLine string: newLine.
	text changed.
	"(self lines) at: (self lineIndex) put: humTextLine."
	"Back the cursor."
	self characterIndex: currentIndex - 1.
	
]

{ #category : #accessing }
HumEditor >> emptySelection [
	"The selection is empty.
	start and end are at current cursor"
	selectionAnchor := lineIndex @ characterIndex.
	selectionStart := selectionAnchor.
	selectionEnd   := selectionAnchor.
]

{ #category : #accessing }
HumEditor >> initialize [
	"Set up undo stack and notification."
	self undoStack.
]

{ #category : #accessing }
HumEditor >> insertCharacter: aCharacter [ 
	"Insert a character into the text at the current (cursor) position"
	| humTextLine currentLine currentIndex stringUpto stringAfter newLine |
	humTextLine := (self lines) at: (self lineIndex).
	currentLine := humTextLine string.
	currentIndex := self characterIndex.
	( currentIndex >= currentLine size )
		ifFalse: [	stringUpto := currentLine copyFrom: 1 to: currentIndex.
					stringAfter := currentLine copyFrom: ( currentIndex +1 ) to: (currentLine size).
					]
		ifTrue: [ 	stringUpto := currentLine copy.
			       	stringAfter := ''. 
					].
	
	newLine := stringUpto, (aCharacter asString), stringAfter.
	humTextLine string: newLine.
	"notify model"
	text changed.
	"(self lines) at: (self lineIndex) put: humTextLine."
	"Advance the cursor."
	self characterIndex: (self characterIndex + 1).
	
]

{ #category : #accessing }
HumEditor >> insertLine [
	"Delegate to our HumText instance"
	self text insertEmptyLineAfter: (self lineIndex).
	"Adjust the cursor to point to the beginning of the new line."
	lineIndex := lineIndex + 1.
	characterIndex := 0.
	
	
	
]

{ #category : #'user interface' }
HumEditor >> interpretKey: aSymbol [ 
	"Interpret various keyboard gestures."
	| action |
	keyboardActions ifNil: ["initialize"
		keyboardActions := Dictionary  new.
		keyboardActions
			"Simple arrow keys"
			at: #arrowUp      put: [ self lineIndex: ( (self lineIndex) - 1 ).  self emptySelection. ];
			at: #arrowDown put: [ self lineIndex: ( (self lineIndex) + 1 ).  self emptySelection. ];
			at: #arrowLeft   put: [ self characterIndex: ( (self characterIndex ) - 1).  self emptySelection. ];
			at: #arrowRight put: [ self characterIndex: ( (self characterIndex ) + 1).  self emptySelection. ];
			
			"Alt-Arrow keys"
			at: #altArrowUp      put: [ self lineIndex: 1. self emptySelection.];
			at: #altArrowDown put: [ self lineIndex: ( self lines size ). 
				                                  self characterIndex:  (self currentLine string size). self emptySelection. ];
			at: #altArrowLeft   put: [ self characterIndex: 0. self emptySelection. ];
			at: #altArrowRight  put: [ self characterIndex: (self currentLine string size). self emptySelection. ];
			
			"Shift-Arrow keys move cursor same as simple arrow keys, but selection is updated."
			at: #shiftArrowUp      put: [ self lineIndex: ( (self lineIndex) - 1). self updateSelection. ];
			at: #shiftArrowDown put: [ self lineIndex: ( (self lineIndex) + 1 ). self updateSelection. ];
			at: #shiftArrowLeft    put: [ self characterIndex: ( (self characterIndex ) - 1). self updateSelection. ];
			at: #shiftArrowRight  put: [ self characterIndex: ( (self characterIndex ) + 1). self updateSelection. ];
			
			"Escape key is a no-op at this time."
			at: #escape put: [ Beeper beep ].
		 ].
	"Interpret the symbol (keyboard action name) given"
	action := keyboardActions at: aSymbol 
						ifAbsent: [ Error signal: 'No action for: ', (aSymbol asString)].
	action value.
	

]

{ #category : #accessing }
HumEditor >> lineIndex [
	^ lineIndex ifNil: [ lineIndex := 1 ].
]

{ #category : #accessing }
HumEditor >> lineIndex: aSmallInteger [ 
	| maxLine |
	lineIndex := aSmallInteger.
	maxLine := ((self text ) lines size).
	( lineIndex >  maxLine ) ifTrue: [ lineIndex := maxLine].
	( lineIndex < 1 ) ifTrue: [ lineIndex := 1 ].
]

{ #category : #accessing }
HumEditor >> lines [
	^ self text lines.
]

{ #category : #'user interface' }
HumEditor >> redo [
	"Replace text with text that was replaced at last undo."
	| stack replacedText |
	stack := self redoStack.
	stack ifEmpty: [ self beep. ^self ].
	replacedText := stack removeLast.
	text := replacedText.
]

{ #category : #'user interface' }
HumEditor >> redoStack [
	^ redoStack ifNil: [ redoStack := OrderedCollection new ].
]

{ #category : #accessing }
HumEditor >> selectedText [
	"Return selected text as a string with CR inserted as needed at ends of lines."
	| result calc startRow startColumn endRow endColumn line|
	calc := HumCalculator new.
	result := String new.
	startRow  := selectionStart x.
	endRow    := selectionEnd x.
	
	(startRow to: endRow) 
	 do: [ :row | 
		line := (text lines at: row ) string.
		calc cases;
			when: [row = startRow and: [row < endRow]] 
				then: [startColumn := selectionStart y. endColumn := line size. ];
			when: [row = startRow and: [row = endRow]] 
				then: [startColumn := selectionStart y. endColumn := selectionEnd y. ];
			when: [row = endRow and: [row > startRow]]   
				then: [startColumn := 0. endColumn := selectionEnd y. ];
			otherwise: [Error signal: 'eh?'].
		(endColumn > line size) ifTrue: [endColumn := line size].		
		(startColumn+1 to: endColumn)
			do: [:column |
				result := result, ((line at: column) asString).
				].
		 (endRow > startRow and: [(row < endRow) and: [endColumn = line size]]  ) 
				ifTrue:	[result := result, String cr]
		].
	
	^result.
]

{ #category : #accessing }
HumEditor >> selectionAnchor [
	"Return selection anchor."
	^ selectionAnchor ifNil: [selectionAnchor := lineIndex @ characterIndex ].
]

{ #category : #accessing }
HumEditor >> text [
	^ text ifNil: [ text := HumText new ].
]

{ #category : #'user interface' }
HumEditor >> undo [
	"Replace text with last item from undo stack."
	| stack priorText replacedText lastText |
	stack := self undoStack.
	stack ifEmpty: [ Error signal: 'Undo stack should never be empty'. self beep. ^self].
	(stack size = 1) ifTrue: [self beep. ^self].
	
	"last contains current text"
	lastText := stack last.
	self assert: ( lastText = text ).
	replacedText := stack removeLast. 
	self redoStack add: replacedText.
	stack ifEmpty: [Error signal: 'programming error?'].
	"Now top contains priorText"
	priorText := stack last.
	text := priorText.
	"TODO: Keep track of where the cursor was."
]

{ #category : #'user interface' }
HumEditor >> undoStack [
	undoStack 
		ifNil: [ "Setup notification. See #update:"
			      self text addDependent: self.
						"Initialize stack"
			      undoStack := OrderedCollection new.
			      undoStack add: text copy. ].
	^undoStack.
	
]

{ #category : #accessing }
HumEditor >> update: aText [
	"When text is updated, we are informed. Put on undo stack."
	self undoStack add: aText copy.
	"TODO: Also track the cursor. 
	self undoStack add: { aText copy. lineIndex. characterIndex. }
	"
]

{ #category : #accessing }
HumEditor >> updateSelection [
	"Selection extends from an anchor-point to current cursor position.
	Constraint: Start < End.
	"
	| currentRowColumn anchorRow currentRow anchorColumn currentColumn calc |
	currentRow := self lineIndex.
	currentColumn := self characterIndex.
	currentRowColumn := currentRow @ currentColumn.
	anchorRow := selectionAnchor x.
	anchorColumn := selectionAnchor y.
	
	calc := HumCalculator new.
	calc cases;
		when: [currentRow > anchorRow] then: [selectionStart := selectionAnchor. selectionEnd   := currentRowColumn];
		when: [currentRow < anchorRow] then: [selectionEnd   := selectionAnchor. selectionStart := currentRowColumn];
		when: [currentColumn > anchorColumn] then: [selectionStart := selectionAnchor. selectionEnd   := currentRowColumn];
		when: [currentColumn <= anchorColumn]then: [selectionEnd  := selectionAnchor. selectionStart := currentRowColumn];
		otherwise: [Error signal: 'programming error'].
	
		
	
	
]
