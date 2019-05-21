"
This class implements fuzzy arithmetic using Monte Carlo sampling of the distributions.
"
Class {
	#name : #HumFuzzy,
	#superclass : #Magnitude,
	#instVars : [
		'distribution',
		'sampleSize',
		'resultDivisions'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'as yet unclassified' }
HumFuzzy class >> distribution: aDistribution [
	"Create a new instance from the given distribution."
	| fuzzy |
	fuzzy := self basicNew.
	fuzzy initialize.
	fuzzy distribution: aDistribution.
	^fuzzy.
]

{ #category : #'instance creation' }
HumFuzzy class >> quantity: aQuantity plusOrMinus: aLimit [ 
	"Create a distribution with given limits."
	| fuzzy stats |
	self assert: ( aQuantity isKindOf: Number ).
	self assert: (    aLimit isKindOf: Number ).
	"Assume upper and lower will not be exceeded.
	The idea is that cases exceeding those measures would be rejected.
	"
	fuzzy := self basicNew.
	fuzzy initialize.
	stats := Dictionary new.
	stats
		at: 0.50  put: aQuantity;
		at: 0.00  put: (aQuantity - aLimit );
		at: 1.00  put: (aQuantity + aLimit ).
	fuzzy distribution: stats.
	^fuzzy.
]

{ #category : #evaluating }
HumFuzzy >> * aHumFuzzy [ 
	| times result |
	times := #*.
	result := self op: times with: aHumFuzzy.
	^result.
]

{ #category : #evaluating }
HumFuzzy >> + aHumFuzzy [ 
	| plus result |
	plus := #+.
	result := self op: plus with: aHumFuzzy.
	^result.
]

{ #category : #evaluating }
HumFuzzy >> - aHumFuzzy [ 
	| minus result |
	minus := #-.
	result := self op: minus with: aHumFuzzy.
	^result.
]

{ #category : #evaluating }
HumFuzzy >> / aHumFuzzy [ 
	| divide result |
	divide := #/.
	result := self op: divide with: aHumFuzzy.
	^result.
]

{ #category : #plot }
HumFuzzy >> asCrudeMorph [
		| magnifyBy scaleX scaleY scalePt vMax extent priorPt canvas morph |
	magnifyBy := 2.
	scaleX := [:v | v*magnifyBy].
	scaleY := [:p | (100 - (100*p))*magnifyBy ]. "Flip Y. Screen coordinates have Y pointing down."
	scalePt := [:pt | (scaleX value: (pt x))@(scaleY value: (pt y)) ].
	vMax := distribution at: 1.0.
	extent := ( scalePt value: (vMax@0.0) )* 1.1.
	
	priorPt := scalePt value: 0.0@0.0.
	canvas := FormCanvas extent: extent depth: 32 origin: (10@10) clipRect: (Rectangle origin: 0@0 extent: extent).
	  canvas fillColor: Color blue muchLighter.
		"verticle grid"
		(0.0 to: vMax by: 100.0)
			do: [:v | canvas line: (scalePt value: v@0.0) to: (scalePt value: v@1.0) width: 1 color: Color green].
	  "horizontal grid"
		(0.0 to: 1.0 by: 0.1)
			do:[:p | canvas line: (scalePt value: 0.0@p) to: (scalePt value: vMax@p) width: 1 color: Color green].
		(0.0 to: 1.0 by: 0.5)
			do:[:p | canvas line: (scalePt value: 0.0@p) to: (scalePt value: vMax@p) width: 2 color: Color green].
	
	self distributionDo: [ :p :v | 
		| xy | 
		xy := scalePt value: v@p.
		canvas line: priorPt to: xy width: 4 color: Color red.
		priorPt := xy.
		].
 
	morph := canvas form asMorph openInWorld. 
	"You can delete morph by double-clicking it."
	morph on: #doubleClick send: #delete to: morph. 


]

{ #category : #plot }
HumFuzzy >> asCrudeMorph2 [
		|  scaleX scaleY scalePt vMax extent priorPt canvas morph pPixels vPixels vMin |
	pPixels := 2.
	vPixels := 2.
	vMax := distribution at: 1.0.
	vMin := distribution at: 0.0.
	"Normalize v range to [0,100]."
	scaleX := [:v | 100*(v-vMin)/(vMax-vMin)*vPixels ].
	"Flip Y. Screen coordinates have Y pointing down."
	scaleY := [:p | (100 - (100*p))*pPixels ]. 
	scalePt := [:pt | (scaleX value: (pt x))@(scaleY value: (pt y)) ].
	
	extent := ( scalePt value: (vMax@0.0) )* 1.1. "TODO: Enable caller to specify extent."
		
	priorPt := scalePt value: 0.0@0.0.
	canvas := FormCanvas extent: extent depth: 32 origin: (10@10) clipRect: (Rectangle origin: 0@0 extent: extent).
	"Paint grid lines"
	  canvas fillColor: Color blue muchLighter.
		"vertical grid"
		(vMin to: vMax by: ((vMax-vMin)*0.1))
			do: [:v | canvas line: (scalePt value: v@0.0) to: (scalePt value: v@1.0) width: 1 color: Color green].
		(vMin to: vMax by: ((vMax-vMin)*0.5))
			do: [:v | canvas line: (scalePt value: v@0.0) to: (scalePt value: v@1.0) width: 2 color: Color green].
	  "horizontal grid"
		(0.0 to: 1.0 by: 0.1)
			do:[:p | canvas line: (scalePt value: 0.0@p) to: (scalePt value: vMax@p) width: 1 color: Color green].
		(0.0 to: 1.0 by: 0.5)
			do:[:p | canvas line: (scalePt value: 0.0@p) to: (scalePt value: vMax@p) width: 2 color: Color green].
	
	self distributionDo: [ :p :v | 
		| xy | 
		xy := scalePt value: v@p.
		canvas line: priorPt to: xy width: 4 color: Color red.
		priorPt := xy.
		].
 
	morph := canvas form asMorph openInWorld. 
	"You can delete morph by double-clicking it."
	morph on: #doubleClick send: #delete to: morph. 


]

{ #category : #plot }
HumFuzzy >> asCrudeMorphInRectangle: aRectangle [
	"Display a plot in a Morph with the origin and extent indicated by the given Rectangle."
	|  scaleX scaleY scalePt vMax extent priorPt canvas morph pPixels vPixels vMin r |
	vMax := distribution at: 1.0.
	vMin := distribution at: 0.0.
	"Pixels per normalized value unit."
	extent := (aRectangle extent) - (10@10). 
	vPixels := (extent x) / 100.
	pPixels := (extent y) / 100.
	"Normalize v range to [0,100]."
	scaleX := [:v | 100*(v-vMin)/(vMax-vMin)*vPixels ].
	"Flip Y. Screen coordinates have Y pointing down."
	scaleY := [:p | (100 - (100*p))*pPixels ]. 
	scalePt := [:pt | (scaleX value: (pt x))@(scaleY value: (pt y)) ].
	
	extent := ( scalePt value: (vMax@0.0) )* 1.1. "TODO: Enable caller to specify extent."
		
	canvas := FormCanvas extent: extent depth: 32 origin: (10@10) clipRect: (Rectangle origin: 0@0 extent: extent).
	"Paint grid lines"
	  canvas fillColor: Color blue muchLighter.
		"vertical grid"
		(vMin to: vMax by: ((vMax-vMin)*0.1))
			do: [:v | canvas line: (scalePt value: v@0.0) to: (scalePt value: v@1.0) width: 1 color: Color green].
		(vMin to: vMax by: ((vMax-vMin)*0.5))
			do: [:v | canvas line: (scalePt value: v@0.0) to: (scalePt value: v@1.0) width: 2 color: Color green].
	  "horizontal grid"
		(0.0 to: 1.0 by: 0.1)
			do:[:p | canvas line: (scalePt value: 0.0@p) to: (scalePt value: vMax@p) width: 1 color: Color green].
		(0.0 to: 1.0 by: 0.5)
			do:[:p | canvas line: (scalePt value: 0.0@p) to: (scalePt value: vMax@p) width: 2 color: Color green].

	priorPt := scalePt value: vMin@0.0.	
	self distributionDo: [ :p :v | 
		| xy | 
		xy := scalePt value: v@p.
		canvas line: priorPt to: xy width: 4 color: Color red.
		priorPt := xy.
		].
 
	morph := canvas form asMorph bounds: aRectangle.
	morph openInWorld. 
	"You can delete morph by double-clicking it."
	morph on: #doubleClick send: #delete to: morph. 


]

{ #category : #accessing }
HumFuzzy >> atP: aFloat [ 
	"Return the appropriate value from the distribution.
	Iterpolate when necessary. 
	This version uses linear interpolation.
	Future versions might use a spline or something."
	| result |
	"Check that aFloat is between zero and one"
	self assert: ( aFloat isKindOf: Float ).
	self assert: ( aFloat >= 0.0 ).
	self assert: ( aFloat <= 1.00).
	"Look up value or interpolate to get a result."
	result := distribution at: aFloat ifAbsent: [ self interpolate: aFloat ].
	^ result.
]

{ #category : #evaluating }
HumFuzzy >> correctInterceptInDistribution: aDistribution [
	"-- Use slope-intercept to get a better estimate of the S-curve value at probability 0.
	v(p) = a + b*p
	v(0) = a.
	v(p1) = a + b*p1.
	v(p2) = a + b*p2.
	v(p2) - v(p1) = b*(p2-p1).
	b = ( v(p2) - v(p1) ) / (p2-p1).
	extrapolate a = v(0) so that we get the same slope b.
	b = ( v(p2) - v(0) ) / (p2 - 0).
	b = ( v(p2) - a ) / p2.
	b * p2 = v(p2) - a.
	a = v(p2) - (b * p2).
	"
	| tick p1 p2 v1 v2 b a | 
	self assert: (aDistribution isKindOf: Dictionary).
	tick := sampleSize / resultDivisions.  "This must be coordinated to match >>op:with:"
	p1 := (tick/sampleSize) asFloat.
	p2 := (tick * 2/sampleSize) asFloat.
	v1 := aDistribution at: p1.
	v2 := aDistribution at: p2.
	b := (v2 - v1) / (p2 - p1).
	a := v2 - ( b * p2 ).
	aDistribution at: 0.0 put: a.
	
]

{ #category : #accessing }
HumFuzzy >> distribution: aDictionary [ 
	"Distribution is an S-curve that maps probability to value.
	Example: 'distribution at: 0.50 put: 12.' 
	  means that sample values will be less than or equal to 12 for 50% of samples.
	In other words, the median of the distribution is 12.
	"
	self assert: ( aDictionary isKindOf: Dictionary ).
	distribution := aDictionary.
]

{ #category : #accessing }
HumFuzzy >> distributionDo: pvBlock [
	"Vist the key->value (probability->value) entries in the distribution."
	| keys |
	self assert: ( pvBlock isKindOf: BlockClosure ).
	self assert: ( pvBlock argumentCount = 2 ).
	self assert: ( distribution isKindOf: Dictionary ).
	keys := distribution keysSortedSafely.
	keys 
		do: [ :p |
			| v |
			v := distribution at: p.
			pvBlock value: p value: v.
			].
]

{ #category : #accessing }
HumFuzzy >> fromScaledDecimal: aScaledDecimal [
	"Set the distribution from the given string.
	Assume the string value is the median (50% point) of a distribution.
	Assume the 0% and 100% value are the median plus or minus the scale (number of decimal places).
	"
	| scaledDecimal assumedMedian err assumedDistribution calc |
	calc := HumCalculator new.
	calc cases;
		when: [ aScaledDecimal isKindOf: ScaledDecimal ]
			then: [ scaledDecimal := aScaledDecimal ];
		when: [ aScaledDecimal isKindOf: String ]
			then: [ scaledDecimal := ScaledDecimal readFrom: aScaledDecimal ];
		otherwise: [ Error signal: 'Expected ScaledDecimal or String. Got: ', (aScaledDecimal class) ].
	assumedMedian := scaledDecimal asFloat.
	err := 10.0 raisedToInteger: (scaledDecimal scale negated).
	assumedDistribution := Dictionary new.
	assumedDistribution
		at: 0.50 put: assumedMedian;
		at: 0.00 put: assumedMedian - err;
		at: 1.00 put: assumedMedian + err.
	self distribution: assumedDistribution.
	 
]

{ #category : #accessing }
HumFuzzy >> fromString: aString [
	"Set the distribution from the given string.
	Assume the string value is the median (50% point) of a distribution.
	Assume the 0% and 100% value are the median plus or minus the scale (number of decimal places).
	"
	| scaledDecimal assumedMedian err assumedDistribution |
	scaledDecimal := ScaledDecimal readFrom: aString.
	assumedMedian := scaledDecimal asFloat.
	err := (10.0 raisedToInteger: (scaledDecimal scale negated))/2.0.
	assumedDistribution := Dictionary new.
	assumedDistribution
		at: 0.50 put: assumedMedian;
		at: 0.00 put: assumedMedian - err;
		at: 1.00 put: assumedMedian + err.
	self distribution: assumedDistribution.
	 
]

{ #category : #accessing }
HumFuzzy >> initialize [
	self sampleSize: 1024*16 resultDivisions: 32.
	
]

{ #category : #accessing }
HumFuzzy >> interpolate: aProbability [
	"Return the predicted value at aProbability using linear interpolation."
	| lowerP lowerF upperP upperF slope result |
	self assert: (aProbability isKindOf: Float ).
	"Following depends on Dictionary semantics"
	self assert: ( distribution isKindOf: Dictionary ).
	"Find the interval that brackets the requested point."
	lowerP := 0.0.
	lowerF := distribution at: lowerP.
	upperP := 1.0.
	upperF := distribution at: upperP.
	distribution keysAndValuesDo: [ :k :v |
		( k > lowerP and: [ k < aProbability ] ) ifTrue: [ lowerP := k. lowerF := v. ].
		( k < upperP and: [ k > aProbability ] ) ifTrue: [ upperP := k. upperF := v. ].
		].
	"Do simple linear interpolation."
	slope :=  ( upperF - lowerF ) / ( upperP - lowerP ).
	"Check: for an S-Curve the slope is always positive."
	self assert: ( slope > 0.0 ).
	
	result := lowerF + ( (aProbability - lowerP) * ( slope) ).
	"Check: the result must be between upper and lower function values"
	self assert: ( result > lowerF ).
	self assert: ( result < upperF ).
	"TODO: If we need more accuracy, use two quadratic splines.
	Currently, the data we have does not justify such accuracy,
	so I decided to keep it simple.
	"
	^result.
]

{ #category : #evaluating }
HumFuzzy >> mean [
	| sum n result |
	sum := 0.0.
	n := 0.
	self sampleWithBlock: [ :x | n := n + 1. sum := sum + x.].
	result := sum / n.
	^result.
]

{ #category : #accessing }
HumFuzzy >> median [
	"find the point that represents the median"
	|  medianPoint |
	"Distribution is list of f->p".
	"Look for f@0.50"
	medianPoint := self atP: 0.50.
	^medianPoint.
]

{ #category : #evaluating }
HumFuzzy >> op: aSymbol with: aHumFuzzy [
 "Add two fuzzy distibutions using Monte Carlo sampling"
	| resultSet random  vC sortedSet distributionC tick count fuzzyC |
	resultSet := Bag new.
	random := Random new.
	( 1 to: sampleSize )
		do: [ :i |
			| rA rB vA vB |
			rA := random next.
			vA := self atP: rA.
			rB := random next.
			vB := aHumFuzzy atP: rB.
			vC := vA perform: aSymbol with: vB.
			resultSet add: vC.
			].
	"Create a new distribution with points every 10%"
	sortedSet := resultSet asSortedCollection.
	self assert: ( sortedSet size = sampleSize ).
	"Note: Assertion above occasionally fails due to accidental matches in set.
	TODO: CONSIDER USING A BAG INSTEAD OF A SET."
	distributionC := Dictionary new.
	distributionC at: 0.0 put: ( sortedSet first ). "This is a placeholder."
	tick := sampleSize / resultDivisions.
	count := 0.
	sortedSet
		do: [ :x | 
				| modulo |
				modulo := ( count \\ tick ).
				( modulo = 0 )
					ifTrue: [ distributionC at: ( (count/sampleSize) asFloat )  put: x ].
			  count := count + 1.
			 ].
	distributionC at: 1.0 put: (sortedSet last).
	"self correctInterceptInDistribution: distributionC."
	self assert: ( distributionC size = (resultDivisions + 1) ).
	fuzzyC := self copy distribution: distributionC.
	^fuzzyC.
	
	
]

{ #category : #accessing }
HumFuzzy >> sampleSize: anInteger [
	"Reset the sample size used in Monte Carlo sampling of input distributions.
	Default value is preset in >>initialize method.
	A value on the order of 10,000 produces good results.
	The sampleSize must be a multiple of 10. (See >>op:with:)
	"
	sampleSize := anInteger.
]

{ #category : #accessing }
HumFuzzy >> sampleSize: aSampleSize resultDivisions: aDivisionCount [
	"Reset the sample size used in Monte Carlo sampling of input distributions.
	Default value is preset in >>initialize method.
	A value on the order of 10,000 produces good results.
	The sampleSize must be a multiple of aDivisionCount. (See >>op:with:)
	"
	self assert: (aSampleSize \\ aDivisionCount = 0).
	"The Monte Carlo will randomly sample the inputs this many times."
	sampleSize := aSampleSize.
	"The resulting S-curve will have N+1 points selected from sampleSize points."
	resultDivisions := aDivisionCount. 
]

{ #category : #evaluating }
HumFuzzy >> sampleWithBlock: aBlock [
 "Operate on fuzzy distibution using Monte Carlo sampling"
	| resultSet random |
	resultSet := Set new.
	random := Random new.
	( 1 to: sampleSize )
		do: [ :i |
			| rA  vA  |
			rA := random next.
			vA := self atP: rA.
			aBlock value: vA.
			].
	
	
]
