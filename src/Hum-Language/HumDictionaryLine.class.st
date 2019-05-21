"
A dictionary line is a line in a dictionary frame.
The statement in a dictionary line must conform to the dictionary DSL.

Instance Variables:
	statement	<HumStatement>
	comment	<String>
"
Class {
	#name : #HumDictionaryLine,
	#superclass : #HumFrameLine,
	#instVars : [
		'statement'
	],
	#category : #'Hum-Language'
}

{ #category : #accessing }
HumDictionaryLine >> comment [
	^ comment ifNil: [ comment := String new. ].
]

{ #category : #compiling }
HumDictionaryLine >> compileLineToOntology: aHumOntology [ 
	"Add nouns and noun-relations to the ontology.
	If statement does not match a dictionary statement pattern,
	return an error.
	"
	| lineErrors s |

	"We may discover syntax errors while compiling.
	 Return an empty list when statement matches okay.
	"
	lineErrors := OrderedCollection new. 
	
	s := HumProgrammersAssistant removeCommentFromSource: self source.  
	( s trimBoth isEmpty ) ifTrue: [ ^lineErrors ].
	
	( '* is a kind of*' match: s )
		ifTrue: [ | subtype supertypes |
			  subtype := ( s findTokens: ' ' ) at: 1.
				supertypes := self getListAfter: ' is a kind of'.
				self assert: ( supertypes size = 1 ).
				aHumOntology addNoun: subtype isA: ( supertypes at: 1 ). 
				^lineErrors.
				].
	( '* is a type of*' match: s )
		ifTrue: [ | subtype supertypes |
			  subtype := ( s findTokens: ' ' ) at: 1.
				supertypes := self getListAfter: ' is a type of'.
				self assert: ( supertypes size = 1 ).
				aHumOntology addNoun: subtype isA: ( supertypes at: 1 ). 
				^lineErrors.
				].
	( '* is an *' match: s )
		ifTrue: [ | subtype supertypes |
			  subtype := ( s findTokens: ' ' ) at: 1.
				supertypes := self getListAfter: 'is an '.
				self assert: ( supertypes size = 1 ).
				aHumOntology addNoun: subtype isA: ( supertypes at: 1 ). 
				^lineErrors.
				].
	( '* is a *' match: s )
		ifTrue: [ | subtype supertypes |
			  subtype := ( s findTokens: ' ' ) at: 1.
				supertypes := self getListAfter: ' is a '.
				self assert: ( supertypes size = 1 ).
				aHumOntology addNoun: subtype isA: ( supertypes at: 1 ). 
				^lineErrors.
				].
	( '* subtypes include *' match: s )
		ifTrue: [ | supertype subtypes | 
			  supertype := ( s findTokens: ' ' ) at: 1.
				subtypes := self getListAfter: ' include '.
				self assert: ( subtypes size >= 1 ).
				subtypes do: [ :sub | aHumOntology addNoun: sub isA: ( supertype ). ].
				^lineErrors.
				].
	( '* attributes include *' match: s ) 
		ifTrue: [ | entity attributes |
			attributes := self getListAfter: 'include'.
			entity := ( s findTokens: ' ' ) at: 1.
			aHumOntology addEntity: entity attributes: attributes.
			^lineErrors. 
			 ].	
	( '* categories include *' match: s ) 
		ifTrue: [ | attribute categories |
			categories := self getListAfter: 'include'.
			attribute := ( s findTokens: ' ' ) at: 1.
			categories 
				do: [ :category | 
						((category at: 1) isLetter) 
							ifFalse: [ |error| 
								error := 'Category name must be a word. But see: {', category, '}'.
								self assert: (error isKindOf: String).
								lineErrors add: error.
								^lineErrors.  
								].
							].
			aHumOntology categoriesOf: attribute include: categories.
			^lineErrors. 
			 ].	
	(( '*includes a set of*' match: s )
	  or: [ '*has a set of*' match: s  ] )
		ifTrue: [ | attribute entity |
			  attribute := ( self getListAfter: 'a set of' ) at: 1.
				entity := ( s findTokens: ' ' ) at: 1.
				aHumOntology addEntity: entity attribute: attribute.
				aHumOntology addNoun: attribute isA: 'set'.
				^ lineErrors.
				].
	(( '*includes a list of*' match: s )
	  or: [ '*has a list of*' match: s ] )
		ifTrue: [ | entity attribute| 
				attribute := ( self getListAfter: 'a list of' ) at: 1.
				entity := ( s findTokens: ' ' ) at: 1.
				aHumOntology addEntity: entity attribute: attribute.
				aHumOntology addNoun: attribute isA: 'list'.
				^ lineErrors.
				].
			
	(( '*is synonym for*' match: s) or: ['*is a synonym for*' match: s])
		ifTrue: [ | synonym aNoun |
				synonym := ( s findTokens: ' ' ) at: 1.
				aNoun := self getListAfter: ' synonym for '.
				( aNoun size = 1 ) ifFalse: [ ^lineErrors add: ( 'Expecting one word but see more in: {', aNoun, '}' )].
				aHumOntology addNoun: synonym isSynonymFor: ( aNoun at: 1 ). 
				^lineErrors.
				].

	(( '*is shorthand for*' match: s) or: ['*is a shorthand for*' match: s])
		ifTrue: [ | shorthand aNoun |
				shorthand := ( s findTokens: ' ' ) at: 1.
				aNoun := self getListAfter: ' shorthand for '.
				( aNoun size = 1 ) ifFalse: [ ^lineErrors add: ( 'Expecting one word but see more in: {', aNoun, '}' )].
				aHumOntology addNoun: shorthand isSynonymFor: ( aNoun at: 1 ). 
				^lineErrors.
				].
	(( '*is abbreviation for*' match: s) or: ['*is an abbreviation for*' match: s])
		ifTrue: [ | abbreviation aNoun |
				abbreviation := ( s findTokens: ' ' ) at: 1.
				aNoun := self getListAfter: ' abbreviation for '.
				( aNoun size = 1 ) ifFalse: [ ^lineErrors add: ( 'Expecting one word but see more in: {', aNoun, '}' )].
				aHumOntology addNoun: abbreviation isSynonymFor: ( aNoun at: 1 ). 
				^lineErrors.].

	"Comment: Shorthand and synonym and abbreviation features enable jargon. 
	One could argue that enabling jargon improves readability - or not.
	We could treat these nouns as subtypes and everything would work 
	... except that subtype graphs would show anomolous subtypes.
	"

	"If we fall through to here, 
	 the statement was not matched to any dictionary statement pattern."		
	lineErrors add:( 'Dictionary statement not understood: ', s).	
	
	^ lineErrors.
]

{ #category : #parsing }
HumDictionaryLine >> getListAfter: aString [ 
	| s sAfter list |
	s := HumProgrammersAssistant removeCommentFromSource:  self source.
	sAfter := HumCalculator given: s extractAfter: aString. 
	list := sAfter findTokens: ', .'.
	"Remove the word 'and' from the list."
	list removeAllSuchThat: [ :item | item sameAs: 'and' ].
	^list.
]

{ #category : #accessing }
HumDictionaryLine >> source [
	"Construct a source line based on convention and content of my attributes."
	^source ifNil: [ source := '*** No Source? ***' ].
]

{ #category : #accessing }
HumDictionaryLine >> statement [
	^ statement ifNil: [ statement := HumStatement source: (self source). ]
]

{ #category : #accessing }
HumDictionaryLine >> statement: aStatementString [ 
	statement := HumStatement from: aStatementString.
]
