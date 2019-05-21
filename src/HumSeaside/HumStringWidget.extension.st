Extension { #name : #HumStringWidget }

{ #category : #'*HumSeaside' }
HumStringWidget >> renderContentOn: aWAHtmlCanvas [
	"render self via a simple input tag"
	| |
	aWAHtmlCanvas textInput 
		attributeAt: 'id' put: (self attributeName );
		callback: [:value | self store: value ];
		with: (self attributeValue asString).
]
