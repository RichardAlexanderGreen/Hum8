"
Layout children in a row.
"
Class {
	#name : #HumRowLayoutWidget,
	#superclass : #HumLayoutWidget,
	#category : #'Hum-UI'
}

{ #category : #'Render As' }
HumRowLayoutWidget >> asHTML [
	"Generate a div containing child widget renderings."
	|  html calc rowGenerator |
	calc := HumCalculator new.
	
	rowGenerator := [ | innerHTML |
		innerHTML := String new.
		( self widgets ) do: [ :widget | 
			| cellHTML |
			cellHTML := calc xml: 'td' with: [ widget asHTML ].
			innerHTML := innerHTML, cellHTML. 
			].
			innerHTML. "returned value"
		].
	html := calc xml: 'div' 
						with: [ calc xml: 'table' 
										with: [ calc xml: 'tr' 
														with: [ rowGenerator value  ] 
												]  
								].
	^html.
	
]

{ #category : #'Render As' }
HumRowLayoutWidget >> asMorph [
	| morph childMorphs |
	morph := AlignmentMorph new.
	childMorphs := OrderedCollection new.
	(self widgets) do: [ :widget | childMorphs add: (widget asMorph) ].
	morph inARow: childMorphs.
	morph cellPositioning: #topLeft.
	^morph.
]
