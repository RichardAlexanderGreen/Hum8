Extension { #name : #String }

{ #category : #'*HumSugar' }
String >> includesSubString: aString [ 
	"Enable alternate capitalization"
	^self includesSubstring: aString.
]

{ #category : #'*HumSugar' }
String >> quoted [
	| quote |
	quote := $' asString.
	^quote, self, quote.
]
