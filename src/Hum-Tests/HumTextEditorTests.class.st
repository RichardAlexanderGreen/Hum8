Class {
	#name : #HumTextEditorTests,
	#superclass : #HumTestCase,
	#category : #'Hum-Tests'
}

{ #category : #'keystroke tests' }
HumTextEditorTests >> test110ArrowKeys [
	| editor |
	editor := HumTextEditor new.
	
	editor keyStroke: Character arrowDown.
	self expect: 2@1 actual: editor cursorPosition.	
	
	editor keyStroke: Character arrowUp.
	self expect: 1@1 actual: editor cursorPosition.
	
	editor keyStroke: Character arrowUp.
	self expect: 1@1 actual: editor cursorPosition description: 'Row does not go below one.'.

	editor keyStroke: Character arrowRight.
	self expect: 1@2 actual: editor cursorPosition.
	
	editor keyStroke: Character arrowLeft.
	self expect: 1@1 actual: editor cursorPosition.
	
	editor keyStroke: Character arrowLeft.
	self expect: 1@1 actual: editor cursorPosition description: 'Column does not go below one.'.
	
	self assert: ( editor hasNewContent ) = false description: 'Moving cursor does not change content.'.

]

{ #category : #'keystroke tests' }
HumTextEditorTests >> test120NormalKeys [
	| editor |
	editor := HumTextEditor new.
	
	editor keyStroke: Character arrowDown.
	self expect: 2@1 actual: editor cursorPosition.	

	editor keyStroke: $k.
	self expect: 'k' actual: (editor lineAt: 2).
	self expect: 2@2 actual: editor cursorPosition.
	self expect: '' actual: (editor lineAt: 1).	
	self assert: editor hasNewContent description: 'New content inserted'.
	 
	editor keyStroke:  Character arrowLeft.
	self expect: 2@1 actual: editor cursorPosition.

	editor keyStroke: $O.
	self expect: 'Ok' actual: (editor lineAt: 2).
	self expect: 2@2 actual: editor cursorPosition.
	
	editor keyStroke: Character arrowRight.
	self expect: 2@3 actual: editor cursorPosition.	
		
	editor keyStroke: Character arrowRight.
	self expect: 2@4 actual: editor cursorPosition description: 'Cursor is not limited by currentLine string length'.
	
	editor keyStroke: $!.
	self expect: 'Ok !' actual: (editor lineAt: 2) description: 'Current line may be padded to cursor location on an insert'.
	self expect: 2@5 actual: editor cursorPosition.
	
]

{ #category : #'keystroke tests' }
HumTextEditorTests >> test130BreakLine [
	| editor |
	editor := HumTextEditor new.
	
	editor currentLine: 'Now is the time for all good men'.
	editor column: ('Now is the time' size + 1).
	editor keyStroke: Character cr.
	self expect: 'Now is the time' actual: (editor lineAt: 1).
	self expect: ' for all good men' actual: (editor lineAt: 2).
	self expect: 2@1 actual: editor cursorPosition.
	self assert: editor hasNewContent description: 'Content changed'.

	
]

{ #category : #'keystroke tests' }
HumTextEditorTests >> test140DeleteKey [
	"If cursor column > 1, delete character to the left of cursor and decrement column position."
	| editor |
	editor := HumTextEditor new.
	"Set up"
	editor currentLine: 'abc'.
	editor bumpRow: 1.
	editor currentLine: 'xyz'.
	editor column: 2.
	self expect: 2@2 actual: editor cursorPosition.
	
	"Delete one character"
	editor keyStroke: Character delete.
	self expect: 'yz' actual: (editor lineAt: 2).
	
	
]

{ #category : #'keystroke tests' }
HumTextEditorTests >> test150DeleteLine [
	"If cursor column = 1, append current line to prior line and move remaining lines up."
	| editor |
	editor := HumTextEditor new.
	"Set up three lines"
	editor currentLine: 'abc'.
	editor bumpRow: 1.
	editor currentLine: 'xyz'.
	editor bumpRow: 1.
	editor currentLine: '123'.
	"Move cursor to start of second line."
	editor row: 2; column: 1.
	self expect: 2@1 actual: editor cursorPosition.
	
	"Delete one character"
	editor keyStroke: Character delete.
	self expect: 'abcxyz' actual: (editor lineAt: 1) description: 'Expect line 2 appended to line 1.'.
	self expect: '123' actual: (editor lineAt: 2) description: 'Expect line 3 moved up to line 2.'.
	self expect: 1@4 actual: editor cursorPosition.
	self assert: (editor hasNewContent) description: 'Should signal new content.'
	
	
]

{ #category : #'drawing text' }
HumTextEditorTests >> test208CharacterizeStringDraw [
	"Tinker until we learn what we need to know about canvas, form, font integration."
	|  form canvas font  em lineHeight | 
	form := Form extent: (700@70) depth: 32.
	canvas := BalloonCanvas on: form. 
	font := TextStyle defaultFont.
	em := font linearWidthOf: $m.
	lineHeight := font height.
	canvas 
		drawString: 'The quick brown fox jumps over the lazy dog.' 
		at: em@lineHeight font: font color: (Color black).
	canvas 
		drawString: 'Now is the time for all good men to come to the aid of their country.' 
		at: em@(lineHeight * 2) font: font color: (Color blue).

	"Option to display the form"
	"This canvas has no background, so it will be tranparent when displayed."
	false ifTrue: [form displayOn: Display at: (100@100).].
		
	
]

{ #category : #'drawing text' }
HumTextEditorTests >> test209CharacterizeStringDraw [
	"Tinker until we learn what we need to know about canvas, form, font integration."
	|  form canvas font  em lineHeight | 
	form := Form extent: (700@100) depth: 32.
	canvas := BalloonCanvas on: form. 
	font := TextStyle defaultFont.
	em := font linearWidthOf: $m.
	lineHeight := font height.
	"Paint background and border."
	canvas 
		frameAndFillRectangle: form 
		boundingBox fillColor: Color white 
		borderWidth: 2 
		borderColor: Color blue.
	canvas 
		drawString: 'The quick brown fox jumps over the lazy dog.' 
		at: em@lineHeight font: font color: (Color black).
	canvas 
		drawString: 'Now is the time for all good men to come to the aid of their country.' 
		at: em@(lineHeight * 2) font: font color: (Color blue).

	"Option to display the form"
	false ifTrue: [form displayOn: Display at: (100@100).].
		
	
]

{ #category : #'drawing text' }
HumTextEditorTests >> test226DrawSeveralTextLinesOnPane [
	"TextEditor draws its lines on a HumPane -- ???"
	|    font em lineHeight editor pane |
	"TODO: To be internally consistent, 
	TextEditor should display in a HumPane.
	Low level objects such as Form should be hidden.
	"
	font := TextStyle defaultFont.
	em := font linearWidthOf: $m.
	lineHeight := font height.

	editor := HumTextEditor new.
	editor 
		currentLine: 'Now is the time';
		bumpRow: 1;
		currentLine: ' for all good men';
		bumpRow: 1;
		currentLine: ' to come to the aid';
		bumpRow: 1;
		currentLine: ' of their party.';
		bumpRow: 1.

	pane := HumPane new.
	editor drawTextOnPane: pane font: font.
	
	"Option to display the pane"
	false ifTrue: [|morph| morph := pane asMorph. morph openInWorld.].
	
	
	
]
