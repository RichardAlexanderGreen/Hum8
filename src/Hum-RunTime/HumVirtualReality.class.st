"
A virtual reality contains one or more scenes (HumScene).

Scenes contain objects (HumBox).
The Scene and its Objects may respond to Sensor events.

A virtual reality (VR) contains one or more scenes - It is a model.
The VR-controller (a HumSimulator subclass) 
 provides an API for manipulating scene objects.
External and internal events are added to the event schedule 
 and executed when the internal clock (real or simulated clock) triggers the event.
"
Class {
	#name : #HumVirtualReality,
	#superclass : #HumNode,
	#category : #'Hum-RunTime'
}
