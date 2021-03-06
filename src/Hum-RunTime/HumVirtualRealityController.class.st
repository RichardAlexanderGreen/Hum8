"
This controller class extends HumSimulator to control a virtual reality (VR).

A virtual reality (VR) contains one or more Scenes - It is a model. (See HumVirtualReality, HumScene)
The VR-controller provides an API for manipulating scene objects. (TODO - MAYBE NOT*)
External and internal events are added to the event schedule 
 and executed when the internal clock (real or simulated clock) triggers the event.

This class extends HumSimulator because . . .
. HumSimulator contains step method, internal event queue, and simulated clock.
. This architecture is designed to synchronize multi-player views via event notices.
. It should simplify TDD (test driven development) at higher levels of integration.
. IT SEEMED LIKE A GOOD IDEA AT THE TIME.

* MAYBE NOT: Controlling scene objects from the controller breaks encapsulation.
But, at first level, that seems to be the nature of controllers.
The ideal is that the controller dispatches events.
Some events would be generated by scene objects,
and some by the user (e.g. manipulating avatar and/or cameras within a scene).
. Scribe: Translate user-gesture into dialog-input.
. Dialog: Match dialog-input to vignette and execute the vignette-response.
. Vignette Response: Invoke role-action statement(s).
. Avatar Role: (Actor) Execute action statement. Generate limb and facial move events.
. VR-Controller: (Actor) Synchonize events - send events to Scene.
. Scene: (Actor) Move scene objects per event. (Change visual object state attributes)
. Scene: (Actor) Inform Camera - Scene changed.
. Camera: (Actor?) Inform attached ViewPorts.
. ViewPort: (UI) Display view of changed scene. (Generate triangles or primative objects, texture)
. Display: (UI) Display view of changed scene. (GPU: generate tesselation, map texture)

TODO: TRY TO WRITE ABOVE AS HUM ROLE-ACTIONS.



"
Class {
	#name : #HumVirtualRealityController,
	#superclass : #HumSimulator,
	#category : #'Hum-RunTime'
}
