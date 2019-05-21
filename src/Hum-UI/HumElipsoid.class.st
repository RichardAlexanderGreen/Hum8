Class {
	#name : #HumElipsoid,
	#superclass : #HumRotation,
	#category : #'Hum-UI'
}

{ #category : #'as yet unclassified' }
HumElipsoid class >> id: anId type: aType height: aHeight diameter: aWidth [  
	"Create an instance . . . NOTE: Currently we just rotate an elipse. "
	| rotation xyPoints nFacets  pi |
	self halt.
	pi := Float pi.
	xyPoints := OrderedCollection new.
	nFacets := 10.
	( 1 to: nFacets ) 
		do: [ :facet   |
			| x y angle |
			angle := ( pi / nFacets) * facet.
			y := ( aHeight / nFacets ) * facet.
			x := (angle sin) * (aWidth / 2).
			xyPoints add: x@(y - (aHeight / 2.0)).
			].
	"Currently we just rotate an elipse. TODO: Elipsiod with 3 a,b,c radius."
	rotation := self id: anId type: aType xyList: xyPoints nWedges: nFacets. 	
	^rotation
]

{ #category : #'as yet unclassified' }
HumElipsoid class >> id: anId type: aType height: aHeight width: aWidth length: aDepth [ 
	"Create an instance . . . NOTE: length (North-South dimension) is ignored."
	| instance |
	instance := self new. "Initialize enclosing box edge values."
	instance id: anId; type: aType; height: aHeight; width: aWidth; length: aDepth. 
	^instance
]

{ #category : #polygons }
HumElipsoid >> asPolygons [
	^ self asPolygonsColoredBy: [ self solidColor ].
]

{ #category : #polygons }
HumElipsoid >> asPolygonsColorCoded [
	^ self asPolygonsColoredBy: [ self nextColor ].
]

{ #category : #polygons }
HumElipsoid >> asPolygonsColoredBy: aBlockRule [
	"Produce polygons from the xyList points and the rotation nWedges."
	|  priorAngle pi makePoint fillColor borderColor  wedgeAngle centerX centerY centerZ xMax yMax zMax |
	polygons := OrderedCollection new.
	fillColor := self solidColor.
	borderColor := self wireFrameColor.
	priorAngle := 0.0.
	pi := Float pi.
	wedgeAngle := (2*pi)/16.
	centerX := self centerX.
	centerY := self centerY.
	centerZ := self centerZ.
	xMax := self width / 2.0.
	yMax := self length / 2.0.
	zMax := self height / 2.0.
	"Wikipedia:
	The surface of the ellipsoid may be parameterized in several ways. One possible choice which singles out the 'z'-axis is:
	x = a * cos u * cos v
	y = b * cos u * sin v
	z = c * sin u
	where u is in [ -pi/2, +pi/2 ] and v is in [ -pi, +pi ].
	"
	makePoint := [ :u :v  |  
			| x y z  |
			x := xMax * (u cos ) * (v cos).
			y := yMax * (u cos) * (v sin).
			z := zMax * (u sin).
			{ x + centerX.  y + centerY.  z + centerZ. }
			].
	 ( ((pi/2.0) negated) to: (pi/2.0) by: wedgeAngle ) do: [ :u |
			 ( (pi negated) to: pi by: wedgeAngle ) do: [ :v |
					| polygon  |
					fillColor := aBlockRule value.  "Evaluate the caller`s coloring rule."
					polygon := HumPolygon borderColor: borderColor fillColor: fillColor.
					polygon parentSolid: (self).
					polygon 
						addVertex: ( makePoint value: u value: v );
						addVertex: ( makePoint value: u + wedgeAngle value: v );
						addVertex: ( makePoint value: u + wedgeAngle value: v + wedgeAngle );
						addVertex: ( makePoint value: u value: v + wedgeAngle ).
					polygons add: polygon.
				 ]. "v"
			]. "u"
	^polygons.
]

{ #category : #'render via VPython' }
HumElipsoid >> asVPython [
	self shouldBeImplemented 
]
