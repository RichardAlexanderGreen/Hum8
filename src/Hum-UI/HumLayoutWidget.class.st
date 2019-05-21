"
Layout will arrange children in row or column.

*** TODO: IS THIS REALLY NEEDED ?? ***
*** IF SO: HOW ARE THESE WIDGETS REPRESENTED IN A VIEW ?? ***
"
Class {
	#name : #HumLayoutWidget,
	#superclass : #HumWidget,
	#instVars : [
		'widgets'
	],
	#category : #'Hum-UI'
}

{ #category : #accessing }
HumLayoutWidget >> addWidget: aHumWidget [ 
	(self widgets) add: aHumWidget.
]

{ #category : #accessing }
HumLayoutWidget >> reorder: aSortBlock [
	"Re-order the widgets according to the given sort criteria."
	self notYetImplemented.
]

{ #category : #accessing }
HumLayoutWidget >> widgets [
	^ widgets ifNil: [ widgets := OrderedCollection new. ]
]
