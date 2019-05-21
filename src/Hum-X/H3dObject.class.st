"
Experimental: Rewrite HumBox to simplify dynamics.

TODO: REFACTOR HumBox and subtypes.

Comment: I am probably wasting time by attempting to write logic that duplicates OpenGL functions. But my goal is to define a simpler API than that provided by OpenGL. My motivation is that OpenGL is not object-oriented. It represents many objects by arrays. 

The basic design strategy behind H3dObject is to use H3dPath instead of HumPolygon and HumVector functions for point transforms. 
"
Class {
	#name : #H3dObject,
	#superclass : #Object,
	#instVars : [
		'type',
		'parameters',
		'center',
		'velocity',
		'width',
		'length',
		'height',
		'numberOfWedges',
		'axis',
		'curve',
		'yaw',
		'pitch',
		'roll',
		'yawRate',
		'pitchRate',
		'rollRate',
		'pivotPoint',
		'fillColor',
		'borderColor',
		'parts',
		'clearance'
	],
	#category : #'Hum-X'
}

{ #category : #'instance creation' }
H3dObject class >> newAssemblyFromParts: aPartsList [
	"Create instance of an assembly containing the given parts."
	| instance |
	instance := self new.
	instance type: #assembly.
	instance addParts: aPartsList.
	^instance.
]

{ #category : #'instance creation' }
H3dObject class >> newBoxWidth: aWidth length: aLength height: aHeight [
	"Return instance of a box"
	| instance |
	self assert: ( aWidth isKindOf: HumMeasure ).
	self assert: ( aLength isKindOf: HumMeasure ).
	self assert: ( aHeight isKindOf: HumMeasure ).
	
	instance := self new.
	instance
		type: #box;
		width: aWidth;
		length: aLength;
		height: aHeight.
	^instance.
]

{ #category : #'instance creation' }
H3dObject class >> newElipsoidWidth: aWidth length: aLength height: aHeight [
	"Return instance of an elipsoid"
	| instance |
	self assert: ( aWidth isKindOf: HumMeasure ).
	self assert: ( aLength isKindOf: HumMeasure ).
	self assert: ( aHeight isKindOf: HumMeasure ).

	instance := self new.
	instance
		type: #elipsoid;
		width: aWidth;
		length: aLength;
		height: aHeight.
	^instance.
]

{ #category : #'instance creation' }
H3dObject class >> newRotationAround: anAxis curve: xyPoints [
	"Return instance of a rotation"
	| instance |
	self assert: ( #( #x #y #z ) includes: anAxis ).
	self assert: (xyPoints isKindOf: H3dPath ).
	self assert: ( (xyPoints vertices first) isKindOf: HumVector ).
	
	instance := self new.
	instance
		type: #rotation;
		axis: anAxis;
		curve: xyPoints.
	^instance.
]

{ #category : #'access - assembly' }
H3dObject >> addPart: anH3dObject [
	"Add a part (or subassembly) to my assembly."
	self assert: (anH3dObject isKindOf: H3dObject ).
	self deny: (anH3dObject == self ). 
	
	(self parts) add: anH3dObject.
]

{ #category : #'access - assembly' }
H3dObject >> addParts: aPartsList [
	"Add each part to my set of parts."
	aPartsList do: [  :part | (self parts) add: part. ].

]

{ #category : #'access - position' }
H3dObject >> assertRadians: anAngleInRadians [
		self assert: ( (anAngleInRadians isKindOf: HumMeasure) and: [anAngleInRadians dimensions = (1 radian) dimensions ] )
			description: 'Angles should be HumMeasure with units of #radian'.

]

{ #category : #'access - position' }
H3dObject >> assertRadiansPerSecond: radiansPerSecond [
		self assert: ( (radiansPerSecond isKindOf: HumMeasure) and: [radiansPerSecond dimensions = (1 rpm) dimensions ] ) "Number>>rpm"
			description: 'Angular-velocity should be HumMeasure with units of radians per second'.

]

{ #category : #'access - dimensions' }
H3dObject >> axis: anAxisSymbol [
	"Which axis is rotation around? 
	Use with #curve: to set-up surface of rotation."
	self assert: (anAxisSymbol isKindOf: Symbol ).
	^ axis := anAxisSymbol.
]

{ #category : #access }
H3dObject >> borderColor [
	^ borderColor ifNil: [ borderColor := (self fillColor) lighter. ].
]

{ #category : #'access - edges' }
H3dObject >> bottom [
	"Value without yaw, pitch, roll - Use minZ to see value with yaw, pitch, roll."
	^  ( center z ) - ( height / 2.0 ).
]

{ #category : #'access - edges' }
H3dObject >> bottom: aMeasure [
	"Move so that bottom is at given z value."
	| cx cy cz |
	cx := center x. 
	cy := center y.
	cz := center z.
	self center: ( HumVector newFrom: { cx. cy. ( aMeasure + ( height / 2.0 ) ). } ).
]

{ #category : #draw }
H3dObject >> buildAndOrient [
	"Return polygons in scene coordinates.
	Build base polygons. 
	Then, adjust orientation for yaw, pitch, roll. "
	| basePolygons adjustedPolygons pivot |
	basePolygons := self buildBasePolygons.
	adjustedPolygons := OrderedCollection new.
	pivot := self pivot.
	self assert: ( pivot isKindOf: HumVector ).
	basePolygons do: [ :p0 | "p0 is a polygon"
		|  p1 p2 p3 |
		"To assure consistent results, alway apply in order: yaw, pitch, roll. "
		( yaw quantity closeTo: 0.0 )	ifTrue: [ p1 := p0 ] ifFalse: [ p1 := p0 yaw: yaw aboutPivot: pivot ].
		( pitch quantity closeTo: 0.0 )	ifTrue: [ p2 := p1 ] ifFalse: [ p2 := p1 pitch: pitch aboutPivot: pivot ] .
		( roll quantity closeTo: 0.0 )	ifTrue: [ p3 := p2 ] ifFalse: [ p3 := p2 roll: roll aboutPivot: pivot ].
		adjustedPolygons add: p3. 
		].
	^adjustedPolygons.
	
]

{ #category : #draw }
H3dObject >> buildAssembly [
	"Build the polygons for the assembly by aggregating and translating polygons from the parts."
	| localPolygons translatedPolygons |
	localPolygons := OrderedCollection new.
	translatedPolygons := OrderedCollection new.
	self parts  do: [ :part |  localPolygons addAllLast: ( part buildBasePolygons ) ].
	localPolygons do: [ :polygon | translatedPolygons addLast: (polygon translateBy: self center)  ].  
	^translatedPolygons.
]

{ #category : #draw }
H3dObject >> buildBasePolygons [
	"Return my base polygons. Polygons before pitch, yaw, roll."
	| calc polygons  |
	polygons := OrderedCollection new.
	calc := HumCalculator new.
	calc cases;
		when: [ type = #box ] then: [ polygons := self buildBox ];
		when: [ type = #elipsoid ] then: [ polygons := self buildElipsoid ];
		when: [ type = #rotation ] then: [ polygons := self buildRotation ];
		when: [ type = #assembly ] then: [ polygons := self buildAssembly ];
		otherwise: [ Error signal: 'Unknown type of 3D object: ', (type asString) ].
	self assert: ( polygons size > 0 ) description: 'Empty assembly? Unexpected it is.'.
	^polygons.
]

{ #category : #draw }
H3dObject >> buildBox [
	"Create polygons for a box"
	| polygons points dx dy dz cx cy cz top bottom east west north south |
	polygons := OrderedCollection new.
	dx := width / 2.0.
	dy := length / 2.0.
	dz := height / 2.0.
	cx := center x.
	cy := center y.
	cz := center z.
	
	points := Collection new.
	top := H3dPath new.
	top 
		addVertex: { cx+dx. cy+dy. cz+dz. }; "Right-hand rule: Wind clockwise facing inward."
		addVertex: { cx+dx. cy-dy. cz+dz. };
		addVertex: { cx-dx. cy-dy. cz+dz. };
		addVertex: { cx-dx. cy+dy. cz+dz. }.		
	bottom := H3dPath new.
	bottom
		addVertex: { cx+dx. cy+dy. cz-dz. };
		addVertex: { cx-dx. cy+dy. cz-dz. };
		addVertex: { cx-dx. cy-dy. cz-dz. };
		addVertex: { cx+dx. cy-dy. cz-dz. }.
	north := H3dPath new.
	north
		addVertex: { cx+dx. cy+dy. cz+dz. };
		addVertex: { cx-dx. cy+dy. cz+dz. };
		addVertex: { cx-dx. cy+dy. cz-dz. };
		addVertex: { cx+dx. cy+dy. cz-dz. }.
	south := H3dPath new.
	south
		addVertex: { cx+dx. cy-dy. cz+dz. };
		addVertex: { cx+dx. cy-dy. cz-dz. };
		addVertex: { cx-dx. cy-dy. cz-dz. };
		addVertex: { cx-dx. cy-dy. cz+dz. }.
	east := H3dPath new.
	east
		addVertex: { cx+dx. cy+dy. cz+dz. };
		addVertex: { cx+dx. cy+dy. cz-dz. };
		addVertex: { cx+dx. cy-dy. cz-dz. };
		addVertex: { cx+dx. cy-dy. cz+dz. }.
	west := H3dPath new.
	west
		addVertex: { cx-dx. cy+dy. cz+dz. };
		addVertex: { cx-dx. cy-dy. cz+dz. };
		addVertex: { cx-dx. cy-dy. cz-dz. };
		addVertex: { cx-dx. cy+dy. cz-dz. }.
	"assemble faces"			
	polygons addAll: { top. bottom. north. south. east. west. }.	
	"color"
	polygons do: [ :polygon | polygon borderColor: (self borderColor); fillColor: (self fillColor) ].
	^ polygons.
]

{ #category : #draw }
H3dObject >> buildElipsoid [
	"Create polygons forming the elipsoid."
	| polygons pi minusPi twoPi nWedges  dAlpha dBeta makePoint xMax yMax zMax |
	polygons := OrderedCollection new.
	pi := Float pi.
	minusPi := pi negated.
	twoPi := 2.0 * pi.
	nWedges := self numberOfWedges.
	dAlpha := pi / nWedges.
	dBeta := twoPi / nWedges.
	xMax := width / 2.0.
	yMax := length / 2.0.
	zMax := height / 2.0.
	makePoint := [ :alpha :beta |  	"BlockClosure to build a point given alpha and beta angles."
			| x y z vertex |
			x := xMax * ( beta cos ) * ( alpha cos ).
			y := yMax * ( beta sin ) * ( alpha cos ).
			z := zMax * ( alpha sin ). 
			vertex := HumVector newFrom: { x. y. z. }. 		"return"
			].
	"Work from bottom to top"
	( ((minusPi / 2.0) + dAlpha ) to: pi / 2.0 by: dAlpha) do: [ :alpha |  "verticle angle from x-y plane"
		( minusPi  to: ( pi - dBeta ) by: dBeta ) do: [ :beta | "circle around z axis" 
			| polygon |
			polygon := H3dPath new.
			polygon 
				addVertex: ( makePoint value: alpha value: beta );
				addVertex: ( makePoint value: alpha value: beta + dBeta );
				addVertex: ( makePoint value: alpha - dAlpha value: beta + dBeta );
				addVertex: ( makePoint value: alpha - dAlpha value: beta ).
			polygons add: polygon.
			].
		].
	"color"
	polygons do: [ :polygon | polygon borderColor: (self borderColor); fillColor: (self fillColor) ].

	^polygons.
	
]

{ #category : #draw }
H3dObject >> buildRotation [
	"Given curve and an axis, build a rotation as a collection of polygons."
	| polygons nWedges dAngle cx cy cz priorXY priorPoint twoPi calc adjustedPolygons |
	polygons := OrderedCollection new.
	nWedges := self numberOfWedges.
	cx := center x.
	cy := center y.
	cz := center z.
	priorXY := curve first.
	priorPoint := HumVector newFrom: { cx + (priorXY x). cy. cz + (priorXY y).  }.
	twoPi := 2.0 * (Float pi).
	dAngle := twoPi / nWedges.
	( dAngle to: twoPi by: dAngle ) do: [ :angle |	 
			( curve vertices copyFrom: 2 to: curve size ) do: [ :xy |
					| polygon thisPoint |  
					thisPoint := HumVector newFrom: {  cx + (xy x). cy. cz + (xy y). }.
					polygon := HumPolygon new.
					polygon 
						addVertex: ( thisPoint yaw: angle radian );  "Right-hand rule: Wind clockwise looking inward."
						addVertex: ( priorPoint yaw: angle radian  );
						addVertex: ( priorPoint yaw: (angle - dAngle) radian );
						addVertex: ( thisPoint yaw: (angle - dAngle) radian ).
					polygons add: polygon.
					priorPoint := thisPoint.
				].
			].
	calc := HumCalculator new.
	"Adjust for non-default axis of rotation."
	adjustedPolygons := OrderedCollection new.
	calc cases;
		when: [ axis = #z ] then: [ adjustedPolygons := polygons ];
		when: [ axis = #x ] then: [ adjustedPolygons := polygons collect: [ :polygon | polygon roll:  (Float pi / 2.0) negated radian ]  ];
		when: [ axis = #y ] then: [ adjustedPolygons := polygons collect: [ :polygon | polygon pitch:  (Float pi / 2.0) negated radian ]  ];
		"TODO: Should this be #pitch:aboutPivot: ?? "
		otherwise: [ "default is #z" adjustedPolygons := polygons ].

	"color"
	adjustedPolygons do: [ :polygon | polygon borderColor: (self borderColor); fillColor: (self fillColor ) ]. "Color"

	 ^adjustedPolygons. 
]

{ #category : #'access - position' }
H3dObject >> center [
	^ center ifNil: [ center := (HumVector newFrom: { 0.0 meter. 0.0 meter. 0.0 meter. } ) ].
]

{ #category : #'access - position' }
H3dObject >> center: aVector [
	"Set my center in container coordinates."
	self assert: ( aVector isKindOf: HumVector ).
	center := aVector copy.
]

{ #category : #access }
H3dObject >> clearance [
	"Default value for clearance is one millimeter."
	^clearance ifNil: [ clearance := 0.001 meter ].
]

{ #category : #'access - dimensions' }
H3dObject >> curve: xyPoints [
	"Curve to use when building a rotation.
	Use with #axis to define a surface of rotation."
	self assert: ( xyPoints isKindOf: H3dPath ).
	curve := xyPoints.
]

{ #category : #'access - edges' }
H3dObject >> east [
	"Value without yaw, pitch, roll - Use maxX to see value with yaw, pitch, roll."
	^  ( center x ) + ( width / 2.0 ).
]

{ #category : #'access - edges' }
H3dObject >> east: aMeasure [
	"Move so that east edge is at the given value."
	| cx cy cz |
	cx := center x. 
	cy := center y.
	cz := center z.
	self center: (HumVector newFrom: { (aMeasure - ( width / 2.0 ) ). cy. cz. }).
	
]

{ #category : #access }
H3dObject >> fillColor [
	^ fillColor ifNil: [ fillColor := Color gray. ].
]

{ #category : #'access - dimensions' }
H3dObject >> height [
	"What is my Up-Down height? (prior to pitch, yaw, roll).
	Defines height of box or elipsoid."
	^ height ifNil: [ Error signal: 'height dimension has not been set' ].
]

{ #category : #'access - dimensions' }
H3dObject >> height: aHeight [
	"What is my Up-Down height? (prior to pitch, yaw, roll).
	Defines height of box or elipsoid."
	height := aHeight.
]

{ #category : #'access - position' }
H3dObject >> initialize [
	"Set initial position, orientation, velocity, and rotation rates to zero."
	| zeroOffset zeroSpeed zeroRotation zeroRateOfRotation |
	
	zeroOffset := 0.0 meter.
	zeroSpeed := 0.0 mps.
	zeroRotation := 0.0 radian.
	zeroRateOfRotation := 0.0 rps.
	
	self center: ( HumVector newFrom: { zeroOffset. zeroOffset. zeroOffset. } ).
	self velocity: ( HumVector newFrom: { zeroSpeed.  zeroSpeed.  zeroSpeed. } ).
	
	self yaw: zeroRotation.
	self pitch: zeroRotation.
	self roll: zeroRotation.
	
	self yawRate: zeroRateOfRotation.
	self pitchRate: zeroRateOfRotation.
	self rollRate: zeroRateOfRotation.


]

{ #category : #'access - dimensions' }
H3dObject >> length [
	"What is my North-South length? (prior to pitch, yaw, roll)
	Define length of box or elipsoid."
	^ length ifNil: [ Error signal: 'length dimesion has not been set' ].
]

{ #category : #'access - dimensions' }
H3dObject >> length: aLength [
	"What is my North-South length? (prior to pitch, yaw, roll)
	Define length of box or elipsoid."
	length := aLength.
]

{ #category : #'access - bounds' }
H3dObject >> maxX [
	| v |
	v := nil.
	(self polygons) do: [ :polygon | 
		polygon vertices do: [ :vertex | 
			( v isNil ) 
				ifTrue: [ v := vertex x ]
				ifFalse: [ v := v max: (vertex x) ]
			 ].  
		].
	^ v.
	
]

{ #category : #'access - bounds' }
H3dObject >> maxY [
	| v |
	v := nil.
	(self polygons) do: [ :polygon | 
		polygon vertices do: [ :vertex | 
			( v isNil ) 
				ifTrue: [ v := vertex y ]
				ifFalse: [ v := v max: (vertex y) ]
			 ].  
		].
	^ v.
	
]

{ #category : #'access - bounds' }
H3dObject >> maxZ [
	| v |
	v := nil.
	(self polygons) do: [ :polygon | 
		polygon vertices do: [ :vertex | 
			( v isNil ) 
				ifTrue: [ v := vertex z ]
				ifFalse: [ v := v max: (vertex z) ]
			 ].  
		].
	^ v.
	
]

{ #category : #'access - bounds' }
H3dObject >> minX [
	| v |
	v := nil.
	(self polygons) do: [ :polygon | 
		polygon vertices do: [ :vertex | 
			( v isNil ) 
				ifTrue: [ v := vertex x ]
				ifFalse: [ v := v min: (vertex x) ]
			 ].  
		].
	^ v.
	
]

{ #category : #'access - bounds' }
H3dObject >> minY [
	| v |
	v := nil.
	(self polygons) do: [ :polygon | 
		polygon vertices do: [ :vertex | 
			( v isNil ) 
				ifTrue: [ v := vertex y ]
				ifFalse: [ v := v min: (vertex y) ]
			 ].  
		].
	^ v.
	
]

{ #category : #'access - bounds' }
H3dObject >> minZ [
	| v |
	v := nil.
	(self polygons) do: [ :polygon | 
		polygon vertices do: [ :vertex | 
			( v isNil ) 
				ifTrue: [ v := vertex z ]
				ifFalse: [ v := v min: (vertex z) ]
			 ].  
		].
	^ v.
	
]

{ #category : #positioning }
H3dObject >> move: aH3dObject toMyCoordinate: aHumVector [ 
	aH3dObject center: aHumVector.
]

{ #category : #'access - edges' }
H3dObject >> north [
	"Value without yaw, pitch, roll - Use maxY to see value with yaw, pitch, roll."
	^  ( center y ) + ( length / 2.0 ).
]

{ #category : #'access - edges' }
H3dObject >> north: aMeasure [
	"Move so that north edge is at given value."
	| cx cy cz |
	cx := center x. 
	cy := center y.
	cz := center z.
	self center: (HumVector newFrom: { cx. ( aMeasure - ( length / 2.0 ) ). cz. }).
]

{ #category : #'access - dimensions' }
H3dObject >> numberOfWedges [
	"Number of wedges to produce when drawing rotation or elipsoid."
	^ numberOfWedges ifNil: [ numberOfWedges := 12 ].
]

{ #category : #'access - dimensions' }
H3dObject >> numberOfWedges: anInteger [ 
	numberOfWedges := anInteger
]

{ #category : #'access - assembly' }
H3dObject >> parts [
	"Return my set of parts/subassemblies - each part is unique - hence a member of a set."
	^ parts ifNil: [  parts := Set new. ].
]

{ #category : #'access - position' }
H3dObject >> pitch [
	"Amount of current pitch = rotation about x-axis"
	^ pitch ifNil: [ pitch := 0.0 radian ].
]

{ #category : #'access - position' }
H3dObject >> pitch: anAngleInRadians [
	"Amount of current pitch = rotation about x-axis"
	self assertRadians: anAngleInRadians.
	pitch := anAngleInRadians.
]

{ #category : #'access - position' }
H3dObject >> pitchRate: randiansPerSecond [
	"pitch rate (angular velocity) "
	self assertRadiansPerSecond: randiansPerSecond.
	pitchRate := randiansPerSecond.
]

{ #category : #'access - position' }
H3dObject >> pivot [
	"Return the pivot in scene coordinates."
	| pivot |
	pivot := (self center) + (self pivotPoint).
	^pivot
]

{ #category : #'access - dimensions' }
H3dObject >> pivotPoint [
	"Pivot-point is relative to object`s center. 
	By default we pivot around the center."
	^pivotPoint ifNil: [ pivotPoint := HumVector zeroVector: #meter ].
]

{ #category : #'access - dimensions' }
H3dObject >> pivotPoint: aVector [
	"Pivot-point is relative to object`s center.
	Example: The pivot is inset from top edge of arm.
	w := 0.10.
	h := 0.50
	arm := H3dObject boxWidth: w length: w height: h.
	arm pivotPoint: (HumVector newFrom: { 0.0. 0.0. (h/2)-(w/2). }."
	pivotPoint := aVector
]

{ #category : #positioning }
H3dObject >> place: aH3dObjectA onTopOf: aH3dObjectB [ 
	"Position so that  bottom matches top with a little clearance."
	| offsetA offsetB sameX sameY newCenter  |
	offsetA := ( aH3dObjectA maxZ ) - ( aH3dObjectA center z ).
	offsetB := ( aH3dObjectB center z ) - ( aH3dObjectB minZ ).
	sameX := aH3dObjectA center x.
	sameY := aH3dObjectA center y.
	clearance := self clearance.
	newCenter := aH3dObjectB center + (HumVector newFrom: { sameX. sameY. (offsetA + offsetB + clearance ). } ).
	aH3dObjectA center: newCenter.
	
]

{ #category : #draw }
H3dObject >> polygons [
	| polygons |
	polygons := self buildAndOrient.
	^polygons
]

{ #category : #'access - position' }
H3dObject >> roll [
	"Amount of current roll. = rotation about y-axis"
	^roll ifNil: [ roll := 0.0 radian ].
]

{ #category : #'access - position' }
H3dObject >> roll: anAngleInRadians [
	"Amount of current roll. = rotation about y-axis"
	self assertRadians: anAngleInRadians.
	roll := anAngleInRadians.
]

{ #category : #'access - position' }
H3dObject >> rollRate: randiansPerSecond [
	"roll rate (angular velocity) "
	self assertRadiansPerSecond: randiansPerSecond.
	rollRate := randiansPerSecond.
]

{ #category : #'access - edges' }
H3dObject >> south [
	"Value without yaw, pitch, roll - Use minY to see value with yaw, pitch, roll."
	^  ( center y ) - ( length / 2.0 ).
]

{ #category : #'access - edges' }
H3dObject >> south: aMeasure [
	"Move so that south edge is at given value."
	| cx cy cz |
	cx := center x. 
	cy := center y.
	cz := center z.
	self center: ( HumVector newFrom: { cx. ( aMeasure + ( length / 2.0 ) ). cz. } ).
]

{ #category : #'access - position' }
H3dObject >> step: aTimeIncrement [
	"Step the position and orientation."
	| newCenter newPitch newYaw newRoll |
	"self assert: ((aTimeIncrement isKindOf: HumMeasure) and: [ aTimeIncrement dimensions = { #second->1. } ] )."
	newCenter := center + ( velocity * aTimeIncrement ).
	"Always do yaw, pitch, roll in that order."
	newYaw := yaw + ( yawRate * aTimeIncrement ).
	newPitch := pitch + ( pitchRate * aTimeIncrement ).
	newRoll := roll + ( rollRate * aTimeIncrement ).
	"Update:"
	self 
		center: newCenter;
		yaw: newYaw;
		pitch: newPitch;
		roll: newRoll.
	self changed.  "Inform subscribers."

	
	
	
]

{ #category : #'access - edges' }
H3dObject >> top [
	"Value without yaw, pitch, roll - Use maxZ to see value with yaw, pitch, roll."
	^  ( center z ) + ( height / 2.0 ).
]

{ #category : #'access - edges' }
H3dObject >> top: aMeasure [
	"Move so that top is at given z value."
	| cx cy cz |
	cx := center x. 
	cy := center y.
	cz := center z.
	self center: (HumVector newFrom: { cx. cy. ( aMeasure - ( height / 2.0 ) ). }).
]

{ #category : #'access - dimensions' }
H3dObject >> type: aType [
	"What type of 3D object am I?"
	type := aType.
]

{ #category : #'access - position' }
H3dObject >> velocity: aVector [
	"Set my velocity in container coordinates."
	self assert: ( aVector isKindOf: HumVector ).
	velocity := aVector.
]

{ #category : #'access - dimensions' }
H3dObject >> volume [
	"Return volume of box."
	| volume calc |
	calc := HumCalculator new.
	calc cases;
		when: [ type = #box ] then: [ volume := width * length * height. ];
		when: [ type = #elipsoid ] then: [| a b c | a := width/2.0.  b := length/2.0. c := height/2.0. volume := a * b * c * (Float pi)* 4.0 / 3.0 ];
		when: [ type = #rotation ] then: [ self shouldBeImplemented  ];
		otherwise: [ Error signal: '3D object type not given' ].
	 ^volume.
	
]

{ #category : #'access - edges' }
H3dObject >> west [
	"Value without yaw, pitch, roll - Use minX to see value with yaw, pitch, roll."
	^  ( center x ) - ( width / 2.0 ).
]

{ #category : #'access - edges' }
H3dObject >> west: aMeasure [
	"Move so that west edge is at the given value."
	| cx cy cz |
	cx := center x. 
	cy := center y.
	cz := center z.
	self center:  (HumVector newFrom: { ( aMeasure + ( width / 2.0 ) ). cy. cz. }).
	
]

{ #category : #'access - dimensions' }
H3dObject >> width [
	^ width ifNil: [ Error signal: 'width has not been set' ].
]

{ #category : #'access - dimensions' }
H3dObject >> width: aWidth [
	"What is my East-West width? (prior to pitch, yaw, roll)
	Define width of box or elipsoid."
	width := aWidth.
]

{ #category : #'access - position' }
H3dObject >> yaw [
	"Amount of current yaw. = rotation about z-axis"
	^ yaw ifNil: [ yaw := 0.0 radian ].
]

{ #category : #'access - position' }
H3dObject >> yaw: anAngleInRadians [
	"Amount of current yaw. = rotation about z-axis"
	self assertRadians: anAngleInRadians.
	yaw := anAngleInRadians.
]

{ #category : #'access - position' }
H3dObject >> yawRate: randiansPerSecond [
	"yaw rate (angular velocity) = rotation about z-axis"
	self assertRadiansPerSecond: randiansPerSecond.
	yawRate := randiansPerSecond.
]
