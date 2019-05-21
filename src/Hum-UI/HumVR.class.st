"
A Virtual Reality contains one or more Scenes.

see also: HumScene.

HumVR is a model.
HumVRController is the intended controller.
"
Class {
	#name : #HumVR,
	#superclass : #HumAssembly,
	#instVars : [
		'scenes',
		'jumpTime'
	],
	#category : #'Hum-UI'
}

{ #category : #access }
HumVR >> addScene: aHumScene [ 
	self scenes at: aHumScene id put: aHumScene.
]

{ #category : #stepping }
HumVR >> jump:  aTime [
	"Execute equations of motion, etc."
	self jumpTime: aTime.
	self scenes do: [ :scene | scene jump: (self jumpTime) ].
	"TODO: Make compatible to HumSimulator."
]

{ #category : #stepping }
HumVR >> jumpTime [
	"Get the latest VR-world time. This is set by the last time-jump. See: #jump: "
	jumpTime ifNil: [ self jumpTime: (HumMeasure seconds: 1) ].
	^jumpTime.
]

{ #category : #stepping }
HumVR >> jumpTime: aTime [
	"Set the VR-world time. (Use to synchronize state across scenes) - called from #jump:"

	self assert: (aTime isKindOf: HumMeasure).
	self assert: (aTime dimensions = (HumMeasure seconds: 1) dimensions ).
	jumpTime := aTime.
]

{ #category : #access }
HumVR >> scenes [
	"A VR world has one or more scenes identified and accessed by their IDs. "
	^ scenes ifNil: [  scenes := Dictionary new ].
]

{ #category : #stepping }
HumVR >> start [
	"Start stepping."
	self jump: (self jumpTime) "*** STUB ***  TODO: Fork a process and start it stepping."
]

{ #category : #stepping }
HumVR >> stop [
	"Stop stepping"
	
]
