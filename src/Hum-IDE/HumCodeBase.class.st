"
HumCodeBase provides a wrapper on SystemOrganization
and other Smalltalk introspection facilities
to enable scanning of the Hum Smalltalk Packages.

It is a singleton with all of its methods on the class side.


"
Class {
	#name : #HumCodeBase,
	#superclass : #Object,
	#classInstVars : [
		'myPackages'
	],
	#category : #'Hum-IDE'
}

{ #category : #'package queries' }
HumCodeBase class >> classesInPackage: aPackageNameSymbol [ 
	| myClasses |
	myClasses := SystemOrganizer default classesInCategory: aPackageNameSymbol.
	^myClasses.
]

{ #category : #'quality queries' }
HumCodeBase class >> countLinesOfCode [
	| nLines packageClasses |
	packageClasses := self getPackageClassTuples.
	nLines := 0.
	packageClasses
		do: [ :packageClass |
			| package class |
			package := packageClass at: 1.
			class := packageClass at: 2.
			nLines := nLines + ( class linesOfCode ).
			 ].
	^ nLines.
]

{ #category : #'quality queries' }
HumCodeBase class >> countLongModules [
	"Count modules that contain more than xx lines of code."
	"Twenty lines is roughly the amount of code that can be viewed without scrolling."
	|  nLongModules    |
	nLongModules := self countLongModules: 20.
	^ nLongModules.
]

{ #category : #'quality queries' }
HumCodeBase class >> countLongModules: lineLimit [
	"Count modules that contain more than (lineLimit) lines of code."
	"Twenty lines is roughly the amount of code that can be viewed without scrolling."
	| packageClassMethodSources nLongModules calc cr  |
	nLongModules := 0.
	cr := Character cr.
	packageClassMethodSources := self getPackageClassMethodCode.
	calc := HumCalculator new.
	packageClassMethodSources
		do: [ :packageClassMethodSource |
			| packageName className methodName source   |
			packageName := packageClassMethodSource at: 1.
			className := packageClassMethodSource at: 2.
			methodName := packageClassMethodSource at: 3.
			source := packageClassMethodSource at: 4.
			(( source count: [ :ch | ch =  cr ] ) > lineLimit) ifTrue: [ nLongModules := nLongModules + 1. ]
			 ].
	^ nLongModules.
]

{ #category : #'quality queries' }
HumCodeBase class >> countTestModules [
	"Count the methods whose name begins with 'test'. "
	| packageClassMethodTree nTestModules |
	packageClassMethodTree := HumCodeBase getPackageClassMethodTuples.
	nTestModules := ( packageClassMethodTree count: [ :tuple | (tuple at: 3) selector beginsWith: 'test' ] ).
	^nTestModules

]

{ #category : #printing }
HumCodeBase class >> css [
	| html |
	html := HumCalculator new xml: 'style' with: '
		body {font-family: MONOSPACE;}
		
		method {   }
		comment { color: DarkGreen; }
		todo { color: Red; }
		r { color: Red; }
		return { color: Blue; }
	'.
	^html.
]

{ #category : #'quality queries' }
HumCodeBase class >> findAssertLines [
	| packageClassMethodSources toDoLines calc |
	toDoLines := OrderedCollection new.
	packageClassMethodSources := self getPackageClassMethodCode.
	calc := HumCalculator new.
	packageClassMethodSources
		do: [ :packageClassMethodSource |
			| packageName className methodName source stream  |
			packageName := packageClassMethodSource at: 1.
			className := packageClassMethodSource at: 2.
			methodName := packageClassMethodSource at: 3.
			source := packageClassMethodSource at: 4.
			stream := ReadStream on: source.
			stream position: 0.
			[ stream atEnd ] 
				whileFalse: [ 
					|  aLine | 
					aLine := stream upTo: (Character cr).
					calc cases;
						when: [ '*self assert:*' match: aLine  ] 
							then: [ toDoLines add: { packageName. className. methodName.  aLine. } ];
						when: [ '*self expect:*actual:*' match: aLine  ] 
							then: [ toDoLines add: { packageName. className. methodName.  aLine. } ];
						when: [ '*self deny:*' match: aLine  ] 
							then: [ toDoLines add: { packageName. className. methodName.  aLine. } ].

					].
			 ].
		^ toDoLines.
]

{ #category : #'quality queries' }
HumCodeBase class >> findCommentLines [
	| packageClassMethodSources commentLines |
	commentLines := OrderedCollection new.
	packageClassMethodSources := self getPackageClassMethodCode.
	packageClassMethodSources
		do: [ :packageClassMethodSource |
			| packageName className methodName source stream  |
			packageName := packageClassMethodSource at: 1.
			className := packageClassMethodSource at: 2.
			methodName := packageClassMethodSource at: 3.
			source := packageClassMethodSource at: 4.
			stream := ReadStream on: source.
			stream position: 0.
			[ stream atEnd ] 
				whileFalse: [ 
					|  aLine | 
					aLine := stream upTo: (Character cr).
					( '*"*"*' match: aLine ) ifTrue: [ commentLines add: { packageName. className. methodName.  aLine. } ].
					].
			 ].
		^ commentLines.
]

{ #category : #'quality queries' }
HumCodeBase class >> findMatch: aPattern [
	| packageClassMethodSources toDoLines |
	toDoLines := OrderedCollection new.
	packageClassMethodSources := self getPackageClassMethodCode.
	packageClassMethodSources
		do: [ :packageClassMethodSource |
			| packageName className methodName source stream  |
			packageName := packageClassMethodSource at: 1.
			className := packageClassMethodSource at: 2.
			methodName := packageClassMethodSource at: 3.
			source := packageClassMethodSource at: 4.
			stream := ReadStream on: source.
			stream position: 0.
			[ stream atEnd ] 
				whileFalse: [ 
					|  aLine | 
					aLine := stream upTo: (Character cr).
					( aPattern match: aLine ) ifTrue: [ toDoLines add: { packageName. className. methodName.  aLine. } ].
					].
			 ].
		^ toDoLines.
]

{ #category : #'quality queries' }
HumCodeBase class >> findToDoLines [
		| toDoLines |
		toDoLines := self findMatch: '*TODO*'.
		^ toDoLines.
]

{ #category : #'package queries' }
HumCodeBase class >> getPackageClassMethodCode [
	| packageClassMethods packageClassMethodSources |
	packageClassMethodSources := OrderedCollection new.
	packageClassMethods := self getPackageClassMethodTuples.
	packageClassMethods
		do: [  :packageClassMethod |
			| tuple package class method source |	
			package := packageClassMethod at: 1.
			class      := packageClassMethod at: 2.
			method := packageClassMethod at: 3.
			source := method sourceCode. 
			tuple := { package. class name. method selector. source. }.
			packageClassMethodSources add: tuple.
			 ].
	^packageClassMethodSources.
]

{ #category : #'package queries' }
HumCodeBase class >> getPackageClassMethodTuples [
	| tuples packageClassTuples |
	tuples := OrderedCollection new.
	packageClassTuples := self getPackageClassTuples.
	packageClassTuples
		do: [ :packageClass | 
			| packageName class methods |
			packageName := packageClass at: 1.
			class               := packageClass at: 2.
			methods  := class methods.
			methods
				do: [ :method |
					 tuples add: { packageName. class. method. }.	
					].
			].
	^tuples. 
]

{ #category : #'package queries' }
HumCodeBase class >> getPackageClassTuples [
	| packageClassTree packageList classList |
	packageClassTree := OrderedCollection new.
	
	packageList := self myPackages.
	self assert: (packageList includes: 'Hum-X').
	classList := OrderedCollection new.
	packageList 
		do: [ :package |
			classList := (self classesInPackage: package).
			classList do: [ :class |
				 packageClassTree add: { package. class. }.  "Note: class points to a class, not a string." 
				].
			].
	^packageClassTree.
]

{ #category : #printing }
HumCodeBase class >> listOnHTML [
	| packageClassMethodSources sortedTuples  html |
	html := ReadWriteStream on: String new.
	html nextPutAll: (HumCalculator new xml: 'head' with: [ self css ] ).
	html nextPutAll: '<body>'.

	html nextPutAll: '<h1>Hum Code Base</h1>'.
	packageClassMethodSources := self getPackageClassMethodCode.
    sortedTuples := packageClassMethodSources 
								sorted: [ :tupleA :tupleB | 
									| keyA keyB |
									keyA := (tupleA at: 1), (tupleA at: 2),(tupleA at: 3). 
									keyB := (tupleB at: 1), (tupleB at: 2),(tupleB at: 3). 
									keyA <= keyB.
									].
	sortedTuples
		do: [ :packageClassMethodSource |
			| packageName className methodName source stream subtitle |
			packageName := packageClassMethodSource at: 1.
			className := packageClassMethodSource at: 2.
			methodName := packageClassMethodSource at: 3.
			source := packageClassMethodSource at: 4.
			subtitle := String cr, '<h3>', packageName, ' -- ', className, ' &gt;&gt; ', methodName, '</h3>'.
			html nextPutAll: subtitle.
			html nextPutAll: (String cr,'<pre>').
			stream := ReadStream on: source.
			stream position: 0.
			[ stream atEnd ] 
				whileFalse: [ 
					|  aLine htmlLine | 
					aLine := stream upTo: (Character cr).
					htmlLine := aLine copyReplaceAll: (String tab) with: '   ' asTokens: false.
					htmlLine := htmlLine copyReplaceAll: '<' with: '&lt;' asTokens: false.
					htmlLine := htmlLine copyReplaceAll: '>' with: '&gt;' asTokens: false.
					html nextPutAll: (String cr, htmlLine).
					].
			html nextPutAll: '</pre>'.
			 ].
	^ html.    
]

{ #category : #printing }
HumCodeBase class >> listOnHTML2Lines [
	"Show the first two lines of each method."
	| packageClassMethodSources sortedTuples  html lineCount priorString sayOnce |
	html := ReadWriteStream on: String new.
	html nextPutAll: (HumCalculator new xml: 'head' with: [ self css ] ).
	html nextPutAll: '<body>'.

	html nextPutAll: '<h1>Hum Code Base</h1>'.
	packageClassMethodSources := self getPackageClassMethodCode.
    sortedTuples := packageClassMethodSources 
								sorted: [ :tupleA :tupleB | 
									| keyA keyB |
									keyA := (tupleA at: 1), (tupleA at: 2),(tupleA at: 3). 
									keyB := (tupleB at: 1), (tupleB at: 2),(tupleB at: 3). 
									keyA <= keyB.
									].
	priorString := ''.
    sayOnce := [ :string |  (string = priorString) ifFalse: [ html nextPutAll: string ]. priorString := string ].
	sortedTuples
		do: [ :packageClassMethodSource |
			| packageName className methodName source stream  |
			packageName := packageClassMethodSource at: 1.
			className := packageClassMethodSource at: 2.
			methodName := packageClassMethodSource at: 3.
			source := packageClassMethodSource at: 4.
			sayOnce value: String cr, '<h3>', packageName, ' -- ', className, '</h3>'.
			html nextPutAll: (String cr,'<pre>').
			stream := ReadStream on: source.
			lineCount := 0.
			stream position: 0.
			[ ( stream atEnd not ) and: [ lineCount < 2 ] ]
				whileTrue: [ 
					|  aLine htmlLine | 
					lineCount := lineCount + 1.
					aLine := stream upTo: (Character cr).
					( lineCount < 2 or: [ |s| s := aLine trimBoth,'!'. '"^' includes: (s first) ]  )
						ifTrue: [ 
							htmlLine := aLine copyReplaceAll: (String tab) with: '   ' asTokens: false.
							htmlLine := htmlLine copyReplaceAll: '<' with: '&lt;' asTokens: false.
							htmlLine := htmlLine copyReplaceAll: '>' with: '&gt;' asTokens: false.
                    		html nextPutAll: (String cr, htmlLine).
							].
					].
			html nextPutAll: '</pre>'.
			 ].
	^ html.    
]

{ #category : #printing }
HumCodeBase class >> listOnHTMLcomments [
	"Show the first two lines of each method."
	| packageClassMethodSources sortedTuples  html lineCount priorString  oneTimeDict sayOneTime |
	html := ReadWriteStream on: String new.
	html nextPutAll: (HumCalculator new xml: 'head' with: [ self css ] ).
	html nextPutAll: (String cr, '<body>').

	html nextPutAll: '<h1>Hum Code Base</h1>'.
	packageClassMethodSources := self getPackageClassMethodCode.
    sortedTuples := packageClassMethodSources 
								sorted: [ :tupleA :tupleB | 
									| keyA keyB |
									keyA := (tupleA at: 1), (tupleA at: 2),(tupleA at: 3). 
									keyB := (tupleB at: 1), (tupleB at: 2),(tupleB at: 3). 
									keyA <= keyB.
									].
	priorString := ''.
  oneTimeDict := Dictionary newFrom: { 'pkg'->''. 'class'->''. }.
	sayOneTime := [ :topic :s | 
									( s = (oneTimeDict at: topic) ) ifFalse: [html nextPutAll: s]. 
									oneTimeDict at: topic put: s 
									]. 
	sortedTuples
		do: [ :packageClassMethodSource |
			| packageName className methodName source stream  |
			packageName := packageClassMethodSource at: 1.
			className := packageClassMethodSource at: 2.
			methodName := packageClassMethodSource at: 3.
			source := packageClassMethodSource at: 4.
			sayOneTime value: 'pkg' value: (String cr,'<hr/><hr/>',String cr,'<h2>',packageName,'</h2>').
			sayOneTime value: 'class' value: (String cr,'<hr/>',String cr,'<h3>',packageName,' -- ',className,'</h3>').
			html nextPutAll: (String cr, '<pre>').
			stream := ReadStream on: source.
			lineCount := 0.
			stream position: 0.
			[ ( stream atEnd not )  ]
				whileTrue: [ 
					|  aLine htmlLine | 
					lineCount := lineCount + 1.
					aLine := stream upTo: (Character cr).
					( lineCount < 2 or: [ |s| s := aLine trimBoth,'!'. '"^' includes: (s first) ]  )
						ifTrue: [ 
							| ss calc |
							htmlLine := aLine copyReplaceAll: (String tab) with: '   ' asTokens: false.
							htmlLine := htmlLine copyReplaceAll: '<' with: '&lt;' asTokens: false.
							htmlLine := htmlLine copyReplaceAll: '>' with: '&gt;' asTokens: false.
							ss := htmlLine trimBoth asLowercase .
							calc := HumCalculator new.
							calc cases;
								when: [ ss beginsWith: '"todo:'  ] then: [ html nextPutAll: (String cr, '<todo>',htmlLine,'</todo>' ) ];
								when: [ ss beginsWith: '"'  ] then: [ html nextPutAll: (String cr, '<comment>',htmlLine,'</comment>' ) ];
								when: [ ss beginsWith: '^'  ] then: [ html nextPutAll: (String cr, '<return>',htmlLine,'</return>' ) ];
								when: [ lineCount = 1 ] then: [ html nextPutAll: (String cr, '<b>',htmlLine,'</b>') ];
								otherwise: [ Error signal: 'How did we get here?'  ].
							]. "ifTrue: "
					]. "whileTrue:"
				(lineCount > 20) ifTrue: [ html nextPutAll: (String cr, '<r>***', lineCount asString, ' lines of code ***</r>') ].
				html nextPutAll: (String cr, '</pre>').
		 ]. "sortedTuples do:"
	^ html.       
]

{ #category : #'package queries' }
HumCodeBase class >> myPackages [
	"Collect packages in Hum implementation."
	| |
	^myPackages ifNil: [ myPackages := SystemOrganizer default categoriesMatching: 'Hum*'.].
	
]

{ #category : #'as yet unclassified' }
HumCodeBase >> everythingIsClassSide [
	"This is organized as a singleton - all the methods are on the class side."
]
