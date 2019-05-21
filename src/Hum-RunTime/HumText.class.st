"
HumText models a text.
Text is multi-line and potentially enhanced with color, emphasis, fonts, and font weights.
( Also known as ""Attributed String"" )

The immediate intent is to support a code editor and rich text without going ""over-board"".

See: HumTextLine, HumTextToken.
See also: HumTextEditor, HumTextWidget.

Comment: This implementation is meant to be independent of the built-in Text class.
	However, that class might be used in to render a HumTextWidget in Smalltalk.

*** TODO: The current implementation is far from complete. ***
*** TODO: Consider subtype or composition using Text class. ***
*** TODO: Perhaps a document model would be more useful. ***
Note: Text updates are primarily implemented via HumEditor.

Instance Variables:
	string	< String >
	lines	< OrderedCollection of HumTextLine >
"
Class {
	#name : #HumText,
	#superclass : #Object,
	#instVars : [
		'string',
		'lines'
	],
	#category : #'Hum-RunTime'
}

{ #category : #accessing }
HumText >> = anotherHumText [
	"Does this text have same content as the other"
	| isSame |
	isSame := (self lines) = (anotherHumText lines).
	^isSame.
]

{ #category : #accessing }
HumText >> addLine: aString [ 
	"Append given line at bottom of text."
	| newLine  tempLines |
	self assert: ( aString isKindOf: String ).
	newLine := HumTextLine new.
	newLine string: aString.
	
	tempLines := self lines.
	((tempLines size = 1) and: [( tempLines at: 1) string isEmpty])
		ifTrue: [tempLines := OrderedCollection new. ].
	tempLines add: newLine.
	self lines: tempLines.
	
	self changed.
]

{ #category : #accessing }
HumText >> copy [
	| newInstance newLines|
	newInstance := self class new.
	newLines := self lines class new.
	self lines do: [:line | newLines add: (line copy) ].
	newInstance lines: newLines.
	^newInstance.
]

{ #category : #accessing }
HumText >> insertEmptyLineAfter: lineIndex [ 
	| currentLines tempLines |
	currentLines := self lines.
	tempLines := currentLines copyFrom: 1 to: lineIndex.
	tempLines add: ( HumTextLine new).
	(lineIndex < currentLines size )
		ifTrue: [ tempLines addAll: ( currentLines copyFrom: ( lineIndex + 1 ) to:  currentLines size ). ].
	"Note: Following will call self changed."	
	self lines: tempLines.


]

{ #category : #accessing }
HumText >> lines [
	"Return the HumText list of HumTextLine instances"
	lines 
		ifNil: [ "initialize the list"
			lines := OrderedCollection new. 
			lines add: ( HumTextLine new ). "NOTE: never empty"
			].
	^lines. 
]

{ #category : #accessing }
HumText >> lines: anOrderedCollection [ 
	( anOrderedCollection isKindOf:  OrderedCollection )
		ifFalse: [ Error signal: 'Bad value sent to HumText>>lines: _']
		ifTrue: [ |firstElement| firstElement := anOrderedCollection at: 1.
			(firstElement isKindOf: HumTextLine) 
			ifFalse: [ Error signal: 'First line should be a HumTextLine'] 
			].
	lines := anOrderedCollection.
	self changed.
]

{ #category : #accessing }
HumText >> printOn: aStream [
	"Append to the argument, aStream, a sequence of characters that  
	identifies the receiver."

	| title s |
	title := self class name.
	s := title, ':'.
	lines do: [ :line | s := s, line string, '/'.].
	aStream
		nextPutAll: (title first isVowel ifTrue: ['an '] ifFalse: ['a ']);
		nextPutAll: s
]

{ #category : #accessing }
HumText >> string [
	"Return self as a string. (Lines with CR inserted as needed.)"
	| result |
	result := String new.
	( self lines )
		do: [ :line |
			result := result, line string, String cr.
			].
	^result.
]
