"
The Hum-X package contains 'thinking out loud' code.
Basically, I am thinking about refactoring the persistence system.

My review of current code for world-base, blackboard, entity (HumWorldBase, HumBlackboard, HumEntity)
caused me to feel that there was a design problem 
- those classes did not conform to my expected abstractions.
Also: My fondness for ""quad"" data structure seemed to be skewing the design and the code.
So I decided to experiment with a redesign.

So far, it appears that giving more strength to the Entity concept seems to simplify blackboard and base.

I simplified HTime - making it a singleton that generates unique timestamps as large integers.
That seems to be simplifying some of the code.

I made Event an explicit class and a subclass of Entity.
The who, what, when, where, why attributes of Event 
are NOT sufficiently well-defined as a methodology for consistently describing a business event.
But I am reluctant to abandon the five W`s.  (See HEvent for attempt to stabilize.)
"
Class {
	#name : #HumXReadMe,
	#superclass : #Object,
	#category : #'Hum-X'
}
