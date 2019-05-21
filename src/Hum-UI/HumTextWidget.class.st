"
Widget enables a user to view/enter/edit a multi-line text value for an attribute.

Expect ""Text"" datatype to be used for attributes that are 
short descriptions, diary entries, brief instructions.
Typical values may contain ""end-of-line"" characters
and slots display at least two lines.
Note: The  ""tab"" and ""return"" keystrokes 
may mean ""indent"" and ""newline"" in this view-context.

See also: HumText HumTextEditor

"
Class {
	#name : #HumTextWidget,
	#superclass : #HumWidget,
	#instVars : [
		'rows'
	],
	#category : #'Hum-UI'
}

{ #category : #'as yet unclassified' }
HumTextWidget >> asHTML [
	"Generate HTML textarea element"
	| html calc |
	calc := HumCalculator new.
	html := calc xml: 'textarea' with: [ self attributeValue ].
	^html.

]

{ #category : #'as yet unclassified' }
HumTextWidget >> asMorph [
	| morph |
	"Instantiate a TextMorph of some kind."
	morph := self attributeValue asTextMorph.
	"Set some visual properties."
	morph 
		backgroundColor: Color white;
		margins: 5;
		borderWidth: 2.
	"TODO: Wire up the UI interaction: 
	  KeyStroke >> Morph(TextMorphForEditView ) >> HumTextWidget >> HumTextEditor >> HumText"
	^morph.
]

{ #category : #accessing }
HumTextWidget >> rows [
	"How many rows should we display?" 
	^ rows
]

{ #category : #accessing }
HumTextWidget >> rows: aSmallInteger [
	"How many rows should we display?" 
	rows := aSmallInteger. 
]
