"
A camera provides a projection of the scene onto a viewport.

It is also (optionally) an object in the scene (or a layer)
which can be seen by other cameras.

The center of the camera is the eye-point.
The viewport is located by the camera`s depth in front of the eye.
The width and height attributes describe the viewport dimensions.

Depth, width, height are typically in user-world metrics
for visualization of people-scaled objects.
However, a micro-world bugs-view or astro-world gods-view 
may use measures appropriate to those scales.

"
Class {
	#name : #H3dCamera,
	#superclass : #H3dObject,
	#instVars : [
		'depth',
		'scene'
	],
	#category : #'Hum-X'
}

{ #category : #'as yet unclassified' }
H3dCamera class >> depth: aDepth height: aHeight width: aWidth [ 
	"Set pin-hole camera dimensions (values should be HumMeasures)"
	| instance |
	{ aDepth. aHeight. aWidth } 
		do: [ :measure | self assert: (measure isKindOf: HumMeasure) ].
	instance := self new.
	instance 
		depth: aDepth;		"distance from eye to viewport"
		height: aHeight;	"height of the viewport"
		width: aWidth.		"width of the viewport"
	^instance.
]

{ #category : #access }
H3dCamera >> depth [
	"Distance from eye point to viewport rectangle."
	^ depth
]

{ #category : #access }
H3dCamera >> depth: aHumMeasure [ 
	"Distance from eye point to viewport rectangle."
	depth := aHumMeasure.
	length := depth. "Enable showing me as a box."
]

{ #category : #projection }
H3dCamera >> projectScenePointToScreenPoint: aScenePoint [
	"Map a scene point onto a screen point ( x y z ) ==> ( x' y' z').
	Return nil if the point cannot be mapped."
	| screenPoint diff rotated dzdy dxdy x y z |
	self assert: ( aScenePoint isKindOf: HumVector ).
	diff := (aScenePoint - (self center)). 
	rotated := ((diff pitch: (self pitch negated)) roll: (self roll negated)) yaw: (self yaw negated).
	"Filter points that are behind the screen."
	y := rotated y. "North"
	( y < depth ) ifTrue: [ ^nil ].
	x := rotated x. "East"
	z := rotated z. "Up"
	"Get the rise over run (tangent of angle)."
	dzdy := z / y.
	dxdy := x / y.
	"Filter points that are not visible."
	( dzdy > ( height * 0.5 / depth)) ifTrue: [ ^nil ].
	( dzdy < ( height * 0.5 / depth) negated ) ifTrue: [ ^nil ].
	( dxdy > ( width * 0.5 / depth) ) ifTrue: [ ^nil ].
	( dxdy < ( width * 0.5 / depth) negated ) ifTrue: [ ^nil ].
	"Calculate the offset in meters."
	screenPoint := HumVector newFrom: { dxdy * depth.  ( y ). dzdy * depth. }.
	"Original y is kept so that we can render overlaping points correctly. "
	^screenPoint.
]

{ #category : #access }
H3dCamera >> scene: aScene [
	"Scene (or layer) the camera is viewing."
	self assert: ( aScene isKindOf: H3dObject ).
	scene := aScene.
]
