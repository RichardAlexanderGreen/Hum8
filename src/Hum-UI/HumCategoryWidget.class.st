"
Widget enables user to view and pick a category value
for a noun of category type.

The value of the attribute, if any, is the current value - displayed when I am rendered.
"
Class {
	#name : #HumCategoryWidget,
	#superclass : #HumWidget,
	#instVars : [
		'categories'
	],
	#category : #'Hum-UI'
}

{ #category : #accessing }
HumCategoryWidget >> categories [
	^categories ifNil: [Error signal: 'categories have not been initialized']

]

{ #category : #accessing }
HumCategoryWidget >> categories: anArrayOfCategoryNames [ 
	categories := anArrayOfCategoryNames. 

]
