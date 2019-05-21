"
This ViewPort class is a wrapper on one or more 3D viewport implementations. 

It is intended for use with HumSurface and HumSolid objects.
Note that the dimensions and positions of those objects are HumMeasures.

Intended features:
- The view is 3D.
-- That means that the view will be affected by the ""camera"" (viewport) position.
-- The camera can be moved to effect pan, zoom, rotate, orbit.
-- If no camera position is given, the camera will be positioned automatically.

The basic intent of the Hum 3D package is to simplify the API.
Most 3D API seem overly complex because they mix scene and rendering. 
We wish to avoid that in Hum.
We would like to achieve the level of simplicity seen in VPython.
The strategy involves separating the scene description 
from the rendering logic.

The goal for HumViewPort: Provide a simple way to set-up and view 3D scenes. 
See: HumViewPortTests>>testV330DrawABox.
"
Class {
	#name : #HumViewPort,
	#superclass : #HumWidget,
	#instVars : [
		'scene',
		'camera',
		'projectionMode',
		'bounds',
		'pixelsPerMillimeter',
		'repaintBlock'
	],
	#category : #'Hum-UI'
}

{ #category : #'instance-creation' }
HumViewPort class >> onScene: aScene viaCamera: aCamera [
	"Create an instance attached to the given camera in the given scene." 
	| instance |
	self assert: (aScene isKindOf: HumScene).
	self assert: (aCamera isKindOf: HumCamera).
	self assert: (aScene parts includes: aCamera).
	instance := self new.
	instance scene: aScene; camera: aCamera.
	^instance.
	
	 
]

{ #category : #'as yet unclassified' }
HumViewPort class >> pxPerMillimeter [
	| px mm pxPer |
	mm := 1 millimeter.
	px := (7.0/900.0) inch.            "verticle = HumMeasure( 0.0001975555 meter ) "
	px := (11.25/1440.0) inch.  "horizontal = HumMeasure( 0.0001984375 meter )"
	pxPer := mm / px.              " 5.03937. . .  on my laptop"
	^pxPer quantity asInteger.    "Round to 5 px per mm"
]

{ #category : #render }
HumViewPort >> asMorph [
	| morph |
	morph := (self canvas) asMorph.
	self assert: (morph isKindOf: HumViewPortMorph ).
	morph viewPort: self.
	^morph.
]

{ #category : #accessing }
HumViewPort >> camera [
	"Which camera (in the scene)?"
	^camera ifNil: [ Error signal: 'Viewport needs a camera.' ]
]

{ #category : #accessing }
HumViewPort >> camera: aCamera [ 
	"Which camera (in the scene)?"
	self assert: ( aCamera isKindOf: HumCamera ).
	camera := aCamera.
]

{ #category : #projection }
HumViewPort >> cameraCanSeePolygon: aHumPolygon [ 
	"The camera can see the polygon 
		if . . . y/x and z/x angles for at least one point are within the camera`s field of view."
	aHumPolygon verticesDo: [ :x :y :z | 
		| answer |
		"Delegate to camera (HumCamera)"
		answer := self camera isPointInFieldOfView: { x. y. z. }.
		(answer) ifTrue: [ ^true. ].
		].
	^false.
	
]

{ #category : #events }
HumViewPort >> changed [
	super changed.
]

{ #category : #projection }
HumViewPort >> getPolygonsForSolids: aCollectionOfSolids [ 
	"Return polygons corresponding to the surfaces of the given solids."
	| polygons |
	polygons := OrderedCollection new.
	aCollectionOfSolids
		do: [ :solid | 
			| solidPolygons |
			solidPolygons := solid asPolygonsColorCoded.
			polygons addAll: solidPolygons.
			].
	"NOTE: These polygons are not transformed."
	^polygons.
]

{ #category : #projection }
HumViewPort >> getPolygonsForSolids: aCollectionOfSolids colorRule: aOneArgumentBlock [
	"Return polygons corresponding to the surfaces of the given solids."
	| polygons |
	polygons := OrderedCollection new.
	aCollectionOfSolids
		do: [ :solid | 
			| solidPolygons |
			solidPolygons := solid asPolygonsColoredBy: aOneArgumentBlock.
			polygons addAll: solidPolygons.
			].
	"NOTE: These polygons are not transformed."
	^polygons.
]

{ #category : #projection }
HumViewPort >> mapPolygonsFrom3Dto2D [
	"Each solid in the scene provides a collection of polygons with points in 3D scene coordinates. 
	Those polygons are translated into new polygons with points in 2D viewport coordinates."
	|   cameraSolids viewportPolygons     cameraPolygons culledPolygons sortedPolygons  transformedPolygons cameraTriangles |
	cameraSolids := self selectSolidsInFrontOfCamera.
	cameraPolygons := self getPolygonsForSolids: cameraSolids.
	cameraTriangles := OrderedCollection new.
	transformedPolygons := cameraPolygons collect: [ :polygon | self transformPolygonToCameraFrame: polygon ].
	culledPolygons := transformedPolygons select: [ :polygon |  self cameraCanSeePolygon: polygon  ].
	sortedPolygons := culledPolygons sort: [ :a :b | a northMostPoint  >  b northMostPoint ].
	viewportPolygons := self mapPolygonsToViewPort: sortedPolygons.

	'This works in simple scenes but simply fails when things get just a little more complex.
	What is needed is a kind of pixel matrix where each pixel includes depth (distance from camera) information.
	We could extend BitBlt and BitMap classes to get that effect - But their implementations are hidden behind primatives.
	Then, while painting, pixels that are closer in may overlay pixels that are farther out.'.
	'Of course, much of this might be obviated by delegating to an external 3D scene painter.'.
	 ^viewportPolygons.
]

{ #category : #projection }
HumViewPort >> mapPolygonsFrom3Dto2DcolorCoded [
	"Each solid in the scene provides a collection of polygons with points in 3D scene coordinates. 
	Those polygons are translated into new polygons with points in 2D viewport coordinates."
	| scenePolygons cameraPolygons viewportPolygons cameraDepth transformToCanvas2D |
	scenePolygons := OrderedCollection new.  "For debug?"
	cameraPolygons := OrderedCollection new.
	viewportPolygons := OrderedCollection new.
	
	((scene parts) reject: [ :part | part isKindOf: HumCamera])
		do: [ :solid |
			| solidPolygons |
			solidPolygons := solid asPolygonsColorCoded.
			solid resetColoring.
			( solidPolygons ) "Provides crude z-order - North to South ordering. See HumPolygon"
				do: [ :solidPolygon  | 
					| transformedPolygon  |
					"Project onto camera frustrum"
					transformedPolygon := self transformPolygonToCameraFrame:  solidPolygon.
					cameraPolygons add: transformedPolygon.
					].
			 ].
	cameraDepth := self camera depth.
	transformToCanvas2D := [ :x :y :z | self projectScenePoint: { x. y. z. } cameraDepth: cameraDepth ].
			"TODO: Cull faces that are behind the camera."
			"TODO: Sort faces to draw those that are far from camera under those that are close."
	(cameraPolygons sort: [:a :b | (a maxRsquared) > (b maxRsquared) ]) 
		do: [ :cameraPolygon |
			| viewportPolygon |
			viewportPolygon := HumPolygon copy: cameraPolygon withTransform: transformToCanvas2D.
			viewportPolygons add: viewportPolygon.
			].
	^viewportPolygons.
]

{ #category : #projection }
HumViewPort >> mapPolygonsToViewPort: aCollectionOfPolygons [ 
	"Map from 3D to 2D"
	| cameraDepth transformToCanvas2D viewportPolygons |
	viewportPolygons := OrderedCollection new.
	cameraDepth := self camera depth.
	transformToCanvas2D := [ :x :y :z | self projectScenePoint: { x. y. z. } cameraDepth: cameraDepth ].
	aCollectionOfPolygons
		do: [ :polygon |
					| viewportPolygon |
					viewportPolygon := HumPolygon copy: polygon withTransform: transformToCanvas2D.
					viewportPolygons add: viewportPolygon.
					 ].
	^viewportPolygons

]

{ #category : #projection }
HumViewPort >> mapToCanvas: aHumCanvas bounds: aRectangle [ 
	"Declare where to draw me. Drawing is defered. See . . ."
	self canvas: aHumCanvas.
	bounds := aRectangle.
	"TODO: These declarations should affect asMorph."
	
]

{ #category : #projection }
HumViewPort >> mapTrianglesFrom3Dto2D [
	"Each solid in the scene provides a collection of polygons with points in 3D scene coordinates. 
	Those polygons are translated into new polygons with points in 2D viewport coordinates."
	|   cameraSolids viewportPolygons     cameraPolygons culledPolygons sortedPolygons  transformedPolygons cameraTriangles |
	cameraSolids := self selectSolidsInFrontOfCamera.
	cameraPolygons := self getPolygonsForSolids: cameraSolids.    
	cameraTriangles := OrderedCollection new.
	cameraPolygons do: [ :quad | |triangles|  triangles := quad asTriangles. cameraTriangles addAll: triangles ].
	transformedPolygons := cameraTriangles collect: [ :polygon | self transformPolygonToCameraFrame: polygon ].
	culledPolygons := transformedPolygons select: [ :polygon |  self cameraCanSeePolygon: polygon  ].
	sortedPolygons := culledPolygons sort: [ :a :b | a meanRsquared  >  b meanRsquared ].
	viewportPolygons := self mapPolygonsToViewPort: sortedPolygons.
	^viewportPolygons.
]

{ #category : #render }
HumViewPort >> paintHumPolygon: aHumPolygon [ 
	"The HumPolygon may contain 3D points and specifies fill and border colors. 
	We project to 2D and draw on our form."
	|   aBorderWidth aBorderColor  aFillColor scaledVertices |
	aBorderWidth := 2.
	aBorderColor := aHumPolygon borderColor.
	aFillColor := aHumPolygon fillColor.
	scaledVertices := OrderedCollection new.
	aHumPolygon verticesDo: [ :x :y :z | scaledVertices add: (x@y) ].
	self formCanvas drawPolygon: scaledVertices fillStyle: aFillColor borderWidth: aBorderWidth borderColor: aBorderColor.
]

{ #category : #render }
HumViewPort >> paintScene [
	"Render solids in my scene as polygons projected onto my canvas."
	| flatPolygons aCanvas |
	"Solid faces are 3D polygons. Project to 2D viewport canvas."
	flatPolygons := self mapPolygonsFrom3Dto2D.
	aCanvas := self canvas.
	flatPolygons
		do: [ :polygon |
			self paintHumPolygon: polygon.
			 ].
	self repaint: [ self paintScene. ].
	'This works in simple scenes but easily fails when things get just a little more complex.
	What is needed is a kind of pixel matrix where each pixel includes depth (distance from camera) information.
	Then, while painting, pixels that are closer in may overlay pixels that are farther out.'.
	
]

{ #category : #render }
HumViewPort >> paintSceneAsTriangles [
	"Render solids in my scene as polygons projected onto my canvas."
	|  triangles aCanvas |
	"Solid faces are 3D polygons. Project to 2D viewport canvas."
	triangles := self mapPolygonsToTriangles.
	aCanvas := self canvas.
	triangles
		do: [ :triangle |
			self paintHumPolygon: triangle.
			 ].
	self repaint: [ self paintSceneAsTriangles. ]
	
]

{ #category : #render }
HumViewPort >> paintSceneColorCoded [
	"Render solids in my scene as polygons projected onto my canvas."
	^ self renderSceneAsTriangles. 
	
]

{ #category : #projection }
HumViewPort >> projectPolygon: aScenePolygon [ 
	"Return a new polygon with the points transformed into camera`s coordinate system."
	| transformedPolygon cameraDepth |
	"Initialize polygon colors"
	transformedPolygon := HumPolygon borderColor: aScenePolygon borderColor fillColor: aScenePolygon fillColor.
	"Get camera depth"
	cameraDepth := self camera depth.
	aScenePolygon 
		verticesDo: [ :x :y :z | 
			| cameraXYZ canvasXZ |
			cameraXYZ := self transformPointIntoCameraFrame: { x. y. z. }.
			canvasXZ := self projectScenePoint: cameraXYZ cameraDepth: cameraDepth.
			transformedPolygon addVertex: canvasXZ.
			].
	^transformedPolygon.
]

{ #category : #projection }
HumViewPort >> projectScenePoint: aViewPoint cameraDepth: aCameraDepth [
	"Translate from camera view coordinates (meters) to canvas coordinates (px)"
	| aCanvasPoint  sceneX sceneY sceneZ screenX screenY x y xOffset yOffset dxdy dzdy |
	self assert: (aViewPoint isKindOf: Array ).
	self assert: (aViewPoint size = 3).
	"Map East-West to x; North-South to y; Up-Down to z, Time to w."
	sceneX := aViewPoint at: 1.
	sceneY := aViewPoint at: 2.
	sceneZ := aViewPoint at: 3.
	
	dxdy := (sceneX / sceneY) quantity.  "East over North"
	dzdy := (sceneZ / sceneY) quantity.
	
	screenX :=  aCameraDepth * dxdy.
	screenY :=  aCameraDepth * dzdy.
	
	x := (screenX * (self scalePixelsPerMillimeter)) quantity rounded.
	y := (screenY * (self scalePixelsPerMillimeter)) quantity rounded.
	self assert: ( x isKindOf: Integer ).
	self assert: ( y isKindOf: Integer ).
	
	xOffset := self canvas formCanvas extent x // 2.
	yOffset := self canvas formCanvas extent y // 2.
	
	aCanvasPoint := ( xOffset + x )@(yOffset - y). "flip y"
	self assert: (aCanvasPoint isKindOf: Point).
	self assert: (aCanvasPoint x isKindOf: Integer).
	self assert: (aCanvasPoint y isKindOf: Integer).
	^aCanvasPoint.
]

{ #category : #projection }
HumViewPort >> projectionMode [
	"Map the scene polygons onto the viewport using orthogonal or perspective projection?"
	^ projectionMode ifNil: [ projectionMode := #perspective ]
]

{ #category : #projection }
HumViewPort >> projectionMode: aSymbol [ 
	self assert: (#( #orthographic #perspective ) includes: aSymbol ).
	projectionMode := aSymbol.
]

{ #category : #render }
HumViewPort >> renderScene [
	"Render solids in my scene as polygons projected onto my canvas."
	^self renderSceneAsTriangles.
	
]

{ #category : #render }
HumViewPort >> renderSceneAsTriangles [
		"Render solids in my scene as polygons projected onto my canvas."
	|  triangles aCanvas |
	"Solid faces are 3D polygons. Project to 2D viewport canvas."
	triangles := self mapTrianglesFrom3Dto2D.
	(triangles size < 1) ifTrue: [ Error signal: 'Nothing to see?' ].
	aCanvas := self canvas.
	triangles
		do: [ :polygon |
			self paintHumPolygon: polygon.
			 ].
	self repaint: [ self renderSceneAsTriangles ].
	'TODO: Find algorithm that maps 3D triangle (tesselation) to pixels
	while tracking depth (distance from camera) of 3D point
	so that near point pixels will overlap far point pixels'.
	
]

{ #category : #render }
HumViewPort >> renderSceneAsWireFrame [
	"Render solids in my scene as polygons projected onto my canvas."
	| flatPolygons aCanvas |
	"Solid faces are 3D polygons. Project to 2D viewport canvas."
	flatPolygons := self mapPolygonsFrom3Dto2D.
	aCanvas := self canvas.
	flatPolygons
		do: [ :polygon |
			aCanvas drawHumPolygon: polygon.
			 ].
	self repaint: [ self renderSceneAsWireFrame ].

	
	
]

{ #category : #render }
HumViewPort >> repaint [
	"Repaint using stored block."
	self assert: (repaintBlock notNil).
	self assert: (repaintBlock isKindOf: BlockClosure ).
	self canvas fillBackground.
	repaintBlock value.
]

{ #category : #render }
HumViewPort >> repaint: aBlock [
	"Which method to use when repainting?"
	repaintBlock := aBlock.
]

{ #category : #accessing }
HumViewPort >> scalePixelsPerMillimeter [
	^pixelsPerMillimeter ifNil: [ pixelsPerMillimeter := (5 px) / (1 millimeter) ].
]

{ #category : #drawing }
HumViewPort >> scalePoint: aScenePoint scaleRatio: pxPerMeter [ 
	"Return a x@y point by scaling the given scene point"
	| sceneX sceneY canvasX canvasY |
	((aScenePoint isKindOf: Array) or: [aScenePoint isKindOf: OrderedCollection])
		ifFalse: [ Error signal: 'Scene Point is not of expected type' ].
	sceneX := aScenePoint at: 1.
	sceneY := aScenePoint at: 2.
	( sceneX isPixels ) 
		ifTrue: [ "Already scaled."
			canvasX := sceneX quantity rounded. 
			canvasY := sceneY quantity rounded. 
			] 
		ifFalse: [ "Apply scale factor"
			canvasX := ( sceneX * pxPerMeter ) quantity rounded. 
			canvasY := ( sceneY * pxPerMeter ) quantity rounded.
			].
	
	
	^ canvasX @ canvasY.
	
	
]

{ #category : #accessing }
HumViewPort >> scene: aScene [ 
	self assert: (aScene isKindOf:  HumScene ).
	scene := aScene.
	scene addDependent: self.
]

{ #category : #accessing }
HumViewPort >> selectSolidsInFrontOfCamera [
	"Return collection of solids whose centers are in front of camera."
	| cameraSolids sceneSolids |
		cameraSolids := OrderedCollection new.  "solids with points transformed to camera coordinates"
	 "Explode each assembly to get constituent solids."
	sceneSolids := ((scene exploded) reject: [ :part | part isKindOf: HumCamera]).
	( sceneSolids ) 
		do: [ :solid |
			| centerInSceneFrame centerInCameraFrame |
			centerInSceneFrame := solid center.
			centerInCameraFrame := self transformPointIntoCameraFrame:  centerInSceneFrame.
			((centerInCameraFrame y) quantity > 0.0 ) 
				ifTrue: [ cameraSolids add: solid. ].
			 ].
	^cameraSolids.

]

{ #category : #projection }
HumViewPort >> transformPointIntoCameraFrame: aPoint3D [ 
	"Transform the point into the camera`s coordinate system."
	| sceneX sceneY sceneZ 
	cameraX cameraY cameraZ 
	translatedX translatedY translatedZ  
	rotatedX rotatedY rotatedZ  
	vectorDistance alpha beta  calc |
	calc := HumCalculator new.
	calc cases;
		when: [ aPoint3D isKindOf: Array ]
			then: [ 
				sceneX := aPoint3D at: 1.  "offset East"
				sceneY := aPoint3D at: 2.  "offset North"
				sceneZ := aPoint3D at: 3.  "offset Up" ];
		when: [ aPoint3D isKindOf: HumVector ]
			then: [ 
				sceneX := aPoint3D x.
				sceneY := aPoint3D y.
				sceneZ := aPoint3D z.			
				 ];
		otherwise: [ Error signal: 'aPoint3D not of expected type' ].
	
	"Translate"
	translatedX := sceneX - (camera eyeX).
	translatedY := sceneY - (camera eyeY).
	translatedZ := sceneZ - (camera eyeZ).
	"Rotate"
	vectorDistance := ((translatedX*translatedX) + (translatedY*translatedY) "+ (translatedZ*translatedZ)") sqrt.
	alpha := (translatedX quantity/ vectorDistance quantity) arcCos.  "rise over run"
	beta := alpha - (camera rotation).
	rotatedX := vectorDistance * (beta cos).
	rotatedY := vectorDistance * (beta sin).
	rotatedZ := translatedZ.	
	"Tilt"
	vectorDistance := ("(translatedX*translatedX) +" (rotatedY*rotatedY) + (rotatedZ*rotatedZ)) sqrt.
	alpha := (rotatedZ quantity /  vectorDistance quantity) arcSin. "rise over run"
	beta := alpha - (camera tilt).
	cameraX := rotatedX.
	cameraY := vectorDistance * (beta cos).
	cameraZ := vectorDistance * (beta sin).
	^HumVector newFrom: { cameraX. cameraY. cameraZ. }.
	
]

{ #category : #projection }
HumViewPort >> transformPolygonToCameraFrame: aScenePolygon [ 
	"Return a new polygon with the points transformed into camera`s coordinate system."
	| transformedPolygon cameraDepth |
	"Initialize polygon colors"
	transformedPolygon := HumPolygon parentSolid: aScenePolygon parentSolid fillColor: aScenePolygon fillColor.
	"Get camera depth"
	cameraDepth := self camera depth.
	aScenePolygon 
		verticesDo: [ :x :y :z | 
			| cameraXYZ  |
			cameraXYZ := self transformPointIntoCameraFrame: { x. y. z. }.
			transformedPolygon addVertex: cameraXYZ.
			].
	^transformedPolygon.
]

{ #category : #events }
HumViewPort >> update: anObject [ 
	"Something in my model has been changed."
	self assert: (anObject == scene).
	"Transcript cr; show: 'Scene changed.'."
	self repaint.
]

{ #category : #projection }
HumViewPort >> zmapPolygonsFrom3Dto2D [
	"Each solid in the scene provides a collection of polygons with points in 3D scene coordinates. 
	Those polygons are translated into new polygons with points in 2D viewport coordinates."
	|   cameraSolids viewportPolygons cameraDepth transformToCanvas2D  |
	cameraSolids := self selectSolidsInFrontOfCamera.
	viewportPolygons := OrderedCollection new. "Collect resulting 2D polygons"
	"Define the function we use to may from 3D to camera pixel point."
	cameraDepth := self camera depth.
	transformToCanvas2D := [ :x :y :z | self projectScenePoint: { x. y. z. } cameraDepth: cameraDepth ].
	"Paint distant objects before those that are near."
	( cameraSolids sorted: [ :aSolid :bSolid | aSolid rSquared < bSolid rSquared ] ) "Use R-squared to avoid taking square root."
		do: [ :cameraSolid |
			| cameraPolygons culledPolygons |
			cameraPolygons := cameraSolid polygons. "These HumPolygons were computed above."
			culledPolygons := (cameraPolygons select: [ :polygon |  polygon inFrontOfCamera  ] ).
			(culledPolygons sort: [ :a :b | a northMostPoint  >  b northMostPoint ])
				do: [ :culledPolygon |
					| viewportPolygon |
					viewportPolygon := HumPolygon copy: culledPolygon withTransform: transformToCanvas2D.
					viewportPolygons add: viewportPolygon.
					 ].
			 ].
	^viewportPolygons.
]

{ #category : #render }
HumViewPort >> zrenderScene [
	"Render solids in my scene as polygons projected onto my canvas."
	| flatPolygons aCanvas |
	"Solid faces are 3D polygons. Project to 2D viewport canvas."
	flatPolygons := self mapPolygonsFrom3Dto2D.
	aCanvas := self canvas.
	flatPolygons
		do: [ :polygon |
			self paintHumPolygon: polygon.
			 ].
	self repaint: [ self renderScene ].
	
]
