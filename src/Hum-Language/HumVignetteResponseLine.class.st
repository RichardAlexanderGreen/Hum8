"
A vignette response line is either a markup line or an instruction line.

Vignette response markup lines should not contain widgets.
However, '[noun]' may be present to insert a (read-only) noun value.

If an instruction line does not name a specific role,
the DialogAgent role is assumed.
(See BaseOntology.txt for a description of DialogAgent actions.)

See also: HumFrame4Vignette class comment.

TODO: THIS CLASS APPEARS TO BE UNIMPLEMENTED.
"
Class {
	#name : #HumVignetteResponseLine,
	#superclass : #HumFrameLine,
	#category : #'Hum-Language'
}

{ #category : #'as yet unclassified' }
HumVignetteResponseLine >> checkSyntaxWithOntology: aHumOntology [
	" Look for [noun]. Is the noun defined in the ontology?"
	| nounReferences errors |
	errors := OrderedCollection new.
	nounReferences := self extractNounsInBrackets.
	nounReferences do: [ :noun | 
		(aHumOntology isNoun: noun) 
			ifFalse: [ errors add: ('Vignette Response references an unknown noun: ', noun) ].
		].
	^errors.
]
