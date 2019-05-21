Extension { #name : #HumWidget }

{ #category : #'*HumSeaside' }
HumWidget >> renderContentOn: aWAHtmlCanvas [
	"Default: Render self via a simple input tag"
	| |
	aWAHtmlCanvas textInput 
		attributeAt: 'id' put: (self attributeName );
		callback: [:value | self store: value ];
		with: (self attributeValue asString).
]
