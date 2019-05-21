Class {
	#name : #HumCodeBaseTests,
	#superclass : #HumTestCase,
	#category : #'Hum-Tests'
}

{ #category : #running }
HumCodeBaseTests >> setUp [
	"Set up a default store for these tests."
	|  |
	HumStore defaultDirectory: './Developer/Smalltalk/Hum8/html'.
]

{ #category : #running }
HumCodeBaseTests >> tearDown [ 
	"reset the default store to nil - so it doesn't leak."
	HumStore defaultStore: nil.
]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test110MyPackages [
	| packageList |
	packageList := HumCodeBase myPackages.
	self assert: (packageList size < 20).
	self assert: (packageList includes: 'Hum-X').
	
	Transcript cr; show: 'Hum package count = ', (packageList size asString).
]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test120MyClasses [
	| packageList classList |
	packageList := HumCodeBase myPackages.
	self assert: (packageList includes: 'Hum-X').
	classList := OrderedCollection new.
	packageList 
		do: [ :package |
			classList addAllLast: (HumCodeBase classesInPackage: package).
			].
	self assert: ( classList size <  170 ).
	Transcript cr; show: 'Hum class count = ', (classList size asString).
]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test130GetPackageClassTuples [
	| packageClassTree |
	packageClassTree := HumCodeBase getPackageClassTuples.
	self assert: ( packageClassTree size < 170 ).
	self assert: ( packageClassTree anySatisfy: [ :tuple | (tuple at: 2) = (self class)] ).
	
	Transcript cr; show: 'Hum package-class-tree count = ', (packageClassTree size asString).
	"packageClassTree inspect."
]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test140GetPackageClassMethodTuples [
	| packageClassMethodTree |
	packageClassMethodTree := HumCodeBase getPackageClassMethodTuples.
	self assert: ( packageClassMethodTree size < 2400 ).
	self assert: ( packageClassMethodTree anySatisfy: [ :tuple | (tuple at: 2) = (self class)] ).	
	self assert: ( packageClassMethodTree anySatisfy: [ :tuple | ((tuple at: 3) class )= (CompiledMethod)] ).
	
	Transcript cr; show: 'Hum package-Class-Method count = ', ( packageClassMethodTree size asString ).

]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test146CountTestModules [
	|  nTestModules |
	nTestModules := HumCodeBase countTestModules. 
	Transcript cr; show: 'Hum test-method count = ',  nTestModules asString.

]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test147CountLongModules [
	|  nLongModules |
	nLongModules := HumCodeBase countLongModules. 
	Transcript cr; show: 'Hum long method count = ',  nLongModules asString, ' with more than 20 lines of code'.
"1 --- Twenty lines is roughly the maximum amount of code 
2 ---- that can be viewed without scrolling in typical browser.
3
4
5
6
7
8
9
10
1
2
3
4
5
6
7
8
9
20"
]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test148CountLongModules [
	"Count modules whose listing will exceed one page. "
	|  nLongModules lineLimit |
	lineLimit := 50. "one page of code"
	nLongModules := HumCodeBase countLongModules: lineLimit. 
	Transcript cr; show: 'Hum long method count = ',  nLongModules asString, ' with more than ', lineLimit asString,' lines of code'.
]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test150gatherSources [
	| packageClassMethodCode nLinesOfCode |
	packageClassMethodCode := HumCodeBase getPackageClassMethodCode.
	nLinesOfCode := packageClassMethodCode size. 
	self assert: ( nLinesOfCode  > 2200 ).
	self assert: ( nLinesOfCode  < 2300 ).
	self assert: ( packageClassMethodCode anySatisfy: [ :tuple | (tuple at: 2) isKindOf: String ] ).	
	self assert: ( packageClassMethodCode anySatisfy: [ :tuple | (tuple at: 3) isKindOf: String ] ).	
	self assert: ( packageClassMethodCode anySatisfy: [ :tuple | (tuple at: 4) isKindOf: String ] ).
]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test160LinesOfCode [
	| linesOfCode |
	linesOfCode := HumCodeBase countLinesOfCode.
	self assert: ( linesOfCode >  29000 ).
	self assert: ( linesOfCode < 32999 ).
	Transcript cr; show: 'Hum lines of code = ', (linesOfCode asString).

]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test161LinesOfCodePerModule [
	| linesOfCode nMethods |
	linesOfCode := HumCodeBase countLinesOfCode.
	nMethods := (HumCodeBase getPackageClassMethodTuples) size.
	Transcript cr; show: 'Average method length = ', (1.0 * linesOfCode / nMethods) rounded asString.

]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test170FindToDoLines [
	| toDoLines |
	toDoLines := HumCodeBase findToDoLines.
	self assert: ( toDoLines size > 300 ).
	self assert: ( toDoLines size < 350 ).
	Transcript cr; show: 'Hum TODO lines count = ', (toDoLines size asString).

]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test171FindCommentLines [
	| commentLines n |
	commentLines := HumCodeBase findCommentLines.
	n := commentLines size.
	self assert: ( n > 5000 ).
	self assert: ( n < 6000 ).
	Transcript cr; show: 'Hum comment lines count = ', ( n asString ).

]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test175FindAssertLines [
	| assertLines n |
	assertLines := HumCodeBase findAssertLines.
	n := assertLines size.
	self assert: ( n > 2700 ).
	self assert: ( n < 2800 ).
		
	Transcript cr; show: 'Hum assert lines count = ', (assertLines size asString).


]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test180listOnHTML [
	| html store stream |
	html := HumCodeBase listOnHTML.
	store := HumStore defaultStore. "as specified in setUp"
	stream := store writeStreamOnFileNamed: 'HumCodeBaseListing.html'.
	stream nextPutAll: (html contents).
	stream close.

]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test182listOnHTML2Lines [
	| html store stream |
	html := HumCodeBase listOnHTML2Lines.
	store := HumStore defaultStore.
	stream := store writeStreamOnFileNamed: 'HumCodeBaseShortListing.html'.
	stream nextPutAll: (html contents).
	stream close.

]

{ #category : #'as yet unclassified' }
HumCodeBaseTests >> test183listOnHTMLcomments [
	| html store stream |
	html := HumCodeBase listOnHTMLcomments.
	store := HumStore defaultStore.
	stream := store writeStreamOnFileNamed:  'HumCodeBaseComments.html'.
	stream nextPutAll: (html contents).
	stream close.

]
