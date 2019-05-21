"
Layout children in a column.
"
Class {
	#name : #HumColumnLayoutWidget,
	#superclass : #HumLayoutWidget,
	#category : #'Hum-UI'
}

{ #category : #'Render As' }
HumColumnLayoutWidget >> asHTML [
	"Generate a div containing child widget renderings."
	|  html calc columnGenerator |
	calc := HumCalculator new.
	
	columnGenerator := [ | innerHTML |
		innerHTML := String new.
		( self widgets ) do: [ :widget | 
			| cellHTML |
			cellHTML := calc xml: 'tr' 
									with: [calc xml: 'td' 
													with: [ widget asHTML ]
													].
			innerHTML := innerHTML, cellHTML. 
			].
			innerHTML. "returned value"
		].
	html := calc xml: 'div' 
						with: [ calc xml: 'table' 
										with: [  columnGenerator value  ]. 				
								].
	^html.
	
]

{ #category : #'Render As' }
HumColumnLayoutWidget >> asMorph [
	| layoutMorph childMorphs |
	layoutMorph := AlignmentMorph new.
	childMorphs := OrderedCollection new.
	(self widgets) 
		do: [ :widget |
			 | child |
			child := widget asMorph.
			child cellPositioning: #topLeft; autoFit: true.
			childMorphs add: child. 
			].
	
	layoutMorph  setAsColumn 	
			color: Color white;
			vResizing: #shrinkWrap;
			hResizing: #shrinkWrap;
			layoutInset: 1;
			wrapCentering: #center;
			cellPositioning: #topLeft.
			
	childMorphs
		do: [ :each | layoutMorph addMorphBack: each ].
	^layoutMorph.
]
