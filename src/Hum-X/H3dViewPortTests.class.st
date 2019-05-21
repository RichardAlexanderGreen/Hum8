Class {
	#name : #H3dViewPortTests,
	#superclass : #Object,
	#category : #'Hum-X'
}

{ #category : #'Camera Tests' }
H3dViewPortTests >> test110CreateCamera [
	| camera scene |
	"A camera is a 3d-object. Dimensions refer to virtual viewport and eye-point."
	camera := H3dCamera depth: 0.40 meter height: 0.20 meter width: 0.30 meter.
	self expect: 0.40 meter actual: camera depth.
	self expect: 0.20 meter actual: camera height.
	self expect: 0.30 meter actual: camera width.
	"A camera has a position in a scene."
	scene := H3dObject newAssemblyFromParts: { camera }.
	scene move: camera toMyCoordinate: ( HumVector newFrom: { 10. 20. 30. } ).  
	self expect: 10.0 meter actual: ( camera center x ).	
	self expect: 20.0 meter actual: ( camera center y ).	
	self expect: 30.0 meter actual: ( camera center z ).
	"A camera has an orientation."
	camera pitch: (-10 degrees).
	self expect: ( HumMeasure ) actual: ( camera pitch class ).
	self expect: ( #radian ) actual: ( camera pitch units ).
	self expect: ( 10 degrees negated ) actual: ( camera pitch ).
	"Camera views scene"
	camera scene: scene.
]

{ #category : #'Camera Tests' }
H3dViewPortTests >> test120ProjectScenePointToCameraViewPort [
	|  camera  scenePoint viewPoint |
	"A camera is a 3d-object with dimensions of ..."
	camera := H3dCamera depth: 0.40 meter height: 0.20 meter width: 0.30 meter.
	self expect: ( HumVector newFrom: { 0.0 meter. 0.0 meter. 0.0 meter. } ) actual: ( camera center ).
	"For this test the orientation is level with no yaw."
	self expect: (0.0 radian) actual: ( camera pitch ).
	self expect: (0.0 radian) actual: ( camera roll ).
	self expect: (0.0 radian) actual: ( camera yaw ).
	"Test private method ..."
	scenePoint := HumVector newFrom: { 1.0 meter. 10.0 meter. 2.0 meter. }.
	viewPoint := camera projectScenePointToScreenPoint: scenePoint. 
	self expect: (HumVector newFrom: { 0.04 meter. 10.0 meter. 0.08 meter. })  actual: viewPoint .

]

{ #category : #'Camera Tests' }
H3dViewPortTests >> test130PitchCamera [
	|  camera  scenePoint viewPoint |
	"A camera is a 3d-object with dimensions of ..."
	camera := H3dCamera depth: 0.40 meter height: 0.20 meter width: 0.30 meter.
	self expect: ( HumVector newFrom: { 0.0 meter. 0.0 meter. 0.0 meter. } ) actual: ( camera center ).
	"For this test the orientation is level with no yaw."
	self expect: (0.0 radian) actual: ( camera pitch ).
	self expect: (0.0 radian) actual: ( camera roll ).
	self expect: (0.0 radian) actual: ( camera yaw ).
	"Test private method ..."
	scenePoint := HumVector newFrom: { 1.0 meter. 10.0 meter. 2.0 meter. }.
	viewPoint := camera projectScenePointToScreenPoint: scenePoint. 
	self expect: (HumVector newFrom: { 0.04 meter. 10.0 meter. 0.08 meter. })  actual: viewPoint.
	"Pitch the camera up a little."
	camera pitch: ( 0.01 / 0.40 ) arcTan radian.
	viewPoint := camera projectScenePointToScreenPoint: scenePoint. 
	self expect: (HumVector newFrom: { 0.03981 meter. 10.047 meter. 0.06965 meter. })  actual: viewPoint.

]

{ #category : #'Camera Tests' }
H3dViewPortTests >> test140RollCamera [
	|  camera  scenePoint viewPoint |
	"A camera is a 3d-object with dimensions of ..."
	camera := H3dCamera depth: 0.40 meter height: 0.20 meter width: 0.30 meter.
	self expect: ( HumVector newFrom: { 0.0 meter. 0.0 meter. 0.0 meter. } ) actual: ( camera center ).
	"For this test the orientation is level with no yaw."
	self expect: (0.0 radian) actual: ( camera pitch ).
	self expect: (0.0 radian) actual: ( camera roll ).
	self expect: (0.0 radian) actual: ( camera yaw ).
	"Test private method ..."
	scenePoint := HumVector newFrom: { 1.0 meter. 10.0 meter. 2.0 meter. }.
	viewPoint := camera projectScenePointToScreenPoint: scenePoint. 
	self expect: (HumVector newFrom: { 0.04 meter. 10.0 meter. 0.08 meter. })  actual: viewPoint.
	"Roll the camera 90 degrees."
	camera roll: (Float pi/2.0) radian.
	viewPoint := camera projectScenePointToScreenPoint: scenePoint. 
	self expect: (HumVector newFrom: { 0.08 meter. 10.0 meter. -0.04 meter. }) actual: viewPoint.

]

{ #category : #'Camera Tests' }
H3dViewPortTests >> test150YawCamera [
	|  camera  scenePoint viewPoint |
	"A camera is a 3d-object with dimensions of ..."
	camera := H3dCamera depth: 0.40 meter height: 0.20 meter width: 0.30 meter.
	self expect: ( HumVector newFrom: { 0.0 meter. 0.0 meter. 0.0 meter. } ) actual: ( camera center ).
	"For this test the orientation is level with no yaw."
	self expect: (0.0 radian) actual: ( camera pitch ).
	self expect: (0.0 radian) actual: ( camera roll ).
	self expect: (0.0 radian) actual: ( camera yaw ).
	"Test private method ..."
	scenePoint := HumVector newFrom: { 1.0 meter. 10.0 meter. 2.0 meter. }.
	viewPoint := camera projectScenePointToScreenPoint: scenePoint. 
	self expect: (HumVector newFrom: { 0.04 meter. 10.0 meter. 0.08 meter. })  actual: viewPoint.
	"Yaw the camera a little."
	camera yaw: ( 0.01 / 0.40 ) arcTan radian.
	viewPoint := camera projectScenePointToScreenPoint: scenePoint. 
	self expect: (HumVector newFrom: { 0.050125 meter. 9.972 meter. 0.080226 meter. })  actual: viewPoint.

]

{ #category : #'Camera Tests' }
H3dViewPortTests >> test160TranslateCamera [
	|  camera  scenePoint viewPoint |
	"A camera is a 3d-object with dimensions of ..."
	camera := H3dCamera depth: 0.40 meter height: 0.20 meter width: 0.30 meter.
	self expect: ( HumVector newFrom: { 0.0 meter. 0.0 meter. 0.0 meter. } ) actual: ( camera center ).
	"For this test the orientation is level with no yaw."
	self expect: (0.0 radian) actual: ( camera pitch ).
	self expect: (0.0 radian) actual: ( camera roll ).
	self expect: (0.0 radian) actual: ( camera yaw ).
	"Test private method ..."
	scenePoint := HumVector newFrom: { 1.0 meter. 10.0 meter. 2.0 meter. }.
	viewPoint := camera projectScenePointToScreenPoint: scenePoint. 
	self expect: (HumVector newFrom: { 0.04 meter. 10.0 meter. 0.08 meter. })  actual: viewPoint.
	"Yaw the camera a little."
	camera center: (HumVector newFrom: { 1.0 meter. 0.0 meter. 0.0 meter. }).
	viewPoint := camera projectScenePointToScreenPoint: scenePoint. 
	self expect: (HumVector newFrom: { 0.0 meter. 10.0 meter. 0.08 meter. })  actual: viewPoint.

]

{ #category : #'ViewPort Tests' }
H3dViewPortTests >> test210CreateViewPort [
	"A viewport is a view on a scene via a camera in the scene."
	| viewport camera scene scenePoint viewPoint |
	viewport := H3dViewPort new.
	"A viewport is mapped onto a surface."
	viewport origin: 10@10 extent: 1600@900. "See: Rectangle>>origin:extent:"
	"A viewport scales the camera image."
	viewport scale: 100 px per: 1 centimeter.
	self expect: ( HumMeasure quantity: 100*100 units: #px per: #meter ) actual: ( 100 px / 1 centimeter).
	self expect: ( 100 px / 1 centimeter ) actual: ( viewport scale ).
	"A viewport is attached to a camera in a scene."
	camera := H3dCamera depth: 0.40 meter height: 0.20 meter width: 0.30 meter.
	scene := H3dObject newAssemblyFromParts: { camera }.
	camera scene: scene.
	viewport camera: camera.
	"A viewport maps points in the camera image to points in the viewport image."
	scenePoint := (HumVector newFrom:{ 1.0 meter. 10.0 meter. 2.0 meter. }).
	viewPoint := viewport mapScenePoint: scenePoint.
	self expect: (HumVector newFrom: { 400 px. (10.0*100*100) px. 800 px. }) actual: viewPoint.
	"How much distance does a pixel cover at y distance?"
	self expect: ( 2.5 millimeter ) actual: ( viewport resolutionAt: 10.0 meter ). 
]
