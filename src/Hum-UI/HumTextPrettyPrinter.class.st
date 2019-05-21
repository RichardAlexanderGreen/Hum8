"
HumTextPrettyPrinter is designed to pretty print a text based upon parameters provided.
Parameters include:
- string that begins a multi-line comment -- example: '/*' in several notations derived from the C langauge.
- string that ends a multi-line comment. -- example: '*/' in several notations.
- string that begins a whole-line comment -- example: '#' in several notations.
- string that begins a remainder-of-line comment -- example '//' in several notations.

- string that begins a compiler directive -- example '@' in Java and other languages.
- string of special characters that may be included in names -- example '_' in many languages, '_-' in COBOL.

- tokens that represent ""keywords"" -- exampe 'if', 'else', 'begin', 'end', 'for', 'def', 'class', 'public', 'private'.

- balanced pairs -- For example: '(...)', '[...]', '{...}'

- string delimiters -- For example: ""..."" and '...' 

- string for indentation -- For example: tab or '. '

- treatment for keywords -- example: bold, foreground blue
- treatment for whole-line comment -- example: italic, background dark green, foreground yellow.
- treatment for remainder-of-line comments -- example: italic, foreground green
- treatment for multi-line comments -- example: italic, foreground green
- treatment for strings -- example: normal, forground cyan
- treatment for special characters -- example: bold, forground red
- treatment for whole-line comment -- example: italic, background dark green, foreground yellow.
"
Class {
	#name : #HumTextPrettyPrinter,
	#superclass : #Object,
	#instVars : [
		'startCommentToEndOfLine'
	],
	#category : #'Hum-UI'
}

{ #category : #accessing }
HumTextPrettyPrinter >> addCommentToEndOfLineStartsWith: aString [ 
	| |
	self assert: (aString isKindOf:  String).
	startCommentToEndOfLine := aString.
]

{ #category : #evaluating }
HumTextPrettyPrinter >> parse: aHumTextLine [ 
	|  tokens ppTokens |
	"delimiters := (' ', startCommentToEndOfLine )."
	tokens := ( aHumTextLine string ) substrings. 
	ppTokens := OrderedCollection new.
	tokens do: [ :token | 
		| ppToken |
		ppToken := HumTextPrettyToken new.
		ppToken string: token.
		ppTokens add: ppToken.
		].
	^ ppTokens.
	
]
