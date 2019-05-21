"
These HumSeasideTests are adapted from HumProgrammerAssistantTests.
	The Programmers Assistant provides a technology-free model of the UI.
	The Hum Seaside classes provide UI components via Seaside.
"
Class {
	#name : #HumSeasideProgrammersAssistantTests,
	#superclass : #HumSeasideTests,
	#category : #'Hum-Tests'
}

{ #category : #'PA100 Ontology Actions' }
HumSeasideProgrammersAssistantTests >> aReadMe [
	"
	These HumSeasideTests are adapted from HumProgrammerAssistantTests.
	The Programmers Assistant provides a technology-free model of the UI.
	The Hum Seaside classes provide a UI in Seaside.

	"
	^'See the class description for the intended (future) tests.'
	
]

{ #category : #'PA100 Ontology Actions' }
HumSeasideProgrammersAssistantTests >> test110newOntology [
	"Browser initializes (re-initializes) to an empty ontology."
	| browser |
	browser := HumBrowser new.
	browser clearOntology.
	self assert: (browser ontology nouns isEmpty).
]

{ #category : #'PA100 Ontology Actions' }
HumSeasideProgrammersAssistantTests >> test121loadOntologyInstance [
	"Browser saves (writes) the ontology to a file."
	| browser ontology |
	browser := HumBrowser new.
	browser loadOntologyInstance: 'Hum Seaside Test Ontology'.
	self assert: browser ontology notNil.
	browser saveOntology.
	
]

{ #category : #'PA100 Ontology Actions' }
HumSeasideProgrammersAssistantTests >> test130saveOntology [
	"Browser saves (writes) the ontology to a file."
	| browser |
	browser := HumBrowser new.
	browser clearOntology.
	browser saveOntology.
	
]

{ #category : #'PA200 Menu Dialogs' }
HumSeasideProgrammersAssistantTests >> test222OpenOntologyInstance [
	"Test the dialog that asks the user for the file name."
	| browser fileName |
	"
	Given: User has invokes 'Open ontology' in the browser menu.
	When: User enters an existing (test) filename . . .
	Then: The ontology attached to the browser matches the content of the test file.
	"
	browser := HumBrowser new.
	browser loadOntologyInstance: 'Hum Seaside Test Ontology'.
	self assert: (browser ontology isKindOf: HumOntology).
	self assert: browser ontology title = 'Hum Seaside Test Ontology'.
	
]
