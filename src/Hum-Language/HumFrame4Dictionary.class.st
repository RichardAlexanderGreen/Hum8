"
A dictionary frame defines noun relationships.
"
Class {
	#name : #HumFrame4Dictionary,
	#superclass : #HumFrame,
	#category : #'Hum-Language'
}

{ #category : #'as yet unclassified' }
HumFrame4Dictionary class >> ontology: anOntology title: aString [
	"Create an instance with this ontology and title"
	| instance |
	instance := self new.
	instance
		ontology: anOntology;
		titleLine: (aString).
	^instance
]

{ #category : #accessing }
HumFrame4Dictionary >> addDictionaryLine: aSourceString [ 
	| dictionaryLine |
	dictionaryLine := HumDictionaryLine new source: aSourceString.
	self frameLines add: dictionaryLine.
]

{ #category : #testing }
HumFrame4Dictionary >> compileToOntology: aHumOntology [ 
	"Each dictionary line will have some additive effect on the ontology."
	| syntaxErrors lineErrors |
	"Make sure frame is stored."
	"aHumOntology storeFrame: self."

	"We may discover syntax errors while compiling."
	syntaxErrors := OrderedCollection new.
	(self frameLines select: [ :frameLine | frameLine isKindOf: HumDictionaryLine ] )
		do: [ :dictionaryLine |
			lineErrors := dictionaryLine compileLineToOntology: aHumOntology.
			syntaxErrors := syntaxErrors, lineErrors.
			].
	^syntaxErrors.
]
