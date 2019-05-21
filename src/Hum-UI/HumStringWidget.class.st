"
Widget enables user to view/enter a one-line string value.

Note: Most attributes have string values.

"
Class {
	#name : #HumStringWidget,
	#superclass : #HumWidget,
	#category : #'Hum-UI'
}

{ #category : #'Render As' }
HumStringWidget >> asHTML [
	"Generate HTML input element"
	| html calc |
	calc := HumCalculator new.
	html := calc xml: 'input' dictionary: ((Dictionary new) at: 'name' put: (self attributeName); yourself)
					with: [ self attributeValue ].
	^html.
	
]

{ #category : #'as yet unclassified' }
HumStringWidget >> asMorph [
	|  morph |
	morph := attributeValue asTextMorph. 
	morph 
		color: Color black;                        "<< Foreground text color"
		backgroundColor: Color white;
		borderWidth: 2;
		margins: 5.
	^morph.
]
