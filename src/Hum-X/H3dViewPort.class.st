"
A 3D viewport is a view of a scene via a camera in the scene.

A 3D viewport is also a controller that can move the camera.

A 3D viewport is also a user-interface widget 
with the camera`s view mapped into a raster / canvas / bitmap / form.
The bitmap is dimensioned in pixels.

See also: FormCanvas Form BitBlt
"
Class {
	#name : #H3dViewPort,
	#superclass : #Object,
	#instVars : [
		'rectangle',
		'scale',
		'camera'
	],
	#category : #'Hum-X'
}

{ #category : #access }
H3dViewPort >> camera: anH3dCamera [ 
	"The viewport is attached to this camera."
	camera := anH3dCamera.
]

{ #category : #draw }
H3dViewPort >> mapScenePoint: aScenePoint [ 
	"Map scene point to camera image, camera image to my image."
	| viewPoint cameraPoint |
	self assert: (aScenePoint isKindOf: HumVector).
	"The camera returns nil if the point is not visible on its screen, and so do we."
	cameraPoint := camera projectScenePointToScreenPoint: aScenePoint.
	cameraPoint ifNil: [ ^nil ].
	"TODO: Returning nil as a signal is generally a bad idea."
	"One of the problems with returning nil, is that the point may be the start of a line."
	"Another problem is that I will have to screen for nils in all of the down-stream code."
	viewPoint := cameraPoint * scale.
	^viewPoint.
	
	
]

{ #category : #access }
H3dViewPort >> origin: pointOrigin extent: pointExtent [  
	"What is my origin and extent in container coordinates and pixel metrics?"
	self assert: ( pointOrigin isKindOf: Point ).
	self assert: ( pointOrigin x isKindOf: Integer ). "pixel (px) units are assumed."
	self assert: ( pointOrigin y isKindOf: Integer ). "pixel (px) units are assumed."
	self assert: ( pointExtent isKindOf: Point ).
	self assert: ( pointExtent x isKindOf: Integer ). "pixel (px) units are assumed."
	self assert: ( pointExtent y isKindOf: Integer ). "pixel (px) units are assumed."
	self assert: ( pointExtent x > 0 ). "Extent is non-negative / positive-definite."
	self assert: ( pointExtent y > 0 ). "Extent is non-negative / positive-definite."
	"As a practival matter, viewports dimensions need to be in the hundreds."	
	rectangle := Rectangle origin: pointOrigin extent: pointExtent. 
]

{ #category : #draw }
H3dViewPort >> resolutionAt: aDistance [
	"What is the resolution per pixel at given distance"
	| d dsdy resolution |
	self assert: ( scale isNotNil ).
	self assert: ( aDistance isKindOf: HumMeasure ).
	d := (1 pixel) / scale. " px / (px/mm) ==> px * mm / px ==> mm"
	dsdy := d / (camera depth).  " mm / mm ==> a scalar"
	resolution := aDistance * dsdy.
	^resolution.

]

{ #category : #access }
H3dViewPort >> scale [
	^scale ifNil: [ Error signal: 'This viewport`s scale has not been set yet.' ].
]

{ #category : #access }
H3dViewPort >> scale: measureNumerator per: measureDenominator [ 
	"Multiply camera screen coordinates by scale to get my coordinates."
	"Expect the numerator to be pixels 
	and the denominator to be a length that translates to SI length units."
	self assert: ( measureNumerator dimensions = ( 1 px ) dimensions ).
	self assert: ( measureDenominator dimensions = ( 1 centimeter 	) dimensions ).
	scale := measureNumerator / measureDenominator.
]
