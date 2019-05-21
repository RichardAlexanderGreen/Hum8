"
HumSurface is like a movable canvas - a rectangular 2D surface.
*** This class and its sub`s are inactive -- code retained from an experiment with Seaside. ***
*** NOTE: There is no TDD support for Hum-Seaside classes. ***

Instance Variables:
	(Values are HumMeasure - e.g. 'px' for pixels)
	top   <Number> -- top edge Y value                   (The values for edge positions are relative to the container.)
	bottom	<Number> -- bottom edge Y value
	left	  <Number> -- left edge X value
	right	<Number> -- right edge X value
		
	width	<Number> -- X extent
	height	<Number> -- Y extent
	layer	<Number> -- Z-order. Surfaces with higher layer numbers will overlay those with lower numbers.
		
	origin	<HumSurface> -- a zero-size object positioned at (left top layer) = ( 0 0 0 )
		(origin is private -- It provides syntax sugar.)
	shapes	<Set> -- A set of dependent (child) shapes. 
		The children are rendered after I am.
"
Class {
	#name : #HumSurface,
	#superclass : #Object,
	#instVars : [
		'top',
		'bottom',
		'left',
		'right',
		'origin',
		'width',
		'height',
		'layer',
		'id',
		'title',
		'shapes',
		'backgroundColor',
		'canvas',
		'borderColor',
		'fillColor',
		'defaultUnits'
	],
	#category : #'Hum-UI'
}

{ #category : #'as yet unclassified' }
HumSurface class >> humAttributes [
	"Set up standard attributes for the hum UI prolog."
	| dict |
	dict := OrderedCollection new.
	dict add: 'src' -> 'scripts/hum.js'.
	dict add: 'defer' -> 'defer'.
	^dict.
]

{ #category : #'as yet unclassified' }
HumSurface class >> humSurfaceAttributes [
	"Set up standard attributes for the hum UI prolog."
	| dict |
	dict := Dictionary new.
	dict at: 'src' put: 'scripts/humSurface.js'.
	dict at: 'defer' put: 'defer'.
	^dict.
]

{ #category : #'as yet unclassified' }
HumSurface class >> svgAttributes [
	"Will generate default attributes as follows:
	<svg 	xmlns='http://www.w3.org/2000/svg' 
			xmlns:xlink='http://www.w3.org/1999/xlink' 
			width='100%'
			height='100%'
			>
	Note: 100% width and height assumes that the actual size constraint 
	will be defined in an enclosing <div . . .> tag.		
	"
	| dict |
	"Return default attributes for the svg prolog as a list of associations."
	dict := Dictionary new.
	dict at: 'xmlns' put: 'http://www.w3.org/2000/svg'.
	dict at: 'xmlns:xlink' put: 'http://www.w3.org/1999/xlink'.
	dict at: 'width' put: '100%'.
	dict at: 'height' put: '100%'.
	^dict.
	
]

{ #category : #'render on canvas' }
HumSurface >> about [
"
Q: What is the relation between Sensor, Scribe, Widget, Canvas, Solid, ViewPort.
A: The Scribe interprets inputs from the Sensor and updates a Widget.
The Widget is drawn on a Canvas which is painted on a Surface.
A Surface might be painted on a Solid within a Scene.
Note: A Surface is not rendered if it is not visible to the Viewport`s Camera. 

The data-flow is Sensor >> Scribe >> Widget >> Canvas >> Surface >> ViewPort (Camera).
2016-11-01:
Sensor sends event to Scribe.
Scribe publishes to listeners.
Widget (listener) updates state and informs Canvas.
Canvas paints (raster) image.
Image is painted onto 3D surface texture..
Viewport maps 3D surface texture to viewport screen pixels.
"
"2016-11-01:
Canvas and Image are 2D anachronisms.
3D thinking: Text glyphs are 3D objects such as 
- paint film modeling brush strokes, 
- extruded 2D surfaces, 
- raised type face or tooled grooves,
- or something like neon tubes.
Revision:
Sensor sends event to subscribers.
Widget (subscriber) updates state and associated 3D shapes.
3D shape announces change.
VR pipeline updates viewports.
. 3D shapes become meshes.
. Texture is mapped onto 3D surfaces (3D magic) << This is also a kind of anachronism.
. Viewport pixels updated by simulated light rays.
"
]

{ #category : #accessing }
HumSurface >> addShape: aHumSurface [ 
	(self shapes) add: aHumSurface.
]

{ #category : #converting }
HumSurface >> asBillBoard [
	"Convert the surface to a thin HumBox, facing South, hung at eye-level."
	"Note: Dimensions given in pixels will be coverted to millimeters."
	| billboard zCanvas |
	billboard := HumSolid new.
	billboard
		id: 'billboard';
		length: 0.001;  "one millimeter thick"
		width: self width asMillimeters;    "Same as my width"
		height: self height asMillimeters;
		solidColor: self backgroundColor; 
		westEdge: self left asMillimeters; 
		northEdge: self layer asMillimeters;
		topEdge: (1.75 meter) + (top asMillimeters). "Hang at adult eye level"
	"Draw children, if any, on canvas"
	zCanvas := self canvas.
	(self shapes) 
		do: [ :shape |  
			"TODO: Position the part on the billboard"
			shape drawOn: zCanvas.
			].
	"Attach the canvas to the South face of the billboard."	
	billboard attachCanvas: zCanvas toFace: #North.
	^billboard.
		
]

{ #category : #'render as HTML' }
HumSurface >> asHTML [
	" Render surface as HTML"
	| myBlock html calc |
	calc := HumCalculator new.
	
	myBlock := [ self asHtmlCanvasOffsetX: (self left) y: (self top) ].
	html := calc xml: 'html' 
				with: [ (calc xml: 'head' 
					            with: [ calc xml: 'title' 
						                         with: ['Surface as HTML' ]
						                ]),
					      (calc xml: 'body'
					              with: [ myBlock value ])
					    ].
				
	^html.
]

{ #category : #'render as HTML' }
HumSurface >> asHtmlCanvasOffsetX: offsetX y: offsetY [
	"Return a HTML <rect . . . /> element for this surface."
	| xml canvasAttributes nextLayer viewX viewY calc |
	xml := String new.
	canvasAttributes := Dictionary new.
	( id notNil ) ifTrue: [ canvasAttributes add: 'id' -> id ].
	
	"Don't scale dimensions in this version"
	canvasAttributes at: 'width' put: width asString.
	canvasAttributes at: 'height' put: height asString.

	viewX := left + offsetX.
	viewY := top + offsetY.
	
	canvasAttributes at: 'x' put: viewX asString.
	canvasAttributes at: 'y' put: viewY negated asString.  "Flip our Y value because HTML has Y pointing down."
	canvasAttributes at: 'style' put: 'border:3px solid black;'.
	calc := HumCalculator new.
	xml := '  ', ( calc xml: 'canvas' dictionary: canvasAttributes ), String cr  .
	
	nextLayer := ''.
	(self shapes )
		do: [ :shape | 
			nextLayer := nextLayer, (shape asHtmlCanvasOffsetX: viewX y: viewY).
			].
	xml := xml, nextLayer.
	^xml. 
	
	
]

{ #category : #utility }
HumSurface >> asMeasure: aQuantity [
	| measure |
	( aQuantity isKindOf: HumMeasure )
		ifTrue: [ measure := aQuantity ].
	( aQuantity isKindOf: String ) 
		ifTrue: [ measure := HumMeasure fromString: aQuantity ].
	( aQuantity isKindOf: Number )
		ifTrue: [ 
			(self defaultUnits = '%')
				ifTrue: [ measure := HumMeasure quantity: aQuantity units: defaultUnits ]
				ifFalse: [ measure := aQuantity perform: (self defaultUnits asSymbol) ].
			].
		
	self assert: ( measure isKindOf: HumMeasure ).
	"Require internal consistency."
	self assert: ( measure units = (self defaultUnits)) description: ('Expecting ', defaultUnits, ' but got: ', measure units).
	
	^measure

]

{ #category : #'render on canvas' }
HumSurface >> asMorph [
	| result |
	result := self canvas formCanvas form asMorph.
	^result.
]

{ #category : #'render as SVG' }
HumSurface >> asSVG [
	"Generate the opening <svg . . . > element."
	| myBlock svg calc |
	
	myBlock := [ self asSvgRectOffsetX: (self left) y: (self top) ].
	calc := HumCalculator new.
	svg := calc xml: 'svg' dictionary: ( HumSurface svgAttributes ) with: myBlock.
	
	^svg.
]

{ #category : #'render as SVG' }
HumSurface >> asSvgRect [
	"Return a SVG <rect . . . /> element for this surface."
	| xml rectAttributes nextLayer calc |
	self delegated.
	xml := String new.
	rectAttributes := Dictionary new.
	( id notNil ) ifTrue: [ rectAttributes at: 'ID' put: id ].
	
	"TODO: Determine what SVG scale and transpose should be applied to this surface's rectangle."
	rectAttributes at: 'width' put: width asString.
	rectAttributes at: 'height' put: height asString.
	calc := HumCalculator new.
	xml := calc xml: 'rect' dictionary: rectAttributes .
	
	"TODO: Order the shapes by layer."
	nextLayer := ''.
	(self shapes )
		do: [ :shape | 
			nextLayer := nextLayer, shape asSvgRect.
			].
	xml := xml, nextLayer.
	^xml. 
	
	
]

{ #category : #'render as SVG' }
HumSurface >> asSvgRectOffsetX: offsetX y: offsetY [
	"Return a SVG <rect . . . /> element for this surface."
	| xml rectAttributes nextLayer viewX viewY calc |
	xml := String new.
	rectAttributes := Dictionary new.
	( id notNil ) ifTrue: [ rectAttributes at: 'ID' put: id ]. "TODO: CLEAN UP THIS HACK."
	
	"Don't scale dimensions in this version"
	rectAttributes at: 'width' put: width asString.
	rectAttributes at: 'height' put: height asString.

	( offsetX quantity = 0 ) ifTrue: [ viewX := left ] ifFalse: [ viewX := left + offsetX ].
	( offsetY quantity = 0 ) ifTrue: [ viewY := top  ] ifFalse: [ viewY := top  + offsetY ].

	rectAttributes at: 'x' put: viewX asString.
	rectAttributes at: 'y' put: viewY negated asString.  "Flip our Y value because SVG has Y pointing down."
	calc := HumCalculator new.
	xml := calc xml: 'rect' dictionary: rectAttributes .
	
	nextLayer := ''.
	(self shapes )
		do: [ :shape | 
			nextLayer := nextLayer, (shape asSvgRectOffsetX: viewX y: viewY).
			].
	xml := xml, nextLayer.
	^xml. 
	
	
]

{ #category : #'render as SVG' }
HumSurface >> asSvgViewBox [
	| attributes viewBoxAttribute space myBlock svg calc |
	"Set up standard attributes for the svg prolog."
	calc := HumCalculator new.
	space := $   asString.
	attributes := Dictionary new.
	attributes at: 'xmlns' put: 'http://www.w3.org/2000/svg'.
	attributes at: 'xmlns:xlink' put: 'http://www.w3.org/1999/xlink'.
	attributes at: 'width' put: '100%'.
	attributes at: 'height' put: '100%'.
	
	viewBoxAttribute := self left quantity asString, space, 
	                              self top quantity asString, space, 
	                              self width quantity asString, space, 
	                              self height quantity asString.
	attributes add: 'viewBox' -> viewBoxAttribute.
	
	myBlock := [ self asSvgRectOffsetX: 0 px y: 0 px.  ].
	
	svg := calc xmlOpen: 'svg' dictionary: attributes.
	svg := svg, '<g stroke="#001122" stroke-width="0.03" fill="ffeedd" >'.
	svg := svg, ( myBlock value).
	svg := svg, '</g>'.
	svg := svg, '</svg>'.
	^svg.
]

{ #category : #'render as XML' }
HumSurface >> asXML [
	| myBlock xml calc |
	
	myBlock := [ self asXMLRectOffsetX: (self left) y: (self top) ].
	calc := HumCalculator new.
	xml := calc xml: 'script' dictionary: ( HumSurface humSurfaceAttributes ) with: myBlock.
	
	^xml.
]

{ #category : #'render as XML' }
HumSurface >> asXMLRectOffsetX: offsetX y: offsetY [ 
	"Return a hum <surface . . . /> element for this surface."
	| xml rectAttributes nextLayer viewX viewY calc |
	xml := String new.
	rectAttributes := Dictionary new.
	( id notNil ) ifTrue: [ rectAttributes add: 'ID' -> id ].
	
	rectAttributes at: 'width' put: width asString.
	rectAttributes at: 'height' put: height asString.

	viewX := left + offsetX.
	viewY := top + offsetY.
	
	rectAttributes at: 'x' put: viewX asString.
	rectAttributes at: 'y' put: viewY asString.  
	calc := HumCalculator new.
	xml := calc xml: 'hum:surface' dictionary: rectAttributes .
	
	nextLayer := ''.
	(self shapes )
		do: [ :shape | 
			nextLayer := nextLayer, (shape asXMLRectOffsetX: viewX y: viewY).
			].
	xml := xml, nextLayer.
	^xml. 
	
	
]

{ #category : #accessing }
HumSurface >> backgroundColor [
	
	^ backgroundColor ifNil: [backgroundColor := Color gray ].
]

{ #category : #accessing }
HumSurface >> backgroundColor: aColor [
	"Set color to be used when background is rendered."
	self assert: (aColor isKindOf: Color).
	backgroundColor := aColor.
]

{ #category : #'accessing - bounds' }
HumSurface >> bbBottom [
	"Find my bounding box edge."
	| myEdge  |
	myEdge := self bbEdge: #bottom.
	^myEdge.
]

{ #category : #'accessing - bounds' }
HumSurface >> bbEdge: aSymbol [
	"Find my bounding box edge. 
	aSymbol names an edge."
	| myEdge  |
	self assert: ( { #bottom. #left. #right. #top. } includes: aSymbol ).
	myEdge := self perform: aSymbol.
	self shapes 
		do: [ :shape | 
				| otherEdge |
				otherEdge := (shape perform: aSymbol).
				( ({#right. #top.} includes: aSymbol ) and: [otherEdge > myEdge] ) ifTrue: [ myEdge := otherEdge ].
				( ({#left. #bottom.} includes: aSymbol ) and: [otherEdge < myEdge] ) ifTrue: [ myEdge := otherEdge ].
				].
	^myEdge.
]

{ #category : #'accessing - bounds' }
HumSurface >> bbHeight [
	"Find my bounding box edge."
	|  bbHeight |
	bbHeight := ((self bbTop) - (self bbBottom)) abs.
	^bbHeight.
]

{ #category : #'accessing - bounds' }
HumSurface >> bbLeft [
	"Find my bounding box edge."
	| myEdge  |
	myEdge := self bbEdge: #left.
	^myEdge.
]

{ #category : #'accessing - bounds' }
HumSurface >> bbRight [
	"Find my bounding box edge."
	| myEdge  |
	myEdge := self bbEdge: #right.
	^myEdge.
]

{ #category : #'accessing - bounds' }
HumSurface >> bbTop [
	"Find my bounding box edge."
	| myEdge  |
	myEdge := self bbEdge: #top.
	^myEdge.
]

{ #category : #'accessing - bounds' }
HumSurface >> bbWidth [
	"Find my bounding box edge."
	|  bbWidth |
	bbWidth := ((self bbRight) - (self bbLeft)) abs.
	^bbWidth.
]

{ #category : #accessing }
HumSurface >> borderColor [
	"What color is my border, ifany?"
	^borderColor ifNil: [ borderColor := Color black ].
]

{ #category : #accessing }
HumSurface >> bottom [
	^ bottom ifNil: [ self bottom: 0 meter ].
]

{ #category : #accessing }
HumSurface >> bottom: aNumber [
	"Reset the bottom edge."
	bottom := self asMeasure: aNumber.
	"Force top edge to be bottom + height"
	top := bottom + (self height).
]

{ #category : #'render on canvas' }
HumSurface >> canvas [
	"Attach a canvas - for placing drawings and images on the surface"
	^canvas ifNil:[ canvas := HumCanvas new ].
]

{ #category : #accessing }
HumSurface >> defaultUnits [
	^defaultUnits ifNil: [ defaultUnits := 'px' ].
	
]

{ #category : #accessing }
HumSurface >> defaultUnits: aSymbol [
	^defaultUnits := aSymbol.
	
]

{ #category : #'render on canvas' }
HumSurface >> drawOn: aHumCanvas [ 
	"Draw self on the given canvas."
	| polygon |
	self assert: (aHumCanvas isKindOf: HumCanvas).
	polygon := HumPolygon borderColor: (self borderColor) fillColor: (self fillColor).
	polygon
		addVertex: { left. top. };
		addVertex: { left. bottom. };
		addVertex: { right. bottom. };
		addVertex: { right. top. }.
	aHumCanvas drawPolygon: polygon scale: ((5 px)/(1 millimeter)). 
	
]

{ #category : #layout }
HumSurface >> expandToFit [
	|  |
	((self height) < (self bbHeight)) ifTrue: [self height: (self bbHeight)].
	((self width) < (self bbWidth)) ifTrue: [self width: (self bbWidth)].
	
]

{ #category : #accessing }
HumSurface >> fillColor [
	"What color is my fill, ifany?"
	^fillColor ifNil: [ fillColor := Color gray ].
]

{ #category : #converting }
HumSurface >> generateHumScript [
	"Proof of concept: Generate Hum code."
	| script space period |
	space := ' '.
	period := '.'.
	script := '. Painter: '.
	script := script, 'Paint surface with '.
	script := script, space, 'id', space, (self id) quoted.
	script := script, space, 'width', space, (self width) asString quoted.
	script := script, space, 'height', space, (self height) asString quoted.
	script := script, space, 'left', space, (self left) asString quoted.
	script := script, space, 'top', space, (self top) asString quoted.
	
	script := script, period.
	
	( self shapes )
		do: [ :shape | script := script, String cr, (shape generateHumScript ) ].
	
	^script.
]

{ #category : #accessing }
HumSurface >> height [
	"What is the height of this object?
	This is Y extent or length when surface is horizontal as seen on on table or document.
	This is Z extent or height when surface is vertical as seen on a billboard.
	The other dimensions are width and layer.
	NOTE: In this model, a HumSurface has no thickness.
	"
	^ height ifNil: [ self height: 0 meter ].
]

{ #category : #accessing }
HumSurface >> height: aNumber. [
	"Reset the distance between top and bottom edges."
	height := self asMeasure: aNumber.
	"Force the bottom to be the top minus the height."
	bottom := (self top) - height.
]

{ #category : #accessing }
HumSurface >> id [
	self assert: ( id isKindOf: String ).
	self assert: ( id notEmpty ).
	^ id
]

{ #category : #accessing }
HumSurface >> id: aString [ 
	id := aString.
]

{ #category : #accessing }
HumSurface >> initialize [
	self initialize: 'px'.
	
]

{ #category : #accessing }
HumSurface >> initialize: units [
	| zero unitOfMeasure |
	self assert: ( units isKindOf: String ).
	"Reset #pixel to #px as needed.
	In this case, the abbreviation is the preferred expression.
	"
	unitOfMeasure := units asString.
	(units = 'pixel') ifTrue: [ unitOfMeasure := 'px' ]. 
	(units = 'percent') ifTrue: [ unitOfMeasure := '%'].
	zero := HumMeasure quantity: 0.0 units: unitOfMeasure.
	self defaultUnits: (zero units).
	
	width := zero.
	left := zero.
	right := zero.
	
	height := zero.
	top := zero.
	bottom := zero.
	
	layer := zero.

]

{ #category : #accessing }
HumSurface >> layer [
	"What layer is the surface in?
	Surfaces with higher layer numbers will overlay (obscure) those with lower layer numbers.
	You should avoid overlapping surfaces in the same layer. The result is not deterministic.
	See also: #overlay:onTopOf:
	"
	"By default, a surface is in layer zero."
	^ layer ifNil: [ layer := 0 ].
]

{ #category : #accessing }
HumSurface >> layer: aNumber [
	layer := aNumber
]

{ #category : #accessing }
HumSurface >> left [
	^ left ifNil: [ self left: 0 meter ].
]

{ #category : #accessing }
HumSurface >> left: aNumber [
	| measure |
	measure := self asMeasure: aNumber.
	"Reset the left edge."
	left := measure.
	"Force the right edge to keep width constant."
	right := left + (self width).
]

{ #category : #accessing }
HumSurface >> origin [
	"a zero-size object positioned at ( left top layer ) = ( 0 0 0 )"
	
	^ origin ifNil: [ origin := HumSurface new.  ].
]

{ #category : #layout }
HumSurface >> overlay: aHumSurfaceB onTopOf: aHumSurfaceA [ 
	"Both shapes are assumed (forced) to be present in my collection."
	self addShape: aHumSurfaceA.
	self addShape: aHumSurfaceB.
	"By convention, surface B will be aligned with A's top and left edges."
	aHumSurfaceB top: (aHumSurfaceA top).	
	aHumSurfaceB left: (aHumSurfaceA left).
	"By convention, surface B will be placed in a higher numbered layer."
	"Note: If there already was already another shape on top and in same layer, 
	   there is no attempt to place this one in-between."
	aHumSurfaceB layer: (aHumSurfaceA layer) + 1.
	
]

{ #category : #layout }
HumSurface >> place: aHumSurfaceB above: aHumSurfaceA [ 
	"Place B above A on the surface. 
	(Not to be confused with putting B on a different layer.)"
	
	"Assure that A and B are in my collection."
	self addShape: aHumSurfaceA.
	self addShape: aHumSurfaceB.
	
	"By convention, set B's bottom will be equal to A's top.
	i.e. There is no gap."
	aHumSurfaceB bottom: ( aHumSurfaceA top ).
	
	"By convention, B is now in the same layer as A."
	aHumSurfaceB layer: ( aHumSurfaceA layer ).
	
	
]

{ #category : #layout }
HumSurface >> place: aHumSurface at: anArray [ 
	| x y z |
	x := anArray at: 1.
	y := anArray at: 2.
	z := anArray at: 3.
	
	self addShape: aHumSurface.
	aHumSurface top: y; left: x; layer: z.
]

{ #category : #layout }
HumSurface >> place: aHumSurfaceB below: aHumSurfaceA [ 
	"Place B below A on the surface. (Not to be confused with putting B on a different  layer.)"
	"TODO: Consider making calls to top: right: left: using blocks (closures) so that everything is dynamic.
	 Counter: Use relative positions. 
	          When rendering, we will iterate (self shapes). 
	          If child shape positions are relative, we get the same effect.
	"
	
	"Assure that A and B are in my collection."
	self addShape: aHumSurfaceA.
	self addShape: aHumSurfaceB.
	
	"By convention, set B's top to be equal to A's bottom.
	i.e. There is no gap."
	aHumSurfaceB top: ( aHumSurfaceA bottom ).
	
	"By convention, B is now in the same layer as A."
	aHumSurfaceB layer: ( aHumSurfaceA layer ).
	
	
]

{ #category : #layout }
HumSurface >> place: aHumSurfaceB leftOf: aHumSurfaceA [ 
	"Place B left of A on the surface. "
	
	"Assure that A and B are in my collection."
	self addShape: aHumSurfaceA.
	self addShape: aHumSurfaceB.
	
	"By convention, set B's left to be equal to A's right.
	i.e. There is no gap / gutter."
	aHumSurfaceB left: ( aHumSurfaceA right ).
	
	"By convention, B is now in the same layer as A."
	aHumSurfaceB layer: ( aHumSurfaceA layer ).
	
	
]

{ #category : #layout }
HumSurface >> place: aHumSurfaceB rightOf: aHumSurfaceA [ 
	"Place B right of A on the surface. "
	
	"Assure that A and B are in my collection."
	self addShape: aHumSurfaceA.
	self addShape: aHumSurfaceB.
	
	"By convention, set B's right to be equal to A's left.
	i.e. There is no gap / gutter."
	aHumSurfaceB left: ( aHumSurfaceA right ).
	
	"By convention, B is now in the same layer as A."
	aHumSurfaceB layer: ( aHumSurfaceA layer ).
	
	
]

{ #category : #accessing }
HumSurface >> right [
	^ right ifNil: [self right: 0 meter ].
]

{ #category : #accessing }
HumSurface >> right: aNumber [
	
	"Reset the right edge."
	right := self asMeasure: aNumber.
	"Force the left edge to keep the width constant."
	left := right - (self width).
]

{ #category : #accessing }
HumSurface >> shapes [
	"I remember the 2d objects placed on me."
	^ shapes ifNil: [ shapes := Set new. ].
]

{ #category : #accessing }
HumSurface >> title [
	^ title ifNil: [ self id ].
]

{ #category : #accessing }
HumSurface >> title: aString [
	title := aString.
	
]

{ #category : #accessing }
HumSurface >> top [
	^ top ifNil: [ top := 0 ].
]

{ #category : #accessing }
HumSurface >> top: aNumber [
	"Reset the top edge."
	top := self asMeasure: aNumber.
	"Force the bottom edge to keep the height constant."
	bottom := top - (self height).
]

{ #category : #accessing }
HumSurface >> width [
	^ width ifNil: [ self width: 0 meter. ]
]

{ #category : #accessing }
HumSurface >> width: anObject [
	"Reset the width. 
	This is the X extent in most contexts.
	See also: height and layer."
	width := self asMeasure: anObject.
	"Force the right edge to be consistent."
	right := (self left) + width.
]
