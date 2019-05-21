"
A vignette pattern may have multiple lines.
Lines are matched in the order given.
So higher lines will match before lower ones.
A pattern starts with a label: 'U:'/'User:'/'Client:'/ or some role-name.

When a pattern is matched, the response lines are then interpreted.

TODO: THIS CLASS APPEARS TO BE UNIMPLEMENTED.
"
Class {
	#name : #HumVignettePatternLine,
	#superclass : #HumFrameLine,
	#category : #'Hum-Language'
}

{ #category : #'as yet unclassified' }
HumVignettePatternLine >> checkSyntaxWithOntology: aHumOntology [
	" Look for [noun]. Is the noun defined in the ontology?"
	| nounReferences errors |
	errors := OrderedCollection new.
	nounReferences := self extractNounsInBrackets.
	nounReferences do: [ :noun | 
		(aHumOntology isNoun: noun) 
			ifFalse: [ errors add: ('Vignette pattern references an unknown noun: ', noun) ].
		].
	^errors.
]
