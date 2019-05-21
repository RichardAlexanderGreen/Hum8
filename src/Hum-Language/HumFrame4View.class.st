"
A view frame indicates the organization of a user interface - as an interactive document.
- The view frame notation is a mainly a mark-up notation. (See: HumMarkupLine.)
- Some instructions might be intermixed.
The instructions are intended for the view-frame translators.
For example.
"". Table of <plural-noun>:""

The user views and enters data shown in data-slots (fields)
as indicated by the mark-up.
The intention of a view-frame is that it will be implemented (translated to)
in some user-interface framework such as HTML5, Pharo-Morphs, or perhaps Hum itself.

Instance Variables:
	entity	<a noun> -- The entity which is the subject of the view.
"
Class {
	#name : #HumFrame4View,
	#superclass : #HumFrame,
	#instVars : [
		'entity'
	],
	#category : #'Hum-Language'
}

{ #category : #'instance-creation' }
HumFrame4View class >> ontology: anOntology title: aString [ 
	"Create an instance based on the given title-line."
	| instance  |
	instance := self new.
	instance ontology: anOntology.
	instance titleLine: aString.
	^ instance.
]

{ #category : #'instance-creation' }
HumFrame4View class >> ontology: aHumOntology viewEntity: entityType [ 
	| frame |
	frame := self new.
	frame
			titleLine: 'View: ', entityType, '.';
			ontology: aHumOntology.
	"TODO: Think through instantiation via view. Add tests."
	^frame. 
]

{ #category : #'instance-creation' }
HumFrame4View class >> titleLine: aString [ 
	"Create an instance based on the given title-line."
	| instance  |
	instance := self new.
	instance titleLine: aString. 
	^ instance.
]

{ #category : #accessing }
HumFrame4View >> addMarkUp: aSource [ 
	| frameLine |
	(aSource isKindOf: String)
		ifTrue: [ frameLine := HumMarkupLine source: aSource ].
	(aSource isKindOf: HumMarkupLine )
		ifTrue: [ frameLine := aSource ].
	frameLine ifNil: [Error signal: 'Unexpected object type.'].	
	self frameLines add: frameLine.
]

{ #category : #'as yet unclassified' }
HumFrame4View >> compileToOntology: aHumOntology [
	""
	| errors |
	"Make sure frame is stored."
	aHumOntology storeFrame: self.

	errors := OrderedCollection new.
	"Index cases where a widget refers to another view."
	(self frameLines select: [:frameLine | frameLine isKindOf: HumMarkupLine ])
		do: [ :frameLine |
			| widgets |
			widgets := frameLine widgets.
			widgets
				do: [ :widget |	
					('[pane: *]' match: widget)
						ifTrue: ["Index this case."
							| viewName |
							viewName := (HumCalculator given: widget extractBetween: '[pane:' and: ']') trimBoth.
							"(aHumOntology frameRelations) add: { (self title). #invokesView. viewName. }"
							aHumOntology indexFrame: self relation: #invokesView object: viewName.
							].
					].
			].
		^errors := (super compileToOntology: aHumOntology ).
]

{ #category : #accessing }
HumFrame4View >> entity [
	entity
		ifNil: [ self viewEntity: ( (HumCalculator given: self frameName extractBetween: ' ' and: '.') asLowercase ) 	].
	^entity.
]

{ #category : #accessing }
HumFrame4View >> viewEntity: anEntityType. [ 
	"What entity-type is this view displaying."
"*** Following should be compile-time problems. But are crashing load process. ***"
"*** REMOVED FOR NOW
	self assert: ('* *' match: anEntityType) not description: 'The view name should be a noun - no space/s.'.
	self assert: ('*.*' match: anEntityType) not description: 'The view name should be a noun - no period/s.'.
	self assert: (self ontology isEntity: anEntityType) description: 'View {', self frameName, '} should name an entity.'.
	"
	entity := anEntityType.
]
