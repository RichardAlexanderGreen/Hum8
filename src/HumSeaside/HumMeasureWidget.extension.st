Extension { #name : #HumMeasureWidget }

{ #category : #'*HumSeaside' }
HumMeasureWidget >> renderContentOn: aWAHtmlCanvas [
	"render self via a simple input tag"
	| |
	aWAHtmlCanvas numberInput 
	  type: 'number';
		attributeAt: 'id' put: (self attributeName );
		callback: [:value | self store: value ];
		with: (self attributeValue asString).
]
