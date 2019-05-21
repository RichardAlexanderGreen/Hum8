Extension { #name : #HumCategoryWidget }

{ #category : #'*HumSeaside' }
HumCategoryWidget >> renderContentOn: aWAHtmlCanvas [
	"render self via a simple input tag"
	|  |
aWAHtmlCanvas select
		list: (self categories);
		attributeAt: 'id' put: (self attributeName );
		callback: [:value | self store: value ];
		with: (self attributeValue asString).
]
