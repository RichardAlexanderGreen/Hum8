Extension { #name : #HumFormWidget }

{ #category : #'*HumSeaside' }
HumFormWidget >> renderContentOn: aWAHtmlCanvas [
	| tag |
	tag := aWAHtmlCanvas tag: 'view'.
	tag	attributeAt: 'id' put: (self view id).
	tag with: [ "A view becomes an HTML form."
		aWAHtmlCanvas form 
			attributeAt: 'id' put: (self view id); 
			with: [ self view renderMarkupLinesViaSeasideOn: aWAHtmlCanvas ].
		].
	
]

{ #category : #'*HumSeaside' }
HumFormWidget >> renderOn: aWAHtmlCanvas [
	| tag |
	tag := aWAHtmlCanvas tag: 'view'.
	tag	attributeAt: 'id' put: (self view id).
	tag with: [ "A view becomes an HTML form."
		aWAHtmlCanvas form 
			attributeAt: 'id' put: (self view id); 
			with: [ self view renderMarkupLinesViaSeasideOn: aWAHtmlCanvas ].
		].
	
]
