"
This class (super class) holds the tests where Seaside is used to implement various Hum capabilities.

Subclasses:
- HumSeasideProgrammersAssistantTests holds tests for the Seaside implementation of the Programmers Assistant.
- HumSeasideUserInterfaceTests hold tests for the Seaside implementation of the view-frame interpreter.

Note that the Programmers Assistant is partially implemented in Hum, so that the PA implementation depends on the View and Dialog implementation.

TODO: This class duplicates methods from GivenWhenThen. Consider using a trait or composition instead.
"
Class {
	#name : #HumSeasideTests,
	#superclass : #GivenWhenThen4Seaside,
	#category : #'Hum-Tests'
}
