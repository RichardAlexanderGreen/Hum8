"
a rotation is defined by a list of 2D points which indicate a surface of rotation about the Z axis.

Each 2D point is translated into a set of 3D points which divide a circle whose radius is equal to the x value of the 2D point.
The circle is in a plane who Z value is equal to the Y value of the 2D point.

Instance variables:
xyList (the list of 2D points mentioned above.)
nWedges (the number of wedges in each circle)

Examples 
3-sided pyramid: xyList := #( 0@10 10@0 0@0). nWedges := 3.
cube: #( 0@10 10@10 10@0 0@0 ). nWedges := 4.
cylinder: #( 0@10 10@10 10@0 0@0 ). nWedges := 100.
torus (with triangular section): #(  10@10 15@5 10@5 10@10 ). nWedges := 100.


"
Class {
	#name : #HumRotation,
	#superclass : #HumSolid,
	#instVars : [
		'xyList',
		'nWedges'
	],
	#category : #'Hum-UI'
}

{ #category : #'instance creation' }
HumRotation class >> id: aString type: aSymbol xyList: listOfPoints nWedges: numberOfWedges [ 
	| instance listOfRadius listOfZ maxRadius maxZ minZ |
	instance := self new.
	listOfRadius := listOfPoints collect: [ :point | point x ].
	listOfZ := listOfPoints collect: [ :point | point y ].
	maxRadius := listOfRadius max.
	maxZ := listOfZ max.
	minZ := listOfZ min.
	instance
		width: (maxRadius * 2);
		height: (maxZ - minZ);
		xyList: listOfPoints;
		nWedges: numberOfWedges.
	^instance.
]

{ #category : #polygons }
HumRotation >> asPolygonsColoredBy: aColorRule [
	"Produce polygons from the xyList points and the rotation nWedges."
	|  priorAngle pi makePoint fillColor borderColor tPolygons wedgeAngle centerX centerY centerZ |
	tPolygons := OrderedCollection new.
	fillColor := self solidColor.
	borderColor := self wireFrameColor.
	priorAngle := 0.0.
	pi := Float pi.
	wedgeAngle := (2*pi)/nWedges.
	centerX := self centerX.
	centerY := self centerY.
	centerZ := self centerZ.
	makePoint := [ :angle :xy |  
			| x y z radius |
			radius := xy at: 1.
			x := radius * (angle sin).
			y := radius * (angle cos).
			z := xy at: 2.
			{ x + centerX.  y + centerY.  z + centerZ. }
			].
	 ( wedgeAngle to: (2*pi) by: wedgeAngle )
		do: [ :currentAngle |
			| priorXY |
			priorXY := xyList at: 1.
			xyList 
				allButFirstDo:  [ :xy |
					| polygon  |
					fillColor := (aColorRule value).  "Select from a sequence of colors."
					polygon := HumPolygon borderColor: borderColor fillColor: fillColor.
					polygon parentSolid: self.
					polygon 
						addVertex: (makePoint value: currentAngle value: xy);
						addVertex: (makePoint value: currentAngle value: priorXY);
						addVertex: (makePoint value: priorAngle value: priorXY);
						addVertex: (makePoint value: priorAngle value: xy).
					priorXY := xy.
					tPolygons add: polygon.
					]. "xy"
			priorAngle := currentAngle.
	  		]. "currentAngle"
	^tPolygons.
]

{ #category : #'render via VPython' }
HumRotation >> asVPython [
	self shouldBeImplemented 
]

{ #category : #access }
HumRotation >> nWedges: numberOfWedges [
	nWedges := numberOfWedges.
]

{ #category : #access }
HumRotation >> xyList: aCollection [ 
	"List of XY (XZ) points that define surface of revolution."
	xyList := aCollection 
					collect: [ :point |  
						| x y xMeasure yMeasure |
						x := point x.
						y := point y.
						xMeasure := self asMeasure: x.
						yMeasure := self asMeasure: y.
						{ xMeasure. yMeasure. }.
						].						
]
