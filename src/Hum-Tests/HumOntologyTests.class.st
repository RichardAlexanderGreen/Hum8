"
The ontology tests are mainly concerned 
with manipulating the ontology`s data structures.

The method categories indicate the different kinds off data that are handled.


"
Class {
	#name : #HumOntologyTests,
	#superclass : #HumTestCase,
	#classVars : [
		'Argument'
	],
	#category : #'Hum-Tests'
}

{ #category : #running }
HumOntologyTests >> setUp [
	"Set the default store for these tests."	
	HumStore defaultDirectory:  './Developer/Smalltalk/Hum8/html'.
]

{ #category : #running }
HumOntologyTests >> tearDown [
	"Resst the default store to nil"	
	HumStore defaultStore: nil.
]

{ #category : #'about Ontology' }
HumOntologyTests >> test001newOntology [
	"create a new Ontology"

	| ontology |
	ontology := HumOntology new.
	self assert: ( ontology nouns) isEmpty.
	self assert: ( ontology roles) isEmpty.
	
	
]

{ #category : #'about Nouns' }
HumOntologyTests >> test100nounTypes [
	"An entity noun will have attributes."
	"A category noun will have categories."
	"An entity noun may have supertypes and/or subtypes."
	"A plural noun indicates a list or set or bag collection. By default, it indicates a set."
	"A noun may have a synonym. "
	self skip.
]

{ #category : #'about Nouns' }
HumOntologyTests >> test102addOneNoun [
	"Add one noun to current set."

	| ontology |
	ontology := HumOntology new.
	ontology addNoun: 'location'.
	self assert: ( (ontology nouns) includes: 'location' ).
]

{ #category : #'about Nouns' }
HumOntologyTests >> test103addTwoNouns [
	"Add two nouns to current set."

	| ontology |
	ontology := HumOntology new.
	"Add first noun."
	ontology addNoun: 'location'.
	self assert: ( (ontology nouns) includes: 'location' ).
	"Add second noun."
	ontology addNoun: 'place'.
	self assert: ( (ontology nouns) includes: 'place' ).
	"Make sure we did not overlay original"
	self assert: ( (ontology nouns) includes: 'location' ).  

]

{ #category : #'about Nouns' }
HumOntologyTests >> test104addArrayOfNouns [
	"Add array of nouns to current set."

	| ontology nounSet |
	ontology := HumOntology new.
	"Add one noun."
	ontology addNoun: 'location'.
	self assert: ( (ontology nouns) includes: 'location' ).
	
	"Add from array."
	ontology addNouns: #( 'place-1' 'place-2' 'place-3' ).
	self assert: ( (ontology nouns) includes: 'place-3').
	self assert: ( (ontology nouns) includes: 'location'). "Make sure we did not overlay original"
	"Add from set."
	nounSet := Set new.
	nounSet add: 'first-location'.
	nounSet add: 'second-location'.
	nounSet add: 'third-location'.
	ontology addNouns: nounSet.
	self assert: ( (ontology nouns) includes: 'third-location').
	self assert: ( (ontology nouns) includes: 'location').   "Make sure we did not overlay original"
	
]

{ #category : #'about Nouns' }
HumOntologyTests >> test110addEntityAttribute [
	"Add an entity-attribute relation."

	| ontology  attributes |
	ontology := HumOntology new.
	"Add noun."
	ontology addNoun: 'location'.
	self assert: ( (ontology nouns) includes: 'location' ).
	"Add entity-attribute relation."
	ontology addEntity: 'location' attribute: 'GPS'.
	"Test"
	attributes := ontology immediateAttributesOfEntity: 'location'.
	self assert: ( attributes include: 'GPS' asLowercase ).	
	
	"Add a second entity-attribute relation."
	ontology addEntity: 'location' attribute: 'location-name'.
	"Test"
	attributes := ontology immediateAttributesOfEntity: 'location'.
	self assert: ( attributes include: 'location-name' ).
	self assert: ( attributes include: 'GPS' asLowercase ).	
	
]

{ #category : #'about Nouns' }
HumOntologyTests >> test111getAllAttributesOfNoun [
	"Add an is-A relation."

	| ontology allAttributes |
	ontology := HumOntology new.
	"Define a few relations."
	ontology addEntity: 'party' attributes: #(  'name' 'alphabetized-name' 'address'  ).
	ontology addEntity: 'address' attributes: #( 'street-direction' 'street-number' 'street-name' 'postal-code' ).
	ontology addEntity: 'postal-code' attributes: #( 'city' 'state-province' 'nation' ).
	ontology addNoun: 'person' isA: 'party'.
	ontology addEntity: 'person' attributes: #( 'primary-phone-number'   ).
	ontology addNoun: 'contact' isA: 'person'.
	ontology addNoun: 'organization' isA: 'party'.
	
	"The attrbutes include both the supertypes and the attributes of the supertypes."
	"THINK -- Is this what we want?  What will we do with the supertypes?"
	allAttributes := ontology allAttributesOfEntity: 'contact'.
	self assert: ( allAttributes size ) = 11.
	"Collection should include attribute of supertype."
	self assert: (allAttributes include: 'alphabetized-name').
	"Collection should include attribute of supertype."
	self assert: (allAttributes include: 'primary-phone-number').
	"Collection should include attribute of attribute."
	self assert: (allAttributes include: 'postal-code').
	"Collection should include attribute of attributes all the way down."
	self assert: (allAttributes include: 'nation').
	
	
	
	

	
]

{ #category : #'about Nouns' }
HumOntologyTests >> test120addSubtype [
	"Add an is-A relation."

	| ontology subtypes |
	ontology := HumOntology new.
	"Add noun."
	ontology addNoun: 'location'.
	self assert: ( (ontology nouns) includes: 'location' ).
	"Add is-A relation."
	ontology addNoun: 'residence' isA: 'location'.
	"Test isKindOf"
	self assert: ( ontology yesNoun: 'residence' isAKindOf: 'location').
	"Test subtypes"
	subtypes := ontology immediateSubtypesOf: 'location'.
	self assert: ( subtypes isKindOf: Set).
	self assert: ( ( ontology immediateSubtypesOf: 'location') includes: 'residence').
]

{ #category : #'about Nouns' }
HumOntologyTests >> test121automaticSubtype [
	"Add an is-A relation."

	| ontology |
	ontology := HumOntology new.
	"Add noun."
	ontology addEntity: 'location' attributes: #('latitude' 'longitude').
	self assert: ( (ontology nouns) includes: 'location' ).
	"Add an automatic subtype."
	ontology addNoun: 'store-location'.
	"Test isKindOf"
	self assert: ( ontology yesNoun: 'store-location' isAKindOf: 'location').
	"Test subtypes"
	self assert: ( ( ontology immediateSubtypesOf: 'location') includes: 'store-location').
]

{ #category : #'about Nouns' }
HumOntologyTests >> test122getAllSubtypesOfNoun [
	"Get all subtypes of a noun -- Use at run-time for polymorphism."

	| ontology immediateSubtypes allSubtypes |
	ontology := HumOntology new.
	"Add a few subtype-supertype relations."
	ontology addNoun: 'person' isA: 'party'.
	ontology addNoun: 'organization' isA: 'party'.
	ontology addNoun: 'worker' isA: 'person'.
	
	ontology addNoun: 'employee' isA: 'worker'.
	ontology addNoun: 'contractor' isA: 'worker'.
	ontology addNoun: 'consultant' isA: 'worker'.
	
	ontology addNoun: 'vendor' isA: 'organization'.
	ontology addNoun: 'supplier' isA: 'vendor'.
	
	immediateSubtypes := ontology immediateSubtypesOf: 'party'.
	"Party has two subtypes (person, organization)."
	self assert: ( immediateSubtypes size ) = 2.
	
	"Party has 8 subtypes in the whole subtype tree. "
	allSubtypes := ontology allSubtypesOf: 'party'.
	self assert: ( allSubtypes size ) = 8.
	"Transcript show: allSubtypes asSortedCollection; cr."
	
	
	
	

	
]

{ #category : #'about Nouns' }
HumOntologyTests >> test123getImmediateSupertypesOfNoun [
	"Get immediate super types of a noun -- Use when translating to another language ."

	| ontology immediateSupertypes |
	ontology := HumOntology new.
	"Add a few subtype-supertype relations."
	ontology addNoun: 'person' isA: 'party'.
	ontology addNoun: 'organization' isA: 'party'.
	ontology addNoun: 'worker' isA: 'person'.
	
	ontology addNoun: 'employee' isA: 'worker'.
	ontology addNoun: 'contractor' isA: 'worker'.
	
	ontology addNoun: 'self-employed-consultant' isA: 'worker'.
	ontology addNoun: 'self-employed-consultant' isA: 'vendor'.  "Test multiple inheritance case."
	
	ontology addNoun: 'vendor' isA: 'organization'.
	ontology addNoun: 'supplier' isA: 'vendor'.
	
	immediateSupertypes := ontology immediateSupertypesOf:  'vendor'.
	"Vendor has one immediate supertype: Vendor is an organization."
	self assert: ( immediateSupertypes size ) = 1.
	
	immediateSupertypes := ontology immediateSupertypesOf:  'supplier'.
	"Supplier has one immediate supertype: Supplier is a vendor."
	self assert: ( immediateSupertypes size ) = 1.
	
	immediateSupertypes := ontology immediateSupertypesOf:  'employee'.
	"Employee has one immediate supertype: Employee is a worker.."
	self assert: ( immediateSupertypes size ) = 1.
	
	immediateSupertypes := ontology immediateSupertypesOf:  'worker'.
	"Worker has one immediate supertype: Worker is a party."
	self assert: ( immediateSupertypes size ) = 1.
	
	immediateSupertypes := ontology immediateSupertypesOf:  'person'.
	"Party has two subtypes (person, organization)."
	self assert: ( immediateSupertypes size ) = 1.
	
	immediateSupertypes := ontology immediateSupertypesOf:  'party'.
	"Party has no supertypes in this ontology."
	self assert: ( immediateSupertypes size ) = 0.
	
	immediateSupertypes := ontology immediateSupertypesOf:  'self-employed-consultant'.
	"Self-employed-constulant has two immediate supertypes: 
	Self-employed-consultant is a worker, and also a vendor."
	self assert: ( immediateSupertypes size ) = 2.
	
	
	
	
	

	
]

{ #category : #'about Nouns' }
HumOntologyTests >> test124getAllSupertypesOfNoun [
	"Get immediate super types of a noun -- Use when translating to another language ."

	| ontology immediateSupertypes allSupertypes |
	ontology := HumOntology new.
	"Add a few subtype-supertype relations."
	ontology addNoun: 'person' isA: 'party'.
	ontology addNoun: 'organization' isA: 'party'.
	ontology addNoun: 'worker' isA: 'person'.
	
	ontology addNoun: 'employee' isA: 'worker'.
	ontology addNoun: 'contractor' isA: 'worker'.
	
	ontology addNoun: 'self-employed-consultant' isA: 'worker'.
	ontology addNoun: 'self-employed-consultant' isA: 'vendor'.  "Test multiple inheritance case."
	
	ontology addNoun: 'vendor' isA: 'organization'.
	ontology addNoun: 'supplier' isA: 'vendor'.
	
	immediateSupertypes := ontology immediateSupertypesOf:  'vendor'.
	"Vendor has one immediate supertype: Vendor is an organization."
	self assert: ( immediateSupertypes size ) = 1.
	
	immediateSupertypes := ontology immediateSupertypesOf:  'supplier'.
	"Supplier has one immediate supertype: Supplier is a vendor."
	self assert: ( immediateSupertypes size ) = 1.
	
	immediateSupertypes := ontology immediateSupertypesOf:  'employee'.
	"Employee has one immediate supertype: Employee is a worker.."
	self assert: ( immediateSupertypes size ) = 1.
	
	immediateSupertypes := ontology immediateSupertypesOf:  'worker'.
	"Worker has one immediate supertype: Worker is a party."
	self assert: ( immediateSupertypes size ) = 1.
	
	immediateSupertypes := ontology immediateSupertypesOf:  'person'.
	"Party has two subtypes (person, organization)."
	self assert: ( immediateSupertypes size ) = 1.
	
	immediateSupertypes := ontology immediateSupertypesOf:  'party'.
	"Party has no supertypes in this ontology."
	self assert: ( immediateSupertypes size ) = 0.
	
	immediateSupertypes := ontology immediateSupertypesOf:  'self-employed-consultant'.
	"Self-employed-constulant has two immediate supertypes: 
	Self-employed-consultant is a worker, and also a vendor."
	self assert: ( immediateSupertypes size ) = 2.
	
	allSupertypes := ontology allSupertypesOf: 'self-employed-consultant'.
	"consultant > worker > person > party; also: consultant > vendor > organization > party"
	self assert: ( allSupertypes size ) equals: 5.
	
	
	
	
	

	
]

{ #category : #'about Nouns' }
HumOntologyTests >> test130getSingularFormOfPluralNoun [
	"Return the singular form of a plural noun."

	| nouns ontology |
	ontology := HumOntology new.
	nouns := #( 'regions' 'territories' 'monkeys' 'dresses' 'trees' 'commodores' 'flakes' 'cases' ).
	ontology addNouns: nouns.
	nouns do: [ :plural |
		| singular |
		singular := ontology singularFormOfNoun: plural.
		self deny: ( singular = plural ).
		 ].
	self expect: 'region' actual: (ontology singularFormOfNoun: 'regions').
	self expect: 'territory' actual: (ontology singularFormOfNoun: 'territories').
	self expect: 'monkey' actual: (ontology singularFormOfNoun: 'monkeys').
	self expect: 'dress' actual: (ontology singularFormOfNoun: 'dresses').
	self expect: 'commodore' actual: (ontology singularFormOfNoun: 'commodores').
	self expect: 'tree' actual: (ontology singularFormOfNoun: 'trees').
	self expect: 'flake' actual: (ontology singularFormOfNoun: 'flakes').
	self expect: 'case' actual: (ontology singularFormOfNoun: 'cases').
	self expect: 'toe' actual: (ontology singularFormOfNoun: 'toes').
	self expect: 'house' actual: (ontology singularFormOfNoun: 'houses').
	"If the plural is the same as the singular form, there is no problem - We luck out."
	self expect: 'deer' actual: (ontology singularFormOfNoun: 'deer').
	self expect: 'moose' actual: (ontology singularFormOfNoun: 'moose').
	self expect: 'sheep' actual: (ontology singularFormOfNoun: 'sheep').
	"Currently there is no way to declare irregular nouns in Hum."
	self deny: ('goose' = (ontology singularFormOfNoun: 'geese') ).
	self deny: ('mouse' = (ontology singularFormOfNoun: 'mice') ).
	
	
	
	"Special cases that currently fail:"
	
	
]

{ #category : #'about Roles' }
HumOntologyTests >> test220addOneRole [
	"Add one role to current set."

	| ontology |
	ontology := HumOntology new.
	ontology addRole: 'Mover'.
	self assert: ( (ontology roles) includes: 'Mover' ).
]

{ #category : #'about Roles' }
HumOntologyTests >> test230addTwoRoles [
	"Add two roles  to current set."

	| ontology |
	ontology := HumOntology new.
	"Add first role."
	ontology addRole: 'Mover'.
	self assert: ( (ontology roles) includes: 'Mover' ).
	"Add second role."
	ontology addRole: 'Shaker'.
	self assert: ( (ontology roles) includes: 'Shaker' ).
	"Make sure we did not overlay original"
	self assert: ( (ontology roles) includes: 'Mover' ).  

]

{ #category : #'about Statements' }
HumOntologyTests >> test310statementTokens [
	"A statement is made up of tokens."

	| tokens statement |
	"Make a statement and get its tokens."
	statement := HumStatement from: 'Now, this is the time for all good men to come to the aid of their country.'.
	tokens := statement tokens.
	"Tokens are in an ordered collection (array-like)."
	self assert: ( tokens at: 6 ) = 'time'.
	 "Tokens are converted to lower case."
	self assert: ( tokens includes: 'now' ). 
	"Tokens include punctuation."
	self assert: ( tokens includes: ',' ).
	self assert: ( tokens includes: '.' ).
	
	
]

{ #category : #'about Statements' }
HumOntologyTests >> test320statementEndsWithPeriodOrColon [
	"A statement must end with a period or a colon."

	| statement |
	statement := HumStatement new.
	
	"A statement ending in a period should not raise an error."
	statement source: 'This ends with a period.'.
	self assert: ( statement errors ) isEmpty. 
	
	"A statement ending in a colon should not raise an error."
	statement source: 'For each token in statement tokens:'.
	self assert: ( statement errors ) isEmpty. 
	
	"A statement not ending in a colon or period should raise an error."
	statement source: 'This source statement is missing an ending period'.
	self assert: ( statement errors ) isEmpty not.
	"Transcript show: statement errors; cr."
	
]

{ #category : #'about Statements' }
HumOntologyTests >> test330statementHasNouns [
	"A statement has nouns."

	| statement role ontology statementNouns |
	ontology := HumOntology new.
	statement := HumStatement from: 'Move thing from current-location to new-location.'.
	role := 'Mover'.
	ontology indexRole: role action: statement.
	
	"The nouns might be defined after the statement is defined. "
	ontology addNouns: #( 'thing' 'location' 'current-location' 'new-location' ).
	
	"(Nouns are not completely bound until compile time.)"
	statementNouns := ontology nounsInStatement: statement.
	self assert: (statementNouns include: 'thing').
	self assert: (statementNouns include: 'current-location').
	self assert: (statementNouns include: 'new-location').
	self expect: 3 actual: (statementNouns size).
	
	
	
]

{ #category : #'about Statements' }
HumOntologyTests >> test340statementParsing [
	"The parser recognizes that tokens are nouns, punctuation, keywords, or just words."

	| statement role ontology statementNouns tokenTypes |
	ontology := HumOntology new.
	statement := HumStatement from: 'Add incoming-count to stock-count, giving updated-stock-count.'.
	role := 'Calc'.
	ontology indexRole: role action: statement.
	
	"The nouns might be defined after the statement is defined. "
	ontology addNouns: #( 'count' 'incoming-count' 'stock-count' 'updated-stock-count' ).
	
	"(Nouns are not completely bound until compile time.)"
	statementNouns := ontology nounsInStatement: statement.
	self assert: (statementNouns include: 'incoming-count').
	self assert: (statementNouns include: 'stock-count').
	self assert: (statementNouns include: 'updated-stock-count').
	
	"Get tokenTypes."
	tokenTypes := ontology parseStatement: statement triggerWords: #( 'if' 'else' 'giving' 'for-each' ) keywords: #( 'each' 'giving' ).
	"Check nouns."
	self assert: ( tokenTypes include: ( 'incoming-count' -> #noun ) ).
	self assert: ( tokenTypes include: ( 'stock-count' -> #noun ) ).
	self assert: ( tokenTypes include: ( 'updated-stock-count' -> #noun ) ).
	"Check keywords."
	self assert: ( tokenTypes include: ( 'giving' -> #keyword ) ).
	"Check punctuation."
	self assert: ( tokenTypes include: ( ',' -> #punctuation ) ).
	"Add is only another word.  -- Verbs are not special."
	self assert: ( tokenTypes include: ( 'Add' -> #word ) ).
	"The word 'to' is only another word. -- Prepositions are not special."
	self assert: ( tokenTypes include: ( 'to' -> #word ) ).
	
	
	
]

{ #category : #'about Statements' }
HumOntologyTests >> test342statementParsingConsolidatesStrings [
	"A string is delimited by double quotes."
	|   | 
	Transcript show: 'TODO: test342statementParsingConsolidatesStrings has not been implemented yet.'; cr.


]

{ #category : #'about FrameLines' }
HumOntologyTests >> test350frameLineSeparateLabelStatementCommentAnnotation [
	"Generic frameline = ( indent ) ( label : ) ( statement '.' ) ( '(' comment ')' ) ( '[' annotation ']' )
	where label = word ':'
	"
]

{ #category : #'about FrameLines' }
HumOntologyTests >> test351frameLineParsingRemovesComments [
	"The parser recognizes that tokens are nouns, punctuation, keywords, or just words."
	|   |
	Transcript show: 'TODO: test351frameLineParsingRemovesComments has not been implemented yet.'; cr.

	 
	
]

{ #category : #'about FrameLines' }
HumOntologyTests >> test353frameLineParsingSeparatesAnnotation [
	"The parser recognizes that tokens are nouns, punctuation, keywords, or just words."
	|  |
	Transcript show: 'TODO: test353frameLineParsingSeparatesAnnotation has not been implemented yet.'; cr.

]

{ #category : #'about Statements' }
HumOntologyTests >> test360statementMatchesPatternForEach [
	"Test HumStatement>>onMatch: aPattern do: aBlock "
	| statement pattern result |
	true ifFalse: [ Transcript cr; show: 'test360statementMatchesPattern skipped'; cr.  ^self ].
	"Match for each"
	pattern := 'For each 1 in 2:'.
	statement := HumStatement from: 'For each item in order:'.
	result := 'No match'.
	statement onMatch: pattern do: [ :item :order | result := 'Item=',item,' and ','order=',order ].
	self assert: ( result sameAs: 'No match' ) not.
	self assert: ( result sameAs: 'item=item and order=order' ).

	
	
]

{ #category : #'about Statements' }
HumOntologyTests >> test361statementMatchesPatternForEachInThe [
	"Test HumStatement>>onMatch: aPattern do: aBlock "
	| statement pattern result |
	true ifFalse: [ Transcript cr; show: 'test361statementMatchesPatternForEachInThe skipped'; cr.  ^self ].
	"Match for each"
	pattern := 'For each 1 in the 2:'.
	statement := HumStatement from: 'For each item in order:'.
	"Preset 'No match' -- to fail fast if the pattern match does not work as expected.'"
	result := 'No match'.
	statement onMatch: pattern do: [ :item :order | result := 'Item=',item,' and ','order=',order ].
	"Fail fast if the result was not reset."
	self assert: ( result sameAs: 'No match' ) not.
	"This is the result we are expecting."
	self assert: ( result sameAs: 'item=item and order=order' ).

	
	
]

{ #category : #'about Statements' }
HumOntologyTests >> test362statementMatchesPatternIsA [
	"Test HumStatement>>onMatch: aPattern do: aBlock "
	| statement pattern result |
	true ifFalse: [ Transcript cr; show: 'test362statementMatchesPatternIsA skipped'; cr.  ^self ].
	"Match ___  is a ___"
	pattern := 'A 1 is a 2 .' .
	statement := HumStatement from: 'A menu is a bill-of-material.'.
	
	"Preset 'No match' -- to fail fast if the pattern match does not work as expected.'"
	result := 'No match'.
	statement onMatch: pattern do: [ :menu :billOfMaterial | result := 'menu=',menu, ' and ', 'bill-of-material=',billOfMaterial ].
	"Fail fast if the result was not reset."
	self assert: ( result sameAs: 'No match' ) not.
	"This is the result we are expecting."
	self assert: ( result sameAs: 'menu=menu and bill-of-material=bill-of-material' ).

	
	
]

{ #category : #'about Statements' }
HumOntologyTests >> test363statementMatchesElse [
	"Test HumStatement>>onMatch: aPattern do: aBlock "
	| statement pattern result |
	true ifFalse: [ Transcript cr; show: 'test363statementMatchesElse skipped'; cr.  ^self ].
	"Match 'Else:'"
	pattern := 'Else:' .
	statement := HumStatement from: 'Else:'.
	"Fail fast if there is no match."
	result := 'No match'.
	"The following will fail if the parser thinks there are nouns."
	statement onMatch: pattern do: [ result := 'Else has no arguments.' ].
	"Test for no match."
	self assert: ( result sameAs: 'No match' ) not.
	"This is the result we are expecting."
	self assert: ( result sameAs: 'Else has no arguments.' ).

	
	
]

{ #category : #'about Statements' }
HumOntologyTests >> test364statementMatchesCategories [
	"Test HumStatement>>onMatch: aPattern do: aBlock "
	| statement pattern result |
	true ifFalse: [ Transcript cr; show: 'test364statementMatchesCategories skipped'; cr.  ^self ].
	". . . categories include blah, blah, blah."
	pattern := '1 categories include * . ' .
	statement := HumStatement from: 'Color categories include red, green, blue. '.
	result := 'No match'.
	statement onMatch: pattern do: [:color :list | result := 'color=', color, ' and ', 'list=', list asString. ].
	self assert: ( result sameAs: 'No match' ) not.
	self assert: ( result sameAs: 'color=color and list=an OrderedCollection(''red'' ''green'' ''blue'')' ).

	
	
]

{ #category : #'about Statements' }
HumOntologyTests >> test365statementMatchesCategoriesAnd [
	"Test HumStatement>>onMatch: aPattern do: aBlock "
	| statement pattern result |
	true ifFalse: [ Transcript cr; show: 'test365statementMatchesCategoriesAnd skipped'; cr.  ^self ].
	". . . categories include blah, blah, AND blah.'"
	pattern := '1 categories include * . ' .
	"The word 'and' should be allowed in a list without confusion."
	statement := HumStatement from: 'Color categories include red, green, and blue. '.
	result := 'No match'.
	statement onMatch: pattern do: [:color :list | result := 'color=', color, ' and ', 'list=', list asString. ].
	self assert: ( result sameAs: 'No match' ) not.
	self assert: ( result sameAs: 'color=color and list=an OrderedCollection(''red'' ''green'' ''blue'')' ).

	
	
]

{ #category : #'about Statements' }
HumOntologyTests >> test366statementMatchesAttributes [
	"Test HumStatement>>onMatch: aPattern do: aBlock "
	| statement pattern result |
	true ifFalse: [ Transcript cr; show: 'test366statementMatchesAttributes skipped'; cr.  ^self ].
	". . .  attributes include blah, blah, blah."
	pattern := '1 attributes include * . ' .
	statement := HumStatement from: 'Party attributes include name, address, phone-number. '.
	result := 'No match'.
	statement onMatch: pattern do: [:party :list | result := 'party=', party, ' and ', 'list=', list asString. ].
	self assert: ( result sameAs: 'No match' ) not.
	self assert: ( result sameAs: 'party=party and list=an OrderedCollection(''name'' ''address'' ''phone-number'')' ).

	
	
]

{ #category : #'about Statements' }
HumOntologyTests >> test367statementMatchesAttributesAnd [
	"Test HumStatement>>onMatch: aPattern do: aBlock "
	| statement pattern result |
	true ifFalse: [ Transcript cr; show: 'test367statementMatchesAttributesAnd skipped'; cr.  ^self ].
	". . . attributes include . . . blah, blah, AND blah "
	pattern := '1 attributes include * . ' .
	statement := HumStatement from: 'Party attributes include name, address, and phone-number. '.
	result := 'No match'.
	statement onMatch: pattern do: [:party :list | result := 'party=', party, ' and ', 'list=', list asString. ].
	self assert: ( result sameAs: 'No match' ) not.
	self assert: ( result sameAs: 'party=party and list=an OrderedCollection(''name'' ''address'' ''phone-number'')' ).

	
	
]

{ #category : #'about Actions' }
HumOntologyTests >> test410addOneAction [
	"An action belongs to a role."
	
	| ontology source statement |
	
	"Set up"
	ontology := HumOntology new.
	
	"Add role."
	ontology addRole: 'Mover'.
	self assert: ( ( ontology roles ) includes: 'Mover' ).
	
	"An action is identified by a statement."
	source := 'Move portable-object from current-location to new-location.'.
	statement := HumStatement from: source.
	
	"Add action to the role's set of actions."
	ontology indexRole: 'Mover' action: statement.
	self assert: ( ontology yesRole: 'Mover' hasAction: source ).
	
]

{ #category : #'about Actions' }
HumOntologyTests >> test420actionInstructions [
	"An action statement is defined by a sequence of instructions."
	
	| ontology role action instruction1 instruction2 instructionSequence |
	
	"Set up"
	ontology := HumOntology new.
	
	"Add action to the role's set of actions."
	role := 'Cook'.
	action := 'Bake a cake per recipe.'.
	ontology indexRole: role action:  ( HumStatement from: action ).
	self assert: ( ontology yesRole: role hasAction: action ).
	
	"Create an instruction."
	" -- Instructions elements are all optional and include role, statement, comment, annotaion, translation."
	instruction1 := HumInstructionLine new.
	instruction1 statement: 'Preheat oven to recipe`s oven-temperature.'; role: 'Oven'.
	                   
	"Append instruction to sequence of instructions."
	ontology appendInstruction: instruction1 toRole: role action: action.
	"test"
	instructionSequence := ( ontology instructionsForRole: role action: action ).
	self assert: ( instructionSequence includes: instruction1).
	
	"Create another instruction."
	instruction2 := HumInstructionLine new.
	instruction2 statement: 'Mix batter per recipe.'; role: 'Mixer'; annotation: 'duration: 5 minutes'.
	self assert: ( instructionSequence size) = 1.
	self assert: ( instructionSequence last = instruction1).
	
	"Append second instruction to sequence of instructions."
	ontology appendInstruction: instruction2 toRole: role action: action.
	"test"
	instructionSequence := ( ontology instructionsForRole: role action: action ).
	self assert: ( instructionSequence size) = 2.
	self assert: ( instructionSequence last = instruction2).
	
]

{ #category : #'about Actions' }
HumOntologyTests >> test430createInstructionsInline [
	"Create instructions in-line using Class methods"
	| ontology role action |
	
	"Set up"
	ontology := HumOntology new.
	
	"Add action to the role's set of actions."
	role := 'Cook'.
	action := 'Bake a cake per recipe.'.
	ontology indexRole: role action: (HumStatement from: action).
	
	"Append first instruction to sequence of instructions."
	ontology appendInstruction: 'Preheat oven to recipe`s oven-temperature.' toRole: role action: action.

	"Append second instruction."
	ontology appendInstruction: 'Mix batter per recipe.' toRole: role action: action.

	self assert: ( ( ontology instructionsForRole: role action: action) size) = 2.
	self assert: ( ( ontology instructionsForRole: role action: action) includes:  'Mix batter per recipe.' ).
	
	
	
	
]

{ #category : #'about Actions' }
HumOntologyTests >> test440getRoleActionStatement [
	"An action belongs to a role."
	
	| ontology source actionStatement |
	
	"Set up"
	ontology := HumOntology new.
		
	"Add action to the role's set of actions."
	source :=  'Bake a cake per recipe.'.
	ontology indexRole: 'Baker' action:  (HumStatement from: source ).
	self assert: ( ontology yesRole: 'Baker' hasAction: source ).
	
	"Get back the action statement. "
	actionStatement := ontology getRole: 'Baker' action: source.
	self assert: ( actionStatement isKindOf: HumStatement ).
	
	"It should, of course, match."
	self assert: ( actionStatement matchesCandidateStatement: source inOntology: ontology).
	
]

{ #category : #'about Actions' }
HumOntologyTests >> test441matchActionStatementAgainstCandidate [
	"Retrieve statement object from ontology when given a similar string."
	
	| ontology source actionStatement candidate|
	
	"Set up"
	ontology := HumOntology new.
		
	"Add action to the role's set of actions."
	source := 'Bake a cake per recipe.'.
	ontology indexRole: 'Baker' action:  (HumStatement from: source ).
	candidate :=  'Bake a cake per recipe.'.
	"Check that String>>sameAs: means what we expect."
	self assert: ( candidate sameAs: source ).
	self assert: ( source sameAs: candidate ).
	"Should be able to retrieve with string that matches our source."
	self assert: ( ontology yesRole: 'Baker' hasAction: candidate ).
	
	"Get back the action statement. "
	actionStatement := ontology getRole: 'Baker' action: candidate.
	self assert: ( actionStatement isKindOf: HumStatement ).
	
	"Candidate should match when it is word for word the same."
	self assert: ( actionStatement matchesCandidateStatement: candidate inOntology: ontology).
	"Candidate should also match if the articles are dropped or different."
	candidate :=  'Bake the cake per the recipe.'.
	self assert: ( actionStatement matchesCandidateStatement: candidate inOntology: ontology).
	candidate :=  'Bake cake per recipe.'.
	self assert: ( actionStatement matchesCandidateStatement: candidate inOntology: ontology).
	
	
]

{ #category : #'about Actions' }
HumOntologyTests >> test442matchActionStatementPolymorphic [
	"Retrieve appropriate statement with supertype 
	 when invoking sentence has a subtype."
	
	| ontology source actionStatement candidate|
	
	"Set up"
	ontology := HumOntology new.
	"Define subtypes"
	ontology addNoun: 'cake' isA: 'bake-product'.
	ontology addNoun: 'pie' isA: 'bake-product'.
		
	"Add action to the role's set of actions."
	source := 'Bake a bake-product per recipe.'.
	ontology indexRole: 'Baker' action:  (HumStatement from: source ).
	candidate :=  'Bake a bake-product per recipe.'.
	"Check that String>>sameAs: means what we expect."
	self assert: ( candidate sameAs: source ).
	self assert: ( source sameAs: candidate ).
	"Should be able to retrieve with string that matches our source."
	self assert: ( ontology yesRole: 'Baker' hasAction: candidate ).
	
	"Get back the action statement. "
	actionStatement := ontology getRole: 'Baker' action: candidate.
	self assert: ( actionStatement isKindOf: HumStatement ).
	
	"Candidate should match when it is word for word the same."
	self assert: ( actionStatement matchesCandidateStatement: candidate inOntology: ontology).
	"Candidate should also match if the articles are dropped or different."
	candidate :=  'Bake the bake-product per the recipe.'.
	self assert: ( actionStatement matchesCandidateStatement: candidate inOntology: ontology).
	candidate :=  'Bake bake-product per recipe.'.
	self assert: ( actionStatement matchesCandidateStatement: candidate inOntology: ontology).
	
	"Now prove polymorphism works."
	candidate :=  'Bake a cake per recipe.'.
	self assert: ( actionStatement matchesCandidateStatement: candidate inOntology: ontology).
	candidate :=  'Bake a pie per recipe.'.
	self assert: ( actionStatement matchesCandidateStatement: candidate inOntology: ontology).
	"But cookie-batch is not defined as a subtype in this ontology.
	(Check for false positive.)"
	candidate :=  'Bake a cookie-batch per recipe.'.
	self assert: ( actionStatement matchesCandidateStatement: candidate inOntology: ontology) not.
	
	
	
	
	
]

{ #category : #'about Actions' }
HumOntologyTests >> test450instructionNounAntecedents [
	"Nouns in instructions should have antecedants in the action statement.
	(Test the code critic)"
	| ontology role action critique |
	
	"Set up"
	ontology := HumOntology new.
	
	"Add action to the role's set of actions."
	role := 'Cook'.
	action := 'Bake a cake per recipe.'.
	ontology indexRole: role action: (HumStatement from: action).
	
	"Append first instruction to sequence of instructions."
	ontology appendInstruction: 'Preheat oven to recipe`s oven-temperature.' toRole: role action: action.

	"Append second instruction."
	ontology appendInstruction: 'Mix batter per recipe.' toRole: role action: action.
	
	self assert:  (( ontology instructionsForRole: role action: action ) size) = 2.
	
	ontology addNouns: #( 'recipe' 'oven' 'batter' ).
	"In the given instruction sequence, the nouns 'oven' and 'batter' were not seen in the action statement."
	
	critique := ontology critiqueRole: role action: action.
	self assert: ( critique size > 0 ).
	self assert: ( ( critique at: 1 ) beginsWith: 'Some nouns lack antecedants').
	self assert: ( ( critique at: 1 ) endsWith: 'Preheat oven to recipe`s oven-temperature.' ).
	self assert: ( ( critique at: 2 ) beginsWith: 'Some nouns lack antecedants').
	self assert: ( ( critique at: 2 ) endsWith: 'Mix batter per recipe.' ).
	
]

{ #category : #'about Actions' }
HumOntologyTests >> test461Frame4ActionCrossReferences [
	"Given: An action instruction delegates to another role (or same role).
	When: The action frame is compiled.
	Then: The ontology tracks where (which role-action frame) the action statement is invoked.
	"
	| frameUpdater frameUpdater2 ontology actionTitle1 actionTitle2  relations item actionStatement |
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameUpdater := HumFrameUpdater ontology: ontology  
	                                   role: 'Baker' 
	                                 action: 'Bake the pan in the oven for the time given in the recipe.'.
	frameUpdater appendInstructionStatement: 'Open the oven door.'.
	frameUpdater appendInstructionStatement: 'Place the pan in the oven.'.
	frameUpdater appendInstructionStatement: 'Close the oven door.'.
	frameUpdater appendInstructionRole: 'Oven' 
	                     statement: 'Bake for the baking-time given in the recipe.' 
	                       comment: 'We have a smart oven.'.
	
	ontology storeFrame: ( frameUpdater frame ).
	actionTitle1 := frameUpdater frame title.
	
	frameUpdater2 := HumFrameUpdater ontology: ontology
																	  role: 'Oven'
																	action: 'Bake for the baking-time given in the recipe.'.
	ontology storeFrame: ( frameUpdater2 frame ).
	actionTitle2 := frameUpdater2 frame title.
	
	
	"Frames must be compiled if nouns are to be flagged"
	ontology addNouns: #( 'recipe' 'oven' 'baking-time').
	
  "When: The action frame is compiled."
	ontology compileAllFrames.
	"Then: The ontology tracks where (which role-action frame) the action statement is invoked."
	"*** Look under the covers to check expectations. TODO: REFACTOR THIS. *** "
	self assert: (ontology frameRelations size > 0) description: 'The set of frameRelations should have entries by now'.
	relations := ontology frameRelationsWhere: [ :a :r :b | r = #invokesAction ].
	self expect: 1 actual: ( relations size ) description: 'At this time, only action to action is indexed'.
	item := relations asArray at: 1.
	self expect: actionTitle1 actual: (item at: 1).
	actionStatement := HumInstructionLine role: 'Oven' statement: 'Bake for the baking-time given in the recipe.'. 
	self expect: ( actionStatement title asLowercase ) actual: ( item at: 3 ).

	
	

]

{ #category : #'about Plans and Conditions' }
HumOntologyTests >> test510CreatePlanFrame [
	"Make one plan frame. (TDD to drive basic parts)"
	| planFrame preconditions actionSet ontology |
	
	ontology := HumOntology new.
	"A plan frame has a goal. (post condition)"
	planFrame := HumFrame4Plan ontology: ontology goal: 'Bake a cake per recipe.'.
	self assert: (( planFrame goal ) matchesCandidateStatement: 'Bake a cake per recipe.' inOntology: ontology).
	
	"A plan frame has a collection of preconditions."
	preconditions := planFrame preconditions.
	self assert: ( preconditions isKindOf: Collection ).
	
	planFrame appendPrecondition: 'Oven is preheated per recipe.'.
	self assert: ( preconditions size ) = 1.
	
	planFrame appendPrecondition: 'Batter is mixed per recipe ingredients.'.
	self assert: ( preconditions size ) = 2.

	planFrame appendPrecondition: 'Batter is in cake-pan per recipe pan-size.'.
	self assert: ( preconditions size ) = 3.

	"A plan frame has a set of zero or more actions
	 that move the state
	 from the preconditions 
	to the post condition (goal)."
	actionSet := planFrame planActions.
	self assert: ( actionSet isKindOf: Collection ).
	
	planFrame appendRole: 'Baker' action: 'Bake the cake-pan per recipe baking-time.' comment: ''.
	self assert: ( actionSet size ) = 1.
	
	
	
]

{ #category : #'about Plans and Conditions' }
HumOntologyTests >> test520CheckPlanFrame [
	"A plan frame SHOULD have a goal and at least two preconditions.
	 -- Perhaps this rule is a 'should' rather than a 'must'.
	-- The plan would still work,
	     but a plan with a large number of frames with just one precondition
	     seems a bit odd.
	-- A better check would detect a string of such plan frames. 
	" 
	| planFrame problems  ontology |
	
	ontology := HumOntology new.
		
	planFrame := HumFrame4Plan new.
	problems := planFrame check.
	self assert: ( problems include: 'A plan frame must have a goal.' ).
	
	"Fix that problem."
	planFrame ontology: ontology; goal: 'Bake a cake per recipe'.
	
	"A plan frame SHOULD have at least two preconditions."
	"If there is only one, the business process should be stated as a procedure."
	self assert: ( ( planFrame check) include:  'A plan frame should have at least two preconditions.' ).
	
	"Half fix that problem."
	planFrame appendPrecondition: 'Oven is preheated per recipe.'.	
	
	self assert: (  ( planFrame check)  include:  'A plan frame should have at least two preconditions.' ).
	
	"Fully fix that problem."
	planFrame appendPrecondition: 'Batter is in bake-pan per recipe.'.
	
	self assert: (  ( planFrame check)  isEmpty ).
	
	
	
	
]

{ #category : #'about Plans and Conditions' }
HumOntologyTests >> test530AddPlanFrame [
	"Make one plan frame. (TDD to drive basic parts)"
	| planFrame ontology |
	
	ontology := HumOntology new.

	"A plan frame should have a goal and at least two preconditions."
	
	planFrame := HumFrame4Plan  ontology: ontology goal: 'Bake a cake per recipe'.
	planFrame appendPrecondition: 'Oven is preheated per recipe.'.	
	planFrame appendPrecondition: 'Batter is in bake-pan per recipe.'.
	planFrame appendRole: 'Baker' action: 'Bake bake-pan in the oven per recipe.'.
	
	ontology storeFrame: planFrame.
	
	"===
	Goal: Bake a cake per recipe.
	Preconditions:
	. Oven is preheated per recipe.
	. Batter is in bake-pan per recipe.
	Action:
	. Baker: Bake bake-pan in the oven per recipe.
	===
	"
	
	
]

{ #category : #'about Plans and Conditions' }
HumOntologyTests >> test540GetPlanTree [
	"Make several plan frames. Get the resulting plan tree."
	| planFrame1 planFrame2 planFrame3 ontology planTree |
	
	ontology := HumOntology new.

	"A plan frame must have a goal and at should have at least two preconditions."
	
	planFrame1 := HumFrame4Plan ontology: ontology goal: 'Bake a cake per recipe.'.
	planFrame1 appendPrecondition: 'Oven is preheated per recipe.'.	
	planFrame1 appendPrecondition: 'Batter is in bake-pan per recipe.'.
	planFrame1 appendRole: 'Baker' action: 'Bake bake-pan in the oven per recipe.'.
	ontology storeFrame: planFrame1.
		
	planFrame2 := HumFrame4Plan ontology: ontology goal: 'Oven is preheated per recipe.'.
	planFrame2 appendPrecondition: 'Oven is cleared out.'.
	planFrame2 appendPrecondition: 'Oven is on.'.
	planFrame2 appendPrecondition: 'Oven temperature is set per recipe.'.
	planFrame2 appendRole: 'Timer' action: 'Wait 5 minutes.'.
	ontology storeFrame: planFrame2.
	
	planFrame3 := HumFrame4Plan ontology: ontology goal: 'Batter is in bake-pan per recipe.'.
	planFrame3 appendPrecondition: 'Batter fully mixed per recipe.'.
	planFrame3 appendPrecondition: 'Bake-pan is greased per recipe.'.
	planFrame3 appendRole: 'Baker' action: 'Pour batter into bake-pan per recipe.'.
	ontology storeFrame: planFrame3.
	
	"TODO: The plan tree is incomplete at this point 
	       and the following call to {buildPlanTreeForGoal:} should fail."
	planTree := ontology buildPlanTreeForGoal:  'Bake a cake per recipe.' indent: 0.
	self assert: ( planTree size ) = 7.
	
	"ontology showPlanTree: planTree."
	
	"TODO: IS THIS CORRECT? THIS TEST DOES NOT COUNT THE GOAL AT THE ROOT AS PART OF THE PLAN TREE."
	self assert: ( planTree anySatisfy: [:assoc |
		 ((assoc value) at: 2) = (HumStatement source: 'Batter is in bake-pan per recipe.')
		 ]).
	 
 

	
]

{ #category : #'about Plans and Conditions' }
HumOntologyTests >> test545DrawPlanTree [
	"Make several plan frames. Get the resulting plan tree."
	| planFrame1 planFrame2 planFrame3 ontology planTreeView |
	
	ontology := HumOntology new.

	"A plan frame must have a goal and at should have at least two preconditions."
	
	planFrame1 := HumFrame4Plan ontology: ontology goal: 'Bake a cake per recipe.'.
	planFrame1 appendPrecondition: 'Oven is preheated per recipe.'.	
	planFrame1 appendPrecondition: 'Batter is in bake-pan per recipe.'.
	planFrame1 appendRole: 'Baker' action: 'Bake bake-pan in the oven per recipe.'.
	ontology storeFrame: planFrame1.
		
	planFrame2 := HumFrame4Plan ontology: ontology goal: 'Oven is preheated per recipe.'.
	planFrame2 appendPrecondition: 'Oven is cleared out.'.
	planFrame2 appendPrecondition: 'Oven is on.'.
	planFrame2 appendPrecondition: 'Oven temperature is set per recipe.'.
	planFrame2 appendRole: 'Timer' action: 'Wait 5 minutes.'.
	ontology storeFrame: planFrame2.
	
	planFrame3 := HumFrame4Plan ontology: ontology goal: 'Batter is in bake-pan per recipe.'.
	planFrame3 appendPrecondition: 'Batter fully mixed per recipe.'.
	planFrame3 appendPrecondition: 'Bake-pan is greased per recipe.'.
	planFrame3 appendRole: 'Baker' action: 'Pour batter into bake-pan per recipe.'.
	ontology storeFrame: planFrame3.
	
	"TODO: The plan tree is incomplete at this point 
	       and the following call to {buildPlanTreeForGoal:} should fail."
	planTreeView := ontology view showPlanTreeForGoal: 'Bake a cake per recipe.'.
	
	"Transcript cr; show: 'test545DrawPlanTree'; show: planTreeView; cr."
 

	
]

{ #category : #'about Plans and Conditions' }
HumOntologyTests >> test550CheckPlanTree [
	"Check for an incomplete plan."
	| planFrame1 planFrame2 planFrame3 ontology planTreeProblems |
	
	ontology := HumOntology new.

	"A plan frame must have a goal and should have at least two preconditions."
	
	planFrame1 := HumFrame4Plan ontology: ontology goal: 'Bake a cake per recipe.'.
	planFrame1 appendPrecondition: 'Oven is preheated per recipe.'.	
	planFrame1 appendPrecondition: 'Batter is in bake-pan per recipe.'.
	planFrame1 appendRole: 'Baker' action: 'Bake bake-pan in the oven per recipe.'.
	ontology storeFrame: planFrame1.
		
	planFrame2 := HumFrame4Plan ontology: ontology goal: 'Oven is preheated per recipe.'.
	planFrame2 appendPrecondition: 'Oven is cleared out.'.
	planFrame2 appendPrecondition: 'Oven is on.'.
	planFrame2 appendPrecondition: 'Oven temperature is set per recipe.'.
	planFrame2 appendRole: 'Timer' action: 'Wait 5 minutes.'.
	ontology storeFrame: planFrame2.
	
	planFrame3 := HumFrame4Plan ontology: ontology goal: 'Batter is in bake-pan per recipe.'.
	planFrame3 appendPrecondition: 'Batter fully mixed per recipe.'.
	planFrame3 appendPrecondition: 'Bake-pan is greased per recipe.'.
	planFrame3 appendRole: 'Baker' action: 'Pour batter into bake-pan per recipe.'.
	ontology storeFrame: planFrame3.
	
	planTreeProblems := ontology checkPlanTreeForGoal:  'Bake a cake per recipe.'.
	self assert: ( planTreeProblems size ) = 5.
	"
	Transcript cr; show: 'Plan Tree Problems:'.
	planTreeProblems do: [ :problem | Transcript cr; show: problem. ].
	"


	
]

{ #category : #'render as HTML' }
HumOntologyTests >> test610renderStatementAsHTML [
	"In the HTML rendering, statement nouns are enclosed in <n>...</n> to enable style sheet rendering."

	| statement role ontology html |
	ontology := HumOntology new.
	statement := HumStatement from: 'Add incoming-count to stock-count, giving updated-stock-count.'.
	role := 'Calc'.
	ontology indexRole: role action: statement.
	
	"The nouns might be defined after the statement is defined. "
	ontology addNouns: #( 'count' 'incoming-count' 'stock-count' 'updated-stock-count' ).
	
	html := ontology view renderStatement: statement triggerWords: #('if' 'else' 'for-each') keywords: #( 'giving' 'if' 'then' 'each' ).
	self assert: ( '*Add *' match: html ).
	self assert: ( '*giving*' match: html ).
	self assert: ( '*<k>giving</k>*' match: html ).
	self assert: ( '*<n>stock-count</n>*' match: html ).
	self assert: ( '*<n>stock-count</n>,*' match: html ).
	self assert: ( '*<n>updated-stock-count</n>.*' match: html ).

]

{ #category : #'render as HTML' }
HumOntologyTests >> test611renderInstructionLines [
	"Create instructions in-line using Class methods"
	| ontology role action preheatInstruction mixInstruction frameEditor html |
	
	"Set up"
	ontology := HumOntology new.
	
	"Add action to the role's set of actions."
	role := 'Cook'.
	action := 'Bake a cake per recipe.'.
	ontology indexRole: role action: (HumStatement from: action).
	
	"Append first instruction to sequence of instructions."
	preheatInstruction := HumInstructionLine  statement: 'Preheat oven to recipe`s oven-temperature.'.
	ontology appendInstruction: preheatInstruction toRole: role action: action.
	
	"Append second instruction."
	mixInstruction := HumInstructionLine  statement: 'Mix batter per recipe.'.
	ontology appendInstruction: mixInstruction toRole: role action: action.
	
	"Initialize for a Dictionary Frame."
	frameEditor := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.
	frameEditor addDictionaryLine: 'Recipe attributes include product-name, oven-temperature.'.
  ontology storeFrame: ( frameEditor frame ).

	"Frames must be compiled before rendering if nouns are to be flagged."
	ontology compileAllFrames.
	html := ontology view renderInstruction: preheatInstruction.
	self assert: ( '*Preheat oven*' match: html ).
	self assert: ( '*oven-temperature*' match: html ).
	self assert: ( '*<n>*</n>*' match: html ).
	self assert: ( '*<n>oven-temperature</n>*' match: html ).
	
]

{ #category : #'render as HTML' }
HumOntologyTests >> test620renderFrame4PlanAsHTML [
	"The frame editor instance knows what kind of frame it is editing.
	"
	| frameEditor ontology html thisFrame |
	ontology := HumOntology new.
	
	"Initialize for a Plan Frame."
	frameEditor := HumFrameUpdater ontology: ontology goal: 'Cake is baked according to recipe..'.
	frameEditor appendPrecondition: 'Oven is preheated to the temperature given in the recipe.'.
	frameEditor appendPrecondition: 'The recipe`s batter is in a prepared cake pan.'.
	frameEditor appendRole: 'Timer' action: 'Bake the pan in the oven for the time given in the recipe.' .
	
	thisFrame :=  ( frameEditor frame ).
	ontology storeFrame: thisFrame.
	
	"Frames must be compiled before rendering if nouns are to be flagged."
	ontology addNouns: #( 'recipe' ).
	ontology compileAllFrames.

	html := ontology view asHTML5 .
	"Test:  Is the goal-statement included in the HTML ?"
	self pattern:  '*according*to*' matches: html.	
	"Test: Are each of the preconditions included ?"	
	self pattern:  '*preheated*' matches: html .
	self pattern:  '*batter*'  matches: html .
	"Test: Is the action instruction role and statment included ?"
	self pattern:  '*Timer*'  matches: html.
	self pattern:  '*time given*'  matches: html.
	
	"HTML should include a 'Preconditions' subheading."
	self pattern:  '*Preconditions*' matches: html.
	
	"HTML should include a 'Actions' subheading."
	self pattern: '*Actions*' matches: html.
	
	"HTML should include nouns flags"
	self pattern: '*<n>*</n>*' matches: html.
	self pattern:  '*<n>recipe</n>*' matches: html.
	"Preconditions should have nouns marked"
	self pattern:  '*temperature given in the <n>recipe</n>*' matches: html.
	"Actions should have nouns marked."
	self pattern:  '*time given in the <n>recipe</n>*' matches: html.
	"Goal should have nouns marked."
	self pattern:  '*according to <n>recipe</n>*' matches: html.

]

{ #category : #'render as HTML' }
HumOntologyTests >> test625renderPlanTreeAsHTML [
	"Make several plan frames. Get the resulting plan tree."
	| planFrame1 planFrame2 planFrame3 ontology planTreeView frameEditor |
	
	ontology := HumOntology new.

	"A plan frame must have a goal and at should have at least two preconditions."
	
	planFrame1 := HumFrame4Plan ontology: ontology goal: 'Bake a cake per recipe.'.
	planFrame1 appendPrecondition: 'Oven is preheated per recipe.'.	
	planFrame1 appendPrecondition: 'Batter is in bake-pan per recipe.'.
	planFrame1 appendRole: 'Baker' action: 'Bake bake-pan in the oven per recipe.'.
	ontology storeFrame: planFrame1.
		
	planFrame2 := HumFrame4Plan ontology: ontology goal: 'Oven is preheated per recipe.'.
	planFrame2 appendPrecondition: 'Oven is cleared out.'.
	planFrame2 appendPrecondition: 'Oven is on.'.
	planFrame2 appendPrecondition: 'Oven temperature is set per recipe.'.
	planFrame2 appendRole: 'Timer' action: 'Wait 5 minutes.'.
	ontology storeFrame: planFrame2.
	
	planFrame3 := HumFrame4Plan ontology: ontology goal: 'Batter is in bake-pan per recipe.'.
	planFrame3 appendPrecondition: 'Batter fully mixed per recipe.'.
	planFrame3 appendPrecondition: 'Bake-pan is greased per recipe.'.
	planFrame3 appendRole: 'Baker' action: 'Pour batter into bake-pan per recipe.'.
	ontology storeFrame: planFrame3.
	
		"Create a Dictionary Frame."
	frameEditor := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.
	frameEditor addDictionaryLine: 'Recipe attributes include recipe-name, description, ingredients, steps.'.
	frameEditor addDictionaryLine: 'Recipe includes a list of ingredients.'.
	frameEditor addDictionaryLine: 'Recipe includes a list of steps.'.
	frameEditor addDictionaryLine: 'Ingredient attributes include ingredient-name, quantity, alternate-ingredient.'.
	frameEditor addDictionaryLine: 'Step attributes include step-number, step-description'.
	frameEditor addDictionaryLine: 'Bakery attributes include oven, mixer, counter.'.
	frameEditor addDictionaryLine: 'Recipe attributes include baking-time.'.

	ontology storeFrame: ( frameEditor frame ).

	ontology compileAllFrames.
	
	planTreeView := ontology view renderPlanTreeForGoal: 'Bake a cake per recipe.'.
	
	self expect: '
Plan Tree:
   Bake a cake per <n>recipe</n>.
   |->  <n>Oven</n> is preheated per <n>recipe</n>.
        |->  <n>Oven</n> is cleared out.
        |->  <n>Oven</n> is on.
        |->  <n>Oven</n> temperature is set per <n>recipe</n>.
   |->  Batter is in bake-pan per <n>recipe</n>.
        |->  Batter fully mixed per <n>recipe</n>.
        |->  Bake-pan is greased per <n>recipe</n>.
'
		actual: planTreeView.
 

	
]

{ #category : #'render as HTML' }
HumOntologyTests >> test626renderNounTreeAsHTML [
	"Define a dictionary with more than one level. Render as a noun tree."
	| ontology nounTreeView frameEditor html expected |
	
	ontology := HumOntology new.

		"Create a Dictionary Frame."
	frameEditor := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.
	frameEditor addDictionaryLine: 'Recipe attributes include recipe-name, description, ingredients, steps.'.
	frameEditor addDictionaryLine: 'Recipe includes a list of ingredients.'.
	frameEditor addDictionaryLine: 'Recipe includes a list of steps.'.
	frameEditor addDictionaryLine: 'Measure attributes include quantity, units.'.
	frameEditor addDictionaryLine: 'Ingredient attributes include ingredient-name, ingredient-measure, substitute.'.
	frameEditor addDictionaryLine: 'Step attributes include step-number, step-description'.
	frameEditor addDictionaryLine: 'Bakery attributes include oven, mixer, counter.'.
	frameEditor addDictionaryLine: 'Recipe attributes include bake-time, bake-temperature.'.

	ontology storeFrame: ( frameEditor frame ).

	ontology compileAllFrames.
	
	nounTreeView := ontology view renderNounTreeForNoun: 'recipe'.
	
	self expect: '
Noun Tree:
   recipe
    |-> bake-temperature
    |-> bake-time
    |-> description
    |-> ingredients
         |-> ingredient-measure
              |=> measure
                   |-> quantity
                   |-> units
         |-> ingredient-name
         |-> substitute
    |-> recipe-name
    |-> steps
         |-> step-description
         |-> step-number
'
		actual: nounTreeView.
 
"TODO: HumCalculator translates <> to &lt; &gt;"
	expected := HumCalculator given: nounTreeView replaceAll: '>'  with: '&gt;'.
	html := ontology view renderNounTreeForNounAsHTML: 'recipe'.
	self expect: expected actual: html.
	
]

{ #category : #'render as HTML' }
HumOntologyTests >> test630renderFrame4ActionAsHTML [
	"Given: The frame editor contains a role-action frame.
	 When: Rendering a role-action frame as HTML.
	 Then: The HTML identifies the nouns. (see test610renderStatementAsHTML)
	 Then: The HTML indents instructions.
	 Then: The HTML includes the heading.
	 Then: The HTML includes each comment.
	 Note: CSS boiler-plate (generated elsewhere) will handle the color-coding.
	"
	| frameEditor ontology html |
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameEditor := HumFrameUpdater ontology: ontology  
	                                   role: 'Baker' 
	                                 action: 'Bake the pan in the oven for the time given in the recipe.'.
	frameEditor appendInstructionStatement: 'Open the oven door.'.
	frameEditor appendInstructionStatement: 'Place the pan in the oven.'.
	frameEditor appendInstructionStatement: 'Close the oven door.'.
	frameEditor appendInstructionRole: 'Oven' statement: 'Bake for the baking-time given in the recipe.' comment: 'We have a smart oven.'.
	
	ontology storeFrame: ( frameEditor frame ).
	
	"Frames must be compiled if nouns are to be flagged"
	ontology addNouns: #( 'recipe' 'oven' 'baking-time').
	ontology compileAllFrames.
	html := ontology view asHTML5.
	
	"Test: Title line is rendered."
	self pattern:  '*time given*' matches: html.
	"First instruction is rendered."
	self pattern:  '*Open the*' matches: html.	
	"2nd instruction is rendered."
	self pattern:  '*pan in the*' matches: html.
	"3rd instruction is rendered."
	self pattern:  '*Close the*' matches: html.
	"4th inststruction statement is rendered"
	self pattern:  '*Bake for the*' matches: html.
	"Comment is rendered"
	self pattern:  '*smart oven*' matches: html.
	"Role is rendered."
	self pattern:  '*<role>*Oven*' matches: html.

	"HTML should include 'Action:' label."
	self pattern:  '*Action:*' matches: html.

	"Avoid double-space bug"
	self assert:(  '*<br/><br/><InstructionLine>*' match: html ) not.
	
	
	"html inspect."
	
	

]

{ #category : #'render as HTML' }
HumOntologyTests >> test640renderFrame4ViewAsHTML [
	"Given: The frame editor instance knows what kind of frame it is editing.
	 When: The frame is a view and we render it as HTML for viewing the ontology source.
	 Then: The rendering shows a reasonable facsimile of the corresponding HTML form, 
	       but with source navigation.
	"
	| frameEditor ontology html |
	ontology := HumOntology new.
	"Entity 'recipe' must be defined before we try to store the view frame."
	ontology addEntity: 'recipe' attributes: #('name' 'description' 'ingredients' 'steps').
	
	"Initialize for a View Frame."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'recipe.'.
	frameEditor addMarkUp: '!! Recipe'.
	frameEditor addMarkUp: ' recipe-name: [name]'.
	frameEditor addMarkUp: '   description: [description 5]'.
	frameEditor addMarkUp: '   ingredients: [ingredients]'.
	frameEditor addMarkUp: '           steps: [steps]'.
	self assert: ( frameEditor notNil ).
	
	ontology storeFrame: ( frameEditor frame ).
	
	ontology compileAllFrames.
	html := ontology view asHTML5.

	"Test that labels are present in the rendering."
	"Title line"
	self pattern: '*Recipe*' matches: html.
	"1st markup line"
	self pattern: '*recipe-name: *' matches: html.
	"2nd markup line"
	self pattern: '*description: *' matches: html.
	"3rd markup line"
	self pattern: '*ingredients: *' matches: html.
	"4th (last) marup line"
	self pattern: '*steps: *' matches: html.
	
	"Test that widgets are present in the rendering."
	"1st markup line"
	self assert: ( ( html match:  '*[name]*'  ) not )
	      description: 'Hum widget should be replaced by HTML element'.
	self pattern: '*recipe-name: <input name="*"*/>*' matches: html.
	"2nd markup line -- TODO: Should be multi-line box."
	self assert: ( ( '*[description 5]*' match: html ) not )
	      description: 'Hum widget should be replaced by HTML element'.
	self pattern: '*description: <textarea name="*"*/>*' matches: html.
	"3rd markup line -- TODO: Should be input-table.  (HOW?) "
	self pattern: '*ingredients: <table name="*"*/>*' matches: html.
	"4th markup line -- TODO: Should be input-table.  (HOW?) "
	self pattern: '*steps: <table name="*"*/>*' matches: html.
	
	"TODO: WIDGETS NEED TO BE ARTICULATED BY TYPE."
	"Inspect -- paste result into HTML tool/file."
	"html inspect."

]

{ #category : #'render as HTML' }
HumOntologyTests >> test641renderRadioButtonAsHTML [
	"Given: The frame editor instance knows what kind of frame it is editing.
	 When: The frame is a view and we render it as HTML for viewing the ontology source.
	 Then: The rendering shows a reasonable facsimile of the corresponding HTML form, 
	       but with source navigation.
	"
	| frameEditor ontology html |
	ontology := HumOntology new.
	
	"Entity 'pizza-order' must be defined before we try to store the view frame."
	ontology addEntity: 'pizza-order' attributes: #('customer' 'crust' 'size' 'toppings').
		
	"Initialize for a View Frame."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'pizza-order.'.
	frameEditor addMarkUp: '!! Pizza Order'.
	frameEditor addMarkUp: '!!! Size'.
	frameEditor addMarkUp: '  (S) Small  (M) Medium  (L) Large'.
	self assert: ( frameEditor notNil ).
	
	ontology storeFrame: ( frameEditor frame ).
	ontology compileAllFrames.
	html := ontology view asHTML5.

	"Test that labels are present in the rendering."
	"Title lines"
	self pattern: '*Pizza Order*' matches: html.
	self assert: ('*Size*' match: html).
	"Are radio widgets rendered?"
	self assert: ('*(#)*' match: html ) not description: 'Hum widget should be replaced by HTML element'.
	"Expect radio button"
	self assert: ('*radio*' match: html) description: 'Expecting a radio button.'.

	"Inspect -- paste result into HTML tool/file."
	"html inspect."
	
	
	

]

{ #category : #'render as HTML' }
HumOntologyTests >> test642renderCheckBoxAsHTML [
	"Given: The frame editor instance knows what kind of frame it is editing.
	 When: The frame is a view and we render it as HTML for viewing the ontology source.
	 Then: The rendering shows a reasonable facsimile of the corresponding HTML form, 
	       but with source navigation.
	"
	| frameEditor ontology html |
	ontology := HumOntology new.
	
	"Entity 'pizza-order' must be defined before we try to store the view frame."
	ontology addEntity: 'pizza-order' attributes: #('customer' 'crust' 'size' 'toppings').
		
	"Initialize for a View Frame."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'pizza-order.'.
	frameEditor addMarkUp: '!! Pizza Order'.
	frameEditor addMarkUp: '!!! Toppings'.
	frameEditor addMarkUp: ' [P] Pepperoni  [S] Sausage  [H] Ham'.
	self assert: ( frameEditor notNil ).
	
	ontology storeFrame: ( frameEditor frame ).
	ontology compileAllFrames.
	html := ontology view asHTML5.

	"Test that labels are present in the rendering."
	"Title lines"
	self pattern: '*Pizza Order*' matches: html.
	self pattern: '*Toppings*' matches: html.
	"Are widgets rendered?"
	self assert: ('*[*]*' match: html ) not description: 'Hum widgets should be replaced by HTML element.'.
	"Expect radio button"
	self assert: ('*checkbox*' match: html) description: 'Expecting a checkbox.'.
	"Watch for bug"
	self pattern: '*<input name="H" type="checkbox"/> Ham*' matches: html.
	self pattern: '*<input name="S" type="checkbox"/> Sausage*' matches: html.
	self pattern: '*<input name="P" type="checkbox"/> Pepperoni*' matches: html.

	"Inspect -- paste result into HTML tool/file."
	"html inspect."
	
	
	

]

{ #category : #'render as HTML' }
HumOntologyTests >> test643renderTextAsHTML [
	"Given: The frame editor instance knows what kind of frame it is editing.
	 When: The frame is a view and we render it as HTML for viewing the ontology source.
	 Then: The rendering shows a reasonable facsimile of the corresponding HTML form, 
	       but with source navigation.
	"
	| frameEditor ontology html |
	ontology := HumOntology new.
	
	"Entity 'who' must be defined before we try to store the view frame."
	ontology addEntity: 'who' attributes: #('whoami').
		
	"Initialize for a View Frame."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'Who'.
	frameEditor addMarkUp: '!! Who Are You?'.
	frameEditor addMarkUp: 'Please describe yourself for our members.'.
	frameEditor addMarkUp: 'Description: [whoami 8]'.
	self assert: ( frameEditor notNil ).
	
	ontology storeFrame: ( frameEditor frame ).
	
	ontology compileAllFrames.
	html := ontology view asHTML5.

	"Test that labels are present in the rendering."
	"Title lines"
	self pattern: '*Who Are You?*' matches: html.
	"Are widgets rendered?"
	self assert: ('*[*]*' match: html ) not 
	     description: 'Hum widget should be replaced by HTML element.'.
	"Check textarea tag attributes."
  self assert: ('*<textarea*' match: html) description: 'Expecting a textarea tag.'.
	self pattern: '*rows=8*' matches: html.
	self pattern: '*name="whoami"*' matches: html.
	"Inspect -- paste result into HTML tool/file."
	"html inspect."
	
	
	

]

{ #category : #'render as HTML' }
HumOntologyTests >> test650renderFrame4DictionaryAsHTML [
	"The frame editor instance knows what kind of frame it is editing.
	"
	| frameEditor ontology html |
	ontology := HumOntology new.
		
	"Initialize for a Dictionary Frame."
	frameEditor := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.
	frameEditor addDictionaryLine: 'Recipe attributes include recipe-name, description, ingredients, steps.'.
	frameEditor addDictionaryLine: 'Recipe includes a list of ingredients. (Does sequence matter for ingredients?)'.  
	frameEditor addDictionaryLine: 'Recipe includes a list of steps.  (Sequence is essential for steps.)'. 
	frameEditor addDictionaryLine: 'Ingredient attributes include ingredient-name, quantity, alternate-ingredient.'.
	frameEditor addDictionaryLine: 'Step attributes include step-number, step-description'.
	
		self assert: ( frameEditor notNil ).
	
	ontology storeFrame: ( frameEditor frame ).
	html := ontology view asHTML5.
	
	self pattern:  '*vocabulary*' matches: html.
	self pattern: '*recipe-name*' matches: html.
	self pattern: '*<k>list</k>* of *ingredients*' matches: html.
	self pattern: '*step-number*' matches: html.
	self pattern: '*Ingredient*<k>attributes</k>*' matches: html.
	self pattern: '*Step*<k>attributes</k>*' matches: html.
	
	"Note: String>>match: is not case sensitive.
	So following checks that capitalization is maintained."
	self assert: ( (html findString: '<n>Step</n> <k>attributes</k>') > 0 ).
	self assert: ( (html findString: 'sequence') > 0 ).
	"html inspect."
	
	
	
]

{ #category : #'render as HTML' }
HumOntologyTests >> test680renderOntologyAsHTML [
	"Render an ontology object in HTML and store on given filename."
	| ontology frameEditor html |
	
	ontology := HumOntology new.
	
	"Create a Plan Frame."
	frameEditor := HumFrameUpdater ontology: ontology goal: 'Cake is baked according to recipe..'.
	frameEditor appendPrecondition: 'Oven is preheated to the temperature given in the recipe.'.
	frameEditor appendPrecondition: 'The recipe`s batter is in a prepared cake pan.'.
	frameEditor appendRole: 'Timer' action: 'Bake the pan in the oven for the time given in the recipe.' .
	ontology storeFrame: ( frameEditor frame ).
	
	"Create an Action Frame."
	frameEditor := HumFrameUpdater ontology: ontology  
	                                   role: 'baker' 
																	action: 'Bake the pan in the oven for the time given in the recipe.'.
	frameEditor appendInstructionStatement: 'Open the oven door.'.
	frameEditor appendInstructionStatement: 'Place the pan in the oven.'.
	frameEditor appendInstructionStatement: 'Close the oven door.'.
	frameEditor appendInstructionRole: 'Oven' statement: 'Bake for the time given.' comment: 'We have a smart oven.'.	
	ontology storeFrame: ( frameEditor frame ).
	
	"Create a Dictionary Frame."
	frameEditor := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.
	frameEditor addDictionaryLine: 'Recipe attributes include recipe-name, description, ingredients, steps.'.
	frameEditor addDictionaryLine: 'Recipe includes a list of ingredients.'.
	frameEditor addDictionaryLine: 'Recipe includes a list of steps.'.
	frameEditor addDictionaryLine: 'Ingredient attributes include ingredient-name, quantity, alternate-ingredient.'.
	frameEditor addDictionaryLine: 'Step attributes include step-number, step-description'.
	frameEditor addDictionaryLine: 'Bakery attributes include oven, mixer, counter.'.
	frameEditor addDictionaryLine: 'Recipe attributes include baking-time.'.

	ontology storeFrame: ( frameEditor frame ).

	"Create a View Frame."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'recipe.'.
	frameEditor addMarkUp: '!! Recipe'.
	frameEditor addMarkUp: ' recipe-name: [name]'.
	frameEditor addMarkUp: '   description: [description 5]'.
	frameEditor addMarkUp: '   ingredients: [ingredients]'.
	frameEditor addMarkUp: '            steps: [steps]'.
	ontology storeFrame: ( frameEditor frame ).
	
	"Frames must be compiled if nouns are to be marked."
	ontology compileAllFrames.
	html := ontology view asHTML5.
	self assert: ( html size > 1000 ).
	
	"Frames should be have horizontal lines between."
	self pattern:  '*<hr/>*<HumFrame>*' matches: html.
	
	"Should see some nouns flagged."
	self pattern:  '*<n>*</n>*' matches: html.
	self pattern:  '*<n>oven</n>*' matches: html.
	self pattern:  '*<n>recipe</n>*' matches: html.
	
	
	
	


	
	

	
]

{ #category : #'render as HTML' }
HumOntologyTests >> test690renderOntologyAsHTMLonFile [
	"Render an ontology object in HTML and store on given filename."
	| ontology frameEditor html planFrame1 planFrame2 planFrame3 |
	
	ontology := HumOntology new.
	ontology title: 'test690renderOntologyAsHTMLonFile'.
		
	planFrame1 := HumFrame4Plan ontology: ontology goal: 'Bake a cake per recipe.'.
	planFrame1 appendPrecondition: 'Oven is preheated per recipe.'.	
	planFrame1 appendPrecondition: 'Batter is in bake-pan per recipe.'.
	planFrame1 appendRole: 'Baker' action: 'Bake bake-pan in the oven per recipe.'.
	ontology storeFrame: planFrame1.
		
	planFrame2 := HumFrame4Plan ontology: ontology goal: 'Oven is preheated per recipe.'.
	planFrame2 appendPrecondition: 'Oven is cleared out.'.
	planFrame2 appendPrecondition: 'Oven is on.'.
	planFrame2 appendPrecondition: 'Oven temperature is set per recipe.'.
	planFrame2 appendRole: 'Timer' action: 'Wait 5 minutes.'.
	ontology storeFrame: planFrame2.
	
	planFrame3 := HumFrame4Plan ontology: ontology goal: 'Batter is in bake-pan per recipe.'.
	planFrame3 appendPrecondition: 'Batter fully mixed per recipe.'.
	planFrame3 appendPrecondition: 'Bake-pan is greased per recipe.'.
	planFrame3 appendRole: 'Baker' action: 'Pour batter into bake-pan per recipe.'.
	ontology storeFrame: planFrame3.

	
	"Create an Action Frame."
	frameEditor := HumFrameUpdater ontology: ontology  
	                                   role: 'baker' 
																	action: 'Bake the pan in the oven for the time given in the recipe.'.
	frameEditor appendInstructionStatement: 'Open the oven door.'.
	frameEditor appendInstructionStatement: 'Place the pan in the oven.'.
	frameEditor appendInstructionStatement: 'Close the oven door.'.
	frameEditor appendInstructionRole: 'Oven' statement: 'Bake for the baking-time given in the recipe.' comment: 'We have a smart oven.'.	
	ontology storeFrame: ( frameEditor frame ).
	
	"Create a Dictionary Frame."
	frameEditor := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.
	frameEditor addDictionaryLine: 'Recipe attributes include recipe-name, description, ingredients, steps.'.
	frameEditor addDictionaryLine: 'Recipe includes a list of ingredients.'.
	frameEditor addDictionaryLine: 'Recipe includes a list of steps.'.
	frameEditor addDictionaryLine: 'Ingredient attributes include ingredient-name, quantity, alternate-ingredient.'.
	frameEditor addDictionaryLine: 'Step attributes include step-number, step-description'.
	frameEditor addDictionaryLine: 'Bakery attributes include oven, mixer, counter.'.
	frameEditor addDictionaryLine: 'Recipe attributes include baking-time.'.
	ontology storeFrame: ( frameEditor frame ).

	"Create a View Frame."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	frameEditor addMarkUp: '!! Recipe'.
	frameEditor addMarkUp: ' recipe-name: [name]'.
	frameEditor addMarkUp: '   description: [description 5]'.
	frameEditor addMarkUp: '   ingredients: [ingredients]'.
	frameEditor addMarkUp: '            steps: [steps]'.
	ontology storeFrame: ( frameEditor frame ).
	
	"Frames must be compiled if nouns are to be marked."
	ontology compileAllFrames.
	html := ontology view asHTML5.
	self assert: ( html size > 1000 ).
	
	"Write on a file."
	ontology view renderAsHTMLonFileNamed: 'test690renderOntologyAsHTMLonFile.html'.


	
	

	
]

{ #category : #'pattern matching' }
HumOntologyTests >> test900checkUsability [
	"Test the pattern matching.
	When the current line contains the pattern, 
	Then the match is true.
	"
	| frameLine pattern template  cr code |

	"Test using a dictionary statement pattern."
	pattern := '1 has a list of 2'.

	"Create a frame line that will match the pattern."
	frameLine := HumFrameLine new.
	frameLine source: 'Frame has a list of frameLines. '.
	"Should match"
	self assert: (frameLine matchesPattern: pattern ).

	"Generate some code"
	"Check usability -- What if we wanted to generate Smalltalk?"
	cr := String cr.
	template := 'ontology addEntity: ''1'' attribute: ''2''.', cr, 'ontology addNoun: ''2'' isA: ''list''.'.

	"Check usability -- What if we wanted to generate Java?  
	In this situation, we need the singular form of the noun.
	So we will extend the template notation . . .
	(2~ indicates the singular form of noun 2)"
	template := 'private List<2~> 2;', cr, '1.attribute( 2 );'.

	"Check usability -- What if we wanted to generate JavaScript?"
	template := 'var 2 = [];  1["2"] = 2;'.
	
	"Check usability -- What if we wanted to generate Erlang?
	We will use an ets to represent an entity in Erlang.
	(An Erlang record would probably be a better representation but it is not very dynamic.).
	Anyway, this is mainly for testing 
	Note: 2 must be a good-enough Erlang atom.
	All of these languages will require that Hum nouns such as billing-address be translated to camelCase.
	"
	template := 'ets:new( 1, [ ordered_set, named_table ] ),', cr, 'ets:insert( 1, { 2, [] } ),'.
	
	"Check usability -- What if we wanted to generate Python?
	 We will represent entities using a dictionary in Python."
	template := '1 = dict()', cr, '1.setdefault( "2", [ ] )'.  
	
	"Generate arbitrary code"
	code := frameLine onMatch: pattern generate: template.
	
	
]

{ #category : #'pattern matching' }
HumOntologyTests >> test910lineMatchesPattern [
	"Test the pattern matching.
	When the current line contains the pattern, 
	Then the match is true.
	"
	| frameLine pattern template arguments cr |
	"Test using a dictionary statement pattern."
	pattern := '1 has a list of 2'.
	"Create a frame line that will match the pattern."
	frameLine := HumFrameLine new.
	frameLine source: 'Frame has a list of frameLines. '.
	"Should match"
	self assert: (frameLine matchesPattern: pattern ).
	
]

{ #category : #'pattern matching' }
HumOntologyTests >> test911lineDoesNotMatchPattern [
	"Test the pattern matching.
	When the current line contains the pattern, 
	Then the match is true.
	"
	| frameLine pattern template arguments cr |
	"Test using a dictionary statement pattern."
	pattern := '1 has a list of 2'.
	"Create a frame line that will match the pattern."
	frameLine := HumFrameLine new.
	frameLine source: 'Frame has a set of frameLines. '.
	"Should not match"
	self assert: (frameLine matchesPattern: pattern ) not.
	
]

{ #category : #'pattern matching' }
HumOntologyTests >> test912lineMatchesFloatingPattern [
	"Test the pattern matching.
	When the current line contains the pattern, 
	Then the match is true.
	"
	| frameLine pattern template arguments cr |
	"Test using a dictionary statement pattern."
	pattern := '[1]'.
	"Create a frame line that will match the pattern."
	frameLine := HumFrameLine new.
	frameLine source: ' blah blah label: [attribute] blah blah '.
	"Should match"
	self assert: (frameLine matchesPattern: pattern ).
	
]

{ #category : #'pattern matching' }
HumOntologyTests >> test913lineMatchesFloatingPattern [
	"Test the pattern matching.
	When the current line contains the pattern, 
	Then the match is true.
	"
	| frameLine pattern template arguments cr |
	"Test using a dictionary statement pattern."
	pattern := '[1 2]'.
	"Create a frame line that will match the pattern."
	frameLine := HumFrameLine new.
	frameLine source: ' blah blah label: [entity attribute] blah blah '.
	"Should match"
	self assert: (frameLine matchesPattern: pattern ).
	
]

{ #category : #'pattern matching' }
HumOntologyTests >> test914lineMatchesFloatingPattern [
	"Test the pattern matching.
	When the current line contains the pattern, 
	Then the match is true.
	"
	| frameLine pattern template arguments cr |
	"Test using a dictionary statement pattern."
	pattern := '[1: 2]'.
	"Create a frame line that will match the pattern."
	frameLine := HumFrameLine new.
	frameLine source: ' blah blah label: [pane: view] blah blah '.
	"Should match"
	self assert: (frameLine matchesPattern: pattern ).
	
]

{ #category : #'pattern matching' }
HumOntologyTests >> test915lineFailsFloatingPattern [
	"Test the pattern matching.
	When the current line contains the pattern, 
	Then the match is true.
	"
	| frameLine pattern template arguments cr |
	"Test using a dictionary statement pattern."
	pattern := '(1)'.
	"Create a frame line that will match the pattern."
	frameLine := HumFrameLine new.
	frameLine source: ' blah blah label: [pane: view] blah blah '.
	"Should match"
	self assert: (frameLine matchesPattern: pattern ) not.
	
]

{ #category : #'pattern matching' }
HumOntologyTests >> test920lineMatchesPatternParameters [
	"Test the pattern matching.
	When the current line contains the pattern, 
	Then the match is true.
	"
	| frameLine pattern template parameters cr |
	"Test using a dictionary statement pattern."
	pattern := '1 has a list of 2'.
	"Create a frame line that will match the pattern."
	frameLine := HumFrameLine new.
	frameLine source: 'Frame has a list of frameLines. '.
	"Should match"
	self assert: (frameLine matchesPattern: pattern ).
	"Get parameters"
	parameters := frameLine extractPatternParameters: pattern.
	self assert: ( parameters at: 1 ) = 'frame'.	
	self assert: ( parameters at: 2 ) = 'framelines'.
	
]

{ #category : #'pattern matching' }
HumOntologyTests >> test922lineMatchesFloatingPatternParameters [
	"Test the pattern matching.
	When the current line contains the pattern, 
	Then the match is true.
	"
	| frameLine pattern template parameters cr |
	"Test using a dictionary statement pattern."
	pattern := '[1]'.
	"Create a frame line that will match the pattern."
	frameLine := HumFrameLine new.
	frameLine source: ' blah blah label: [attribute] blah blah '.
	"Should match"
	self assert: (frameLine matchesPattern: pattern ).
	"Get parameters"
	parameters := frameLine extractPatternParameters: pattern.
	self assert: ( parameters at: 1 ) = 'attribute'.	
	

]

{ #category : #'pattern matching' }
HumOntologyTests >> test923lineMatchesFloatingPatternParameters [
	"Test the pattern matching.
	When the current line contains the pattern, 
	Then the match is true.
	"
	| frameLine pattern template parameters cr |
	"Test using a dictionary statement pattern."
	pattern := '[1 2]'.
	"Create a frame line that will match the pattern."
	frameLine := HumFrameLine new.
	frameLine source: ' blah blah label: [entity attribute] blah blah '.
	"Should match"
	self assert: (frameLine matchesPattern: pattern ).
	
	"Get parameters"
	parameters := frameLine extractPatternParameters: pattern.
	self assert: ( parameters at: 1 ) = 'entity'.	
	self assert: ( parameters at: 2 ) = 'attribute'.

	
]

{ #category : #'pattern matching' }
HumOntologyTests >> test930generateCode [
	"Generate some code that does not require that we find a singular noun.
	"
	| frameLine pattern template  cr code |

	"Test using a dictionary statement pattern."
	pattern := '1 has a list of 2'.

	"Create a frame line that will match the pattern."
	frameLine := HumFrameLine new.
	frameLine source: 'Frame has a list of frameLines. '.
	"Should match"
	self assert: (frameLine matchesPattern: pattern ).

	"Generate some code"

	"Check usability -- What if we wanted to generate JavaScript?"
	template := 'var 2 = [];  1["2"] = 2;'.
	
	"Generate arbitrary code"
	code := frameLine onMatch: pattern generate: template.
	
	self assert: ( code sameAs: 'var framelines = [];  frame["framelines"] = framelines;' ).
	
	
]
