Class {
	#name : #HumFuzzyTests,
	#superclass : #HumTestCase,
	#category : #'Hum-Tests'
}

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF100FuzzyArithmeticReadMe [
	"
	Spurious precision is a form of disinformation because it hides the uncertainty in the result.
	Hum`s fuzzy arithmetic feature provides facilities to calculate and present the uncertainty 
	 that is inherent in all real-world situations.
	
	Real-world numbers represent observations.
	An observation is a measurement taken at a point in time using a specific method and set of calibrated sensors.
	Measurements always have limited precision and accuracy.
	That means that each measurement is associated with a distribution curve. (Typically a 'bell' curve of some kind.)
	
	The goal of Hum`s fuzzy arithmetic is to correctly represent the uncertainty involved
	  so that results may be stated with appropriate confidence intervals or probability curves (S-curves).
	Use Cases:
	. Software effort estimates tend to have distributions with long tails.
	. Many measurements cannot be negative, and therefore, do not have symetric distributions.
	. Simulations involve many estimates for inputs and process parameters.
	. . Thus any 'result' can only be a probability distribution. 
	. . . Otherwise, spurious precision is a form of disinformation.
	. Engineering calculations are estimates that involve many sources of uncertainty and approximation.
	. . Fuzzy arithmetic provides a way of representing those spreads in the results.
	. . In effect, the fuzzy arithmetic automatically provides a sensitivity analysis.
	"
]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF110CreateFuzzyWithDistribution [
	"Create a fuzzy quantity from a given distribution."
	| distribution median fuzzy |
	"A distribution is a Dictionary of f->p points
	where p is the probability that observations will be less than or equal to f.
	When the distribution is plotted mapping (f,p) to (x,y) you get an S-Curve."
	distribution := Dictionary new.
	distribution
		at: 0.00 put: 0;
		at: 0.20 put: 50;
		at: 0.50 put: 100;
		at: 0.80 put: 200;
		at: 1.00 put: 400.

	fuzzy := HumFuzzy distribution: distribution.
	
	self assert: 100 equals: ( fuzzy median ).
]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF112CheckEdgeCases [
	"Create a fuzzy quantity from a given distribution."
	| distribution median fuzzy |
	"A distribution is a Dictionary of f->p points
	where p is the probability that observations will be less than or equal to f.
	When the distribution is plotted mapping (f,p) to (x,y) you get an S-Curve."
	distribution := Dictionary new.
	distribution
		at: 0.00 put: 0;
		at: 0.50 put: 100;
		at: 0.20 put: 50;
		at: 0.80 put: 200;
		at: 1.00 put: 400.

	fuzzy := HumFuzzy distribution: distribution.
	
	self assert: 100 equals: ( fuzzy median ).
	self assert: 0 equals: ( fuzzy atP: 0.0 ).
	self assert: 400 equals: ( fuzzy atP: 1.00 ).
]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF120Interpolation [
	"Create a fuzzy quantity from a given distribution."
	| distribution median fuzzy |
	"A distribution is a Dictionary of p->f points
	where p is the probability that observations will be less than or equal to f.
	When the distribution is plotted 
	 by mapping p->f to (f,p) = (x,y),
	 you get an S-Curve."
	distribution := Dictionary new.
	distribution
		at: 0.50 put: 100;  "Estimate 100 hours"
		at: 0.00 put: 0;    "Cannot be less than zero"  
		at: 0.10 put: 50;   "Will come at less than half the estimate no more than 10% of time."
		at: 0.90 put: 200;  "Will come at upto double the estimate no more than 90% of time."
		at: 1.00 put: 400.  "At worst, the actual will be 4 times the estimate."

	fuzzy := HumFuzzy distribution: distribution.
	
	self assert: 100 equals: ( fuzzy median ).
	"Should be able to return given point value."
	self assert: 100 equals: ( fuzzy atP: 0.50 ).  
	"Force interpolation"
	self assert: ( ( fuzzy atP: 0.70 ) closeTo: 150.0 ).
	self assert: ( ( fuzzy atP: 0.05 ) closeTo:  25.0 ).
	self assert: ( ( fuzzy atP: 0.95 ) closeTo: 300.0 ).
	
	
]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF125Mean [
	"Create a fuzzy quantity from a given distribution."
	| distribution median fuzzy average |
	"A distribution is a Dictionary of p->f points
	where p is the probability that observations will be less than or equal to f.
	When the distribution is plotted 
	 by mapping p->f to (f,p) = (x,y),
	 you get an S-Curve."
	distribution := Dictionary new.
	distribution
		at: 0.50 put: 100;  "Estimate 100 hours"
		at: 0.00 put: 0;    "Cannot be less than zero"  
		at: 0.10 put: 50;   "Will come at less than half the estimate no more than 10% of time."
		at: 0.90 put: 200;  "Will come at upto double the estimate no more than 90% of time."
		at: 1.00 put: 400.  "At worst, the actual will be 4 times the estimate."

	fuzzy := HumFuzzy distribution: distribution.
	
	self assert: 100 equals: ( fuzzy median ).

	"Calculate mean"
	average := fuzzy mean.
	"the mean will be higher than the median because of long tail"
	self assert: ( average > ( fuzzy median ) ).
		
	
]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF130Plus [
	"Add fuzzy distributions.
	NOTE: The test assertions will fail occasionally. "
	| distributionA distributionB median fuzzyA fuzzyB fuzzyC resultMedian expectedMedian  expectedMean actualMean diffMean diffMedian |
	"A distribution is a Dictionary of p->f points
	where p is the probability that observations will be less than or equal to f.
	When the distribution is plotted 
	 by mapping p->f to (f,p) = (x,y),
	 you get an S-Curve."
	distributionA := Dictionary new.
	distributionA
		at: 0.50 put: 100;  "Estimate 100 hours"
		at: 0.00 put: 0;    "Cannot be less than zero"  
		at: 0.10 put: 50;   "Will come at less than half the estimate no more than 10% of time."
		at: 0.90 put: 200;  "Will come at upto double the estimate no more than 90% of time."
		at: 1.00 put: 400.  "At worst, the actual will be 4 times the estimate."

	distributionB := distributionA.
	fuzzyA := HumFuzzy distribution: distributionA.
	fuzzyB := HumFuzzy distribution: distributionB.
	fuzzyC := fuzzyA + fuzzyB.
	
	resultMedian := fuzzyC median.
	" Niave median is just . . . "
	expectedMedian := (( fuzzyA median) + fuzzyB median). 
	" But, because there is a long tail . . . "
	self assert: ( resultMedian > expectedMedian ).
	diffMedian := ( resultMedian - expectedMedian ) abs.
	self assert:( diffMedian > ((expectedMedian) * 0.10) ).
	
	"Examine expectedMean"
	actualMean := fuzzyC mean.
	expectedMean := ( fuzzyA mean ) + ( fuzzyB mean ).
	diffMean := 1.00 - (( expectedMean / actualMean ) abs).
	"Expect some difference due to long tail."
	self assert: ( diffMean closeTo: 0.0 ) not. 
	"The difference is typically about 3 to 4%; but is occasionally greater than 5%."
	self assert: ( diffMean <  0.05 ).
	"Transcript cr; show: 'testF130Plus diffMean = ', ( diffMean asString)."
	
	
	
]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF140Op [
	"Test op:with:"
	| distributionA distributionB median fuzzyA fuzzyB fuzzyC resultMedian expectedMedian diff plus |
	"A distribution is a Dictionary of p->f points
	where p is the probability that observations will be less than or equal to f.
	When the distribution is plotted 
	 by mapping p->f to (f,p) = (x,y),
	 you get an S-Curve."
	distributionA := Dictionary new.
	distributionA
		at: 0.50 put: 100;  "Estimate 100 hours"
		at: 0.00 put: 0;    "Cannot be less than zero"  
		at: 0.10 put: 50;   "Will come at less than half the estimate no more than 10% of time."
		at: 0.90 put: 200;  "Will come at upto double the estimate no more than 90% of time."
		at: 1.00 put: 400.  "At worst, the actual will be 4 times the estimate."

	distributionB := distributionA.
	fuzzyA := HumFuzzy distribution: distributionA.
	fuzzyB := HumFuzzy distribution: distributionB.
	plus := #+.
	fuzzyC := fuzzyA op: plus with: fuzzyB.
	
	resultMedian := fuzzyC median.
	" Niave median is just . . . "
	expectedMedian := (( fuzzyA median) + fuzzyB median). 
	" But, because there is a long tail . . . "
	self assert: ( resultMedian > expectedMedian ).
	diff := ( resultMedian - expectedMedian ) abs.
	self assert:( diff > ((expectedMedian) * 0.10) ).
	
]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF150MinusOp [
	"Subtract fuzzy distributions."
	| distributionA distributionB median fuzzyA fuzzyB fuzzyC resultMedian expectedMedian diff  minus |
	"A distribution is a Dictionary of p->f points
	where p is the probability that observations will be less than or equal to f.
	When the distribution is plotted 
	 by mapping p->f to (f,p) = (x,y),
	 you get an S-Curve."
	distributionA := Dictionary new.
	distributionB := Dictionary new.
	distributionA
		at: 0.50 put: 200;  "Estimate 200 hours"
		at: 0.00 put: 0;    "Cannot be less than zero"  
		at: 0.10 put: 100;   "Will come at less than half the estimate no more than 10% of time."
		at: 0.90 put: 400;  "Will come at upto double the estimate no more than 90% of time."
		at: 1.00 put: 800.  "At worst, the actual will be 4 times the estimate."
	distributionB
		at: 0.50 put: 100;  "Estimate 100 hours"
		at: 0.00 put: 0;    "Cannot be less than zero"  
		at: 0.10 put: 50;   "Will come at less than half the estimate no more than 10% of time."
		at: 0.90 put: 200;  "Will come at upto double the estimate no more than 90% of time."
		at: 1.00 put: 400.  "At worst, the actual will be 4 times the estimate."

	fuzzyA := HumFuzzy distribution: distributionA.
	fuzzyB := HumFuzzy distribution: distributionB.
	minus := #-.
	fuzzyC := fuzzyA op: minus with: fuzzyB.
	
	resultMedian := fuzzyC median.
	" Niave median is just . . . "
	expectedMedian := (( fuzzyB median) - fuzzyA median). 
	" But, because there is a long tail . . . "
	self assert: ( resultMedian > expectedMedian ).
	diff := ( resultMedian - expectedMedian ) abs.
	self assert:( diff > ((expectedMedian) * 0.10) ).
	
]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF155Minus [
	"Subtract fuzzy distributions."
	| distributionA distributionB median fuzzyA fuzzyB fuzzyC resultMedian expectedMedian diffMedian  minus actualMean expectedMean diffMean |
	"A distribution is a Dictionary of p->f points
	where p is the probability that observations will be less than or equal to f.
	When the distribution is plotted 
	 by mapping p->f to (f,p) = (x,y),
	 you get an S-Curve."
	distributionA := Dictionary new.
	distributionB := Dictionary new.
	distributionA
		at: 0.50 put: 200;  "Estimate 200 hours"
		at: 0.00 put: 0;    "Cannot be less than zero"  
		at: 0.10 put: 100;   "Will come at less than half the estimate no more than 10% of time."
		at: 0.90 put: 400;  "Will come at upto double the estimate no more than 90% of time."
		at: 1.00 put: 800.  "At worst, the actual will be 4 times the estimate."
	distributionB
		at: 0.50 put: 100;  "Estimate 100 hours"
		at: 0.00 put: 0;    "Cannot be less than zero"  
		at: 0.10 put: 50;   "Will come at less than half the estimate no more than 10% of time."
		at: 0.90 put: 200;  "Will come at upto double the estimate no more than 90% of time."
		at: 1.00 put: 400.  "At worst, the actual will be 4 times the estimate."

	fuzzyA := HumFuzzy distribution: distributionA.
	fuzzyB := HumFuzzy distribution: distributionB.
	minus := #-.
	fuzzyC := fuzzyA - fuzzyB.
	
	resultMedian := fuzzyC median.
	" Niave median is just . . . "
	expectedMedian := (( fuzzyA median) - (fuzzyB median) ). 
	" But, because there is a long tail . . . "
	diffMedian := ( resultMedian - expectedMedian ) abs.
	"NOTE: Following will fail occasionally."
	self assert: ( diffMedian closeTo: 0.0 ) not.
	
		"Examine expectedMean"
	actualMean := fuzzyC mean.
	expectedMean := ( fuzzyA mean ) - ( fuzzyB mean ).
	diffMean := ( expectedMean - actualMean ) abs.
	"The difference will typically be on the order of 5-15%"
	"It could be close to zero, but that will be a rare event."
	self assert: ( diffMean closeTo: 0.0 ) not. 
	

	
]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF160Division [
	"Divide fuzzy distributions."
	| distributionA distributionB median fuzzyA fuzzyB fuzzyC resultMedian expectedMedian diff   diffMedian actualMean expectedMean diffMean |
	"A distribution is a Dictionary of p->f points
	where p is the probability that observations will be less than or equal to f.
	When the distribution is plotted 
	 by mapping p->f to (f,p) = (x,y),
	 you get an S-Curve."
	distributionA := Dictionary new.
	distributionB := Dictionary new.
	distributionA
		at: 0.50 put: 200;  "Estimate 200 hours"
		at: 0.00 put: 0;    "Cannot be less than zero"  
		at: 0.10 put: 100;   "Will come at less than half the estimate no more than 10% of time."
		at: 0.90 put: 400;  "Will come at upto double the estimate no more than 90% of time."
		at: 1.00 put: 800.  "At worst, the actual will be 4 times the estimate."
	distributionB
		at: 0.50 put: 100;  "Estimate 100 hours"
		at: 0.00 put: 0;    "Cannot be less than zero"  
		at: 0.10 put: 50;   "Will come at less than half the estimate no more than 10% of time."
		at: 0.90 put: 200;  "Will come at upto double the estimate no more than 90% of time."
		at: 1.00 put: 400.  "At worst, the actual will be 4 times the estimate."

	fuzzyA := HumFuzzy distribution: distributionA.
	fuzzyB := HumFuzzy distribution: distributionB.
	fuzzyC := fuzzyA / fuzzyB.
	
	resultMedian := fuzzyC median.
	" Niave median is just . . . "
	expectedMedian := (( fuzzyA median) / (fuzzyB median) ). 
	" But, because there is a long tail . . . "
	diffMedian := ( resultMedian - expectedMedian ) abs.
	"NOTE: Following will fail occasionally."
	self assert: ( diffMedian closeTo: 0.0 ) not.
	
		"Examine expectedMean"
	actualMean := fuzzyC mean.
	expectedMean := ( fuzzyA mean ) / ( fuzzyB mean ).
	diffMean := ( expectedMean - actualMean ) abs.
	"The difference will typically be on the order of 5-15%"
	"It could be close to zero, but that will be a rare event."
	self assert: ( diffMean closeTo: 0.0 ) not. 

]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF170Product [
	"Multiply fuzzy distributions."
	| distributionA distributionB  fuzzyA fuzzyB fuzzyC resultMedian expectedMedian    diffMedian actualMean expectedMean diffMean |
	"A distribution is a Dictionary of p->f points
	where p is the probability that observations will be less than or equal to f.
	When the distribution is plotted 
	 by mapping p->f to (f,p) = (x,y),
	 you get an S-Curve."
	distributionA := Dictionary new.
	distributionB := Dictionary new.
	distributionA
		at: 0.50 put: 200;  "Estimate 200 hours"
		at: 0.00 put: 0;    "Cannot be less than zero"  
		at: 0.10 put: 100;   "Will come at less than half the estimate no more than 10% of time."
		at: 0.90 put: 400;  "Will come at upto double the estimate no more than 90% of time."
		at: 1.00 put: 800.  "At worst, the actual will be 4 times the estimate."
	distributionB
		at: 0.50 put: 100;  "Estimate 100 hours"
		at: 0.00 put: 0;    "Cannot be less than zero"  
		at: 0.10 put: 50;   "Will come at less than half the estimate no more than 10% of time."
		at: 0.90 put: 200;  "Will come at upto double the estimate no more than 90% of time."
		at: 1.00 put: 400.  "At worst, the actual will be 4 times the estimate."

	fuzzyA := HumFuzzy distribution: distributionA.
	fuzzyB := HumFuzzy distribution: distributionB.
	fuzzyC := fuzzyA * fuzzyB.
	
	
	resultMedian := fuzzyC median.
	" Niave median is just . . . "
	expectedMedian := (( fuzzyA median) * (fuzzyB median) ). 
	" But, because there is a long tail . . . "
	diffMedian := ( resultMedian - expectedMedian ) abs.
	"NOTE: Following will fail occasionally."
	self assert: ( diffMedian closeTo: 0.0 ) not.
	
		"Examine expectedMean"
	actualMean := fuzzyC mean.
	expectedMean := ( fuzzyA mean ) * ( fuzzyB mean ).
	diffMean := 1.00 - (( expectedMean - actualMean ) abs).
	"The difference will typically be less than 3%"
	"It could be close to zero, but that will be a rare event."
	self assert: ( diffMean closeTo: 0.0 ) not. 
	self assert: ( diffMean < 0.03 ).
	

]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF210PlusOrMinus [
	"A measure stated as plus-or-minus 
	 is assumed to exclude cases outside the limits."
	| measure sampleMean sampleMedian |
	measure := HumFuzzy quantity: 100 plusOrMinus: 1.
	"Use Float #closeto: "
	sampleMean := measure mean.
	sampleMedian := measure median.
	"Note: Following will fail occasionally."
	self assert: ( sampleMean closeTo: 100.0 ) description: 'This sampleMean value will deviate now and then'. 
	self assert: ( sampleMedian closeTo: 100.0 ) description: 'This sampleMedian value will deviate now and then'.
	
	
]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF230Plus [
	"Add fuzzy distributions."
	|    fuzzyA fuzzyB fuzzyC resultMedian expectedMedian  expectedMean actualMean diffMean diffMedian |
	"A distribution is a Dictionary of p->f points
	where p is the probability that observations will be less than or equal to f.
	When the distribution is plotted 
	 by mapping p->f to (f,p) = (x,y),
	 you get an S-Curve."
	fuzzyA := HumFuzzy quantity: 100.0 plusOrMinus: 1.0.
	fuzzyB := HumFuzzy quantity: 100.0 plusOrMinus: 1.0.
	fuzzyC := fuzzyA + fuzzyB.
	
	resultMedian := fuzzyC median.
	" Niave median is just . . . "
	expectedMedian := (( fuzzyA median) + fuzzyB median). 
	" In this case, the tail is not long. "
	diffMedian := 1.00 - ( resultMedian / expectedMedian ) abs.
	self assert:( diffMedian < 0.01 ).
	
	"Examine expectedMean"
	actualMean := fuzzyC mean.
	expectedMean := ( fuzzyA mean ) + ( fuzzyB mean ).
	diffMean := 1.00 - (( expectedMean / actualMean ) abs).
	"The difference is typically less than 1% "
	self assert: ( diffMean <  0.01 ).
	"Transcript cr; show: 'testF230Plus diffMean = ', ( diffMean asString)."
	
	
	
]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF310Mode [
	"Estimate the mode of a distribution by calculating expected value."
	| mode distribution fuzzy sum mean expected |
	distribution := Dictionary new.
	distribution
		at: 0.00 put: 0;
		at: 0.20 put: 50;
		at: 0.50 put: 100;
		at: 0.80 put: 200;
		at: 1.00 put: 400.

	fuzzy := HumFuzzy distribution: distribution.
	sum := 0.
	fuzzy distributionDo: [:p :v | sum := sum + (p*v)].
	mode := sum.
	expected := ((20*50)+(50*100)+(80*200)+(100*400))/100. 
	self expect: expected actual: mode.
	

]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF410Plot [
	"Estimate the mode of a distribution by calculating expected value."
	| distribution fuzzy   canvas scaleX scaleY extent magnifyBy scalePt priorPt vMax |
	distribution := Dictionary new.
	distribution
		at: 0.00 put: 0;
		at: 0.20 put: 50;
		at: 0.50 put: 100;
		at: 0.80 put: 200;
		at: 1.00 put: 400.

	fuzzy := HumFuzzy distribution: distribution.

	false ifTrue: [ fuzzy asCrudeMorph ].	

]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF430PlotPlus [
	"Add fuzzy distributions.
	NOTE: The test assertions will fail occasionally. "
	| distributionA distributionB  fuzzyA fuzzyB fuzzyC  |
	"A distribution is a Dictionary of p->f points
	where p is the probability that observations will be less than or equal to f.
	When the distribution is plotted 
	 by mapping p->f to (f,p) = (x,y),
	 you get an S-Curve."
	distributionA := Dictionary new.
	distributionA
		at: 0.50 put: 100;  "Estimate 100 hours"
		at: 0.00 put: 0;    "Cannot be less than zero"  
		at: 0.10 put: 50;   "Will come at less than half the estimate no more than 10% of time."
		at: 0.90 put: 200;  "Will come at upto double the estimate no more than 90% of time."
		at: 1.00 put: 400.  "At worst, the actual will be 4 times the estimate."

	distributionB := distributionA.
	fuzzyA := HumFuzzy distribution: distributionA.
	fuzzyB := HumFuzzy distribution: distributionB.
	fuzzyC := fuzzyA + fuzzyB.

	false ifTrue: [ fuzzyC asCrudeMorph2 ].

		
	
	
]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> testF431PlotPlus [
	"Add fuzzy distributions.
	NOTE: The test assertions will fail occasionally. "
	| distributionA distributionB fuzzyA fuzzyB fuzzyC  |
	"A distribution is a Dictionary of p->f points
	where p is the probability that observations will be less than or equal to f.
	When the distribution is plotted 
	 by mapping p->f to (f,p) = (x,y),
	 you get an S-Curve."
	distributionA := Dictionary new.
	distributionA
		at: 0.50 put: 100;  "Estimate 100 hours"
		at: 0.00 put: 0;    "Cannot be less than zero"  
		at: 0.10 put: 50;   "Will come at less than half the estimate no more than 10% of time."
		at: 0.90 put: 200;  "Will come at upto double the estimate no more than 90% of time."
		at: 1.00 put: 400.  "At worst, the actual will be 4 times the estimate."

	distributionB := distributionA.
	fuzzyA := HumFuzzy distribution: distributionA.
	fuzzyB := HumFuzzy distribution: distributionB.
	fuzzyC := fuzzyA + fuzzyB.

	false ifTrue: [ fuzzyC asCrudeMorphInRectangle: (Rectangle origin: 111@222 extent: 500@500) ]	

		
	
	
]

{ #category : #'Fuzzy Arithmetic Tests' }
HumFuzzyTests >> ztestF410LearnToPlot [
	"Estimate the mode of a distribution by calculating expected value."
	| distribution fuzzy   canvas scaleX scaleY extent magnifyBy scalePt priorPt vMax |
	distribution := Dictionary new.
	distribution
		at: 0.00 put: 0;
		at: 0.20 put: 50;
		at: 0.50 put: 100;
		at: 0.80 put: 200;
		at: 1.00 put: 400.

	fuzzy := HumFuzzy distribution: distribution.
	
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
	
	fuzzy distributionDo: 
		[:p :v | 
		| xy | 
		xy := scalePt value: v@p.
		canvas line: priorPt to: xy width: 4 color: Color red.
		priorPt := xy.
		].
	"Should we display the canvas?"
	false ifTrue: [| morph | 
		morph := canvas form asMorph openInWorld. 
		"You can delete morph by double-clicking it."
		morph on: #doubleClick send: #delete to: morph. 
		].
	
]
