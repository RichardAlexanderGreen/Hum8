"
A vector to be used in geometry and Physics. 
Also implements functional programming concepts that enable cascading operations on large arrays.

Extends FloatArray.  (That means that complex-number values are not enabled.)
Uses FloatArray dot: for dot product.

Adds cross product:
The three scalar components 
of the vector s = s1 i + s2 j + s3 k = u × v 
are:

s1 = u2*v3 - u3*v2
s2 = u3*v1 - u1*v3
s3 = u1*v2 - u2*v1

where i,j,k are unit vectors parallel to x,y,z axes.
See #cross: method.
"
Class {
	#name : #HumVector,
	#superclass : #HumMeasure,
	#instVars : [
		'x',
		'y',
		'z'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'instance creation' }
HumVector class >> identityVector [
	"Create a dimensionless identity vector (all ones)."
	| instance |
	instance := self basicNew.
	instance dimensions. "Create an empty dimensions dictionary."
	instance quantity: #( 1.0 1.0 1.0 ).
	"TODO: Dimensionless measure is not working very well. 
	 It may need more thought (or more testing)."
	^instance.
]

{ #category : #'instance creation' }
HumVector class >> newFrom: xyz [
	| a3dPoint instance v |
	a3dPoint := xyz.
	( a3dPoint isKindOf: Point ) ifTrue: [ ^self newFromPoint: a3dPoint ].
	self assert: (a3dPoint isKindOf: Array).
	( a3dPoint size = 2 ) ifTrue: [ a3dPoint := { xyz at:1. xyz at:2. HumMeasure quantity: 0.0 units: ((xyz at:1) units). } ].
	self assert: (a3dPoint size = 3).
	instance := self new.
	v := a3dPoint at: 1.
	(v isKindOf: HumMeasure)
		ifTrue: [ "Make quantity an xyz array. Assume units all same."
			instance x: (a3dPoint at:1) y: (a3dPoint at: 2) z: (a3dPoint at: 3).
			instance dimensions: (v dimensions).
			]
		ifFalse: [ "Make quantity an xyz array. Assume units all meter."
			self assert: (v isKindOf: Number).
			instance x: (a3dPoint at:1) y: (a3dPoint at: 2) z: (a3dPoint at: 3).
			instance dimensions: (1 meter) dimensions.  
			].
	
	 ^instance.
]

{ #category : #'instance creation' }
HumVector class >> newFrom: aCollection units: aUnitOfMeasure [ 
	| instance |
	instance := self newFrom: aCollection.
	(aUnitOfMeasure = 'none') "enable dimensionless vector -- e.g. unit vector."
		ifTrue: [ instance dimensions: Dictionary new. ]
		ifFalse: [ instance dimensions: (HumMeasure quantity: 1 units: aUnitOfMeasure) dimensions. ].
	
	^instance.
]

{ #category : #'create instance' }
HumVector class >> newFromPoint: aPoint [ 
	| instance |
	instance :=  self newFrom: {  aPoint x. aPoint y. 0.0. } units: #px.
	^instance.
]

{ #category : #'instance initialization' }
HumVector class >> x: xValue y: yValue z: zValue [ 
	| instance |
	instance := self basicNew.
	instance x: xValue y: yValue z: zValue.
	^instance.
]

{ #category : #'instance creation' }
HumVector class >> zeroVector [
	"Create a dimensionless zero vector (all zero)."
	| instance |
	instance := self zeroVector: #meter.
	^instance.
]

{ #category : #'instance creation' }
HumVector class >> zeroVector: aUnitOfMeasureSymbol [
	"Create a dimensionless zero vector (all zero)."
	| instance |
	instance := self newFrom: { 0.0. 0.0. 0.0. } units: aUnitOfMeasureSymbol.
	^instance.
]

{ #category : #render }
HumVector >> asString [
	"render my value as a string"
	| result |
	self assert: (quantity isKindOf: Array).
	result := self quantityAsString.
	result := result, ' ', self units.
	^result.
]

{ #category : #access }
HumVector >> at: index [
	| v |
	self assert: (self quantity isKindOf: Array).
	v := HumMeasure new. 
	v quantity: (quantity at: index); dimensions: (self dimensions).
	^v.
]

{ #category : #access }
HumVector >> at: k put:  aValue [
	quantity ifNil: [ quantity := Array new: 3. ].
	self assert: (quantity isKindOf: Array).
	(aValue isKindOf: HumMeasure) 
		ifTrue: [quantity at: k put: aValue. self dimensions: aValue]
		ifFalse: [ Error signal: 'What?' ].
]

{ #category : #arithmetic }
HumVector >> checkLength: newVector [
	"newVector should have same length as me"
	| rNew rMe rDiff |
	false ifFalse: [ ^self].
	rNew := newVector length.
	rMe := self length.
	rDiff := rMe - rNew.
	self assert: (rDiff closeTo: 0.0) description: 'Expect zero difference after some transform. Got: ', rDiff asString.
	
]

{ #category : #arithmetic }
HumVector >> cross: anotherHumVector [
	"Return the 3-dimensional vector cross product U x V
	where U is self and V is the argument.
	The three scalar components 
		of the vector s=s1i+s2j+s3k = u×v 
		are:
			s1 = u2*v3 - u3*v2
			s2 = u3*v1 - u1*v3
			s3 = u1*v2 - u2*v1
	"
	| u   ux uy uz     v  vx vy vz   s sx sy sz   |
	u := self.
	v := anotherHumVector.
	self assert: ( v isKindOf: HumVector ).
	self assert: ( self quantity size = 3 ).
	self assert: (     v quantity size = 3 ).
	ux := u x.  uy := u y.  uz := u z.
	vx := v x.  vy := v y.  vz := v z.
	sx := (uy * vz) - (uz * vy).
	sy := (uz * vx) - (ux * vz).
	sz := (ux * vy) - (uy * vx).
	s := HumVector newFrom: { sx. sy. sz. }.
	^s.
	
	
]

{ #category : #arithmetic }
HumVector >> dot: aHumVector [
	|  sum  |
	sum := 	   ( self x * aHumVector x )
			 	+ ( self y * aHumVector y )
				+ ( self z * aHumVector z ).
	^sum.
]

{ #category : #access }
HumVector >> length [
	| s length vx vy vz |
	vx := self x.
	vy := self y.
	vz := self z.
	s := (vx*vx) + (vy*vy) + (vz*vz).
	length := s sqrt.
	^length.
]

{ #category : #arithmetic }
HumVector >> lengthSquared [
	| s2 vx vy vz |
	vx := self x.
	vy := self y.
	vz := self z.
	s2 := (vx*vx) + (vy*vy) + (vz*vz).
	"length := s sqrt."
	^s2.
]

{ #category : #rotations }
HumVector >> pitch: anAngleInRadians [
	"Transform receiver by a rotation about x (East pointing) axis."
	| vector |
	vector := self pitch: anAngleInRadians aboutPivot: ( HumVector zeroVector: #meter ).
	^vector.
]

{ #category : #rotations }
HumVector >> pitch: anAngleInRadians aboutPivot: pivot [
	"Transform receiver by a rotation about X (side pointing) axis."
	| xx yy zz r alpha vector px py pz dx dy dz |
	"The effect is to move the effective origin."
	( anAngleInRadians quantity closeTo: 0.0 ) ifTrue: [ ^self copy ].
	px := pivot x.
	py := pivot y.
	pz := pivot z.
	dx := (self x) - px.
	dy := (self y) - py.
	dz := (self z) - pz.
	r := ((dy * dy) + (dz * dz)) sqrt. "Note: x and y are measures"
	alpha := (dz arcTan: dy) radian.	"co-tangent Float"

	xx := px + dx.
	yy := py + ( r * ( ( alpha + anAngleInRadians ) cos ) ).
	zz := pz + ( r * ( ( alpha + anAngleInRadians ) sin ) ).
	vector := self class newFrom: { xx. yy. zz. }.

	^vector.
]

{ #category : #render }
HumVector >> quantityAsString [
	| s |
	self assert: (quantity isKindOf: Array).
	s := '( '.
	quantity do: [ :each |  s := s, (self quantityAsString: each), ' '. ].
	s := s, ')'.
	^s.
]

{ #category : #rotations }
HumVector >> roll: anAngleInRadians [
	"Transform receiver by a rotation about y (North pointing) axis."
	| vector |
	vector := self roll: anAngleInRadians aboutPivot: ( HumVector zeroVector: #meter ).
	^vector.
]

{ #category : #rotations }
HumVector >> roll: anAngleInRadians aboutPivot: pivot [
	"Transform receiver by a rotation about Y (forward pointing) axis."
	| xx yy zz r alpha vector px py pz dx dy dz |
	"Arithmetic is all via HumMeasure"
	"The effect is to move the effective origin."
	( anAngleInRadians quantity = 0.0 ) ifTrue: [ ^self copy ].

	px := pivot x.
	py := pivot y.
	pz := pivot z.
	dx := (self x) - px.
	dy := (self y) - py.
	dz := (self z) - pz.
	r := ((dx * dx) + (dz * dz)) sqrt. 
	alpha := (dz arcTan: dx) radian.	"co-tangent Float"

	xx := px + ( r * ( ( alpha + anAngleInRadians ) cos ) ).
	yy := py + dy.
	zz := pz + ( r * ( ( alpha + anAngleInRadians ) sin ) ).
	vector := self class newFrom: { xx. yy. zz. }.
	
	^vector.
]

{ #category : #access }
HumVector >> size [
	"compatibility"
	( quantity isKindOf: Array ) ifTrue: [ ^quantity size ].
	Error signal: 'Why are we here?'.
]

{ #category : #access }
HumVector >> x [
	^(self at: 1).
]

{ #category : #access }
HumVector >> x: xValue y: yValue z: zValue [
	"Hum coordinates are plan-view. x points East. y North. z Up."
	(xValue isKindOf: HumMeasure)
		ifTrue: [ 
			x := xValue. 
			y := yValue. 
			z := zValue. 
			]
		ifFalse: [ self assert: (xValue isKindOf: Number). 
			x := HumMeasure quantity: xValue units: #meter.
			y := HumMeasure quantity: yValue units: #meter.
			z := HumMeasure quantity: zValue units: #meter.
			].
	"Create array and store as quantity."
	self quantity:( { x. y. z. } collect: [:each | each quantity] ).
	"Assume all elements have same unit of measure (by definition)."
	self dimensions: (x dimensions).


]

{ #category : #access }
HumVector >> y [
	^self at: 2.
]

{ #category : #rotations }
HumVector >> yaw: anAngleInRadians [
	"Transform receiver by a rotation about z (Up pointing) axis."
	| vector |
	vector := self yaw: anAngleInRadians aboutPivot: ( HumVector zeroVector: #meter ).
	^vector.
]

{ #category : #rotations }
HumVector >> yaw: anAngleInRadians aboutPivot: pivot [
	"Transform receiver by a rotation about Z (Up pointing) axis."
	| xx yy zz r alpha vector px py pz dx dy dz dR |
	( anAngleInRadians = 0.0 ) ifTrue: [ ^self copy ].

	"The effect of a pivot is to move the effective origin."
	px := pivot x.
	py := pivot y.
	pz := pivot z.
	dx := (self x) - px.
	dy := (self y) - py.
	dz := (self z) - pz.
	r := ((dx * dx) + (dy * dy)) sqrt. "Note: x and y are measures"
	alpha := (dy arcTan: dx) radian.	"co-tangent Float"
		
	xx := px + ( r * ( ( alpha + anAngleInRadians ) cos ) ).
	yy := py + ( r * ( ( alpha + anAngleInRadians ) sin ) ).
	zz := pz + dz.
	vector := self class newFrom: { xx. yy. zz. }.

	^vector.
]

{ #category : #access }
HumVector >> z [
	^z := self at: 3.
]
