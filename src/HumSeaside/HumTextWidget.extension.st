Extension { #name : #HumTextWidget }

{ #category : #'*HumSeaside' }
HumTextWidget >> renderContentOn: aWAHtmlCanvas [
	"render self via a text area tag"
	| |
	aWAHtmlCanvas textArea 
		attributeAt: 'id' put: (self attributeName );
		rows: (self rows);
		callback: [:value | self store: value ];
		with: (self attributeValue asString).
]
