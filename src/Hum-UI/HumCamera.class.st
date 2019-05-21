"
The camera is modeled as a 'virtual' HumBox HumAssembly.
It is initialized with the fustrum on the North Edge (away from the eye)
and the eye pin-hole on the South Edge.
The dimensions of the box determine the aspect ratio and the angle of view.

To get a bug-eye (microscopic) view, 
  make the camera dimensions microscopic.
To get a cosmic view (as seen via a telescope), 
  make the camera dimensions cosmic in scale.

The camera is set up as an assembly to enable representing a camera as seen by another camera.  For example, a lense may be painted or represented as a cylinder. 
However, the default is just a box.
"
Class {
	#name : #HumCamera,
	#superclass : #HumAssembly,
	#instVars : [
		'orientationVector'
	],
	#category : #'Hum-UI'
}

{ #category : #'as yet unclassified' }
HumCamera class >> defaultCamera [
	"Dimension the virtual pin-hole camera box and position it"
	| instance |
	"These dimensions approximate a window at the position of a laptop screen.
	To get other views, change the height, width, depth. 
	Example: Try these dimensions on a millimeter scale - approximating dimensions of human eye.
	"
	instance := self
		id: 'virtual pin-hole camera '
		height: 7 inches  "height of my laptop screen"
		width: 11 inches "width of my laptop screen"
		depth: 20 inches. "typical distance from eye to laptop screen"
	"Position it at a moderate adult eye height"
	instance topEdge: (175 centimeter).
	"Position North edge on zero plane."
	instance northEdge: (1 centimeter).  "This hovers just in front of a default billboard."
	"TODO: Add an assembly to model the camera as a box and cylinder."
	^ instance.
]

{ #category : #'as yet unclassified' }
HumCamera class >> onScene: aHumScene [
	"The scene will be notified when I am moved."
	| instance |
	instance := self defaultCamera.
	instance scene: aHumScene.
	^instance.
]

{ #category : #projection }
HumCamera >> eyeX [
	"Eye in scene coordinates.  
	Note: In a simulation, this should be location of pin-hole; 
	but . . . center point is more convenient."
	^(self westEdge + ((self width) * 0.5) ).
]

{ #category : #projection }
HumCamera >> eyeY [
	"Eye in scene coordinates."
	^(self northEdge) - (self depth).
]

{ #category : #projection }
HumCamera >> eyeZ [
	"Eye in scene coordinates."
	^((self topEdge) - ((self height) * 0.5) )
]

{ #category : #'as yet unclassified' }
HumCamera >> isPointInFieldOfView: a3Dpoint [ 
	"Is the given 3D point within my field of view.  
	Note: The point must be in camera coordinates."
	| x y z  pointDxDy pointDzDy  cameraDxDy cameraDzDy |
	
	x := a3Dpoint at: 1.
	y := a3Dpoint at: 2.
	z := a3Dpoint at: 3.
	
	"Is the point behind the camera`s aperture?"
	(y  < (self depth)) ifTrue: [  ^false ].

	"Is point in horizontal field of view?"
	pointDxDy := x / y.
	cameraDxDy :=  ( self width )  / ( self depth ).
	( (pointDxDy abs) <= cameraDxDy ) ifFalse: [ ^false. ].

	"Is point in verticle field of view?"
	pointDzDy := z / y.
	cameraDzDy :=  ( self height )  / ( self depth ).
	( (pointDzDy abs) <= cameraDzDy ) ifFalse: [ ^false. ].

	"Passed the filters. Looks okay."
	^true.

]

{ #category : #'move slide rotate tilt' }
HumCamera >> slideBackward: aDistance [
	self slideForward: ( aDistance negated ).
]

{ #category : #'move slide rotate tilt' }
HumCamera >> slideForward: aDistance [
	"Move in the direction the camera is pointing."
	| myCentroid nextCentroid directionVector |
	self assert: (aDistance isKindOf: HumMeasure). "a scalar"
	
	myCentroid := self center.
	self assert: (myCentroid isKindOf: HumVector).
	directionVector := self unitForward.
	self assert: (directionVector isKindOf: HumVector).
	nextCentroid := myCentroid + (directionVector * aDistance).
	self centerAt: nextCentroid.
	self changed.
	
	
]

{ #category : #'move slide rotate tilt' }
HumCamera >> slideLeft: aDistance [
	^self slideRight: (aDistance negated).
	
	
]

{ #category : #'move slide rotate tilt' }
HumCamera >> slideRight: aDistance [
	"Move in the direction the camera is pointing."
	| myCentroid nextCentroid directionVector |
	self assert: (aDistance isKindOf: HumMeasure). "a scalar"
	
	myCentroid := self center.
	self assert: (myCentroid isKindOf: HumVector).
	directionVector := self unitSideways.
	self assert: (directionVector isKindOf: HumVector).
	nextCentroid := myCentroid + (directionVector * aDistance).
	self centerAt: nextCentroid.
	self changed.
	
	
]

{ #category : #'move slide rotate tilt' }
HumCamera >> slideUpward: aDistance [
	"Move in the direction the camera is pointing."
	| myCentroid nextCentroid directionVector |
	self assert: (aDistance isKindOf: HumMeasure). "a scalar"
	
	myCentroid := self center.
	self assert: (myCentroid isKindOf: HumVector).
	directionVector := self unitUpDown.
	self assert: (directionVector isKindOf: HumVector).
	nextCentroid := myCentroid + (directionVector * aDistance).
	self centerAt: nextCentroid.
	self changed.
	
	
]

{ #category : #'move slide rotate tilt' }
HumCamera >> unitForward [
	"Return unit vector pointing along my internal y axis due to my rotation and tilt."
	| x y z alpha beta unitVector |
	alpha := self rotation.
	beta := self tilt.
	x := ( alpha sin ) * ( 1.0 ).
	y := ( alpha cos ) * ( beta cos ).
	z := ( alpha cos ) * ( beta sin ).
	unitVector := HumVector newFrom: { x. y. z. } units: 'none'. "unit vector is dimensionless"
	self assert: (  ( unitVector length quantity - 1.0 ) abs < (0.001 )  ).
	^unitVector.
]

{ #category : #'move slide rotate tilt' }
HumCamera >> unitSideways [
	"Return unit vector pointing along my internal x axis due to my rotation and tilt."
	| x y z alpha beta unitVector |
	alpha := (self rotation) + ( 90.0 degreesToRadians ).
	beta := self tilt.
	x := ( alpha sin ) * ( 1.0 ).
	y := ( alpha cos ) * ( beta cos ).
	z := ( alpha cos ) * ( beta sin ).
	unitVector := HumVector newFrom: { x. y. z. } units: 'none'. "unit vector is dimensionless"
	self assert: (  ( unitVector length quantity - 1.0 ) abs < (0.001 )  ).
	^unitVector.
]

{ #category : #'move slide rotate tilt' }
HumCamera >> unitUpDown [
	"Return unit vector pointing along my internal x axis due to my rotation and tilt."
	| x y z alpha beta unitVector |
	alpha := ( self rotation ).
	beta := ( self tilt ) + ( 90.0 degreesToRadians ).
	x := ( alpha sin ) * ( 1.0 ).
	y := ( alpha cos ) * ( beta cos ).
	z := ( alpha cos ) * ( beta sin ).
	unitVector := HumVector newFrom: { x. y. z. } units: 'none'. "unit vector is dimensionless"
	self assert: (  ( unitVector length quantity - 1.0 ) abs < (0.001 )  ).
	^unitVector.
]
