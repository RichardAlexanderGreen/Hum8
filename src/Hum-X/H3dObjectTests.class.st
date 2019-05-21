"
TODO: Replace HumBox with Hum3dObject ???
"
Class {
	#name : #H3dObjectTests,
	#superclass : #Object,
	#category : #'Hum-X'
}

{ #category : #'as yet unclassified' }
H3dObjectTests >> test110buildBox [
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	"Check that dimension were stored."
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 10.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	"Volume"
	self expect: (HumMeasure quantity: (10*20*30) units: 'cubic meter') actual: (box volume).
	"Polygons ==> cube faces in this case"
	self expect: 6 actual: (box polygons size).
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test120yawBox90degrees [
	"90 degree yaw exchanges X and Y"
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 10.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	box yaw: ((Float pi)/ 2.0) radian.
	self expect: ( 10.0 meter ) actual: ( box maxX ).	
	self expect: ( 05.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test122yawBox90degreesAroundPivot [
	"90 degree yaw exchanges X and Y"
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (22 meter) height: (30 meter).
	box pivotPoint: ( HumVector newFrom: { 0.0. 0.0. 0.0 } ).
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 11.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	box yaw: ((Float pi)/ 2.0) radian.
	self expect: ( 11.0 meter ) actual: ( box maxX ).	
	self expect: ( 05.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	box pivotPoint: ( HumVector newFrom: { box east. 0.0 meter. 0.0 meter. } ).
	self expect: ( 16.0 meter ) actual: ( box maxX ).	"5 + 11 = 16"
	self expect: (-06.0 meter ) actual: ( box minX ).	"5 - 11 = -6"
	self expect: ( 00.0 meter ) actual: ( box maxY ).	
	self expect: (-10.0 meter) actual: (box minY). 		"0 - 10 = -10"
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	self expect: (-15.0 meter ) actual: ( box minZ ).

	
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test125yawBox180degrees [
	"180 degree rotations should leave bounds the same."
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 10.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	box yaw: ((Float pi)) radian.
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 10.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test130pitchBox90degrees [
	"90 degree pitch exchanges Y and Z"
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 10.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	box pitch: ((Float pi)/ 2.0) radian.
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 15.0 meter ) actual: ( box maxY ).	
	self expect: ( 10.0 meter ) actual: ( box maxZ ).	
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test132pitchBox90degreesAboutPivot [
	"90 degree pitch exchanges Y and Z"
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (22 meter) height: (30 meter).
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 11.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	box pitch: ((Float pi)/ 2.0) radian.
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 15.0 meter ) actual: ( box maxY ).	
	self expect: ( 11.0 meter ) actual: ( box maxZ ).	
	box pivotPoint: (HumVector newFrom: { 0.0 meter. box north. 0.0 meter. } ).
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( -5.0 meter ) actual: ( box minX ).	
	self expect: ( 26.0 meter ) actual: ( box maxY ).	"11 + 15 = 26"
	self expect: ( -4.0 meter ) actual: ( box minY ).	"11 - 15 = -4"
	self expect: ( 00.0 meter ) actual: ( box maxZ ).	
	self expect: ( -22.0 meter ) actual: ( box minZ ).

	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test135pitchBox180degrees [
	"180 degree rotations should leave bounds the same."
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 10.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	box pitch: ((Float pi)) radian.
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 10.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test140rollBox90degrees [
	"90 degree roll exchanges X and Z"
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 10.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	box roll: ((Float pi)/ 2.0) radian.
	self expect: ( 15.0 meter ) actual: ( box maxX ).	
	self expect: ( 10.0 meter ) actual: ( box maxY ).	
	self expect: ( 05.0 meter ) actual: ( box maxZ ).	
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test142rollBox90degreesAboutPivot [
	"90 degree roll exchanges X and Z"
	| box |
	box := H3dObject newBoxWidth: (12 meter) length: (22 meter) height: (30 meter).
	self expect: ( 06.0 meter ) actual: ( box maxX ).	
	self expect: ( 11.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	box roll: ((Float pi)/ 2.0) radian.
	self expect: ( 15.0 meter ) actual: ( box maxX ).	
	self expect: ( 11.0 meter ) actual: ( box maxY ).	
	self expect: ( 06.0 meter ) actual: ( box maxZ ).	
	box pivotPoint: ( HumVector newFrom: { box west. 0.0 meter. 0.0 meter. } ).
	self expect: ( 09.0 meter ) actual: ( box maxX ).	"15 - 6 = 9"
	self expect: ( 11.0 meter ) actual: ( box maxY ).	
	self expect: ( 12.0 meter ) actual: ( box maxZ ).	

	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test143rollBox90degreesAboutPivot [
	"90 degree roll exchanges X and Z"
	| box |
	box := H3dObject newBoxWidth: (12 meter) length: (22 meter) height: (30 meter).
	self expect: ( 06.0 meter ) actual: ( box maxX ).	
	self expect: ( 11.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	box roll: ((Float pi)/ 2.0) radian.
	self expect: ( 15.0 meter ) actual: ( box maxX ).	
	self expect: ( 11.0 meter ) actual: ( box maxY ).	
	self expect: ( 06.0 meter ) actual: ( box maxZ ).	
	box pivotPoint: ( HumVector newFrom: { 1.0 meter. 0.0 meter. 2.0 meter. } ).
	self expect: ( 18.0 meter ) actual: ( box maxX ).	"0+1+(15+2) = 18"
	self expect: ( 11.0 meter ) actual: ( box maxY ).	"STS"
	self expect: ( 07.0 meter ) actual: ( box maxZ ).	"0+1+(6+1)"

	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test145rollBox180degrees [
	"180 degree rotations should leave bounds the same."
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 10.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	box roll: ((Float pi)) radian.
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 10.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test150yawPitchRollBox [
	"180 degree rotations should leave it looking the same."
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 10.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	box yaw: ((Float pi)) radian.
	box pitch: ((Float pi)) radian.
	box roll: ((Float pi)) radian.
	self expect: ( 05.0 meter ) actual: ( box maxX ).	
	self expect: ( 10.0 meter ) actual: ( box maxY ).	
	self expect: ( 15.0 meter ) actual: ( box maxZ ).	
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test220moveBoxEast [
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	box east: 40 meters.
	self expect: (40 meter) actual: (box east).
	self expect: (35 meter) actual: (box center x).
	self expect: 40 meter actual: (box maxX).
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test225moveBoxWest [
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: ( -5.0 meter) actual: (box west).
	box west: 40 meters.
	self expect: (40 meter) actual: (box west).
	self expect: (45 meter) actual: (box center x).
	self expect: 40 meter actual: (box minX).
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test230moveBoxNorth [
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: (10 meter) actual: (box maxY).
	box north: 40 meters.
	self expect: (40 meter) actual: (box north).
	self expect: (30 meter) actual: (box center y).
	self expect: (40 meter) actual: (box maxY).
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test235moveBoxSouth [
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: (-10 meter) actual: (box south).
	box south: 40 meters.
	self expect: (40 meter) actual: (box south).
	self expect: (50 meter) actual: (box center y).
	self expect: (40 meter) actual: (box minY).
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test240moveBoxTop [
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: (15 meter) actual: (box maxZ).
	box top: 40 meters.
	self expect: (40 meter) actual: (box top).
	self expect: (25 meter) actual: (box center z).
	self expect: (40 meter) actual: (box maxZ).
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test245moveBoxBottom [
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: (-15 meter) actual: (box bottom).
	box bottom: 40 meters.
	self expect: (40 meter) actual: (box bottom).
	self expect: (55 meter) actual: (box center z).
	self expect: (40 meter) actual: (box minZ).
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test310stepVelocity [
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	box velocity: (HumVector newFrom: {1 mps. 2 mps. 3 mps.} ).
	self expect: ( HumVector newFrom: {0 meter. 0 meter. 0 meter} ) actual: (box center).
	box step: (HumMeasure seconds: 1).
	self expect: ( HumVector newFrom: {1 meter. 2 meter. 3 meter} ) actual: (box center).
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test320stepYawRate [
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: (05 meter) actual: (box east).
	self expect: (10 meter) actual: (box north).
	self expect: (15 meter) actual: (box top).
	box yawRate: (0.25 rps).
	self expect: ( HumVector newFrom: {0 meter. 0 meter. 0 meter} ) actual: (box center).
	box step: (HumMeasure seconds: 1).
	self expect: ( HumVector newFrom: {0 meter. 0 meter. 0 meter} ) actual: (box center).
	"Expect X and Y bounds to exchange."
	self expect: (10 meter) actual: (box maxX).
	self expect: (05 meter) actual: (box maxY).
	self expect: (15 meter) actual: (box maxZ).

	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test325stepVelocityAndYawRate [
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: (05 meter) actual: (box east).
	self expect: (10 meter) actual: (box north).
	self expect: (15 meter) actual: (box top).
	self expect: ( HumVector newFrom: {0 meter. 0 meter. 0 meter} ) actual: (box center).
	self expect: (05 meter) actual: (box maxX).
	self expect: (10 meter) actual: (box maxY).
	self expect: (15 meter) actual: (box maxZ).
	box yawRate: (0.25 rps).
	box velocity: ( HumVector newFrom: { 100 mps. 100 mps. 100 mps.} ).
	box step: (HumMeasure seconds: 1).
	self expect: ( HumVector newFrom: {100 meter. 100 meter. 100 meter} ) actual: (box center).
	"Expect X and Y bounds to exchange."
	self expect: (110 meter) actual: (box maxX).
	self expect: (105 meter) actual: (box maxY).
	self expect: (115 meter) actual: (box maxZ).

	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test330stepPitchRate [
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: (05 meter) actual: (box east).
	self expect: (10 meter) actual: (box north).
	self expect: (15 meter) actual: (box top).
	box pitchRate: (0.25 rps).
	self expect: ( HumVector newFrom: {0 meter. 0 meter. 0 meter} ) actual: (box center).
	box step: (HumMeasure seconds: 1).
	self expect: ( HumVector newFrom: {0 meter. 0 meter. 0 meter} ) actual: (box center).
	"Expect Y and Z bounds to exchange."
	self expect: (05 meter) actual: (box maxX).
	self expect: (15 meter) actual: (box maxY).
	self expect: (10 meter) actual: (box maxZ).

	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test335stepVelocityAndPitchRate [
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: (05 meter) actual: (box east).
	self expect: (10 meter) actual: (box north).
	self expect: (15 meter) actual: (box top).
	self expect: ( HumVector newFrom: {0 meter. 0 meter. 0 meter} ) actual: (box center).
	self expect: (05 meter) actual: (box maxX).
	self expect: (10 meter) actual: (box maxY).
	self expect: (15 meter) actual: (box maxZ).
	box pitchRate: (0.25 rps).
	box velocity: ( HumVector newFrom: { 100 mps. 100 mps. 100 mps.} ).
	box step: (HumMeasure seconds: 1).
	self expect: ( HumVector newFrom: {100 meter. 100 meter. 100 meter} ) actual: (box center).
	"Expect Y and Z bounds to exchange."
	self expect: (105 meter) actual: (box maxX).
	self expect: (115 meter) actual: (box maxY).
	self expect: (110 meter) actual: (box maxZ).

	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test340stepRollRate [
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: (05 meter) actual: (box east).
	self expect: (10 meter) actual: (box north).
	self expect: (15 meter) actual: (box top).
	box rollRate: (0.25 rps).
	self expect: ( HumVector newFrom: {0 meter. 0 meter. 0 meter} ) actual: (box center).
	box step: (HumMeasure seconds: 1).
	self expect: ( HumVector newFrom: {0 meter. 0 meter. 0 meter} ) actual: (box center).
	"Expect X and Z bounds to exchange."
	self expect: (15 meter) actual: (box maxX).
	self expect: (10 meter) actual: (box maxY).
	self expect: (05 meter) actual: (box maxZ).

	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test345stepVelocityAndRollRate [
	| box |
	box := H3dObject newBoxWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: (05 meter) actual: (box east).
	self expect: (10 meter) actual: (box north).
	self expect: (15 meter) actual: (box top).
	self expect: ( HumVector newFrom: {0 meter. 0 meter. 0 meter} ) actual: (box center).
	self expect: (05 meter) actual: (box maxX).
	self expect: (10 meter) actual: (box maxY).
	self expect: (15 meter) actual: (box maxZ).
	box rollRate: (0.25 rps).
	box velocity: ( HumVector newFrom: { 100 mps. 100 mps. 100 mps.} ).
	box step: (HumMeasure seconds: 1).
	self expect: ( HumVector newFrom: {100 meter. 100 meter. 100 meter} ) actual: (box center).
	"Expect X and Z bounds to exchange."
	self expect: (115 meter) actual: (box maxX).
	self expect: (110 meter) actual: (box maxY).
	self expect: (105 meter) actual: (box maxZ).

	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test350stepEverything [
	| box |
	box := H3dObject newBoxWidth: ( 10 meter ) length: ( 22 meter ) height: ( 30 meter ).
	self expect: ( 05 meter ) actual: ( box east ).
	self expect: ( 11 meter ) actual: ( box north ).
	self expect: ( 15 meter ) actual: ( box top ).
	self expect: (  HumVector newFrom: {0 meter. 0 meter. 0 meter}  ) actual: ( box center ).
	self expect: ( 05 meter ) actual: ( box maxX ).
	self expect: ( 11 meter ) actual: ( box maxY ).
	self expect: ( 15 meter ) actual: ( box maxZ ).
	box yawRate: ( 0.5 rps ). "Rotate 180 degrees per second. -- Should leave maxX . . . the same."
	box pitchRate: ( 0.5 rps ).
	box rollRate: ( 0.5 rps ).
	box velocity: ( HumVector newFrom: { 100 mps. 100 mps. 100 mps.} ).
	box step: ( HumMeasure seconds: 1 ).
	self expect: ( HumVector newFrom: {100 meter. 100 meter. 100 meter} ) actual: ( box center ).
	"Expect X and Z bounds to exchange."
	self expect: ( 105 meter ) actual: ( box maxX ).
	self expect: ( 095 meter ) actual: ( box minX ).
	self expect: ( 111 meter ) actual: ( box maxY ).
	self expect: ( 089 meter ) actual: ( box minY ).
	self expect: ( 115 meter ) actual: ( box maxZ ).
	self expect: ( 085 meter ) actual: ( box minZ ).
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test610buildElipsoid [
	| elipsoid |
	elipsoid := H3dObject newElipsoidWidth: (10 meter) length: (20 meter) height: (30 meter).
	"Check that dimensions were stored."
	self expect: (HumMeasure quantity: (5*10*15*(Float pi)*4/3) units: 'cubic meter') actual: (elipsoid volume).
	"The number of polygons should be the square of the numberOfWedges."
	self expect: (elipsoid numberOfWedges squared) actual: (elipsoid polygons size).
	"Check that the polygons are in range."
	self expect: ( 05.0 meter ) actual: ( elipsoid maxX ).	
	self expect: ( 10.0 meter ) actual: ( elipsoid maxY ).	
	self expect: ( 15.0 meter ) actual: ( elipsoid maxZ ).	
		
	self expect: ( -05.0 meter ) actual: ( elipsoid minX ).	
	self expect: ( -10.0 meter ) actual: ( elipsoid minY ).	
	self expect: ( -15.0 meter ) actual: ( elipsoid minZ ).	


]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test620yawElipsoid90degrees [
	"90 degree yaw exchanges X and Y"
	| elipsoid |
	elipsoid := H3dObject newElipsoidWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: ( 05.0 meter ) actual: ( elipsoid maxX ).	
	self expect: ( 10.0 meter ) actual: ( elipsoid maxY ).	
	self expect: ( 15.0 meter ) actual: ( elipsoid maxZ ).	
	elipsoid yaw: ((Float pi)/ 2.0) radian.
	self expect: ( 10.0 meter ) actual: ( elipsoid maxX ).	
	self expect: ( 05.0 meter ) actual: ( elipsoid maxY ).	
	self expect: ( 15.0 meter ) actual: ( elipsoid maxZ ).	
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test630pitchElipsoid90degrees [
	"90 degree pitch exchanges Y and Z"
	| elipsoid |
	elipsoid := H3dObject newElipsoidWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: ( 05.0 meter ) actual: ( elipsoid maxX ).	
	self expect: ( 10.0 meter ) actual: ( elipsoid maxY ).	
	self expect: ( 15.0 meter ) actual: ( elipsoid maxZ ).	
	elipsoid pitch: ((Float pi)/ 2.0) radian.
	self expect: ( 05.0 meter ) actual: ( elipsoid maxX ).	
	self expect: ( 15.0 meter ) actual: ( elipsoid maxY ).	
	self expect: ( 10.0 meter ) actual: ( elipsoid maxZ ).	
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test640rollElipsoid90degrees [
	"90 degree roll exchanges X and Z bounds"
	| elipsoid |
	elipsoid := H3dObject newElipsoidWidth: (10 meter) length: (20 meter) height: (30 meter).
	self expect: ( 05.0 meter ) actual: ( elipsoid maxX ).	
	self expect: ( 10.0 meter ) actual: ( elipsoid maxY ).	
	self expect: ( 15.0 meter ) actual: ( elipsoid maxZ ).	
	elipsoid roll: ((Float pi)/ 2.0) radian.
	self expect: ( 15.0 meter ) actual: ( elipsoid maxX ).	
	self expect: ( 10.0 meter ) actual: ( elipsoid maxY ).	
	self expect: ( 05.0 meter ) actual: ( elipsoid maxZ ).	
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test710buildRotation [
	| rotation xyPoints |
	xyPoints := H3dPath newFrom: { 0@0. 11@0. 11@11. 0@11. } units: #meter.
	rotation := H3dObject newRotationAround: #z curve: xyPoints.
	rotation numberOfWedges: 4.
	"Check that dimension were stored."
	self expect: 12 actual: ( rotation polygons size ).
	"Check expected bounds"
	self expect: ( 11 meter ) actual: ( rotation maxX ).
	self expect: ( 11 meter ) actual: ( rotation maxY ).
	self expect: ( 11 meter ) actual: ( rotation maxZ ).
	
	self expect: ( -11 meter ) actual: ( rotation minX ).
	self expect: ( -11 meter ) actual: ( rotation minY ).
	self expect: ( 0 meter ) actual: ( rotation minZ ).
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test711buildRotationAroundX [
	| rotation xyPoints |
	xyPoints := H3dPath newFrom: { 0@0. 11@0. 11@11. 0@11. } units: #meter.
	rotation := H3dObject newRotationAround: #x curve: xyPoints.
	rotation numberOfWedges: 4.
	"Check that dimension were stored."
	self expect: 12 actual: ( rotation polygons size ).
	"Check expected bounds"
	self expect: ( 11 meter ) actual: ( rotation maxX ).
	self expect: (11 meter ) actual: ( rotation maxY ).
	self expect: ( 11 meter ) actual: ( rotation maxZ ).
	
	self expect: ( 0 meter ) actual: ( rotation minX ).
	self expect: ( -11 meter ) actual: ( rotation minY ).
	self expect: ( -11 meter ) actual: ( rotation minZ ).
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test712buildRotationAroundY [
	| rotation xyPoints |
	xyPoints := H3dPath newFrom: { 0@0. 11@0. 11@11. 0@11. } units: #meter.
	rotation := H3dObject newRotationAround: #y curve: xyPoints.
	rotation numberOfWedges: 4.
	"Check that dimension were stored."
	self expect: 12 actual: ( rotation polygons size ).
	"Check expected bounds"
	self expect: ( 11 meter ) actual: ( rotation maxX ).
	self expect: ( 11 meter ) actual: ( rotation maxY ).
	self expect: ( 11 meter ) actual: ( rotation maxZ ).
	
	self expect: ( -11 meter ) actual: ( rotation minX ).
	self expect: ( 0 meter ) actual: ( rotation minY ).
	self expect: ( -11 meter ) actual: ( rotation minZ ).
	
]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test810buildAssembly [
	| boxA boxB boxC assembly |
	boxA := H3dObject newBoxWidth: ( 0.10 meter ) length: ( 0.20 meter)  height: ( 0.30 meter ).
	boxB := H3dObject newBoxWidth: ( 1.10 meter ) length: ( 1.20 meter ) height: ( 1.30 meter ).
	boxC := H3dObject newBoxWidth: ( 2.10 meter ) length: ( 2.20 meter ) height: ( 2.30 meter ).
	assembly := H3dObject newAssemblyFromParts: { boxA. boxB. boxC }.

]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test820stackBoxes [
	| boxA boxB boxC assembly clearance totalHeight |
	boxA := H3dObject newBoxWidth: ( 0.10 meter ) length: ( 0.20 meter)  height: ( 0.30 meter ).
	boxB := H3dObject newBoxWidth: ( 1.10 meter ) length: ( 1.20 meter ) height: ( 1.30 meter ).
	boxC := H3dObject newBoxWidth: ( 2.10 meter ) length: ( 2.20 meter ) height: ( 2.30 meter ).
	assembly := H3dObject newAssemblyFromParts: { boxA. boxB. boxC }.
	"Part positions are relative to the assembly center."
	assembly center: (HumVector newFrom: { 10.0 meter. 20.0 meter. 30.0 meter. }).
	assembly move: boxA toMyCoordinate: ( HumVector newFrom: { 1.0 meter. 2.0 meter. 3.0 meter. } ).
	assembly place: boxB onTopOf: boxA.
	assembly place: boxC onTopOf: boxB.
	"Check resulting positions in CONTAINER coordinates."
	self expect:  ( HumVector newFrom: { 1.0 meter. 2.0 meter. 3.0 meter. } ) actual: ( boxA center ).

	self expect: ( boxA center x ) actual: ( boxB center x ).
	self expect: ( boxA center y ) actual: ( boxB center y ).
	self expect: ( boxA center x ) actual: ( boxC center x ).
	self expect: ( boxA center y ) actual: ( boxC center y ).

	clearance := 0.001 meter.
	self expect: ( ( boxA center z ) +  ( boxA height/2 ) )  actual: ( boxA maxZ ).
	self expect: ( boxA maxZ + clearance + ( boxB height ) ) actual: ( boxB maxZ ).
	self expect: ( boxB maxZ + clearance + ( boxC height ) ) actual: ( boxC maxZ ).
	totalHeight := boxA height + clearance + boxB height + clearance + boxC height.
	self expect: ( 3.902 meter ) actual: (totalHeight).

	"Check resulting positions in SCENE coordinates"
	self expect: ( ( assembly center + boxA center) x + ((boxC width)/2.0 ) ) actual: ( assembly maxX ).
	self expect: ( ( assembly center + boxA center) x - ((boxC width)/2.0 )  ) actual: ( assembly minX ).
	self expect: ( ( assembly center + boxA center) y + ((boxC length)/2.0 ) ) actual: ( assembly maxY ).
	self expect: ( ( assembly center + boxA center) y - ((boxC length)/2.0 ) ) actual: ( assembly minY ).
	self expect: ( ( assembly center + boxA center) z - ((boxA height)/2.0 ) ) actual: ( assembly minZ ).
	self expect: ( ( assembly center + boxA center) z - ((boxA height)/2.0 ) + totalHeight ) actual: ( assembly maxZ ).

]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test821stackAndYaw90 [
	| boxA boxB boxC assembly clearance totalHeight heightOverPivot |
	boxA := H3dObject newBoxWidth: ( 0.10 meter ) length: ( 0.20 meter)  height: ( 0.30 meter ).
	boxB := H3dObject newBoxWidth: ( 1.10 meter ) length: ( 1.20 meter ) height: ( 1.30 meter ).
	boxC := H3dObject newBoxWidth: ( 2.10 meter ) length: ( 2.20 meter ) height: ( 2.30 meter ).
	assembly := H3dObject newAssemblyFromParts: { boxA. boxB. boxC }.
	"Part positions are relative to the assembly center."
	assembly center: (HumVector newFrom: { 10.0 meter. 20.0 meter. 30.0 meter. }).
	assembly move: boxA toMyCoordinate: ( HumVector newFrom: { 1.0 meter. 2.0 meter. 3.0 meter. } ).
	assembly place: boxB onTopOf: boxA.
	assembly place: boxC onTopOf: boxB.
	"Check resulting positions in CONTAINER coordinates."
	self expect:  ( HumVector newFrom: { 1.0 meter. 2.0 meter. 3.0 meter. } ) actual: ( boxA center ).

	self expect: ( boxA center x ) actual: ( boxB center x ).
	self expect: ( boxA center y ) actual: ( boxB center y ).
	self expect: ( boxA center x ) actual: ( boxC center x ).
	self expect: ( boxA center y ) actual: ( boxC center y ).

	clearance := 0.001 meter.
	self expect: ( ( boxA center z ) +  ( boxA height/2 ) )  actual: ( boxA maxZ ).
	self expect: ( boxA maxZ + clearance + ( boxB height ) ) actual: ( boxB maxZ ).
	self expect: ( boxB maxZ + clearance + ( boxC height ) ) actual: ( boxC maxZ ).
	totalHeight := boxA height + clearance + boxB height + clearance + boxC height.
	self expect: ( 3.902 meter ) actual: (totalHeight).

	"Check resulting positions in SCENE coordinates"
	assembly pivotPoint: boxA center. 
	assembly
		yaw: 0.0 radian.
	"Zero yaw should have no effect."	
	self expect: ( ( assembly center + boxA center) x + ( (boxC width) / 2.0 ) ) actual: ( assembly maxX ).
	self expect: ( ( assembly center + boxA center) x - ( (boxC width) / 2.0 )  ) actual: ( assembly minX ).
	self expect: ( ( assembly center + boxA center) y + ( (boxC length) / 2.0 ) ) actual: ( assembly maxY ).
	self expect: ( ( assembly center + boxA center) y - ( (boxC length) / 2.0 ) ) actual: ( assembly minY ).
	self expect: ( ( assembly center + boxA center) z - ( (boxA height) / 2.0 ) ) actual: ( assembly minZ ).
	self expect: ( ( assembly center + boxA center) z - ( (boxA height) / 2.0 ) + totalHeight ) actual: ( assembly maxZ ).
	
	"Yaw 90 degrees and see . . ."
	assembly
		yaw: (Float pi/2.0) radian.
	heightOverPivot := totalHeight - (boxA height/2.0).
	"x and y offsets should exchange"
	self expect: ( ( assembly center + boxA center) x + ( (boxC length) / 2.0 ) ) actual: ( assembly maxX ). "STS"
	self expect: ( ( assembly center + boxA center) x - ( (boxC length) / 2.0 )  ) actual: ( assembly minX ).	"STS"
	self expect: ( ( assembly center + boxA center) y + ( (boxC width ) / 2.0 ) ) actual: ( assembly maxY ).
	self expect: ( ( assembly center + boxA center) y - ( (boxC width) / 2.0 ) ) actual: ( assembly minY ).
	self expect: ( ( assembly center + boxA center) z - ( (boxA height) / 2.0 ) ) actual: ( assembly minZ ).
	self expect: ( ( assembly center + boxA center) z - ( (boxA height) / 2.0 ) + totalHeight ) actual: ( assembly maxZ ).

]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test822stackAndPitch90 [
	| boxA boxB boxC assembly clearance totalHeight heightOverPivot |
	boxA := H3dObject newBoxWidth: ( 0.10 meter ) length: ( 0.20 meter)  height: ( 0.30 meter ).
	boxB := H3dObject newBoxWidth: ( 1.10 meter ) length: ( 1.20 meter ) height: ( 1.30 meter ).
	boxC := H3dObject newBoxWidth: ( 2.10 meter ) length: ( 2.20 meter ) height: ( 2.30 meter ).
	assembly := H3dObject newAssemblyFromParts: { boxA. boxB. boxC }.
	"Part positions are relative to the assembly center."
	assembly center: (HumVector newFrom: { 10.0 meter. 20.0 meter. 30.0 meter. }).
	assembly move: boxA toMyCoordinate: ( HumVector newFrom: { 1.0 meter. 2.0 meter. 3.0 meter. } ).
	assembly place: boxB onTopOf: boxA.
	assembly place: boxC onTopOf: boxB.
	"Check resulting positions in CONTAINER coordinates."
	self expect:  ( HumVector newFrom: { 1.0 meter. 2.0 meter. 3.0 meter. } ) actual: ( boxA center ).

	self expect: ( boxA center x ) actual: ( boxB center x ).
	self expect: ( boxA center y ) actual: ( boxB center y ).
	self expect: ( boxA center x ) actual: ( boxC center x ).
	self expect: ( boxA center y ) actual: ( boxC center y ).

	clearance := 0.001 meter.
	self expect: ( ( boxA center z ) +  ( boxA height/2 ) )  actual: ( boxA maxZ ).
	self expect: ( boxA maxZ + clearance + ( boxB height ) ) actual: ( boxB maxZ ).
	self expect: ( boxB maxZ + clearance + ( boxC height ) ) actual: ( boxC maxZ ).
	totalHeight := boxA height + clearance + boxB height + clearance + boxC height.
	self expect: ( 3.902 meter ) actual: (totalHeight).

	"Check resulting positions in SCENE coordinates"
	assembly pivotPoint: boxA center. 
	assembly
		pitch: 0.0 radian.
	"Zero pitch should have no effect."	
	self expect: ( ( assembly center + boxA center) x + ( (boxC width) / 2.0 ) ) actual: ( assembly maxX ).
	self expect: ( ( assembly center + boxA center) x - ( (boxC width) / 2.0 )  ) actual: ( assembly minX ).
	self expect: ( ( assembly center + boxA center) y + ( (boxC length) / 2.0 ) ) actual: ( assembly maxY ).
	self expect: ( ( assembly center + boxA center) y - ( (boxC length) / 2.0 ) ) actual: ( assembly minY ).
	self expect: ( ( assembly center + boxA center) z - ( (boxA height) / 2.0 ) ) actual: ( assembly minZ ).
	self expect: ( ( assembly center + boxA center) z - ( (boxA height) / 2.0 ) + totalHeight ) actual: ( assembly maxZ ).
	
	"Pitch 90 degrees up and see . . ."
	assembly
		pitch: (Float pi/2.0) radian.
	heightOverPivot := totalHeight - (boxA height/2.0).
	"y and z offsets should exchange"
	self expect: ( ( assembly center + boxA center) x + ( (boxC width) / 2.0 ) ) actual: ( assembly maxX ). "STS"
	self expect: ( ( assembly center + boxA center) x - ( (boxC width) / 2.0 )  ) actual: ( assembly minX ).	"STS"
	self expect: ( ( assembly center + boxA center) y + ( boxA height / 2.0)  ) actual: ( assembly maxY ).
	self expect: ( ( assembly center + boxA center) y - heightOverPivot ) actual: ( assembly minY ).
	self expect: ( ( assembly center + boxA center) z - ( (boxC length) / 2.0 )  ) actual: ( assembly minZ ).
	self expect: ( ( assembly center + boxA center) z + ( (boxC length) / 2.0 )  ) actual: ( assembly maxZ ).

]

{ #category : #'as yet unclassified' }
H3dObjectTests >> test824stackAndRoll90 [
	| boxA boxB boxC assembly clearance totalHeight heightOverPivot |
	boxA := H3dObject newBoxWidth: ( 0.10 meter ) length: ( 0.20 meter)  height: ( 0.30 meter ).
	boxB := H3dObject newBoxWidth: ( 1.10 meter ) length: ( 1.20 meter ) height: ( 1.30 meter ).
	boxC := H3dObject newBoxWidth: ( 2.10 meter ) length: ( 2.20 meter ) height: ( 2.30 meter ).
	assembly := H3dObject newAssemblyFromParts: { boxA. boxB. boxC }.
	"Part positions are relative to the assembly center."
	assembly center: (HumVector newFrom: { 10.0 meter. 20.0 meter. 30.0 meter. }).
	assembly move: boxA toMyCoordinate: ( HumVector newFrom: { 1.0 meter. 2.0 meter. 3.0 meter. } ).
	assembly place: boxB onTopOf: boxA.
	assembly place: boxC onTopOf: boxB.
	"Check resulting positions in CONTAINER coordinates."
	self expect:  ( HumVector newFrom: { 1.0 meter. 2.0 meter. 3.0 meter. } ) actual: ( boxA center ).

	self expect: ( boxA center x ) actual: ( boxB center x ).
	self expect: ( boxA center y ) actual: ( boxB center y ).
	self expect: ( boxA center x ) actual: ( boxC center x ).
	self expect: ( boxA center y ) actual: ( boxC center y ).

	clearance := 0.001 meter.
	self expect: ( ( boxA center z ) +  ( boxA height/2 ) )  actual: ( boxA maxZ ).
	self expect: ( boxA maxZ + clearance + ( boxB height ) ) actual: ( boxB maxZ ).
	self expect: ( boxB maxZ + clearance + ( boxC height ) ) actual: ( boxC maxZ ).
	totalHeight := boxA height + clearance + boxB height + clearance + boxC height.
	self expect: ( 3.902 meter ) actual: (totalHeight).

	"Check resulting positions in SCENE coordinates"
	assembly pivotPoint: boxA center. 
	assembly
		roll: 0.0 radian.
	"Zero roll should have no effect."	
	self expect: ( ( assembly center + boxA center) x + ( (boxC width) / 2.0 ) ) actual: ( assembly maxX ).
	self expect: ( ( assembly center + boxA center) x - ( (boxC width) / 2.0 )  ) actual: ( assembly minX ).
	self expect: ( ( assembly center + boxA center) y + ( (boxC length) / 2.0 ) ) actual: ( assembly maxY ).
	self expect: ( ( assembly center + boxA center) y - ( (boxC length) / 2.0 ) ) actual: ( assembly minY ).
	self expect: ( ( assembly center + boxA center) z - ( (boxA height) / 2.0 ) ) actual: ( assembly minZ ).
	self expect: ( ( assembly center + boxA center) z - ( (boxA height) / 2.0 ) + totalHeight ) actual: ( assembly maxZ ).
	
	"Roll 90 degrees and see . . ."
	assembly
		roll: (Float pi/2.0) radian.
	heightOverPivot := totalHeight - (boxA height/2.0).
	"x and z offsets should exchange"
	self expect: ( ( assembly center + boxA center) x + ( (boxA height) / 2.0 ) ) actual: ( assembly maxX ). 
	self expect: ( ( assembly center + boxA center) x - heightOverPivot  ) actual: ( assembly minX ).	
	self expect: ( ( assembly center + boxA center) y + ( boxC length / 2.0)  ) actual: ( assembly maxY ).	"STS"
	self expect: ( ( assembly center + boxA center) y - ( boxC length / 2.0)  ) actual: ( assembly minY ).		"STS"
	self expect: ( ( assembly center + boxA center) z - ( (boxC width) / 2.0 )  ) actual: ( assembly minZ ).
	self expect: ( ( assembly center + boxA center) z + ( (boxC width) / 2.0 )  ) actual: ( assembly maxZ ).

]
