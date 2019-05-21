"
HumBox is designed to facilitate layout.
It has boundaries called Edges. 
The boundary metrics provide position and extent information.

HumBox coordinates are { East. North. Up. } .
X-Y plane is plan view projection. 
X-Z plane is front view projection.

Box-like (enclosing box) objects may be positioned adjacent to each other.
A HumAssembly is a container that may hold other boxes.

Use the subtype HumSolid to model 3D scene objects such as rooms, walls, doors, and windows.

Although the term Box might might not seem to map well to hollow objects such as rooms, doors, and windows,
you can think of those things as boxes that happen to be hollow or filled with air.

The coordinate system is geographic and rectilinear.

Any unit of measure may be used. 
You may use meters, feet, cm, mm
whatever you feel comfortable with 
and suits the domain you are modeling.
If an ordinary number is given as a dimension,
 it will be assumed to be in meters.

Note: Hum scene dimensions are plan view: 
. X points East. 
. Y points North. 
. Z points up.
Instance Variables:

	length	<Number> y 
	width	<Number> x
	height	<Number> z
	""By convention length is North-to-South, width is East-to-West, and height is Top-to-Bottom.""
	
	eastEdge	<Number> x
	westEdge	<Number> x
	northEdge	<Number> y
	southEdge	<Number> y
	topEdge	    <Number> z
	bottomEdge	<Number> z
		
	origin	<HumBox>

"
Class {
	#name : #HumBox,
	#superclass : #Object,
	#instVars : [
		'length',
		'width',
		'height',
		'topEdge',
		'bottomEdge',
		'eastEdge',
		'westEdge',
		'northEdge',
		'southEdge',
		'origin',
		'velocity',
		'id',
		'solidColor',
		'rotation',
		'tiltUpDown',
		'polygons',
		'equationOfMotion',
		'colorStream',
		'centerX',
		'centerY',
		'centerZ'
	],
	#category : #'Hum-UI'
}

{ #category : #accessing }
HumBox class >> id: aString [ 
	"Instantiate an instance with these parameters"
	| instance |
	instance := self basicNew.
	instance initialize.  "Initialize everything to zero."
	instance id: aString.
	^instance.
]

{ #category : #'as yet unclassified' }
HumBox class >> id: aString  height: aHeight width: aWidth depth: aLength [ 
	"instantiate with these parameters"
	| instance |
	^self id: aString  height: aHeight width: aWidth length: aLength .
]

{ #category : #accessing }
HumBox class >> id: aString  height: aHeight width: aWidth length: aLength [ 
	"Instantiate an instance with these parameters"
	| instance |
	instance := self basicNew.
	instance initialize.  "Initialize everything to zero."
	instance id: aString  height: aHeight width: aWidth depth: aLength.
	^instance.
]

{ #category : #'accessing - edges' }
HumBox >> aboutEdges [
	^'WARNING: The set/get methods for edges assume a default orientation.'.
]

{ #category : #polygons }
HumBox >> addPolygon: aHumPolygon [ 
	(self polygons) add: aHumPolygon
]

{ #category : #'render as Three.js' }
HumBox >> asCamelCase [
	"Return identifier as a camelcase string."
	^ (self id asCamelCase uncapitalized ).
]

{ #category : #private }
HumBox >> asMeasure: aQuantity [
	"Convert string/number/measure to a measure. (default unit is meter)"
	| measure |
	( aQuantity isKindOf: HumMeasure )
		ifTrue: [ measure := aQuantity ].
	( aQuantity isKindOf: String ) 
		ifTrue: [ measure := HumMeasure fromString: aQuantity ].
	( aQuantity isKindOf: Number )
		ifTrue: [ measure := HumMeasure quantity: aQuantity units: 'meter' ].
	self assert: ( measure isKindOf: HumMeasure ).
	^measure

]

{ #category : #'render as Three.js' }
HumBox >> asThreeJS [
	"Render this as a box in Three.js"
	| js template dictionary calc |
	"Note: Caller must merge this into a scene or group geometry"
	template := '
			var @ID = new THREE.Mesh( ( new THREE.CubeGeometry( @width, @length, @height   )  )
			                            , ( new THREE.MeshBasicMaterial( { transparent: true } )  )
			                            );
			@ID.position.set( @x, @y, @z );
			'. 
	dictionary := Dictionary new.
	dictionary
	  at: 'ID' put: (self asCamelCase );
	  at: 'width'  put: ( self mm: width  );
	  at: 'length' put: ( self mm: length );
	  at: 'height' put: ( self mm: height );
		at: 'x' put: (self mm: #centerX );
		at: 'y' put: (self mm: #centerY );
		at: 'z' put: (self mm: #centerZ ).
	calc := HumCalculator new.
	js := calc fillTemplate: template fromDictionary: dictionary.
	^js. 
]

{ #category : #'render as X3D' }
HumBox >> asX3D [
	"Return a string in X3D notation representing this box / thing.
	Caller is responsible for embedding this in a scene.
	"
	|  x3d calc space position extent |
	space := String space.	
	position := Dictionary new.
	position at: 'translation' put: ( self x3dCenter ).
	extent := Dictionary new.
	extent at: 'size' put: ( self x3dExtent ).
	calc := HumCalculator new.
	x3d := calc xml: 'transform' dictionary: position 
						   with: [ calc xml: 'box' dictionary: extent ].
  "TODO: Subtypes may add appearance and/or material elements"							
	^x3d.
]

{ #category : #'accessing - edges' }
HumBox >> bottomEdge [
	^ bottomEdge
]

{ #category : #'accessing - edges' }
HumBox >> bottomEdge: aQuantity [
	"WARNING: Assumes the box has default orientation."
	| measure |
	measure := self asMeasure: aQuantity.

	"Reset the bottom edge"
	bottomEdge := measure.
	"Force the top "
	topEdge := bottomEdge + height.
]

{ #category : #geometry }
HumBox >> center [
	"Center of box (and/or center of bounding box) -- { x y z } = { east north up }"
	| position |
	"Compute my center coordinates - { east. north. up }"
	position := HumVector newFrom: { self centerX.  self centerY.  self centerZ. }.
	^position.
	
	
]

{ #category : #'move slide rotate tilt' }
HumBox >> centerAt: a3Vector [ 
	"Center myself at the given coordinates. { east. north. up. }
	Note: Those coordinates are relative to my container`s origin."
	| eastOffset northOffset topOffset |
	eastOffset  := self asMeasure: (a3Vector x).
	northOffset := self asMeasure: (a3Vector y).
	topOffset   := self asMeasure: (a3Vector z).
	
	"Compute new edge positions to center aBox at those coordinates relative to my origin."
	"TODO: This does not provide pitch, yaw, roll."
	self eastEdge:   ( eastOffset  + ( ( self width  ) * 0.5 ) ).
	self northEdge: ( northOffset + ( ( self length ) * 0.5 ) ).
	self topEdge:    ( topOffset    + ( ( self height ) * 0.5 ) ).
	
	
]

{ #category : #geometry }
HumBox >> centerX [
	"X axis points East"
 	^(self westEdge + ( (self width ) * 0.5 )).
]

{ #category : #geometry }
HumBox >> centerY [
	"Y dimension points North"
 	^( self southEdge + ( (self length ) * 0.5 ) ).
]

{ #category : #geometry }
HumBox >> centerZ [
	"Z dimension points up."
 	^( self bottomEdge + ( (self height ) * 0.5 )  ).
]

{ #category : #events }
HumBox >> changed [
	"Notify my rendering engine that I am changed."
	| comma |
	"Notify my dependents."
	super changed.
	"x,y,z are HumMeasure"
	comma := ', '.
	"Transcript cr; 
		show: 'id: ', self id, '(x,y,z): ', self centerX quantityAsString, comma, self centerY quantityAsString, comma, self centerZ quantityAsString;
		show: ' (rot,tilt): ', self rotation asString, comma, self tilt asString."
]

{ #category : #'accessing - dimensions' }
HumBox >> depth [
  "synonym"
	^ length.
]

{ #category : #'accessing - dimensions' }
HumBox >> depth: aHumMeasure [ 
	"synonym"
	self length: aHumMeasure.
]

{ #category : #'accessing - edges' }
HumBox >> eastEdge [
	^ eastEdge
]

{ #category : #'accessing - edges' }
HumBox >> eastEdge: aQuantity [
	| measure |
	measure := self asMeasure: aQuantity.

	"Reset the East edge."
	eastEdge := measure.
	"Force the West edge."
	westEdge := eastEdge - width.
	
]

{ #category : #geometry }
HumBox >> equationOfMotion [
	"The equation-of-motion should be a block with args: box and time"
	equationOfMotion 
			ifNil: [ self equationOfMotion: [ :box :time | box centerAt: (box center) + (velocity*time) ] ].
	^equationOfMotion.
]

{ #category : #geometry }
HumBox >> equationOfMotion: fcSelfAndTime [
	"The equation-of-motion should be a block with args: box and time"
	self assert: ( fcSelfAndTime isKindOf: BlockClosure ).
	self assert: ( fcSelfAndTime numArgs = 2 ).
	equationOfMotion := fcSelfAndTime.
]

{ #category : #access }
HumBox >> exploded [
	^{ self }.
]

{ #category : #'accessing - dimensions' }
HumBox >> height [
	"Get the height. By convention, height runs up and down."

	^ height
]

{ #category : #'accessing - dimensions' }
HumBox >> height: aQuantity [
	"Reset the up-down dimension."
	| measure |
	measure := self asMeasure: aQuantity.

	height := measure.
	self assert: ( height quantity >= 0.0 ).
	"Hold botton steady and force the top."
	topEdge := bottomEdge + height.
]

{ #category : #geometry }
HumBox >> id [
	"Identifier used in rendering context"
	^ id ifNil: [ id := self identityHash printString ].
]

{ #category : #geometry }
HumBox >> id: aString [
	"Identifier used in rendering contexts"
	id := aString.
]

{ #category : #geometry }
HumBox >> id: aString height: aHeight width: aWidth depth: aDepth [ 
	"synonym"
	^ self id: aString height: aHeight width: aWidth length: aDepth.
]

{ #category : #geometry }
HumBox >> id: aString height: aHeight width: aWidth length: aLength [ 
	self initialize;
	     id: aString; 
	     height: aHeight; 
	     width: aWidth; 
	     length: aLength.
]

{ #category : #geometry }
HumBox >> initialize [
	"Set dimensions to zero."
	| zero |
	"By convention length is North-South, width is East-West, and height is top-bottom."
	"X: East is +. West is -."
	"Y: North is +. South is -."
	"Z: Up is +. Down is -."
	"Default system of metrics is MKS (Meters, Kilograms, Seconds)"
	zero := 0 meter.
	length := zero.
	width := zero.
	height := zero.
	"Velocity vector = (northward, eastward, upward)"
	self velocity: (HumVector newFrom: { 0 mps. 0 mps. 0 mps. }).
	"Position edges at zero."
	bottomEdge := zero.
	topEdge := zero.
	eastEdge := zero.
	westEdge := zero.
	northEdge := zero.
	southEdge := zero.

]

{ #category : #stepping }
HumBox >> jump: aTime [
	self assert: (aTime isKindOf: HumMeasure).
	"Evaluate my equationOfMotion"
	self equationOfMotion value: self value: aTime.
	"TODO: Can we make this compatible with HumSimulator?"
	
]

{ #category : #'accessing - dimensions' }
HumBox >> length [
	"Get the length. By convention, length runs North and South."

	^ length
]

{ #category : #'accessing - dimensions' }
HumBox >> length: aQuantity [
	"set North-South dimension"
	| measure |
	measure := self asMeasure: aQuantity.

	"Reset the length. By convention, length runs North and South."
	self assert: ( measure quantity >= 0.0 ).

	length := measure.
	"Hold South steady and force the North."
	northEdge := southEdge + length.
]

{ #category : #private }
HumBox >> mm: aMeasure [
	"Format this measure to 3 digits accuracy - i.e. millimeter accuracy"
	( aMeasure isKindOf: HumMeasure )
			ifTrue: [^ aMeasure quantity printShowingDecimalPlaces: 3.].
	( aMeasure isKindOf: Symbol )
			ifTrue: [ |measure|
				measure := self perform: aMeasure.
				^ measure quantity printShowingDecimalPlaces: 3. ].
			self fail.
	
]

{ #category : #private }
HumBox >> mmShave: aMeasure [
	"Format this measure to 3 digits accuracy - i.e. millimeter accuracy.
	But first shave a millimeter from both ends."
	^ (aMeasure - (2 millimeter)) quantity printShowingDecimalPlaces: 3.
]

{ #category : #coloring }
HumBox >> nextColor [
	 "Select from a sequence of colors. Enables reproducable result."
	| colorSequence  nextColor |
	colorStream 
		ifNil: [ colorSequence := { Color red. Color orange. Color yellow. Color green. Color blue. Color purple. }.
			
			colorStream := ReadStream on: colorSequence.  
			].
	(colorStream atEnd) ifTrue: [ colorStream position: 0 ].
	nextColor := colorStream next.
	^nextColor.
		
]

{ #category : #'accessing - edges' }
HumBox >> northEdge [
	^ northEdge
]

{ #category : #'accessing - edges' }
HumBox >> northEdge: aQuantity [
	| measure |
	measure := self asMeasure: aQuantity.


	"Reset North edge."
	northEdge := measure.
	"Hold North steady and force South."
	southEdge := northEdge - length.
]

{ #category : #private }
HumBox >> origin [
	"Origin is always a zero-sized object at (0 0 0)."
	^ origin ifNil: [ origin := HumBox new.  ].
]

{ #category : #polygons }
HumBox >> polygons [
	"TODO: DANGER -- asPolygons is not defined in this supertype."
	^ polygons ifNil: [ polygons := self asPolygonsColoredBy: [ self color ] ].
]

{ #category : #polygons }
HumBox >> polygons: aCollection [ 
	"Computed polygons *may* be stored here."
	polygons := aCollection.
]

{ #category : #geometry }
HumBox >> printOn: aStream [
	"Append to the argument, aStream, a sequence of characters that  
	identifies the receiver."

	| title |
	title := self class name.
	aStream
		nextPutAll: (title first isVowel ifTrue: ['an '] ifFalse: ['a ']);
		nextPutAll: title;
		nextPutAll: '(', self id,')'.
]

{ #category : #geometry }
HumBox >> rSquared [
	"How far am I from the origin? Use R-squared of my centroid as metric."
	| cx cy cz rSquared |
	cx := self centerX.
	cy := self centerY.
	cz := self centerZ.
	rSquared := (cx*cx) + (cy*cy) + (cz*cz).
	^rSquared.
]

{ #category : #coloring }
HumBox >> resetColoring [
	self nextColor.
	colorStream position: 0.
]

{ #category : #'move slide rotate tilt' }
HumBox >> rotateLeft: angleInDegrees [
	"Set rotation (yaw) in scene coordinates - Note: This is not additive."
	self rotationDegrees: angleInDegrees.
]

{ #category : #'move slide rotate tilt' }
HumBox >> rotatePolygons: inputPolygons [ 
	"Correct the polygons for my rotation (yaw)."
	| resultPolygons centerX centerY  |
	centerX := self centerX.
	centerY := self centerY.
	resultPolygons := OrderedCollection new.
	inputPolygons 
		do: [ :polygon |
			| resultPolygon |
			resultPolygon := HumPolygon borderColor: polygon borderColor fillColor: polygon fillColor.
			resultPolygon parentSolid: self.
			resultPolygons add: resultPolygon.
			polygon verticesDo: [  :x :y :z |
				| alpha beta distance relativeX relativeY rotatedX rotatedY |
				relativeX := x - centerX.
				relativeY := y - centerY.
				alpha := relativeY arcTan: relativeX.
				beta := alpha + (self rotation).
				distance := ((relativeX*relativeX) + (relativeY*relativeY)) sqrt.
				rotatedX := (distance * ( beta cos ) )+ centerX.
				rotatedY := (distance * ( beta sin ) ) + centerY.
				resultPolygon addVertex: { rotatedX. rotatedY. z. }.
				 ].
			].
	^resultPolygons.
]

{ #category : #'move slide rotate tilt' }
HumBox >> rotateRight: angleInDegrees [
	"Set rotation (yaw) in scene coordinates - Note: This is not additive."
	self rotationDegrees: angleInDegrees negated.
]

{ #category : #'move slide rotate tilt' }
HumBox >> rotation [
	"Get my rotation (yaw) in scene coordinates as a value expressed in radians "
	| |
	^rotation ifNil: [ rotation := 0.0 ].
	
]

{ #category : #'move slide rotate tilt' }
HumBox >> rotation: angle [
	"Set my rotation (yaw) in scene coordinates as a value expressed in radians "
	| calc |
	calc := HumCalculator new.
	calc cases;
		when: [ angle isKindOf: Float ] 
			then: [ rotation := angle ];
		when: [( angle isKindOf: HumMeasure ) and: [ angle units = #radian ] ] 
			then: [ rotation := angle quantity ];
		otherwise: [ Error signal: 'angle not in expected units' ].
	self changed.
	
]

{ #category : #'move slide rotate tilt' }
HumBox >> rotationDegrees: angle [
	"Set my rotation (yaw) angle in scene coordinates. "
	| calc |
	calc := HumCalculator new.
	calc cases;
		when: [ (angle isKindOf: HumMeasure) and: [angle units = #radian] ] 
			then: [ self rotation: ( self rotation )+( angle quantity). ];
		when: [ (angle isKindOf: HumMeasure) and: [angle units = #degree] ] 
			then: [ self rotation: ( self rotation )+( angle quantity degreesToRadians ). ];
		when: [ angle isKindOf: Float ]
			then: [ self rotation: (self rotation) + angle ]; 		"Assume radian angle."
		otherwise: [ Error signal: 'angle not in expected units' ].
	self changed.
 
]

{ #category : #'move slide rotate tilt' }
HumBox >> slideBackward: aHumMeasure [ 
	"Slide in the South direction - TODO: adjust for camera rotation."
	self slideForward: ( aHumMeasure negated ).
]

{ #category : #'move slide rotate tilt' }
HumBox >> slideDown: aHumMeasure [ 
	"Move box (e.g. camera) up or down in the scene coordinates."
	self topEdge: (self topEdge) - aHumMeasure.
	"TODO: Refactor to make this work in camera coordinates - corrected for rotation and tilt."
	self changed.
]

{ #category : #'move slide rotate tilt' }
HumBox >> slideForward: aHumMeasure [ 
	"Slide in the North direction - TODO: adjust for camera rotation."
	self southEdge:  ( self southEdge ) + aHumMeasure.
	self changed.
]

{ #category : #'move slide rotate tilt' }
HumBox >> slideLeft: aHumMeasure [ 
	^self slideRight: (aHumMeasure negated).
]

{ #category : #'move slide rotate tilt' }
HumBox >> slideRight: aHumMeasure [ 
	"Move camera left or right --- TODO: Correct this for camera orientation."
	self westEdge: (self westEdge) + aHumMeasure.
	self changed.
]

{ #category : #'move slide rotate tilt' }
HumBox >> slideUp: aHumMeasure [ 
	^self slideDown: (aHumMeasure negated).
]

{ #category : #geometry }
HumBox >> solidColor: aColor [
	"What color should be used to render box or bounding-box in a view?"
	self assert: (aColor isNil or: [aColor isKindOf: Color]).
	solidColor := aColor.
]

{ #category : #'accessing - edges' }
HumBox >> southEdge [
	^ southEdge
]

{ #category : #'accessing - edges' }
HumBox >> southEdge: aQuantity [
	| measure |
	measure := self asMeasure: aQuantity.

	"Reset the South edge."
	southEdge := measure.
	"Force North edge."
	northEdge := southEdge + length.
]

{ #category : #'move slide rotate tilt' }
HumBox >> tilt [
	"Get my tilt (pitch) in scene coordinates as a value expressed in radians.
	Positive value is an upward tilt. "
	^tiltUpDown ifNil: [ tiltUpDown := 0.0. ].
	
]

{ #category : #'move slide rotate tilt' }
HumBox >> tilt: tiltInRadians [
	"Set my tilt (pitch) in scene coordinates as a value expressed in radians.
	Positive value is an upward tilt. "
	| |
	self assert: (tiltInRadians isKindOf: Float).
	tiltUpDown := tiltInRadians.
	self changed.
	
]

{ #category : #'move slide rotate tilt' }
HumBox >> tiltDegrees: angleInDegrees [
	"Set my tilt (pitch) angle in scene coordinates. "
	| |
	(angleInDegrees isKindOf: HumMeasure)
		ifTrue: [ ^self tilt: ( self tilt ) + ( angleInDegrees quantity degreesToRadians )  ].
	"Otherwise:"
	self tilt: ( self tilt ) + ( angleInDegrees degreesToRadians ).
]

{ #category : #'move slide rotate tilt' }
HumBox >> tiltDown: angleInDegrees [
	"Set tilt  (pitch)  in scene coordinates - Note: This is not additive."
	self tiltDegrees: angleInDegrees negated.
]

{ #category : #'move slide rotate tilt' }
HumBox >> tiltPolygons: inputPolygons [ 
	"Correct the polygons for my tilt (pitch)."
	| resultPolygons  centerY  centerZ |
	(self tilt = 0) ifTrue: [ ^inputPolygons ].
	centerY := self centerY.
	centerZ := self centerZ.
	resultPolygons := OrderedCollection new.
	inputPolygons 
		do: [ :polygon |
			| resultPolygon |
			resultPolygon := HumPolygon borderColor: polygon borderColor fillColor: polygon fillColor.
			resultPolygon parentSolid: self.
			resultPolygons add: resultPolygon.
			polygon verticesDo: [  :x :y :z |
				| alpha beta distance  relativeY relativeZ  tiltY tiltZ |
				relativeY := y - centerY.
				relativeZ := z - centerZ.
				alpha := relativeY arcTan: relativeZ. "Float>>arcTan"
				beta := alpha + (self tilt).
				distance := ( (relativeY*relativeY) + (relativeZ*relativeZ) ) sqrt.
				tiltY := ( distance * ( beta cos  ) ) + centerY.
				tiltZ := ( distance * ( beta sin ) ) + centerZ.
				resultPolygon addVertex: { x. tiltY. tiltZ. }.
				 ].
			].
	^resultPolygons.
]

{ #category : #'move slide rotate tilt' }
HumBox >> tiltUp: angleInDegrees [
	"Set tilt (pitch) in scene coordinates - Note: This is not additive."
	self tiltDegrees: angleInDegrees.
]

{ #category : #'accessing - edges' }
HumBox >> topEdge [
	^ topEdge
]

{ #category : #'accessing - edges' }
HumBox >> topEdge: aQuantity [
	| measure |
	measure := self asMeasure: aQuantity.


	"Reset the top edge."
	topEdge := measure.
	"Force the bottom edge."
	bottomEdge := topEdge - height.
]

{ #category : #geometry }
HumBox >> velocity: aHumVector [
	"What is the 3D object`s current velocity?"
	self assert: (aHumVector isKindOf: HumVector).
	self assert: (aHumVector dimensions = (1.0 meterPerSecond dimensions) ).
	velocity := aHumVector.
]

{ #category : #'accessing - dimensions' }
HumBox >> volume [
	"Calculate the volume"
	| v |
	v := (self height) * (self width) * (self length).
	"TODO: This should be a HumMeasure with dimension of L^3"
	^v.
]

{ #category : #'accessing - edges' }
HumBox >> westEdge [
	^ westEdge
]

{ #category : #'accessing - edges' }
HumBox >> westEdge: aQuantity [
	| measure |
	measure := self asMeasure: aQuantity.


	"Reset the West edge."
	westEdge := measure.
	"Force the East edge."
	eastEdge := westEdge + width.
]

{ #category : #'accessing - dimensions' }
HumBox >> width [
	"Get the width. By convention, the width runs East and West."

	^ width
]

{ #category : #'accessing - dimensions' }
HumBox >> width: aQuantity [
	"Reset the East-West dimension"
	| measure |
	measure := self asMeasure: aQuantity.

	self assert: (measure quantity >= 0.0 ).

	width := measure.
	"Hold West edge steady and force the East edge."
	eastEdge := westEdge + width.
]

{ #category : #'render as X3D' }
HumBox >> x3dCenter [
	"Center of box (and/or center of bounding box) -- { x y z }
	Note: This needs to map Hum coordinates to X3D coordinates.
	"
	| s |
	"X"
	s := ( self westEdge + ( (self width ) * 0.5 ) ) quantity asString.
	"Y"
	s := s, ' ', ( self southEdge + ( (self length ) * 0.5 ) ) quantity asString.
	"Z"
	s := s, ' ', ( self bottomEdge + ( (self height ) * 0.5 ) ) quantity asString.
	^s
	
	
]

{ #category : #'render as X3D' }
HumBox >> x3dExtent [
	"Return x y z extents as a string
	Note: This needs to map Hum coordinates to X3D coordinates.
	TODO: HumSolid may override to subtract some clearance quantity (e.g. 1 or 2 mm) from quantities.
	"
	|s|
	"X"
	s :=         ( self mm: width  ).
	"Y"
	s := s, ' ', ( self mm: length ).
	"Z"
	s := s, ' ', ( self mm: height ).
	^s.
]

{ #category : #geometry }
HumBox >> xyzString [
	| s x y z space |
	x := self centerX.
	y := self centerY.
	z := self centerZ.
	self assert: (x isKindOf: HumMeasure).
	space := ' '.
	s := '( ',(x quantityAsString), space, (y quantityAsString), space, (z quantityAsString), ')'.
	^s.
]

{ #category : #'move slide rotate tilt' }
HumBox >> zslideRight: aHumMeasure [ 
	"Move camera left or right --- TODO: Correct this for camera orientation."
	self westEdge: (self westEdge) + aHumMeasure.
	self changed.
]
