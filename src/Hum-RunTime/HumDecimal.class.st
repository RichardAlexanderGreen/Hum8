"
HumDecimal tracks the number of digits of accuracy in a number.
Arithmetic can never increase the number of digits.
Arithmetic is performed using HumFuzzy 
  so that S-curves (not just triangular distributions) are available.
The user interface uses scientific notation 
  for input and output (to/from strings).

"
Class {
	#name : #HumDecimal,
	#superclass : #HumFuzzy,
	#instVars : [
		'nDecimal'
	],
	#category : #'Hum-RunTime'
}

{ #category : #accessing }
HumDecimal >> fromString: aString [
	"Count the digits in the string to estimate accuracy."
	|  parser value  nDigits assumedMedian err  lowerBound upperBound aDistribution |
	parser := HumNumberParser on: aString.
	value := parser nextNumber.
	nDigits := parser nDigits.
	assumedMedian := value.
	err := (10.0 raisedToInteger: (nDigits negated)) / 2.0.
	lowerBound := assumedMedian - err.
	upperBound :=  assumedMedian + err.
	aDistribution := Dictionary new.
	aDistribution
		at: 0.50 put: assumedMedian;
		at: 0.00 put: lowerBound;
		at: 1.00 put: upperBound.
	self distribution: aDistribution.
	self nDecimal: nDigits.
	
	
	
]

{ #category : #'as yet unclassified' }
HumDecimal >> nDecimal [
	"How many decimal places should we display."
	^nDecimal ifNil: [ 0 ].
]

{ #category : #accessing }
HumDecimal >> nDecimal: anInteger [ 
	"How many decimal places should we display."
	nDecimal := anInteger.
]

{ #category : #'as yet unclassified' }
HumDecimal >> printOn: aStream [
	super printOn: aStream.
	distribution ifNil: [ ^self ].
	aStream
		nextPut: $(;
		nextPutAll: (self median printShowingDecimalPlaces: self nDecimal );
		nextPut: $).
	
]
