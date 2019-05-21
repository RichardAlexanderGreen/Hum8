"
The Calculator role (agent) provides 
- base level arithmetic (using measures)
- string utilities used to parse Hum source code.
"
Class {
	#name : #HumCalculatorTests,
	#superclass : #HumTestCase,
	#category : #'Hum-Tests'
}

{ #category : #'string utilities' }
HumCalculatorTests >> test110substringAfter [
	"Test helper method that finds a substring between two given substrings."
	| stringIn stringOut calc|
	stringIn := 'This is just the begining. We are expecting content after this colon: And this is it.'.
	stringOut := HumCalculator given: stringIn extractAfter: ':'.
	self assert: ( stringOut sameAs: ' And this is it.' ).
	
	stringIn := 'This is just the begining. We are expecting content after this operator := Right hand side.'.
	stringOut := HumCalculator given: stringIn extractAfter: ':='.
	self assert: ( stringOut sameAs: ' Right hand side.' ).
	
]

{ #category : #'string utilities' }
HumCalculatorTests >> test115substringBefore [
	"Test helper method that finds a substring between two given substrings."
	| stringIn stringOut |
	stringIn := 'We are expecting content before this colon: And this is it.'.
	stringOut := HumCalculator given: stringIn extractUpto: ':'.
	self assert: ( stringOut sameAs: 'We are expecting content before this colon' ). 
]

{ #category : #'string utilities' }
HumCalculatorTests >> test120substringBetween [
	"Test helper method that finds a substring between two given substrings."
	| stringIn stringOut calc |
	stringIn := 'This is just the begining. We are expecting the stuff between [ and ].'.
	stringOut := HumCalculator given: stringIn extractBetween: '[' and: ']'.
	self assert: ( stringOut sameAs: ' and ' ).
	
	stringIn := 'This is just the begining. We are expecting the stuff between [[button]].'.
	stringOut := HumCalculator given: stringIn extractBetween: '[[' and: ']]'.
	self assert: ( stringOut sameAs: 'button' ).
	
	calc := HumCalculator new.
	self assert: (calc given: 'lunch snacks dinner' extractBetween: 'lunch' and: 'dinner') = ' snacks '.
]

{ #category : #'string utilities' }
HumCalculatorTests >> test130substringBetweenBrackets [
	"Test helper method that finds a substring between a pair of brackets or similar pairs."
	| stringIn stringOut |
	stringIn := 'We are expecting the stuff between [[ and ]], including the brackets, but nothing else.'.
	stringOut := HumCalculator given: stringIn extractIncludingMatching: '[]'.
	self assert: ( stringOut sameAs: '[[ and ]]' ).
	
	stringOut := HumCalculator given: 'Sometimes (parends (may be nested)).' extractIncludingMatching: '()'.
	self assert: (stringOut = '(parends (may be nested))').
		
	stringOut := HumCalculator given: 'Note (parends (may be (deeply) nested)).' extractIncludingMatching: '()'.
	self assert: (stringOut = '(parends (may be (deeply) nested))').
]

{ #category : #'string utilities' }
HumCalculatorTests >> test210templateFill [
	| template parameters expect result calc|
	template := '
	  <div id="@id" class="@class">
	     @body
	  </div>
	  '.
	parameters := Dictionary new.
	parameters 
	  at: 'id' put: 'identifier';
	  at: 'class' put: 'HighClass';
	  at: 'body' put: 'Torso'.
	calc := HumCalculator new.
	result := calc fillTemplate: template fromDictionary: parameters.
	expect := '
	  <div id="identifier" class="HighClass">
	     Torso
	  </div>
	  '.
	self assert: expect equals: result.
	
]

{ #category : #'string utilities' }
HumCalculatorTests >> test305parse [
	"Test the simple parser."
	| string calc tokens n |
	string := 'Example: This is a sentence. This is a question?'.
	calc := HumCalculator new.
	tokens := calc parse: string.
	n := tokens size.
	self expect: 20 actual: n.
	"Parse produces a collection of tuples: { token. type. start. stop. }"
	self expect: {'Example'. #word. 1. 7. } actual: (tokens at: 1).
	self expect: {':'. #separator. 8. 8. } actual: (tokens at: 2).
	self expect: {' '. #whitespace. 9. 9. } actual: ( tokens at: 3).
	self expect: 48 actual: (string size).
	self expect: {'?'. #separator. 48. 48. } actual: (tokens at: n).
	
]

{ #category : #'string utilities' }
HumCalculatorTests >> test310parse [
	"calc parse: s - recognizes quoted strings as single tokens."
	| string calc tokens n |
	string := 'This is a "quoted text"?'.
	calc := HumCalculator new.
	tokens := calc parse: string.
	n := tokens size.
	self expect: 8 actual: n.
	self expect: {'This'. #word. 1. 4. } actual: (tokens at: 1).
	self expect: {' '. #whitespace. 5. 5. } actual: ( tokens at: 2).
	self expect: {'?'. #separator. 24. 24. } actual: (tokens at: n).
	self expect: {'"quoted text"'. #string. 11. 23. } actual: (tokens at: (n-1)).
	self expect: {' '. #whitespace. 10. 10. } actual: (tokens at: (n-2)).
	
]

{ #category : #'string utilities' }
HumCalculatorTests >> test311parse [
	"What if string ends with quoted text?"
	| string calc tokens n |
	string := 'This is a "quoted text"'.
	calc := HumCalculator new.
	tokens := calc parse: string.
	n := tokens size.
	self expect: 7 actual: n.
	self expect: {'This'. #word. 1. 4. } actual: (tokens at: 1).
	self expect: {' '. #whitespace. 5. 5. } actual: ( tokens at: 2).
	self expect: {'"quoted text"'. #string. 11. 23. } actual: (tokens at: (n)).
	self expect: {' '. #whitespace. 10. 10. } actual: (tokens at: (n-1)).
	
]

{ #category : #'string utilities' }
HumCalculatorTests >> test312parse [
	"Test parse with quote within string."
	| string calc tokens quote |
	quote := $' asString.
	string := 'Parse a "internal quote (',quote,')"'.
	calc := HumCalculator new.
	tokens := calc parse: string.
	self expect: 5 actual: (tokens size).
	self expect: { '"internal quote (',quote,')"'. #string. 9. 28.} actual: tokens last.
]

{ #category : #'string utilities' }
HumCalculatorTests >> test313parse [
	"calc parse: s - recognizes quoted strings as single tokens."
	| string calc tokens n quote |
	quote := $' asString.
	string := 'This is a ',quote,'quoted text',quote,'?'.
	calc := HumCalculator new.
	tokens := calc parse: string.
	n := tokens size.
	self expect: 8 actual: n.
	self expect: {'This'. #word. 1. 4. } actual: (tokens at: 1).
	self expect: {' '. #whitespace. 5. 5. } actual: ( tokens at: 2).
	self expect: {'?'. #separator. 24. 24. } actual: (tokens at: n).
	self expect: {'''quoted text'''. #string. 11. 23. } actual: (tokens at: (n-1)).
	self expect: {' '. #whitespace. 10. 10. } actual: (tokens at: (n-2)).
	
]

{ #category : #'string utilities' }
HumCalculatorTests >> test314parse [
	"Test parse with quote within string."
	| string calc tokens quote |
	quote := $" asString.
	string := 'Parse a ''internal quote (',quote,')'''.
	calc := HumCalculator new.
	tokens := calc parse: string.
	self expect: 5 actual: (tokens size).
	self expect: { '''internal quote (',quote,')'''. #string. 9. 28.} actual: tokens last.
	"TODO: Think about following convention where doubled quote within a string is treated as embedded quote."
	"TODO: Think about following convention where special characters are preceded with back-slash (\)."
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test510measurePlusSameUnits [
	"Measures may be added if same units."
	| m1 m2 m3 |
	m1 := HumMeasure quantity: 10 units: #meter.
	m2 := HumMeasure quantity: 20 units: #meter.
	m3 := m1 + m2.
	self expect: m3 quantity actual: 30.
	self expect: m3 units actual: #meter.
	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test520measureMinusSameUnits [
	"Measures may be added if same units."
	| m1 m2 m3 |
	m1 := HumMeasure quantity: 10 units: #meter.
	m2 := HumMeasure quantity: 25 units: #meter.
	m3 :=  m2 - m1.
	self expect: m3 quantity actual: 15.
	self expect: m3 units actual: #meter.


]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test540CommonUnits [
	| v d t a |
	"Test that these do not crash"
	v := 10 kps.                 "kilometers per second = approximate escape velocity (10.735 going East at equator)"
	self assert: (10*1000) equals: (v quantity). 
	
	a := 20 mps / (1 second).    "meters per second per second = approximately 2 G acceleration"
	self assert: (20) equals: (a quantity).
	self assert: ( Dictionary newFrom: { 'meter'->1. 'second'->(-2). } ) equals: (a dimensions).
	self assert: 'meter per square second' equals: ( a units ).
	
	t := v / a.                  "How many seconds to reach escape velocity?"
	self assert: (10*1000/20) equals: (t quantity).
	self assert: ( Dictionary newFrom: { 'second'->1. } ) equals: ( t dimensions ).
	self assert: 'second' equals: ( t units ).
	
	d := ( a / 2 ) * ( t * t ) . "How much distance covered in that amount of time?"
	self assert: ((20/2)* (10*1000/20) * (10*1000/20)) equals: ( d quantity ).
	"Transcript cr; show: 'test540CommonUnits d = '; show: d asString."
	
	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test542UnitsShouldCancel [
	| v d t a m kineticEnergy |
	"Test that these do not crash"
	v := 10 kps.
	self assert: ( Dictionary newFrom: { 'meter'->1. 'second'->(-1). } ) equals: ( v dimensions ).
	
	a := 2 gravity.
	self assert: ( Dictionary newFrom: { 'meter'->1. 'second'->(-2). } ) equals: ( a dimensions ).
	
	t := v / a.
	self assert: ( Dictionary newFrom: { 'second'->(1). } ) equals: ( t dimensions ).
	
	d := a * t * t / 2.
	self assert: ( Dictionary newFrom: { 'meter'->1. } ) equals: ( d dimensions ).
	
	m := 1 tonne. "metric ton"
	self assert: ( Dictionary newFrom: { 'kilogram'->1. } ) equals: ( m dimensions ).

	kineticEnergy := m * v * v / 2.
	self assert: ( Dictionary newFrom: { 'kilogram'->1. 'meter'->2. 'second'->(-2). } ) equals: ( kineticEnergy dimensions ).
	
	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test545Conversions [
	| v vDisplay d dDisplay t a aDisplay e |
	"Test that these do not crash"
	v := 10 kps.                 "kilometers per second = approximate escape velocity (10.735 going East at equator)"
	self expect: (10*1000) actual: (v quantity). 
	vDisplay := v as: #mph.
	self assert: '22369.382 mph' equals: vDisplay.
	
	a := 20 mps / (1 second).    "meters per second per second = approximately 2 G acceleration"
	self expect: (20) actual: (a quantity).
	self expect: ( Dictionary newFrom: { 'meter'->1. 'second'->(-2). } ) actual: (a dimensions).
	self expect: 'meter per square second' actual: ( a units ).
	aDisplay := a as: #gravity.
	self pattern: '2.*gravity' matches: aDisplay .
	
	t := v / a.                  "How many seconds to reach escape velocity?"
	self expect: (10*1000/20) actual: (t quantity).
	self expect: ( Dictionary newFrom: { 'second'->(1). } ) actual: ( t dimensions ).
	self expect: 'second' actual: ( t units ).
	self expect: (HumMeasure quantity: 500 units: #second) actual: t.
	
	d := ( a / 2 ) * ( t * t ) . "How much distance covered in that amount of time?"
	self expect: ((20/2) * (10*1000/20) * (10*1000/20)) actual: ( d quantity ).
	dDisplay := d as: #miles.
	self expect: '1553.429 miles' actual: dDisplay.
	
	e := (1 kilogram) * (v * v) / 2.0. "energy per kilogram"
	self expect: '5.0e7 joule' actual: (e as: #joule).   
	self expect:  (100 kilowatt)  actual: (e / t)  . "Average power requirement?"
	
	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test546ConvertVolumeMeasures [
	| s a volume cubicInch displacement asLitre |
	s := 1 inch.
	a := s * s.
	volume := a * s. 
	cubicInch := volume.
	displacement := cubicInch * 400. 
	self expect: ( HumMeasure quantity: 0.0065548256 units: 'cubic meter') actual: (displacement).
	
	asLitre := displacement as: #litre. 
	self expect: '6.555 litre' actual: asLitre.
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test550CasualMeasures [
	"Work with non-KMS measures. Develop HumMeasure2"
	| milesPerHour feetPerMile feetPerHour secondsPerHour feetPerSecond pixelWidth |
	milesPerHour := HumMeasure quantity: 60 units: 'mile' per: 'hour'.
	self assert: ((milesPerHour dimensions) at: 'mile') = 1.
	self assert: ((milesPerHour dimensions) at: 'hour') = -1.
	
	feetPerMile := HumMeasure quantity: 5280 units: 'foot' per: 'mile'.
	self assert: ((feetPerMile dimensions) at: 'foot') = 1.
	self assert: ((feetPerMile dimensions) at: 'mile') = -1.
	
	
	feetPerHour := milesPerHour * feetPerMile.
	self assert: ((feetPerHour dimensions) at: 'foot') = 1.
	self assert: ((feetPerHour dimensions) at: 'hour') = -1.
	
	secondsPerHour := HumMeasure quantity: 3600 units: 'second' per: 'hour'.
	self assert: ((secondsPerHour dimensions) at: 'second') = 1.
	self assert: ((secondsPerHour dimensions) at: 'hour') = -1.
	
	feetPerSecond := feetPerHour / secondsPerHour.
	self assert: ((feetPerSecond dimensions) at: 'foot') = 1.
	self assert: ((feetPerSecond dimensions) at: 'second') = -1.
	self assert: (60*5280/3600) equals: (feetPerSecond quantity).
	
	pixelWidth := (1.0/96.0) inch. "Convert to KMS units"
	self expect: (0.000264583333) actual: ( pixelWidth quantity ). "about 265 micrometre (micron) per pixel at 96 DPI"
	
	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test552CasualMeasuresAdd [
	"Work with non-KMS measures. Develop HumMeasure2"
	| pretax taxRate tax total |
	pretax := HumMeasure quantity: 100.0 units: 'dollar'.
	taxRate := HumMeasure quantity: 0.06 units: 'dollar' per: 'dollar'.
	tax := pretax * taxRate.
	total := pretax + tax.
	
	self assert: (total quantity) = 106.00.

]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test553CasualMeasuresSubtract [
	"Work with non-KMS measures. Develop HumMeasure2"
	| prediscount discountRate discount total |
	prediscount := HumMeasure quantity: 100.0 units: 'dollar'.
	discountRate := HumMeasure quantity: 0.05 units: 'dollar' per: 'dollar'.
	discount := prediscount * discountRate.
	total := prediscount - discount.
	
	self assert: (total quantity) = 95.00.

]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test554AsPercent [
	"Work with non-KMS measures. Develop HumMeasure2"
	| prediscount discountRate discount total |
	prediscount := HumMeasure quantity: 100.0 units: 'dollar'.
	discountRate := HumMeasure quantity: 0.05 units: 'dollar' per: 'dollar'.
	discount := prediscount * discountRate.
	total := prediscount - discount.
	
	self assert: (total quantity) = 95.00.

]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test555CasualMeasuresAsString [
	"Test asString"
	| force distance work time power length width area height volume|
	force := HumMeasure quantity: 550 units: 'pound'.
	self assert: (force asString) = '550 pound'.
	distance := HumMeasure quantity: 1 units: 'foot'.
	self assert: (distance asString) = '1 foot'.
	work := force * distance.
	self assert: '550 foot pound' equals: (work asString).
	time := HumMeasure quantity: 1 units: 'second'.
	"check ' per '"
	power := work / time.
	self assert: '550 foot pound per second' equals: (power asString).
	"Check square"
	length := HumMeasure quantity: 10 units: 'feet'.
	width  := HumMeasure quantity: 20 units: 'feet'.
	area := length * width.
	self assert: ('200 square foot') equals: (area asString).
	"Check cubic"
	height := HumMeasure quantity: 8 units: 'feet'.
	volume := area * height.
	self assert: ('1600 cubic foot') equals: (volume asString).
	
	
	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test556CasualMeasuresSquares [
	"Test asString"
	| squareFeet squareYard squareFeetPerSquareYard |
	
	squareFeet := HumMeasure quantity: 900 units: 'square feet'.
	squareFeetPerSquareYard := HumMeasure quantity: 9 units: 'square feet' per: 'square yard'.
	squareYard := squareFeet / squareFeetPerSquareYard.
	self assert: '100 square yard' equals: ( squareYard asString ).
	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test557CasualMeasuresCubics [
	"Test asString"
	| cubicFeet cubicYard cubicFeetPercubicYard |
	
	cubicFeet := HumMeasure quantity: 2700 units: 'cubic feet'.
	cubicFeetPercubicYard := HumMeasure quantity: 27 units: 'cubic feet' per: 'cubic yard'.
	cubicYard := cubicFeet / cubicFeetPercubicYard.
	self assert: '100 cubic yard' equals: ( cubicYard asString ).
	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test560coefficientOfExpansion [
	"Sometimes the exponents are all negative."
	| coefficient |
	"coefficient of expansion for aluminum
	See: http://www.engineeringtoolbox.com/linear-expansion-coefficients-d_95.html"
	coefficient := HumMeasure quantity: 22.2e-6 per: #degreeKelvin.
	self assert: ( Dictionary newFrom: { 'degreeKelvin' -> (-1). } ) equals: ( coefficient dimensions ).
	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test570CreateMeasureFromString [
	"Create a measure from a sting of the form: -999 units"
	| string expect result |
	string := '-123 meter'.
	result := HumMeasure fromString: string.
	expect := HumMeasure quantity: -123 units: #meter.
	self assert: expect equals: result.
	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test580exampleBussardRamJet [
	| pi area speed z beta gamma volume density energy energyPerHydrogen ePerSecond |
	pi := Float pi.
	area :=  (1 km) * (1 km) * pi. "Assume the ram scoop is a circle."
	speed := 0.1 lightSpeed.
	
	"Is relatvity relevant at this speed?"
	z := 0.1 * 0.1.      "v squared over c squared"
	beta := (1 - z) sqrt.
	gamma := 1.0 / beta. 
	self assert: (gamma < 1.06 )."~ 1.05 :: Ignored because smaller than other engineering uncertainties. "
	
	"The interstellar medium within the Local Bubble has a density of about 0.07 atoms/cm3"
	density := (HumMeasure quantity: 0.07 units: #HydrogenAtom)/(1 cubicCentimeter).
	energy := (26.7 mev)/ 4. "CNO fusion energy per hydrogen atom"
	energyPerHydrogen := energy / (HumMeasure quantity: 1 units: #HydrogenAtom).
	
	"How much power does the CNO fusion provide?"
	volume := area * speed. "volume per second"
	ePerSecond := volume * density * energyPerHydrogen.
	self expect: (HumMeasure watt: 7.05e6 )   "7 megawatts"
	        actual: (ePerSecond).
	"Seems way too small to power, let alone move, a structure 1 km in radius." 
	

	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test581megaWattToAcceleration [
	"What kind of acceleration does a megaWatt per tonne give?"
	| power mass vSquared energy deltaVqty deltaV acceleration |
	power := 1 megaWatt.
	mass := 1 tonne.
	energy := power * (1 second) .
	
	"kinetic energy KE = mass * v * v / 2. 
	==> v := sqrt{ 2 * KE / mass }
	"
	vSquared := (( energy / mass ) * 2.0).
	deltaVqty := (vSquared quantity ) sqrt.
	deltaV := deltaVqty meterPerSecond.
	self expect: '44.721 meterPerSecond' actual: (deltaV as: #meterPerSecond).
	acceleration := deltaV / (1 second).
	self expect: '4.560 gravity' actual: ( acceleration as: #gravity ).
	"1 kilowatt per kilogram ==> high acceleration (assuming perfect energy conversion). So this is an upper limit."
	"Of course, the rocket equation and thermodynamic efficiency should be used for realistic results. "
	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test582exampleBussardRamJet [
	| pi area speed z beta gamma volume density energy energyPerHydrogen ePerSecond |
	pi := Float pi.
	area :=  (1 km) * (1 km) * pi. "Assume the ram scoop is a circle."
	speed := 0.2 lightSpeed.
	
	"Is relatvity relevant at this speed?"
	z := 0.2 * 0.2.      "v squared over c squared"
	beta := (1 - z) sqrt.
	gamma := 1.0 / beta. 
	self assert: (gamma < 1.06 )."~ 1.05 :: Ignored because smaller than other engineering uncertainties. "
	
	"The interstellar medium within the Local Bubble has a density of about 0.07 atoms/cm3"
	density := (HumMeasure quantity: 0.07 units: #HydrogenAtom)/(1 cubicCentimeter).
	"density = HumMeasure( 70000 HydrogenAtom per cubic meter )"
	energy := (26.7 mev)/ 4. "CNO fusion energy per hydrogen atom"
	energyPerHydrogen := energy / (HumMeasure quantity: 1 units: #HydrogenAtom).
	
	"How much power does the CNO fusion provide?"
	volume := area * speed. "volume per second"
	ePerSecond := volume * density * energyPerHydrogen.
	self expect: (HumMeasure watt: 14.1e6 )   "14 megawatts"
	        actual: (ePerSecond).
	"Still seems way too small to power, let alone move, a structure 1 km in radius." 
	"Conclusion: This mechanism requires a relatively high-density hydrogen gas in the medium.
	Note: We assumed that drag is magically cancelled by the propulsion mechanism.
	"
	

	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test582megaWattToAcceleration [
	"What level of acceleration does a megaWatt give to 100 tonnes of ship mass?"
	| power mass vSquared energy deltaVqty deltaV acceleration |
	power := 1 megaWatt.
	mass := 100 tonne.
	energy := power * (1 second) .
	
	"kinetic energy KE = mass * v * v / 2. 
	==> v := sqrt{ 2 * KE / mass }
	"
	vSquared := (( energy / mass ) * 2.0).
	deltaVqty := (vSquared quantity ) sqrt.
	deltaV := deltaVqty meterPerSecond.
	self expect: '4.472 meterPerSecond' actual: (deltaV as: #meterPerSecond).
	acceleration := deltaV / (1 second).
	self expect: '0.456 gravity' actual: ( acceleration as: #gravity ).
	"Lower limit for one megawatt of energy production and conversion is probably about 10 tonne. 
	 So we might have 90 tonne of payload."
	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> test590examples [
	"Class-side examples should not fail"
	HumMeasure exampleOrbitTable.
	HumMeasure exampleStarVoyage.
	HumMeasure exampleWateringHighPlains.
	HumMeasure exampleSlingShotToOrbit. 
]

{ #category : #'Formula Tests' }
HumCalculatorTests >> test610areaOfCircleFormula [
	"Make sure it works with HumMeasure"

	| result radius |
	radius := 100 meters.
	result := HumMeasure areaOfCircleRadius: radius.
	self expect: 31415.926 actual: result quantity.
	self expect: (radius * radius) units actual: result units.
	self expect: ( 1e4 squareMeter ) units actual: result units.

]

{ #category : #'Formula Tests' }
HumCalculatorTests >> test615circumferenceOfCircleFormula [
	"Make sure it works with HumMeasure"

	| result radius |
	radius := 100 meters.
	result := HumMeasure circumferenceOfCircleRadius: radius.
	self expect: ( radius * 2.0 * Float pi ) quantity actual: result quantity.
	self expect: ( radius ) units actual: result units.
	self expect: ( 1e2 meter ) units actual: result units.

	
]

{ #category : #'Formula Tests' }
HumCalculatorTests >> test620areaOfSphereFormula [
	"Make sure it works with HumMeasure"

	| result radius |
	radius := 100 meters.
	result := HumMeasure areaOfSphereRadius: radius.
	self expect: ( radius * radius * 4.0 * Float pi) quantity  actual: result quantity.
	self expect: ( radius * radius ) units actual: result units.
	self expect: ( 1e4 squareMeter ) units actual: result units.


	
]

{ #category : #'Formula Tests' }
HumCalculatorTests >> test630volumeOfSphereFormula [
	"Make sure it works with HumMeasure"

	| result radius |
	radius := 100 meters.
	result := HumMeasure volumeOfSphereRadius: radius.
	self expect: ( radius * radius * radius * 4.0 * Float pi / 3.0 ) quantity  actual: result quantity.
	self expect: ( radius * radius * radius ) units actual: result units.
	self expect: ( 1e6 cubicMeter ) units actual: result units.

	
]

{ #category : #'Solver Tests' }
HumCalculatorTests >> testSolverSqrt [
	"Test the solver by asking for a square root."

	| root result guess formula err | 
	formula := [ :x | x * x ].
	root := 1.414.
	guess := 1.4.
	err := 0.001.
	result := HumMeasure solveFormula: formula target: 2.0 guess: guess precision: 0.001 iterate: 10.
	self assert: (((result/root)-1.0) abs < err) description: 'result = ', result asString.
	"Should also find negative root if we start near there."
	root := -1.414.
	guess := -1.4.
	err := 0.001.
	result := HumMeasure solveFormula: formula target: 2.0 guess: guess precision: 0.001 iterate: 10.
	self assert: (((result/root)-1.0) abs < err) description: 'result = ', result asString.
	
	
]

{ #category : #'HumVector Tests' }
HumCalculatorTests >> testV110VectorCrossProduct [
	"Check the vector cross product"
	| u v s |
	u := HumVector newFrom: #( 1.0 0.0 0.0 ). "Default unit of measure is 'meter'."
	v := HumVector newFrom: #( 0.0 1.0 0.0 ).
	
	s := u cross: v.
	self expect: 'square meter' actual: s units. "Thus cross product has units of 'square meter'."
	
	self expect: 0.0 actual: ( s at: 1 ) quantity.
	self expect: 0.0 actual: ( s at: 2 ) quantity .
	self expect: 1.0 actual: ( s at: 3 ) quantity.
	
	
]

{ #category : #'HumVector Tests' }
HumCalculatorTests >> testV111VectorCrossProduct [
	"Check the vector cross product"
	| u v s |
	u := HumVector newFrom: #( 0.0 0.0 1.0 ).
	v := HumVector newFrom: #( 0.0 1.0 0.0 ).
	
	s := u cross: v.
	self expect: 'square meter' actual: s units.
	self assert: ( s at: 1 ) quantity = -1.0.
	self assert: ( s at: 2 ) quantity =  0.0.
	self assert: ( s at: 3 ) quantity =  0.0.
	
	
]

{ #category : #'HumVector Tests' }
HumCalculatorTests >> testV112VectorCrossProduct [
	"Check the vector cross product"
	| u v s |
	u := HumVector newFrom: #( 0.0 1.0 0.0 ).
	v := HumVector newFrom: #( 0.0 0.0 1.0 ).
	
	s := u cross: v.
	self expect: 'square meter' actual: s units.
	self assert: ( s at: 1 ) quantity =  1.0.
	self assert: ( s at: 2 ) quantity =  0.0.
	self assert: ( s at: 3 ) quantity =  0.0.
	
	
]

{ #category : #'HumVector Tests' }
HumCalculatorTests >> testV113VectorCrossProduct [
	"Check the vector cross product"
	| u v s |
	u := HumVector newFrom: #( 0.0 1.0 0.0 ).
	v := HumVector newFrom: #( 1.0 0.0 0.0 ).
	
	s := u cross: v.
	self expect: 'square meter' actual: s units.
	self assert: ( s at: 1 ) quantity =  0.0.
	self assert: ( s at: 2 ) quantity =  0.0.
	self assert: ( s at: 3 ) quantity = -1.0.
	
	
]

{ #category : #'HumVector Tests' }
HumCalculatorTests >> testV115VectorCrossProduct [
	"Check the vector cross product"
	| u v s |
	u := HumVector newFrom: #( 5.0 0.0 0.0 ).
	v := HumVector newFrom: #( 0.0 5.0 0.0 ).
	
	s := u cross: v.
	self expect: 'square meter' actual: s units.
	self assert: ( s at: 1 ) quantity = 0.0.
	self assert: ( s at: 2 ) quantity = 0.0.
	self assert: ( s at: 3 ) quantity = 25.0.
	
	
]

{ #category : #'HumVector Tests' }
HumCalculatorTests >> testV117VectorCrossProduct [
	"Check the vector cross product"
	| u v s |
	u := HumVector newFrom: #( 5.0 2.0 0.0 ).
	v := HumVector newFrom: #( 2.0 5.0 0.0 ).
	
	s := u cross: v.
	self expect: 'square meter' actual: s units.
	self assert: ( s at: 1 ) quantity = 0.0.
	self assert: ( s at: 2 ) quantity = 0.0.
	self assert: ( s at: 3 ) quantity = 21.0.
	
	
]

{ #category : #'HumVector Tests' }
HumCalculatorTests >> testV210IdentityVector [
	"Creat a identity vector I * V = V.
	u * v = v.
	"
	| i  v |
	i := HumVector identityVector.
	self assert: (i dimensions size = 0). "Identity vector should be dimensionless"
	
	v := HumVector newFrom: #( 1.1 2.2 3.3 ). "Note: Default unit of measure is 'meter'."
	"Multiplication by unit vector should return same."
	self expect: v actual: ( i * v ).
	self expect: v actual: ( v* i ).
	"Dot product should produce sum of elements."
	self expect: (6.6 meter) actual: ( i dot: v ).
	"Crossed with itself."
	self expect: ( HumVector newFrom: #(0.0 0.0 0.0) units: #none ) actual: ( i cross: i ) .
	"Dot with itself."
	self expect: ( HumMeasure quantity: 3 units: #none ) actual: ( i dot: i ).
	
	
	
	
	
]

{ #category : #'Measure Tests' }
HumCalculatorTests >> ztest530measureTimesPercent [
	"Percent times percent produces percent"
	| m1 m2 m3 |
	m1 := HumMeasure percent: 10.
	m2 := HumMeasure percent: 25.
	m3 :=  m2 * m1.
	self expect: m3 quantity is: (0.10 * 0.25 * 100).
	self expect: m3 units is: #percent. 
	
]
