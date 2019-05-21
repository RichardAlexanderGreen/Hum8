"
Form Widget is a container for attribute widgets.
It corresponds to a Hum view frame.
It is invoked with ""Ask view-name."" or ""Show view-name."" in a dialog vignette.
It may also be invoked with the form ""[pane: view-name]"" from another view.

When appropriately rendered, it is expected to provide typical 
fill-in-the blank form actions.
. tab from active slot to active slot.
. [[ submit ]] -- submit changed data, return to prior dialog
. [[ reset ]] -- reset field values to some prior state
. [[ quit ]] -- ignore changed values, return to prior dialog
"
Class {
	#name : #HumFormWidget,
	#superclass : #HumWidget,
	#instVars : [
		'view'
	],
	#category : #'Hum-UI'
}

{ #category : #'instance creation' }
HumFormWidget class >> onView: aHumView [ 
	| instance |
	instance := self basicNew.
	instance view: aHumView.
	^instance.
]

{ #category : #accessing }
HumFormWidget >> view [
  "Return my view"
	^ view ifNil: [Error signal: (self class,' not properly initialized')]
]

{ #category : #accessing }
HumFormWidget >> view: aHumView [ 
	view := aHumView.
]
