"
Intended as a very simple, easy-to-understand, text editor.
This editor is simpler than HumEditor. 
But, it does not (2015-12-10) support select operations, undo, redo.
See: >>keyStroke: aCharacter for a summary of UI features.

See Also: HumEditor HumText HumTextLine HumTextToken

Navigation Features:
. Responds to up/down/left/right by moving cursor.
. Beep if user attempts to move cursor beyond left margin or top row.

Editing Features:
. Respond to normal character by inserting character to left of cursor. 
. Respond to return by splitting the current line.
. Respond to delete key by deleting character, if any, to left of cursor.
. If cursor is at beginning of line, 
. . delete key will merge current line with prior line,
. . and move remaining rows up.
. Cursor is repositioned appropriately.

Integration Features:
. #keyStroke: responds to Character codes (ASCII-7 conventions).
. Set ""hasNewContent"" flag when content has changed.
. TODO: Add Announcement features.
. TODO: Add MVC integration features.


"
Class {
	#name : #HumTextEditor,
	#superclass : #Object,
	#instVars : [
		'row',
		'column',
		'lines',
		'hasNewContent'
	],
	#category : #'Hum-IDE'
}

{ #category : #navigating }
HumTextEditor >> beep [
	"Signal that cursor is out-of-bounds."
	Beeper beep.
]

{ #category : #navigating }
HumTextEditor >> bumpColumn: anInteger [ 
	self column: (self column) + anInteger.
]

{ #category : #navigating }
HumTextEditor >> bumpRow: anInteger [ 
	self row: (self row) + anInteger.
]

{ #category : #accessing }
HumTextEditor >> column [
	"What is the current column position of the cursor?"
	^column ifNil: [ column := 1 ].
]

{ #category : #accessing }
HumTextEditor >> column: anInteger [ 
	"Move cursor to given column position."
	column := anInteger.
	(column < 1) ifTrue: [ column := 1.  self beep. ].
]

{ #category : #accessing }
HumTextEditor >> currentLine [
	^self lineAt: (self row).
]

{ #category : #accessing }
HumTextEditor >> currentLine: aString [ 
	self lines at: (self row) put: aString.
	self hasNewContent: true.
]

{ #category : #accessing }
HumTextEditor >> cursorPosition [
	"Where is the insert point?"
	^ (self row)@(self column).
]

{ #category : #editing }
HumTextEditor >> deleteOrMerge [
	"Delete character to left of cursor.
	If cursor is at beginning of line, 
	append current line to prior line and move everything up."
	|  currentLine calc |
	currentLine := self currentLine.
	calc := HumCalculator new.
	calc cases;
		when: [ self cursorPosition = (1@1) ]
			then: [ self beep ];
		when: [ (column > 1) and: [ column > currentLine size ] ]
			then: [ self bumpColumn: -1 ];	
		 when: [ column > 1 ]
			then: [ |  stringBefore stringAfter  |
				stringBefore := currentLine copyFrom: 1 to: ( column - 2 ).
				stringAfter := currentLine copyFrom: column to: currentLine size.
				self currentLine: (stringBefore, stringAfter).
				];
		when: [ column = 1 ] 
			then: [ | stringBefore stringAfter linesAfter | 
				stringBefore := self lineAt: (row-1).
				stringAfter := currentLine.
				self currentLine: ''.
				self bumpRow: -1.
				self currentLine: (stringBefore,stringAfter).
				self column: stringBefore size + 1.
				"Move remaining lines up"
				linesAfter := Dictionary new.
				(self lines)
					keysAndValuesDo: [ :key :value |
						(key > (row+1))
							ifTrue: [ linesAfter at: (key - 1) put: value ]
							ifFalse: [ linesAfter at: key put: value ].
			 			].
				lines := linesAfter.
				];
		otherwise: [ Error signal: 'How did we get here?' ].
	
]

{ #category : #drawing }
HumTextEditor >> drawTextOnCanvas: aHumCanvas font: aFont [ 
	
	aHumCanvas drawTextLines: (self lines) withFont: aFont
	
]

{ #category : #drawing }
HumTextEditor >> drawTextOnPane: aHumPane font: aFont [ 
	self assert: ( aHumPane isKindOf: HumPane).
	self assert: ( aFont isKindOf: AbstractFont).  "I would prefer a vector-based font."
	aHumPane textChanged: self.
	
]

{ #category : #editing }
HumTextEditor >> hasNewContent [
	"Has the content been changed? -- (Dirty data flag)"
	^hasNewContent ifNil: [ hasNewContent := false ].
]

{ #category : #editing }
HumTextEditor >> hasNewContent: aBoolean [ 
	"Set true whenever the content has been changed."
	self assert: (aBoolean isKindOf: Boolean).
	hasNewContent := aBoolean
	"TODO: Notify watchers if the boolean is true."
]

{ #category : #editing }
HumTextEditor >> insertCharacter: aCharacter [ 
	| currentLine stringBefore stringAfter |
	currentLine := self lineAt: (self row).
	(self column > currentLine size)
		ifTrue: [ currentLine := currentLine padRightTo: (self column - 1) ].

	stringBefore := currentLine copyFrom: 1 to: (self column - 1).
	stringAfter := currentLine copyFrom: (self column) to: (currentLine size).
	self currentLine: (stringBefore, aCharacter asString, stringAfter).
	self bumpColumn: 1.
	self hasNewContent: true.
]

{ #category : #navigating }
HumTextEditor >> keyStroke: aCharacter [
	"Respond to simple keyboard input. (KISS: a character)
	NOTE simplification: Input is a character, not an event."
	| calc |
	self assert: (aCharacter isKindOf: Character).
	calc := HumCalculator new.
	calc 
		switch: aCharacter;
		on: Character arrowUp do: [ self bumpRow: -1 ];		
		on: Character arrowDown do: [ self bumpRow:  1 ];
		on: Character arrowLeft do: [ self bumpColumn: -1 ];
		on: Character arrowRight do: [ self bumpColumn: 1 ];
		on: Character cr do: [ self splitRow ];
		on: Character delete do: [ self deleteOrMerge ];
		otherwise: [ self insertCharacter: aCharacter ].
	"NOTE: Character does not support control, command, or shift modes."
		
]

{ #category : #accessing }
HumTextEditor >> lineAt: anInteger [ 
	"Get string for given row"
	| aLine |
	aLine := (self lines) at: anInteger ifAbsent: [ '' ].
	^aLine.
]

{ #category : #accessing }
HumTextEditor >> lines [
	"PRIVATE: My text lines. 
	Use '... lineAt: row' or 'currentLine' to access lines as strings."
	^lines ifNil: [ lines := Dictionary new ].
	
]

{ #category : #accessing }
HumTextEditor >> row [
	"What is the current row position of the cursor?"
	^row ifNil: [ row := 1 ].
]

{ #category : #accessing }
HumTextEditor >> row: anInteger [ 
	"Move cursor to given row position."
	row := anInteger.
	(row < 1) ifTrue: [ row := 1. self beep. ].
	"Note: You can move row beyond current lines."
]

{ #category : #editing }
HumTextEditor >> splitRow [
	| currentLine linesAfter stringBefore stringAfter |
	linesAfter := Dictionary new.
	"Everything after the current row is moved down one."
	(self lines)
		keysAndValuesDo: [ :key :value |
			(key > (self row))
				ifTrue: [ linesAfter at: (key + 1) put: value ]
				ifFalse: [ linesAfter at: key put: value ].
			 ].
	"Split the current line."
	currentLine := self lineAt: (self row).
	(self column > currentLine size)
		ifTrue: [ currentLine := currentLine padRightTo: (self column - 1) ].
	stringBefore := currentLine copyFrom: 1 to: (self column - 1).
	stringAfter := currentLine copyFrom: (self column) to: (currentLine size).
	self currentLine: stringBefore.
	self bumpRow: 1.
	self currentLine: stringAfter.
	self column: 1.
	self hasNewContent: true.


]
