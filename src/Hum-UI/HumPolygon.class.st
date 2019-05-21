"
HumPolygon is used in HumViewPort 
to represent both 3D scene polygons and 2D projection ploygons.
It also differs from standard Shape polygon by having a fill-color.

The convention is to list vertices in a counter-clockwise direction as seen from the 'outside' of a solid. The 'normal' of the surface is thereby defined by a right-hand rule, where the resulting vector points away from the interior of the solid.
"
Class {
	#name : #HumPolygon,
	#superclass : #Object,
	#instVars : [
		'vertices',
		'borderColor',
		'fillColor',
		'parentSolid'
	],
	#classInstVars : [
		'fillColor'
	],
	#category : #'Hum-UI'
}

{ #category : #'instance creation' }
HumPolygon class >> borderColor: aColor [ 
	| instance |
	instance := self new.
	instance color: aColor.
	^instance.
]

{ #category : #'instance creation' }
HumPolygon class >> borderColor: aBorderColor fillColor: aFillColor [
	| instance |
	instance := self new.
	instance borderColor: aBorderColor;  fillColor: aFillColor.
	^instance.
]

{ #category : #'instance creation' }
HumPolygon class >> color: aColor [ 
	| instance |
	instance := self new.
	instance color: aColor.
	^instance.
]

{ #category : #'instance creation' }
HumPolygon class >> copy: aHumPolygon withTransform: aTransformBlock [
	"copy the given polygon colors. Transform the vertices via the block.
	The block takes :x :y :z and returns tranformed 3D { tx. ty. tz. } or tx@ty point."
	| instance |
	instance := self borderColor: aHumPolygon borderColor fillColor: aHumPolygon fillColor.
	aHumPolygon
		verticesDo: [ :x :y :z |
			| transformedVertex |
			transformedVertex := aTransformBlock value: x value: y value: z.
			instance addVertex: transformedVertex.
			 ].
	^instance
]

{ #category : #accessing }
HumPolygon class >> fillColor: aColor [ 
	| instance |
	self assert:(aColor isKindOf: Color).
	instance := self new.
	instance fillColor: aColor.
	^instance.

]

{ #category : #accessing }
HumPolygon class >> parentSolid: aHumSolid fillColor: aColor [ 
	| instance |
	self assert:(aColor isKindOf: Color).
	instance := self new.
	instance fillColor: aColor.
	instance borderColor: aColor.
	instance parentSolid: aHumSolid.
	^instance.

]

{ #category : #comparing }
HumPolygon >> <= aHumPolygon [ 
	"Z-ordering: Is my north-most point more northerly than the other."
	| myNorthMost otherNorthMost result |
	myNorthMost := self northMostPoint.
	otherNorthMost := aHumPolygon northMostPoint.
	(myNorthMost = otherNorthMost)
		ifFalse: [ result := ( myNorthMost >= otherNorthMost ). ]
		ifTrue: [ | myCentroid otherCentroid |
			myCentroid := self centroid.
			otherCentroid := aHumPolygon centroid.
			result := ( myCentroid at: 2) >= (otherCentroid at: 2).
			 ].
	
	^result.
]

{ #category : #comparing }
HumPolygon >> > aHumPolygon [ 
	"Is my north-most point more northerly than the other."
	| result |
	result := ( self <= aHumPolygon ) not.
	
	^result.
]

{ #category : #accessing }
HumPolygon >> addVertex: aScenePoint [ 
	"The convention is to list vertices in a counter-clockwise direction as seen from the 'outside' of a solid."
	| calc |
	"Comment: Wishing to be programmer-friendly or more generic, we allow more than one kind of point.
	     Of course: There will be consequences."
	calc := HumCalculator new.
	calc cases;
		when: [ ( self vertices size > 0 )  and: [aScenePoint = vertices last] ]
			then: [ "Do not add redundant scene point." ];
		when: [ ( aScenePoint isKindOf: Array ) and: [ aScenePoint size >= 2 ] ]  "Allow for 3D to 2D mapping."
			then:  [ self path addVertex: aScenePoint. ];
		when: [ ( aScenePoint isKindOf: Collection ) and: [ aScenePoint size = 3 ] ] "Allow for collection instead of array."
			then:  [ self halt. self vertices add: aScenePoint. ];
		when: [ aScenePoint isKindOf: HumVector ]
			then: [ self path addVertex: { aScenePoint x. aScenePoint y. aScenePoint z. } ];	
		when: [ aScenePoint isKindOf: Point ]
			then: [ "okay" self path addVertex: aScenePoint ];  "Viewport XY pixel coordinates"
		otherwise: [ Error signal: 'Scene point is not of expected type' ].	
]

{ #category : #enumerating }
HumPolygon >> asTriangles [
	| center triangles firstVertex priorVertex triangle |
	self assert: (vertices size > 2) description: 'A polygon should have at least 3 vertices.'.
	triangles := OrderedCollection new.
	center := self centroid.
	firstVertex := vertices first.
	priorVertex := firstVertex.
	vertices 
		allButFirstDo:  [ :thisVertex |  
			"Make a polygon with same colors"
			triangle := HumPolygon borderColor: (self fillColor) fillColor: (self fillColor).
			triangle parentSolid: (self parentSolid).
			triangle
				addVertex: center; 
				addVertex: priorVertex;
				addVertex: thisVertex.
			triangles add: triangle.
			priorVertex := thisVertex.
		].
			triangle
				addVertex: center; 
				addVertex: priorVertex;
				addVertex: firstVertex.
			triangles add: triangle.
	
	^triangles.
	
]

{ #category : #accessing }
HumPolygon >> borderColor [
	^ borderColor ifNil: [ borderColor := Color blue ].
]

{ #category : #accessing }
HumPolygon >> borderColor: aColor [ 
	borderColor := aColor
]

{ #category : #evaluating }
HumPolygon >> bottom [
	"If points are 2D, Return min y or zero."
	| minY  |
	minY := self vertices max: [ :vertex | (vertex at: 2) negated ].
	^minY negated.
]

{ #category : #comparing }
HumPolygon >> centroid [
	"Compute the centroid of the vertices."
	| sumX sumY sumZ centroid n |
	n := self vertices size.
	self assert: (n > 2).
	sumX := sumY := sumZ := 0.0 meter.

	self verticesDo: [ :x :y :z |
		sumX := sumX + x.
		sumY := sumY + y.
		sumZ := sumZ + z.
		].
	centroid := {  sumX / n. sumY / n. sumZ / n. }.
	^centroid.
]

{ #category : #accessing }
HumPolygon >> color: aColor [ 
	"Specify border-color or fll-color instead."
	self shouldNotBeImplemented.
]

{ #category : #drawing }
HumPolygon >> drawOn: aHumCanvas [ 
	aHumCanvas drawPolygon: self scale: ((5 px )/ (1 millimeter)).
]

{ #category : #accessing }
HumPolygon >> fillColor [
	^ fillColor ifNil: [  fillColor := Color gray. ].
]

{ #category : #accessing }
HumPolygon >> fillColor: aColor [ 
	fillColor := aColor
]

{ #category : #testing }
HumPolygon >> inFrontOfCamera [
	"Return true if at least one y-value is positive."
	|  |
	"This only works properly if vertices have been transformed into camera coordinates."
	self verticesDo: [ :x :y :z | ( y quantity > 0.0 ) ifTrue: [ ^true ] ].
	^false.
]

{ #category : #evaluating }
HumPolygon >> left [
	| minY |
	"Trick because we collection has max: method but no min: method."
	minY := self vertices max: [ :vertex | (vertex at: 2) negated ]. 
	^minY negated.
]

{ #category : #comparing }
HumPolygon >> maxRsquared [
	"Compute the centroid of the vertices."
	|  maxSquared n |
	n := self vertices size.
	self assert: (n > 0).
	maxSquared := 0.

	self verticesDo: [ :xMeasure :yMeasure :zMeasure |
		| thisSquared x y z |
		x := xMeasure quantity.
		y := yMeasure quantity.
		z := zMeasure quantity.
		thisSquared := (x*x) + (y*y) + (z*z).
		(thisSquared > maxSquared) ifTrue: [ maxSquared := thisSquared ].
		].
	
	^maxSquared.
]

{ #category : #comparing }
HumPolygon >> meanRsquared [
	"Compute the centroid of the vertices."
	|  meanRsquared n |
	n := self vertices size.
	self assert: (n > 0).
	meanRsquared := 0.

	self verticesDo: [ :xMeasure :yMeasure :zMeasure |
		| thisSquared x y z |
		x := xMeasure quantity.
		y := yMeasure quantity.
		z := zMeasure quantity.
		thisSquared := (x*x) + (y*y) + (z*z).
		meanRsquared := meanRsquared + thisSquared.
		].
	
	^(meanRsquared / n).
]

{ #category : #comparing }
HumPolygon >> minRsquared [
	"Compute the centroid of the vertices."
	|  minSquared n |
	n := self vertices size.
	self assert: (n > 0).
	minSquared := 0.

	self verticesDo: [ :xMeasure :yMeasure :zMeasure |
		| thisSquared x y z |
		x := xMeasure quantity.
		y := yMeasure quantity.
		z := zMeasure quantity.
		thisSquared := (x*x) + (y*y) + (z*z).
		(thisSquared < minSquared) ifTrue: [ minSquared := thisSquared ].
		].
	
	^minSquared.
]

{ #category : #comparing }
HumPolygon >> northMostPoint [
	"Find the value of the point that is furtherest North (z-Ordering)"
	| northMost |
	"Hum coordinate axis point {East. North. Up.}"
	northMost := ( (self vertices) first ) at: 2.
	self verticesDo: [ :x :y :z | northMost := northMost max: y ].
	^northMost.
	
]

{ #category : #accessing }
HumPolygon >> parentSolid [
	"Remember where I came from."
	^ parentSolid ifNil: [ Error signal: 'parentSolid not defined' ].
]

{ #category : #accessing }
HumPolygon >> parentSolid: aHumSolid [ 
	"Remember where I came from."
	parentSolid := aHumSolid. 
]

{ #category : #accessing }
HumPolygon >> path [
	^self vertices.
]

{ #category : #transforms }
HumPolygon >> pitch: pitchAngle [ 
	"Return a new polygon with my points adjusted by pitch about origin."
	| newPolygon |
	newPolygon := HumPolygon new.
	self vertices do: [ :vertex |  newPolygon addVertex: (vertex pitch: pitchAngle). ].
	^newPolygon

]

{ #category : #comparing }
HumPolygon >> rSquared [
	| xyz cx cy cz rSquared |
	xyz  := self centroid.
	cx := xyz at: 1.
	cy := xyz at: 2.
	cz := xyz at: 3.
	rSquared := (cx*cx) + (cy*cy) + (cz*cz).
	^rSquared.
	
]

{ #category : #evaluating }
HumPolygon >> right [
	| maxY |
	maxY := self vertices max: [ :vertex | (vertex at: 2) ].
	^maxY
]

{ #category : #transforms }
HumPolygon >> roll: rollAngle [ 
	"Return a new polygon with my points adjusted by roll about origin."
	| newPolygon |
	newPolygon := HumPolygon new.
	self vertices do: [ :vertex |  newPolygon addVertex: (vertex roll: rollAngle). ].
	^newPolygon

]

{ #category : #evaluating }
HumPolygon >> top [
	"If points are 2D, Return max y."
	| maxY |
	maxY := 0 meter.
	self verticesDo: [ :x :y :z |  y > maxY ifTrue: [maxY := y] ].
	^maxY.
]

{ #category : #accessing }
HumPolygon >> vertices [
	"The convention is to list vertices in a counter-clockwise direction as seen from the 'outside' of a solid."
	^vertices ifNil: [ vertices := H3dPath new ].
]

{ #category : #enumerating }
HumPolygon >> verticesDo: aBlockClosure [ 
	self vertices do: [ :vertex |
		| x y z |
		x := vertex at: 1. y := vertex at: 2. 
		(vertex size = 3) ifTrue: [ z := vertex at: 3 ] ifFalse: [ z := nil ].
		aBlockClosure value: x value: y value: z. 
		].

]

{ #category : #enumerating }
HumPolygon >> xyPoints [
	"Flatten my 3D points to 2D points in X-Y (floor plan) plane"
	| xyVertices |
	xyVertices := OrderedCollection new.
	self verticesDo: [ :x :y :z | 
		self assert: ( (x isKindOf: HumMeasure) and: [x units = #px]).
		xyVertices add: (x quantity) @ (y quantity). 
		].
	^xyVertices.
	
]

{ #category : #enumerating }
HumPolygon >> xzPoints [
	"Flatten my 3D points to 2D points in X-Z (viewport/billboard) plane. "
	| xzVertices  |
	xzVertices := OrderedCollection new.
	self verticesDo: [ :x :y :z | xzVertices add: (x@z) ].
	^xzVertices.
	
]

{ #category : #transforms }
HumPolygon >> yaw: yawAngle [ 
	"Return a new polygon with my points adjusted by yaw about origin."
	| newPolygon |
	newPolygon := H3dPath new.
	self vertices do: [ :vertex |  newPolygon addVertex: (vertex yaw: yawAngle). ].
	"See HumVector"
	^newPolygon

]

{ #category : #transforms }
HumPolygon >> yaw: yawAngle aboutPivot: pivot [
	"Return a new polygon with my points adjusted by yaw about origin."
	| newPolygon |
	newPolygon := H3dPath new.
	self vertices do: [ :vertex |  newPolygon addVertex: (vertex yaw: yawAngle aboutPivot: pivot). ].
	"See HumVector"
	^newPolygon

]
