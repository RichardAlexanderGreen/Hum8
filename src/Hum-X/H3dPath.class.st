"
a list of 3D vertices
But it can also be interpreted as a polygon if the path is in a plane.
Each vertex is a HumVector.
"
Class {
	#name : #H3dPath,
	#superclass : #Object,
	#instVars : [
		'vertices',
		'borderColor',
		'fillColor'
	],
	#category : #'Hum-X'
}

{ #category : #'as yet unclassified' }
H3dPath class >> newFrom: aCollection [
	"Create an instance from the points in the collection/array"
	| instance |
	instance := self new.
	aCollection do: [ :vertex | instance addVertex: vertex ].
	^instance
]

{ #category : #'as yet unclassified' }
H3dPath class >> newFrom: aCollection units: aSymbol [
	"Create an instance from the points in the collection/array"
	| instance |
	instance := self new.
	aCollection do: [ :vertex | 
		| vector |
		vector := HumVector newFrom: vertex units: aSymbol.
		instance addVertex: vector ].
	^instance
]

{ #category : #access }
H3dPath >> = anotherPath [
	"Are the two paths equal."
	| result |
	"Are they the same size?"
	( self vertices size = anotherPath vertices size ) 
		ifFalse: [ ^false ].
	
	result := true. "Innocent until proven otherwise."
	(1 to: self size)
		do: [ :i | ((self vertices at: i) = (anotherPath vertices at: i)) ifFalse: [ ^false ]. ].
	^result.
	
]

{ #category : #access }
H3dPath >> addVertex: xyzCoordinates [ 
	| vector calc |
	calc := HumCalculator new.
	calc cases;
		when: [ xyzCoordinates isKindOf: HumVector ] then: [ vector := xyzCoordinates. ];
		when: [ xyzCoordinates isKindOf: Array ] then: [ vector := HumVector newFrom: xyzCoordinates. ];
		when: [ xyzCoordinates isKindOf: Point ] then: [ vector := HumVector newFromPoint: xyzCoordinates. ];
		
		otherwise: [ Error signal: 'xyzCoordinates of unexpected type' ].
	(self vertices) add: vector.
	
]

{ #category : #access }
H3dPath >> allButFirstDo: aBlockClosure [ 
	^self vertices allButFirstDo: aBlockClosure.
]

{ #category : #access }
H3dPath >> at: anInteger [
	"Return the vertex at: ..."
	| vertex |
	self assert: (anInteger <= (self vertices size)).
	vertex := (self vertices) at: anInteger.
	^vertex.
]

{ #category : #access }
H3dPath >> borderColor [
	^ borderColor ifNil: [ borderColor := (self fillColor) lighter ].
]

{ #category : #access }
H3dPath >> borderColor: aColor [ 
	"Color to use when rendering path (polygon edges)."
	borderColor := aColor.
]

{ #category : #access }
H3dPath >> do: aBlockClosure [ 
	^self vertices do: aBlockClosure.
]

{ #category : #access }
H3dPath >> fillColor [
	^ fillColor ifNil: [ fillColor := Color gray ].
]

{ #category : #access }
H3dPath >> fillColor: aColor [ 
	"Color to use when rendering path as a polygon"
	fillColor := aColor.
]

{ #category : #access }
H3dPath >> first [
	| points |
	points := self vertices.
	self assert: ( points size > 0 ). "OrderedCollection"
	^ points at: 1.
]

{ #category : #access }
H3dPath >> last [
	| points |
	points := self vertices.
	self assert: ( points size > 0 ). "OrderedCollection"
	^ points last.
]

{ #category : #access }
H3dPath >> max: aBlockClosure [ 
	^self vertices max: aBlockClosure.
]

{ #category : #transforms }
H3dPath >> pitch: pitchAngle [ 
	"Return a new path with my points adjusted by pitch about origin."
	| newPath |
	newPath := self pitch: pitchAngle aboutPivot: ( HumVector zeroVector: #meter ).
	^newPath

]

{ #category : #transforms }
H3dPath >> pitch: pitchAngle aboutPivot: aPivot [
	"Return a new path with my points adjusted by pitch about origin."
	| newPath |
	newPath := self class  new.
	self vertices do: [ :vertex |  newPath addVertex: ( vertex pitch: pitchAngle aboutPivot: aPivot ). ].
	^newPath

]

{ #category : #transforms }
H3dPath >> roll: rollAngle [ 
	"Return a new path with my points adjusted by roll about origin."
	| newPath |
	newPath := self roll: rollAngle aboutPivot: ( HumVector zeroVector: #meter ).
	^newPath

]

{ #category : #transforms }
H3dPath >> roll: rollAngle aboutPivot: aPivot [
	"Return a new path with my points adjusted by roll about origin."
	| newPath |
	newPath := self class new.
	self vertices do: [ :vertex |  newPath addVertex: ( vertex roll: rollAngle aboutPivot: aPivot ). ]."HumVector"
	^newPath

]

{ #category : #access }
H3dPath >> size [
	^ self vertices size.
]

{ #category : #transforms }
H3dPath >> translateBy: aHumVector [ 
	"Return a path with vertices translated by the given vector."
	| newVertices instance |
	newVertices := OrderedCollection new.
	self vertices do: [ :vertex | 
			| newVertex |
			newVertex := vertex + aHumVector.
			newVertices addLast: newVertex.
		 ].
	instance := self class newFrom: newVertices.
	instance 
		fillColor: (self fillColor);
		borderColor: (self borderColor).
	^instance.
	
	
]

{ #category : #transforms }
H3dPath >> translatedBy: aHumVector [
	"Return a new path with my vertices translated by the given vector"
	"This is just a synonym"
	^self translateBy: aHumVector.
]

{ #category : #access }
H3dPath >> vertices [
	^ vertices ifNil: [ vertices := OrderedCollection new ].
]

{ #category : #transforms }
H3dPath >> yaw: yawAngle [ 
	"Return a new path with my points adjusted by yaw about origin."
	| newPath  |
	newPath := self yaw: yawAngle aboutPivot: ( HumVector zeroVector: #meter ).
	^newPath

]

{ #category : #transforms }
H3dPath >> yaw: yawAngle aboutPivot: pivot [
	"Return a new path with my points adjusted by yaw about origin."
	| newPath |
	newPath := self class new.
	self vertices do: [ :vertex |  newPath addVertex: ( vertex yaw: yawAngle aboutPivot: pivot ). ].
	^newPath

]
