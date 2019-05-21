"
A Canvas is a surface on which to paint. (It is not interactive. See HumScribe)
HumCanvas provides a wrapper on an actual implementation.

The goal is to keep the API simple.
Where Canvas / FormCanvas / . . .  provide more than one way to accomplish the same thing, HumCanvas should provide just one.

Use Cases:
- Set and position brush:
- - canvas brush: aForm.  (TODO: Replace this with something that is not raster-based.)
- - canvas moveTo: aPoint. (Note: points are in pixel coordinates.)
- Draw lines.
- - canvas drawTo: aPoint. 
- Draw curves:
- - canvas drawCurve: aListOfPoints. 
- Draw and fill polygons.
- - drawPolygon: aPolygon.  (HumPolygon attributes include vertices, fill-color, border-color.)
- - drawPolygonBorderedPolygon: aPolygon. (Use current brush to draw border)
- Draw text.
- - drawText: aText. (Defaults to vector-based font, and round-nib pen.)
- - drawText: aText brush: aForm font: aVectorFont. 
- Paint images.
- - loadImageFromFileNamed: aFileName.
- - paintImageOnSurface: aHumSurface scale: pixelsPerMillimeter.
=========================
Consider possible future use cases:
- Enable canvas to be a 3D surface. 
- - I prefer parameterized design to hand-crafting.
- - Accordingly, I also prefer textures that are determined by a solid`s specified material and algorithmically painted rather then mapping from flat images.


"
Class {
	#name : #HumCanvas,
	#superclass : #DisplayObject,
	#instVars : [
		'brushPosition',
		'formCanvas',
		'brushColor',
		'pixelsPerMillimeter',
		'skyColor'
	],
	#classInstVars : [
		'canvas'
	],
	#category : #'Hum-UI'
}

{ #category : #'instance-creation' }
HumCanvas class >> extent: anExtent [ 
	"Create an instance with the give extent (pixel metrics)"
	| instance actualCanvas |
	instance := self new.
	actualCanvas := FormCanvas extent: anExtent depth: nil origin: 0@0 clipRect: (Rectangle origin: 0@0 extent: anExtent ).
	instance formCanvas:  actualCanvas.
	^instance.
	
]

{ #category : #'instance creation' }
HumCanvas class >> extent: anExtent depth: aDepth origin: anOrigin clipRect: aClipRectangle [
	"Create an instance with the given extent, origin, and clipping rectangle - given in pixel metrics."
	| internalCanvas instance |
	internalCanvas := FormCanvas extent: anExtent depth: aDepth origin: anOrigin clipRect: aClipRectangle.
	instance := self new.
	instance formCanvas: internalCanvas.
	^instance.
]

{ #category : #'instance creation' }
HumCanvas class >> onForm: aForm [ 
	"Create an instance using the given form."
	| instance |
	instance := self new.
	instance formCanvas: (FormCanvas on: aForm).
	^instance.
]

{ #category : #drawing }
HumCanvas >> about [
"
Q: What is the relation between Sensor, Scribe, Widget, Canvas, Solid, ViewPort.
A: The Scribe interprets inputs from the Sensor and updates a Widget.
The Widget is drawn on a Canvas which is painted on a Surface.
A Surface might be painted on a Solid within a Scene.
Note: A Surface is not rendered if it is not visible to the Viewport`s Camera. 

The flow is Sensor >> Scribe >> Widget >> Canvas >> Surface >> ViewPort (Camera)."
]

{ #category : #morph }
HumCanvas >> asMorph [
	| morph baseForm |
	"morph := self formCanvas form asMorph."
	baseForm :=  self formCanvas form.
	morph := HumViewPortMorph withForm: baseForm.
	morph isOpaque: true. 
	^morph.
	
]

{ #category : #drawing }
HumCanvas >> borderWidth: aWidth borderColor: aColor [ 
	self formCanvas form border: (formCanvas form boundingBox) width: aWidth fillColor: aColor.
]

{ #category : #drawing }
HumCanvas >> brushColor [
	"Get my brush color."
	
	^brushColor ifNil: [brushColor := Color black].
]

{ #category : #drawing }
HumCanvas >> brushColor: aColor [ 
	"Set my brush color."
	self assert: ( aColor isKindOf: Color ).
	brushColor := aColor.
]

{ #category : #drawing }
HumCanvas >> brushPosition [
	"Get my latest brush position."
	^brushPosition ifNil: [ Error signal: 'brush position has not been set' ]
]

{ #category : #drawing }
HumCanvas >> brushPosition: aPoint [ 
	"Remember my latest brush position."
	brushPosition := aPoint
]

{ #category : #'drawing-polygons' }
HumCanvas >> drawHumPolygon: aHumPolygon [ 
	"The HumPolygon contains 3D points  and specifies fill and border colors. 
	We translate to 2D and draw on our form."
	| polygonVertices  borderWidth aBorderColor firstPoint  |
	borderWidth := 3.  "TODO: MAGIC NUMBER."
	aBorderColor := aHumPolygon borderColor.
	self brushColor: aBorderColor.
	"aFillColor := aHumPolygon fillColor."
	"Transform to 2D points"
	polygonVertices := aHumPolygon xyPoints. 
	firstPoint := "self scaleScenePoint:" ( polygonVertices at: 1 ).
	self moveBrushTo: firstPoint.
	polygonVertices allButFirstDo: [ :vertex |
			| nextPoint |
			nextPoint := "self scaleScenePoint:" vertex.
			self paintTo: nextPoint.
			 ].
	self paintTo: firstPoint.
]

{ #category : #'drawing-polygons' }
HumCanvas >> drawPolygon: aHumPolygon scale: pxPerMeter [ 
	|  vertices  |
	self assert: ( aHumPolygon isKindOf: HumPolygon).
	self assert: ( pxPerMeter isKindOf: HumMeasure).
	
	self brushColor: aHumPolygon borderColor.
	vertices := aHumPolygon vertices.
	self moveBrushTo: ( self scalePoint: (vertices first) scaleRatio: pxPerMeter ).
	vertices allButFirstDo: [ :vertex |  self paintTo: (self scalePoint: vertex scaleRatio: pxPerMeter) ].
	self paintTo: ( self scalePoint: (vertices first) scaleRatio: pxPerMeter).

]

{ #category : #drawing }
HumCanvas >> drawTextLines: textLines withFont: aFont [
	| lineHeight em myCanvas |
	lineHeight := aFont height.
	em := aFont linearWidthOf: $m.
	myCanvas := (self formCanvas)."FormCanvas"
	textLines
		keysAndValuesDo: [ :key :value |
			| string |
			
			string:= "(key printPaddedWith: Character space to: 3 ), ' ', " value.
			myCanvas drawString: string at: em@(key*(lineHeight)) font: aFont color: (Color black). 
			].
]

{ #category : #access }
HumCanvas >> extent [
	"What is my height and width?"
	| extent |
	extent := self formCanvas extent.
	self assert: (extent isKindOf: Point).
	^extent.
	
]

{ #category : #drawing }
HumCanvas >> fillBackground [
	| rectangle fillColor |
	fillColor := self skyColor.
	rectangle := Rectangle origin: 0@0 extent: formCanvas  extent .
	"self formCanvas 
				frameAndFillRectangle: rectangle 
				fillColor: fillColor 
				borderWidth: 2 topLeftColor: fillColor bottomRightColor: fillColor."
	self formCanvas form fillWithColor: fillColor.

]

{ #category : #drawing }
HumCanvas >> formCanvas [ 
	"What form should I draw on."
	^formCanvas ifNil: [  formCanvas := FormCanvas on: (Form extent: DisplayScreen boundingBox extent depth: 32) ].
]

{ #category : #drawing }
HumCanvas >> formCanvas: aFormCanvas [ 
	"What form should I draw on."
	formCanvas := aFormCanvas.
	self fillBackground.
]

{ #category : #access }
HumCanvas >> height [
	"What is my height?"
	| extent height |
	extent := self extent.
	self assert: (extent isKindOf: Point).
	height := extent y.
	^height.
	
]

{ #category : #drawing }
HumCanvas >> moveBrushTo: aCanvasPoint [
	"Position the brush, but do not paint yet."
	|  |
	self assert: (aCanvasPoint isKindOf: Point).
	self brushPosition: aCanvasPoint.
	 
	
]

{ #category : #drawing }
HumCanvas >> paintTo: aCanvasPoint [ 
	self assert: (aCanvasPoint isKindOf: Point).
	"The point should be inside the canvas bounds. Rectangle"
	self assert: (self formCanvas clipRect containsPoint: aCanvasPoint ) 
	      description: 'Attempt to move brush beyond canvas: ', (aCanvasPoint asString).
	"TODO: Put pixels from brush onto my Form."
	self formCanvas line: self brushPosition to: aCanvasPoint width: 2 color: self brushColor.
	self brushPosition: aCanvasPoint.
]

{ #category : #drawing }
HumCanvas >> projectScenePoint: aScenePoint cameraDepth: aCameraDepth [
	"Translate from scene coordinates (meters) to canvas coordinates (px)"
	| aCanvasPoint  sceneX sceneY sceneZ screenX screenY x y xOffset yOffset dxdy dzdy |
	self assert: (aScenePoint isKindOf: Array ).
	self assert: (aScenePoint size > 1).
	"Map East-West to x; North-South to y; Up-Down to z, Time to w."
	sceneX := aScenePoint at: 1.
	sceneY := aScenePoint at: 2.
	sceneZ := aScenePoint at: 3.
	
	dxdy := (sceneX / sceneY) quantity.  "East over North"
	dzdy := (sceneZ / sceneY) quantity.
	
	screenX :=  aCameraDepth * dxdy.
	screenY :=  aCameraDepth * dzdy.
	
	x := (screenX * (self scalePixelsPerMillimeter)) quantity rounded.
	y := (screenY * (self scalePixelsPerMillimeter)) quantity rounded.
	
	xOffset := self formCanvas form width // 2.
	yOffset := self formCanvas form height // 2.
	aCanvasPoint := ( x + xOffset )@(y +  yOffset). 
	^aCanvasPoint.
]

{ #category : #drawing }
HumCanvas >> scalePixelsPerMillimeter [
	"How many pixels per millimeter of camera viewbox?"
	^ pixelsPerMillimeter ifNil: [ 4 ].
]

{ #category : #drawing }
HumCanvas >> scalePixelsPerMillimeter: aNumber [
	"How many pixels per millimeter of viewbox?"
	pixelsPerMillimeter := aNumber.
]

{ #category : #drawing }
HumCanvas >> scalePoint: aScenePoint scaleRatio: pxPerMeter [ 
	"Return a x@y point by scaling the given scene point"
	| sceneX sceneY canvasX canvasY |
	(((aScenePoint isKindOf: HumVector) 
		or: [aScenePoint isKindOf: Array])
		or: [aScenePoint isKindOf: OrderedCollection]
	)
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

{ #category : #drawing }
HumCanvas >> skyColor [
	"What color to use for background fill?"
	^ skyColor ifNil: [ skyColor := Color cyan lighter lighter  ]
]

{ #category : #drawing }
HumCanvas >> skyColor: aColor [
	"What color to use for background fill?"
	skyColor := aColor.
]

{ #category : #access }
HumCanvas >> width [
	"What is my width?"
	| extent width |
	extent := self extent.
	self assert: (extent isKindOf: Point).
	width := extent x.
	^width.
	
]
