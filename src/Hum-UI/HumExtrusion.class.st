"
The moldLoop origin is translated along the extrusionPath
to define the vertices of the extruded solid.

Note: The end-caps are not covered by this method.
If end-caps are needed, the caller must produce them.
(i.e. Cover the end-cap surfaces with polygons.)



"
Class {
	#name : #HumExtrusion,
	#superclass : #HumSolid,
	#instVars : [
		'moldLoop',
		'extrusionPath'
	],
	#category : #'Hum-UI'
}

{ #category : #'as yet unclassified' }
HumExtrusion class >> id: aSymbol moldLoop: a3DpathForMold extrusionPath: a3DpathForExtrusion [
	"Create an instance defining an extrusion."
	| instance |
	instance := self basicNew.
	instance
		moldLoop: a3DpathForMold;
		extrusionPath: a3DpathForExtrusion.
	^instance.
]

{ #category : #polygons }
HumExtrusion >> asPolygonsColoredBy: aColorRule [
	"Translate the moldLoop`s points 
	 so that the origin is translated to each point in the extrusionPath."
	"Create quadrangles (HumPolygons) by connecting the dots."
	| priorMoldLoop |
	polygons ifNil: [ polygons := OrderedCollection new ] ifNotNil: [ ^polygons ].
	"Preconditions"
	self assert: (self extrusionPath size > 1).
	self assert: (self moldLoop size >= 4).
	polygons := OrderedCollection new.
	"Make polygons covering exterior of the extrusion."
	priorMoldLoop := (self moldLoop) translatedBy: (extrusionPath at: 1).
	(2 to: extrusionPath size)
		do: [ :x |
			| thisMoldLoop |
			thisMoldLoop := (self moldLoop) translatedBy: (extrusionPath at: x).
			(2 to: moldLoop size)
				do: [ :m | 
					| polygon |
					polygon := HumPolygon parentSolid: self fillColor: aColorRule value.
					polygon
					"start"
						addVertex: (thisMoldLoop at: m);
					"up"
						addVertex: (thisMoldLoop at: m-1);
					"back" 
						addVertex: (priorMoldLoop at: m-1);
					"down"
						addVertex: (priorMoldLoop at: m);
					"forward to end"
						addVertex: (thisMoldLoop at: m). "Close the loop."
					self polygons add: polygon.
					].
			priorMoldLoop := thisMoldLoop.
			 ].
	self assert: (polygons size >= 3).
	"Note: If end-caps need to be covered, the caller must do it."
	^polygons.

]

{ #category : #'render via VPython' }
HumExtrusion >> asVPython [
	self shouldBeImplemented 
]

{ #category : #geometry }
HumExtrusion >> centerX [
	"centerX = average value of x from polygon vertices"
	|  sum n |
	centerX ifNotNil: [ ^centerX ].
	sum := 0.0 meter.
	n := 0.
	(self polygons)
		do: [ :polygon | "HumPolygon"
			polygon verticesDo: [ :x :y :z | n := n + 1. sum := sum + x. ]. 
			].
	centerX := sum / n.
	^centerX.
	
]

{ #category : #geometry }
HumExtrusion >> centerY [
	"centerY = average value of Y values from polygon vertices"
	|  sum n |
	centerY ifNotNil: [ ^centerY ].
	sum := 0.0 meter.
	n := 0.
	(self polygons)
		do: [ :polygon | "HumPolygon"
			polygon verticesDo: [ :x :y :z | n := n + 1. sum := sum + y. ]. 
			].
	centerY := sum / n.
	^centerY.
	
]

{ #category : #geometry }
HumExtrusion >> centerZ [
	"centerZ = average value of Z values from polygon vertices"
	|  sum n |
	centerZ ifNotNil: [ ^centerZ ].
	sum := 0.0 meter.
	n := 0.
	(self polygons)
		do: [ :polygon | "HumPolygon"
			polygon verticesDo: [ :x :y :z | n := n + 1. sum := sum + z. ]. 
			].
	centerZ := sum / n.
	^centerZ.
	
]

{ #category : #geometry }
HumExtrusion >> changed [
	"Force recalculation of geometry when next asked."
	polygons := nil.
	centerX := nil.
	centerY := nil.
	centerZ := nil.
	
]

{ #category : #access }
HumExtrusion >> extrusionPath [
	"The moldLoop origin is translated along this path to outline the extrusion."
	self assert: ( extrusionPath isKindOf: H3dPath ).
	^extrusionPath. 
]

{ #category : #access }
HumExtrusion >> extrusionPath: a3Dpath [
	"The moldLoop origin is translated along this path to outline the extrusion."
	extrusionPath := a3Dpath.
	self assert: ( extrusionPath isKindOf: H3dPath ).
]

{ #category : #access }
HumExtrusion >> moldLoop [
	"This loop defines the edges of the extrusion. See also: #extrusionPath:"
	"The 3D path is closed by connecting the last point to the first."
	self assert: ( moldLoop isKindOf: H3dPath ).
	^moldLoop.
]

{ #category : #access }
HumExtrusion >> moldLoop: a3Dpath [
	"This loop defines the edges of the extrusion. See also: #extrusionPath:"
	"The 3D path must be closed by connecting the last point to the first."

	moldLoop := a3Dpath.
	self assert: ( moldLoop isKindOf: H3dPath ).
	self assert: (a3Dpath first) = (a3Dpath last).
]

{ #category : #access }
HumExtrusion >> volume [
	Error signal: 'I do not know how to compute the volume of an extrusion in the general case.'.
]
