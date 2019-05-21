"
HumTextPrettyToken is a string that may be enhanced with color, emphasis, fonts, and font weights
when it is ""pretty printed"".
See also: HumTextPrettyPrinter.

	foregroundColor 
	backgroundColor 
	isBold 
	isItalic 
	isUnderlined 
	fontFamily 
	fontSize

"
Class {
	#name : #HumTextPrettyToken,
	#superclass : #Object,
	#instVars : [
		'foregroundColor',
		'backgroundColor',
		'isBold',
		'isItalic',
		'isUnderlined',
		'fontFamily',
		'fontSize',
		'string'
	],
	#category : #'Hum-UI'
}

{ #category : #accessing }
HumTextPrettyToken >> string [
	
	^ string ifNil: [ string := String new. ].
]

{ #category : #accessing }
HumTextPrettyToken >> string: aString [ 
	self assert: ( aString isKindOf: String ).
	string := aString.
]
