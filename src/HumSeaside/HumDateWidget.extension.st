Extension { #name : #HumDateWidget }

{ #category : #'*HumSeaside' }
HumDateWidget >> renderContentOn: aWAHtmlCanvas [
	"render self via a simple input tag"
	| |
	aWAHtmlCanvas textInput
	  type: 'date'; 
		attributeAt: 'id' put: (self attributeName );
		callback: [:value | self store: value ];
		with: (self attributeValue asString).
]
