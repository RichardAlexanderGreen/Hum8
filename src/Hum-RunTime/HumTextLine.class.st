"
A text is assumed have a collection of text-lines.
Each text line is assumed to be a collection of tokens.
Each token may have attributes that affect how it is rendered.
For example, rendering attributes may include emphasis, color, highlight, link, editable.  (ToDo)
Emphasis in turn might include isBold, isItalic, isUnderlined, relative height. (ToDo)

See also: HumText, HumTextToken, HumEditor, HumTextWidget.

Note -- Lines might be re-flowed during the rendering if the context permits / requires it.
But the source lines in the text remain the same regardless of the rendering.
We don't want to surprise the author by changing the source.

(TODO: There is some conceptual conflict here that I have to resolve.)

Instance Variables:
	string	<String>
	indentLevel	<Integer>
"
Class {
	#name : #HumTextLine,
	#superclass : #Object,
	#instVars : [
		'string',
		'indentLevel'
	],
	#category : #'Hum-RunTime'
}

{ #category : #comparing }
HumTextLine >> = otherTextLine [
	"Do the two text lines contain the same string?"	
	| result |
	result := (self string) = (otherTextLine  string).
	^result.
]

{ #category : #accessing }
HumTextLine >> copy [
	| newInstance |
	newInstance := self class new.
	newInstance
		indentLevel: (self indentLevel copy);
		string: (self string copy).
	^newInstance.
]

{ #category : #accessing }
HumTextLine >> indentLevel [
	"The indent level indicates the level of indentation,
	  but not the rendering of the indentation."
	^ indentLevel ifNil: [ indentLevel := 0 ].
]

{ #category : #accessing }
HumTextLine >> indentLevel: aSmallInteger [
	indentLevel := aSmallInteger.
]

{ #category : #accessing }
HumTextLine >> size [
	^ self string size
]

{ #category : #accessing }
HumTextLine >> string [
	string ifNil: [ string := String new. ].
	^string.
]

{ #category : #accessing }
HumTextLine >> string: aByteString [ 
	string := aByteString
]
