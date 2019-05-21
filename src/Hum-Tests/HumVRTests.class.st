"
Use Cases:
. Create a VR with 2 scenes.
. Build scenes.
. Build avatar.
. Walk avatar through a scene.
. Teleport to other scene.
. Proximity detection - event-driven behavior.
. Collision detection - physics.


"
Class {
	#name : #HumVRTests,
	#superclass : #HumTestCase,
	#category : #'Hum-Tests'
}

{ #category : #'as yet unclassified' }
HumVRTests >> test100CreateVRwith2scenes [
	"A virtual reality has one or more scenes."

	| world sceneA sceneB |
	"Create a VR world"
	world := HumVR new.
	"Create two scenes"
	sceneA := HumScene id: 'Scene with cube'.
	sceneA addPart: (HumBox new).
	sceneB := HumScene id: 'Scene with ball'.
	sceneB addPart: (HumElipsoid new).
	"Add scenes to world."
	world addScene: sceneA.
	world addScene: sceneB.
	"Start the world - stepping."
	world start.
	"Stop the world - stop stepping."
	world stop.
]
