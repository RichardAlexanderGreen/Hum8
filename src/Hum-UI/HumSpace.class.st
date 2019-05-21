"
HumSpace is a synoym for HumBox.
It is provided to make code more readable.
The intent is that you would use HumSolid to model things that are mostly solid, like walls,
but you would use HumSpace to model things that are hollow 
(filled with air) for things like rooms, doorways, gardens, landscapes.

Consider: A HumWall (TBD) might have HumSurface objects mapped to its main faces. 
"
Class {
	#name : #HumSpace,
	#superclass : #HumSolid,
	#category : #'Hum-UI'
}

{ #category : #polygons }
HumSpace >> asPolygons [
	"Return an empty collection of polygons - HumSpace is not drawn. It is used for spacing in layout logic."
	^ 	OrderedCollection new.
]

{ #category : #polygons }
HumSpace >> asPolygonsColorCoded [
	"Return an empty collection of polygons - HumSpace is not drawn. It is used for spacing in layout logic."
	^ 	OrderedCollection new.
]

{ #category : #'render via VPython' }
HumSpace >> asVPythonThing [
	"A space has no color and is not visible."
	| pythonCode |
	pythonCode := id, ' = BoxThing( label = "',id,'"'
	                              ,', length = ', (length quantity printShowingDecimalPlaces: 3) "millimeter precision"
	                              ,', width = ',   (width quantity printShowingDecimalPlaces: 3)
	                              ,', height = ', (height quantity printShowingDecimalPlaces: 3)
								  ,', pos = ', ( self asVPythonPosition )
	                              ,', visible = false'
	                              ,' )'.
	^pythonCode
]
