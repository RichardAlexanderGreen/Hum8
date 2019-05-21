"
HumMeasure expresses most measurements in KMS (SI) units.
Note: A protocol has been added to Number - to convert numbers into Measures.

s := 1 lightSecond.  ""HumMeasure( 299792458 meter )""s
milliC := s / 1000.  ""HumMeasure( 299792.458 meter ) about 300 kilometers""
microC := s / 1e6.   ""HumMeasure( 299.792 meter ) a football field""
nanoC := s / 1e9.    ""HumMeasure( 0.300 meter ) about 300 millimeter"" 
picoC := s / 1e12.   ""HumMeasure( 0.000299792458 meter ) about 0.3 millimeter""  
femtoC := s / 1e15.  ""HumMeasure( 2.99792458e-7 meter ) about 4000 atoms - See below.""
attoC := s / 1e18.   ""HumMeasure( 2.99792458e-10 meter ) about 4 atoms"" 


picoMeter := 1 meter / 1e12."" HumMeasure( (1/1000000000000) meter )""
carbonRadius := picoMeter * 70."" HumMeasure( (7/100000000000) meter )""
nCarbonAtoms := femtoC / carbonRadius."" HumMeasure( 4282.749  )"" 
"
Class {
	#name : #HumMeasure,
	#superclass : #Magnitude,
	#instVars : [
		'dimensions',
		'quantity'
	],
	#classInstVars : [
		'unitsSynonyms'
	],
	#category : #'Hum-RunTime'
}

{ #category : #formula }
HumMeasure class >> areaOfCircleRadius: radius [
	"Return the volume of a sphere of given radius"

	| r pi area |
	pi := Float pi.
	r := radius.
	area :=  (r * r) * pi.
	^area.
	
]

{ #category : #formula }
HumMeasure class >> areaOfSphereRadius: radius [
	"Return the volume of a sphere of given radius"

	| r pi area |
	pi := Float pi.
	r := radius.
	area :=  (r * r) * 4.0 * pi.
	^area.
	
]

{ #category : #'instance creation' }
HumMeasure class >> astronomicalUnit: aNumber [
	| measure |
	measure := self quantity: ( aNumber * 149597870700 ) units: 'meter'.	
	^measure.
]

{ #category : #'instance creation' }
HumMeasure class >> au: aNumber [
	| measure |
	measure := self astronomicalUnit: aNumber.
	^measure.
]

{ #category : #'instance creation' }
HumMeasure class >> britishThermalUnit: aNumber [
	"Energy - British Thermal Unit (ISO)"
	| measure |
	measure := self quantity: ( aNumber * 1.0545) units: 'Joule'.
	measure dimensions: (Dictionary newFrom: {'kilogram'->1. 'meter'->2. 'second'->(-2).}). 
	^measure.
]

{ #category : #'instance creation' }
HumMeasure class >> btu: aNumber [
	"Energy - British Thermal Unit (ISO)"
	| measure |
	measure := self britishThermalUnit: aNumber.
	^measure.
]

{ #category : #formula }
HumMeasure class >> circumferenceOfCircleRadius: radius [
	"Return the volume of a sphere of given radius"

	| r pi circumference |
	pi := Float pi.
	r := radius.
	circumference :=  r * 2.0 * pi.
	^circumference.
	
]

{ #category : #examples }
HumMeasure class >> exampleCloudCity [
	"Suppose we wanted to float a small city (1000 people) using Helium"
	|  person personStuff nPeople  payload buoyancy heliumCubic heliumDensity radius pi volume personCubic peopleCubic totalCubic formula q lift load safetyFactor  |
	person := (100 kilogram). 
	personStuff := (1000 kilogram). "2200 lb (My camping trailer weighs 1600 lb)" 
	"allowance for structure, furniture, water, fuel, and air."
	nPeople := 99000.  "Ten Thousand people . . . a village."
	payload := (person + personStuff) * nPeople.
	personCubic := (3 meter) * (4 meter) * (5 meter). "HumMeasure( 60 cubic meter )"
	peopleCubic := personCubic * nPeople.
	buoyancy := (1 kilogram) / (1 cubicMeter).
	heliumCubic := payload / buoyancy .  "This is only a first approximation."
	"Assumes weight of airframe, propulsion is already covered."
	totalCubic := peopleCubic + heliumCubic.
	
	pi := Float pi.
	formula := [ :r | r * r * r * 4.0 * pi / 3.0 ]. "This is a sphere - not an elipsoid."
	safetyFactor := 2.0.
    q := HumMeasure solveFormula: formula target: ((totalCubic quantity)*safetyFactor)  guess: ( totalCubic quantity ln *0.33 )exp  precision: 0.1 iterate: 10.
	radius := HumMeasure quantity: (q ceiling) units: 'meter'.
	volume := (radius * radius * radius * 4.0 * pi / 3.0). 
	
	self assert: (volume > totalCubic ) description: ('Expect solution volume: ', volume asString, ' > totalCubic: ', totalCubic asString).
	heliumDensity := (1 kilogram * (4.0/14.0) ) / (1 cubicMeter).  "approximation"
	lift := volume * buoyancy.
	load := payload + ( heliumCubic * heliumDensity ).
	self assert: (lift > load) description: 'Expect lift to exceed minimum'.
	^( 'radius = ', radius asString, ' floats ',  nPeople asString, ' people', ' -- lift/load = ', (lift/load) asString ).
]

{ #category : #examples }
HumMeasure class >> exampleLorentzTable [
	"Display  a table of Lorentz factors for various fractions of light-speed."
	|  table |
	table := String new.
	"Generate values of v/c ==> 0.5 0.75 0.875 . . . "
( 1 to: 10  ) 
	do: [ :power |  
		| zeno v beta gamma s | 
		zeno := 2.0 raisedToInteger: ( power  ).
		v := 1.0 - (1.0/zeno).          "Incrementally halve the remaining distance to 1.0"
		beta := (1.0 - (v*v)) sqrt. 
		gamma := 1.0 / beta. 
		s := ' v = ',( v printShowingDecimalPlaces: 6)
		     , ' beta = ', (beta printShowingDecimalPlaces: 6)
		     , ' gamma = ', (gamma printShowingDecimalPlaces: 6).
		Transcript cr; show: s. 
		table := table, s, String cr.
		].  
 ^table.
]

{ #category : #examples }
HumMeasure class >> exampleOrbitTable [
	"Compute kineticEnergy per kilogram for a Holman transfer Earth-Mars"
	| planets table fields bigGM    |
	
	"Initialize table with basic orbital data"
	table := Dictionary new.
	table 
		at: { 'Mercury'. #orbitAu } put: 0.387; at: { 'Mercury'. #orbitYears} put: 0.241;
		at: { 'Venus'. #orbitAu } put: 0.723; at: { 'Venus'. #orbitYears} put: 0.615;
		at: { 'Earth'. #orbitAu } put: 1.000; at: { 'Earth'. #orbitYears} put: 1.00;
		at: { 'Mars'. #orbitAu } put: 1.524; at: { 'Mars'. #orbitYears} put: 1.881;
		at: { 'Jupiter'. #orbitAu } put: 5.203; at: { 'Jupiter'. #orbitYears} put: 11.869.
	bigGM := (1.0 sunMass) * (1 gravitationalConstant).	
	planets := #('Mercury' 'Venus' 'Earth' 'Mars' 'Jupiter' ).
	planets do: [  :planet |
		    | radius circumference orbitTime years auPerYear velocity potentialEnergy  kineticEnergy netEnergy |
					radius := (table at: { planet. #orbitAu }).
					circumference := (radius au)  * 2 * 3.14159.
					orbitTime := table at: {planet. #orbitYears}.
					auPerYear := (radius/orbitTime).
					years := orbitTime years.
					velocity := circumference / years.
					"Compute the potential energy due to Sun`s gravity"
					potentialEnergy := ( (1.0 kg )* bigGM / (radius au)) negated.
					kineticEnergy := (0.5 kg) * velocity * velocity.
					netEnergy := potentialEnergy + kineticEnergy.
					table
						at: { planet. #circumference } put: (circumference as: #au);
						at: { planet. #AUperYear } put: auPerYear;
						at: { planet. #velocity } put: (velocity as: #kps);
						at: { planet. #potentialEnergy } put: (potentialEnergy as: #gigajoule );
						at: { planet. #kineticEnergy } put: (kineticEnergy as: #gigajoule );
						at: { planet. #netEnergy } put: (netEnergy as: #gigajoule ).
			 ].
	"Show table"
	fields := #( #orbitAu #orbitYears #AUperYear #circumference #velocity #kineticEnergy #potentialEnergy #netEnergy ).	
	planets do: [  :planet |
		Transcript cr; cr; show: planet.
		#( #orbitAu #velocity #kineticEnergy #potentialEnergy #netEnergy ) 
				do: [ :field | Transcript tab; show: field asString, ': ', ( table at: { planet. field } ) asString ].
		 ].
]

{ #category : #examples }
HumMeasure class >> exampleSaucerCity [
	"Suppose we wanted to float a small city (1000 people) using Helium"
	|  person personStuff nPeople  payload buoyancy heliumCubic heliumDensity radius pi volume personCubic peopleCubic totalCubic formula q lift load safetyFactor  |
	person := (100 kilogram). 
	personStuff := (1000 kilogram). "2200 lb (My camping trailer weighs 1600 lb)" 
	"allowance for structure, furniture, water, fuel, and air."
	nPeople := 99000.  "Ten Thousand people . . . a village."
	payload := (person + personStuff) * nPeople.
	personCubic := (3 meter) * (4 meter) * (5 meter). "HumMeasure( 60 cubic meter )"
	peopleCubic := personCubic * nPeople.
	buoyancy := (1 kilogram) / (1 cubicMeter).
	heliumCubic := payload / buoyancy .  "This is only a first approximation."
	"Assumes weight of airframe, propulsion is already covered."
	totalCubic := peopleCubic + heliumCubic.
	
	pi := Float pi.
	formula := [ :r | |height| height := r / 5. (height * r * r * 4.0 * pi / 3.0) ]. "An elipsoid with a height 20% of radius"
	safetyFactor := 2.0.
    q := HumMeasure solveFormula: formula target: ((totalCubic quantity)*safetyFactor)  guess: 300.0 "( totalCubic quantity ln *0.33 ) exp / 5.0"  precision: 0.1 iterate: 10.
	radius := HumMeasure quantity: (q ceiling) units: 'meter'.
	volume := (radius * radius * radius * 4.0 * pi / 3.0). 
	
	self assert: (volume > totalCubic ) description: ('Expect solution volume: ', volume asString, ' > totalCubic: ', totalCubic asString).
	heliumDensity := (1 kilogram * (4.0/14.0) ) / (1 cubicMeter).  "approximation"
	lift := volume * buoyancy.
	load := payload + ( heliumCubic * heliumDensity ).
	self assert: (lift > load) description: 'Expect lift to exceed minimum'.
	^( 'radius = ', radius asString, ' floats ',  nPeople asString, ' people', ' -- lift/load = ', (lift/load) asString ).
]

{ #category : #examples }
HumMeasure class >> exampleSlingShotToOrbit [
	"Calculate kinetic energy and average power for various stages."
	| vSound kg eSound acceleration time1 distance1 vNEO eNEO time2 distance2 watt peakWatt protonBoron  mole nReactions |
	"Imagine a tube that accelerates craft to speed of sound."
	vSound := (1100 feet) / (1 second).		" HumMeasure( 335.280 meter per second )"
	kg := 1 kilogram.
	eSound := kg * vSound * vSound * 0.5.	" Kinetic Energy = HumMeasure( 56206.241 Joule )"
	acceleration := 1 gravity.
	time1 := vSound / acceleration.				" HumMeasure( 34.189 second )"
	distance1 := acceleration * time1 * time1 * 0.5.	" HumMeasure( 5731.442 meter )"
	"Imagine that a ram-jet + rocket accelerates to NEO speed"
	vNEO := (10 kilometer) / (1 second).			" HumMeasure( 10000 meter per second )"
	eNEO := kg * vNEO * vNEO * 0.5.				" HumMeasure( 50000000 Joule )"
	time2 := vNEO / acceleration.						" HumMeasure( 1019.716 second )"
	distance2 := acceleration * time2 * time2 * 0.5.	" HumMeasure( 5.098e6 meter ) ".
	(distance2 < (5100 kilometer) ).					" = 5100 kilometer"			
	watt := eNEO / time2.								" HumMeasure( 49033.250 Watt )"
	self assert: (watt < (50 kilowatt ) ). 	" average power = 50 kilowatt per kilogram of payload - at this level of acceleration"
	"However, at peak velocity ... if the rate of acceleration is constant ..."
	"F = m*a and e = F*d and power = e/t so power = F*v = m*a*v"
	peakWatt := kg * acceleration * vNEO.	" HumMeasure( 98066.500 Watt )"
	"A lower watt per kilogram means a lower acceleration and a longer time and a longer distance to NEO."
	
	"What if the power came from proto-boron reaction?"
	protonBoron := 8 mev. 								"8 Mev per proton-boron reaction."
	nReactions := watt / protonBoron.
	mole := nReactions / (1 avogadro). 		" HumMeasure( 6.352422498172116e-8 mole per second )"
	mole := eNEO / protonBoron / (1 avogadro).		" HumMeasure( 6.477668213071861e-5 mole )"
	"A few grams would launch many tons if the fuel and energy could be used efficiently."
	^mole asString, ' minimum mole of Boron per kilogram '
]

{ #category : #examples }
HumMeasure class >> exampleStarVoyage [
	| watt  m v e d t p megaW n nB11 molesB11 gramsB11 kgB11
 	 nCNOreactions nGrams kgOfHydrogen cubicMeterPerSecond area 
 	minCollectingVelocity minCollectingVoverC  years |
	
	watt := 1 watt.				" HumMeasure( 1 Watt )"
	m := 1000 kilogram.		" HumMeasure( 1000 kilogram )"    
	v := 0.1 lightSpeed.		" HumMeasure( 2.99792458e7 meter per second )"  
	e := m * v * v * 0.5.		" HumMeasure( 449377589368408832 Joule )"
	d := 4 lightYear.			" HumMeasure( 37842921890323200 meter )"
	t := d / v.						" HumMeasure( 1262304000 second )"
	years := t / (1 year). 		"HumMeasure( 40.027  ) ==> 40 years one way."
	p := e / t.						" HumMeasure( 3.5599791283906955e8 Watt )"
	megaW := 3.56e8 / 1e6.	" 356 Megawatt per ton"

	n := e / (8 mev). "350599310495773556710666403840 atoms of B11"
	nB11 := 350599310495773556710666403840.
	molesB11 := nB11 / (1 avogadro quantity). "582183.7997985426"
	gramsB11 := molesB11 * 11." 6.404e6"
	kgB11 := gramsB11/1e3." 6404.021797783969 -- Houston, we have a problem."
	"For each tonne of payload we need over 6 tonne of fuel, 
	 and for each tonne of fuel we need fuel to accelerate the fuel."  	

	"What if we captured Hydrogen in ram scoop and converted them via CNO fusion? "
	nCNOreactions := (3.5599791283906955e8 joule)/(25 mev)." 8.887857e19 reactions/second"
	"Each reaction requires 4 Hydrogen atoms (4 protons)."
	nGrams := 8.887857e19 * 4 / (1 avogadro quantity). "0.000590345"
	kgOfHydrogen := nGrams / 1e3.                " 5.90345e-7 per second per tonne"
	"But we need to sweep up 8.89e19 Hydrogen atoms per second."
	"There is roughly 1e6 Hydrogen atoms per cubic meter in interstellar space "
	cubicMeterPerSecond := 8.89e19 / 1e6." 8.89e13"
	"If our scoop is 1 km in radius . . . area = pi * R * R "
	area := 3.14 * 1e3 * 1e3." 3.14e6 square meters" 
	"Our velocity needs to be at least"
	minCollectingVelocity := cubicMeterPerSecond / area. "==> 28,312 km/second" 
	minCollectingVoverC := minCollectingVelocity / 3e8.  " 0.09 lightSpeed" 
	"So this scheme is feasible if artificial CNO fusion is feasible.
	 And if the CNO reactor and scoop does not consume too much of our mass budget."
	"Feasible at 100% efficiency -- reduced efficiency requires higher collecting velocity."
	"Feasible if ignoring collection drag (an inefficiency)."
	"Also, somehow the catalyst (Carbor, Nitrogen, Oxygen) has to be retained 
	and not blasted out with the reaction mass."
	"At this time, we have no idea about how to produce CNO fusion, except perhaps in a H-bomb."


]

{ #category : #examples }
HumMeasure class >> exampleStudentDebt [
	"Calculate student debt due to direct costs (educator hours)"
	| bs cost classSize gradWage educatorWage bsCost bsCostDollar bsCostNormalized workHoursPerYear gradSalary payBackPeriod flatRate |
	bs := HumMeasure quantity: 120 units: #creditHour per: #grad. 
 "HumMeasure( 120 creditHour per grad )"
	cost := HumMeasure quantity: (15*3) units: #educatorHour per: #creditHour.
 "HumMeasure( 45 educatorHour per creditHour )"
	classSize := HumMeasure quantity: 20 units: #student per: #educator. 
 "HumMeasure( 20 student per educator )"
	gradWage := HumMeasure quantity: 30 units: #dollar per: #workHour.
 "HumMeasure( 30 dollar per workHour )"
	educatorWage := HumMeasure quantity: 60 units: #dollar per: #workHour.
 "HumMeasure( 60 dollar per workHour )"
	bsCost := bs * cost / classSize. 
 "HumMeasure( 270 educatorHour educator per graduate )"
	bsCostDollar := bsCost * educatorWage. 
 	"HumMeasure( 16200 dollar educator educatorHour per workHour graduate )"
	bsCostNormalized := HumMeasure quantity: (bsCostDollar quantity) units: #dollar per: #grad.
 	"HumMeasure( 16200 dollar per grad )"
	"Ignores overheads - admin costs, classroom amortization, materials not covered by fees."
	workHoursPerYear := HumMeasure quantity: 1800 units: #workHour per: #workYear.
 	"HumMeasure( 1800 workHour per workYear )"
	gradSalary := gradWage * workHoursPerYear.  
	"HumMeasure( 54000 dollar per workYear )"
	payBackPeriod := HumMeasure quantity: 10 units: #workYear.
 	"HumMeasure( 10 workYear )"
	flatRate := bsCostNormalized / (gradSalary * payBackPeriod).
 	"HumMeasure( 0.030 per grad )"
	"This 3% rate ignores administative costs and infrastructure costs (e.g. amortization of campus)."
	self assert: (flatRate * gradSalary * payBackPeriod) >= bsCostDollar description: 'Proof failed'.
	^flatRate asString, ' rate for payback period = ', payBackPeriod asString.
]

{ #category : #examples }
HumMeasure class >> exampleThrustFromGigawattOfPhotons [
	"How much thrust from a gigawatt of photons?"
	| e c p n pp |
	e := 3 ev. "Photon energy at low end of UV spectrum. Any reasonable energy will do and cancels out."
	c := 1 lightSpeed.
	p := e/c. "momentum from one photon"
	n := (1e9 watt) / e. "How many photons in a gigawatt?  Energy per photon cancels out here."
	pp := p * n. "( 3.336 Newton ) - How much force from a gigawatt of photons?"
	^pp asString, ' thrust from a gigawatt of photons'.

]

{ #category : #examples }
HumMeasure class >> exampleWateringHighPlains [
	"How much power is required to lift water from Mississippi / Missouri to High Plains?
	"
	| density acre foot acreFoot mass gravity weight lift energy timePeriod watts irrigatedAcres totalWatts |
	
	density := ( 1000 kilogram ) / ( 1 cubicMeter ).
	
	acre := ( 1 acre ).			
	foot := ( 1 foot ).
	acreFoot := acre * foot.																					
	mass := acreFoot * density.		" 1.2334868904e6 kilogram "
																				
	gravity := ( 1 gravity ).
																														 
	weight := mass * gravity.																			" HumMeasure2( 1.2096374213741159e7 Newton )"																			
	lift := ( 5000 feet ).    				" HumMeasure2( 1524 meter )"
	energy := weight * lift.																			" HumMeasure2( 1.8434874301741528e10 Joule )"
	timePeriod := (1 year).	"one year as seconds"
	watts := energy / timePeriod.																	" HumMeasure2( 586.172 Watt ) ==> pennies per day per acre"
	irrigatedAcres := 13.6e6." 1.36e7"
	totalWatts := watts * irrigatedAcres.		" HumMeasure2( 7.971938927798279e9 Watt ) ==> 8 GigaWatt"
			"This is minimum because transmission, pump, and pipe losses are ignored."
	^(totalWatts / (1e9 watt)) asString, ' gigawatt minimum to provide 1 acre-foot per year'.
]

{ #category : #'instance creation' }
HumMeasure class >> foot: aNumber [
	| measure |
	measure := self quantity: (0.3048 * aNumber) units: 'meter'.	
	^measure.
]

{ #category : #'instance creation' }
HumMeasure class >> footH2O: aNumber [
	"foot of water - pressure"
	| measure |
	measure := HumMeasure quantity: ( aNumber * 2.98898e3 ) units: 'Pascal'.
	measure dimensions: (Dictionary newFrom: { }).
	^measure.
]

{ #category : #'instance creation' }
HumMeasure class >> fromString: aString [ 
	"Convert a string of the form '-999 units'"
	| measure quantity units|
	self assert: (aString isKindOf: String).
	quantity := aString asNumber.
	units := (HumCalculator given: aString extractAfter: (String space) ) trimBoth.
	measure := HumMeasure quantity: quantity units: units.
	^measure.
	
	
	
]

{ #category : #'instance creation' }
HumMeasure class >> gravities: gNumber [
	"See also Number>>gravity"
	| instance |
	instance := gNumber gravity.
	^instance.
]

{ #category : #'instance creation' }
HumMeasure class >> gravity [
	"See also: Number>>gravity"
	| instance |
	instance := 1.0 gravity.
	^instance.
]

{ #category : #'instance creation' }
HumMeasure class >> horsePower: aNumber [
	| measure |
	measure := self quantity: ( aNumber * 735.49875 ) units: 'Watt'.
	measure dimensions: (Dictionary newFrom: {'kilogram'->1. 'meter'->2. 'second'->(-3).}).
	^measure.
]

{ #category : #'instance creation' }
HumMeasure class >> joule: aNumber [
	"Energy - Joule . . . "
	| measure |
	measure := self quantity: ( aNumber ) units: 'Joule'.
	measure dimensions: (Dictionary newFrom: {'kilogram'->1. 'meter'->2. 'second'->(-2).}). 
	^measure.
]

{ #category : #'instance creation' }
HumMeasure class >> lightSpeed [
	| measure |
	measure := (1 lightSpeed).
	^measure.
]

{ #category : #'instance creation' }
HumMeasure class >> lightSpeed: aNumber [
	"Only makes sense if aNumber < 1."
	| measure |
	self assert: (aNumber < 1.0).
	measure := self quantity: (1e8 * aNumber) units: 'meter' per: 'second'.
	^measure.
]

{ #category : #'instance creation' }
HumMeasure class >> meter: aNumber [
	| measure |
	measure := self quantity: (aNumber) units: 'meter'.	
	^measure.
]

{ #category : #'instance creation' }
HumMeasure class >> pascal: aNumber [
	"unit of pressure"
	| measure |
	measure := HumMeasure quantity: ( aNumber ) units: 'Pascal'.
	measure dimensions: (Dictionary newFrom: {'kilogram'->1. 'meter'->(-1). 'second'->(-2). }).
	^measure.
]

{ #category : #'instance creation' }
HumMeasure class >> psi: aNumber [
	"pound per square inch - pressure"
	| measure |
	measure := self quantity: ( aNumber * 6.894757e3 ) units: 'Pascal'.
	measure dimensions: (Dictionary newFrom: {'kilogram'->1. 'meter'->(-1). 'second'->(-2).}). 
	^measure.
]

{ #category : #'as yet unclassified' }
HumMeasure class >> pxPerMillimeter [
	| px mm pxPer |
	mm := 1 millimeter.
	px := (7.0/900.0) inch.            "verticle = HumMeasure( 0.0001975555 meter ) "
	px := (11.25/1440.0) inch.  "horizontal = HumMeasure( 0.0001984375 meter )"
	pxPer := mm / px.              " 5.03937. . .  on my laptop"
	^pxPer quantity asInteger.    "Round to 5 px per mm"
]

{ #category : #'instance creation' }
HumMeasure class >> quantity: aNumber per: aSymbol [ 
	| measure |
	measure := self basicNew.
	measure quantity: aNumber per: aSymbol.
	^measure.
]

{ #category : #'instance creation' }
HumMeasure class >> quantity: aNumber units: aString [ 
	| instance |
	instance := self basicNew.
	instance quantity: aNumber units: aString.
	^instance.
]

{ #category : #'instance creation' }
HumMeasure class >> quantity: aNumber units: numeratorUnits per: denominatorUnits [
	"Create instance with given numerator and denominator units.
	Example1:
	   milesPerHour := HumMeasure2 quantity: 65 units: 'miles' per: 'hour'.
	   feetPerMile := HumMeasure2 quantity: 5280 units: 'feet' per: 'mile'.
	   feetPerHour := milesPerHour * feetPerMile.
		 secondsPerHour := HumMeasure2 quantity: 3600 units: 'seconds' per: 'hour'.
		 feetPerSecond := feetPerHour / secondsPerHour.
	"
	| instance numerator denominator |
	"instance := self basicNew.
	instance quantity: aNumber units: numeratorUnits per: denominatorUnits."
	numerator := self quantity: aNumber units: numeratorUnits.
	denominator := self quantity: 1 units: denominatorUnits.
	instance := numerator / denominator.
	^instance.
	
	 
	 
	 
	 
]

{ #category : #'as yet unclassified' }
HumMeasure class >> readMe [
"Wikipedia says:
The International System of Quantities (ISQ) is a system based on seven base quantities: length, mass, time, electric current, thermodynamic temperature, amount of substance and luminous intensity. Other quantities such as area, pressure and electrical resistance are derived from these base quantities by clear non-contradictory equations. The ISQ defines the quantities that are measured with the SI units. The ISQ is defined in the international standard ISO/IEC 80000, and was finalised in 2009 with the publication of ISO 80000-1."

"Wikipedia:
The SI base units and their physical quantities are:

metre for length
kilogram for mass
second for time
ampere for electric current
kelvin for temperature
candela for luminous intensity
mole for the amount of substance
"
]

{ #category : #'instance creation' }
HumMeasure class >> seconds: aNumber [
	"Create a HumMeasure instance with unit-of-measure = second"

	| instance  |
	instance := self quantity: aNumber units: #second.
	^instance.
]

{ #category : #formula }
HumMeasure class >> solveFormula: aBlockClosure target: aTarget guess: aGuess precision: aPrecission iterate: nIterations [
	"Use Newton's method. This is only good for continuous functions."
	| result xn xnPlus gn gnPlus fn fnPlus  nextGuess fPrimeInverse |
	self assert: (nIterations > 0) description: 'Iteration limit exceeded'. 
	self assert: (aTarget isKindOf: Float) description: 'Solver is designed for real numbers'.
	self assert: (aGuess isKindOf: Float) description: 'Solver is designed for real numbers'.
	result := aGuess. "Test the test."
	"x[n+1] = x[n] - f[n] / f'[n]"
	xn := aGuess.
	gn := aBlockClosure value: xn.
	fn := gn - aTarget.
	( (fn abs) < aPrecission ) ifTrue: [ ^xn ].
	xnPlus := xn + aPrecission.
	gnPlus := aBlockClosure value: xnPlus.
	fnPlus := gnPlus - aTarget.
	( (fnPlus abs) < aPrecission ) ifTrue: [ ^xnPlus ].
	"REPLACE fPrime := (fnPlus - fn) / (xnPlus - xn).  nextGuess := xn - (fn / fPrime). AVOID DIVISION BY fPrime"
	fPrimeInverse := (xnPlus - xn) / (fnPlus - fn).
	nextGuess := xn - (fn * fPrimeInverse).
	result := self solveFormula: aBlockClosure target: aTarget guess: nextGuess precision: aPrecission iterate: (nIterations - 1).
	^result.
]

{ #category : #'as yet unclassified' }
HumMeasure class >> unitsSynonyms [
	"Provide a dictionary that transforms various unit-of-measure names to standard names."
	^ unitsSynonyms ifNil: [ unitsSynonyms := Dictionary new.
		unitsSynonyms
			at: 'feet' put: 'foot';
			at: 'miles' put: 'mile';
			at: 'meters' put: 'meter';
			at: 'kg' put: 'kilogram';
			at: 'km' put: 'kilometer';
			at: 'inches' put: 'inch';
			at: 'watt' put: 'Watt';
			at: 'joule' put: 'Joule';
			at: 'amp' put: 'Ampere';
			at: 'ft' put: 'foot';
			at: 'in' put: 'inch';
			at: 'sec' put: 'second';
			at: 'none' put: '';
			yourself.] 
]

{ #category : #formula }
HumMeasure class >> volumeOfSphereRadius: radius [
	"Return the volume of a sphere of given radius"

	| r pi volume |
	pi := Float pi.
	r := radius.
	volume :=  (r * r * r) * (4.0/3.0)*pi.
	^volume.
	
]

{ #category : #'instance creation' }
HumMeasure class >> watt: aNumber [
	"Energy - British Thermal Unit (ISO)"
	| measure |
	measure := self quantity: ( aNumber ) units: 'Watt'.
	measure dimensions: (Dictionary newFrom: {'kilogram'->1. 'meter'->2. 'second'->(-3).}). 
	^measure.
]

{ #category : #arithmetic }
HumMeasure >> * multiplier [ 
	| result |
	result := self deepCopy.
	(multiplier isKindOf: Number) 
		ifTrue: [ result := self deepCopy. 
							result quantity: (self quantity * multiplier).
							^result.
							].
	(multiplier isKindOf: Duration)
		ifTrue: [
			| m |
			m := HumMeasure quantity: (multiplier asSeconds) units: #second.
			result := self * m.
			^result.
			].
	result quantity: (self quantity) * (multiplier quantity).
	(multiplier dimensions)
		keysAndValuesDo: [ :unit :exponent | 
			"Increment and net-out the dimensions."
			result incrementDimensionsAt: unit by: exponent.
			].
	^result.	

]

{ #category : #arithmetic }
HumMeasure >> ** anInteger [
	"return value equal to self raised to an integer power"
	| x n |
	n := anInteger.
	self assert: ( n isKindOf: Integer ).
	self assert: ( n <= 3 ) description: 'We do not expect to raise a measure to a large number.'.
	self assert: ( n > 0 ) description: 'We expect power to be greater than zero.'.
	x := 1.0.
	 1 to: n  do: [ :i | x := self * x ].
	^x.
]

{ #category : #arithmetic }
HumMeasure >> + operand [ 
	| result |
	"The units of measure must be the same."
	self assert: (operand dimensions) = (self dimensions).
	"Make a deep copy to get fresh dimensions and quantity."
	result := self deepCopy.
	result quantity: (self quantity) + (operand quantity).
	^result.	

]

{ #category : #arithmetic }
HumMeasure >> - operand [ 
	| result |
	self assert: (operand dimensions) = (self dimensions).
	result := self deepCopy.
	result quantity: (self quantity) - (operand quantity).
	^result.	

]

{ #category : #arithmetic }
HumMeasure >> / aDivisor [ 
	| result divisor |
	
	result := self deepCopy.
	( aDivisor isKindOf: HumMeasure )
		ifTrue: [divisor := aDivisor].
	( aDivisor isKindOf: Duration )
		ifTrue: [divisor := HumMeasure quantity: (aDivisor asSeconds) units: #second. ].
	( aDivisor isKindOf: Number )
		ifTrue: [ result quantity: (self quantity / aDivisor). ^ result. ].	
	"If the dimensions match, the result is a ratio. But we keep it as a HumMeasure to enable cascade."
	self assert: ( divisor isKindOf: HumMeasure ).	
	( divisor dimensions = self dimensions )
		ifTrue: [ result := HumMeasure new quantity: (self quantity) / (divisor quantity). ^result. ].		
	"Otherwise"		
	result quantity: (self quantity) / (divisor quantity).
	(divisor dimensions)
		keysAndValuesDo: [ :unit :exponent |
			"Decrement and net-out the dimensions."
			result incrementDimensionsAt: unit by: (exponent negated).
			].
	^result.	

]

{ #category : #arithmetic }
HumMeasure >> < operand [ 
	| result |
	"The units of measure must be the same."
	((operand dimensions) = (self dimensions)) ifFalse: [ Error signal: 'Given measures are not comparable.' ].
	
	result := (self quantity) < (operand quantity).
	^result.	

]

{ #category : #arithmetic }
HumMeasure >> = operand [ 
	| result calc q |
	( operand isKindOf: HumMeasure) ifFalse: [ ^false ].
	"The units of measure must be the same."
	((operand dimensions) = (self dimensions)) ifFalse: [^false].
	q := self quantity.
	calc := HumCalculator new.
	calc cases; 
		when: [ self units = 'radian' ] then: [ result := self compareAngle: operand ];
		when: [ q isKindOf: Float ] then: [ result := q closeTo: (operand quantity) ];
		when: [ q isKindOf: Integer ] then: [ result := (q asFloat) closeTo: (operand quantity) ];
		when: [ q isKindOf: Array ] 
			then: [ result := true.
				 (1 to: q size) 
						do: [ :i | 
							((q at: i) closeTo: ( operand quantity at: i ))
								ifFalse: [ ^false. ]
							].
				 ];
		otherwise: [ Error signal: 'quantity not of expected type.' ]	.
	^result.	

]

{ #category : #arithmetic }
HumMeasure >> > operand [ 
	| result |
	"The units of measure must be the same."
	((operand dimensions) = (self dimensions)) ifFalse: [^false].
	
	result := (self quantity) > (operand quantity).
	^result.	

]

{ #category : #arithmetic }
HumMeasure >> @ aHumMeasure [ 
	| point x y |
	self assert: (self units = #px)  description: 'Operator only valid for pixels.'.
	self assert: (aHumMeasure units = #px)  description: 'Operator only valid for pixels.'.
	x := self quantity.
	y := aHumMeasure quantity.
	self assert: (x isKindOf: Integer).
	self assert: (y isKindOf: Integer).
	point := x@y.
	^point.
	
]

{ #category : #arithmetic }
HumMeasure >> abs [
	| measure |
	measure := self copy.
	measure quantity: (quantity abs).
	^measure.
]

{ #category : #'as yet unclassified' }
HumMeasure >> adaptToCollection: aCollection andSend: aSymbol [ 
	| resultingCollection |
	Error signal: 'How did we get here?'.
	resultingCollection := OrderedCollection new.
	aCollection do: [ :each | resultingCollection add: (each perform: aSymbol with: self) ].
	^resultingCollection.
]

{ #category : #arithmetic }
HumMeasure >> arcTan: aDenominator [ 
	"Return the arc-tangent (angle) for self divided by aDenominator"
	| angle |
	self assert: (aDenominator isKindOf: HumMeasure).
	self assert: ( self units ) = ( aDenominator units ).
	
	angle := ( self quantity ) arcTan: ( aDenominator quantity ).
	^angle.
]

{ #category : #converting }
HumMeasure >> as: aSymbol [
	"Convert to the unit of measure indicated by aSymbol, and renders as String"
	| result qty divisor string displayUnits calc |
	divisor := 1.0 perform: aSymbol.
	self assert: (self dimensions) = (divisor dimensions).
	result := self / divisor.
	qty := result quantity.
	displayUnits := aSymbol asString.
	calc := HumCalculator new.
	calc cases;
		when: [(qty abs) between: 0.1 and: 99999.0 ] then: [  string := ( ( qty printShowingDecimalPlaces: 3), ' ', displayUnits ) ];
		when: [(qty abs) between: 0.01 and: 0.1 ] then: [  string := ( ( qty printShowingDecimalPlaces: 4), ' ', displayUnits ) ];
		otherwise: [ string := ( ( qty asString                    ), ' ', displayUnits )].

	^string.
]

{ #category : #convert }
HumMeasure >> asFloat [
	| q |
	q := self quantity asFloat.
	self assert: (q isKindOf: Float).
	^q.
]

{ #category : #converting }
HumMeasure >> asMillimeter [
	"Convert pixel dimensions to millimeter dimensions"
	| px result debug |
	(self units = 'meter') ifTrue: [ ^self ].
	self assert: (self units = 'px') description: 'This method is dedicated to converting pixel dimensions into millimeters'.
	px := (1.0 / (self class pxPerMillimeter)) millimeter.  "There are about 5 px per mm on my laptop."
	 "For convenience while debugging. Enlarge those pixels?"
	(debug := true ) ifTrue: [ px := 1 millimeter.  ].
	result := px * (self quantity).
	self assert: ( result isKindOf: HumMeasure ).
	^result.
]

{ #category : #converting }
HumMeasure >> asMillimeters [
	^self asMillimeter.
]

{ #category : #converting }
HumMeasure >> asPercent [
	| measure |
	"This is valid only if given measure is dimensionless."
	self assert: (self isDimensionless).
	measure := HumMeasure quantity: (self quantity / 0.01) units: '%'.
	"For this to be useful, 
	the caller needs to define what 100 percent means 
	with something like:
	windowWidth := (1600 px)/(100 percent)."
	"TODO: Consider simply returning a scalar: (^self * 0.01)"
	^measure.
]

{ #category : #'user interface' }
HumMeasure >> asString [
	| result  |
	result := self quantityAsString, ' ', self displayUnits.
	^result.
]

{ #category : #arithmetic }
HumMeasure >> compareAngle: aRadianMeasure [
	"Handle special arithmetic for comparing angles."
	| thisAngle thatAngle result |
	thisAngle := self quantity.
	thatAngle := aRadianMeasure quantity.
	result := true.
	( (thisAngle sin) closeTo: (thatAngle sin) ) ifFalse: [ result := false ].	
	( (thisAngle cos) closeTo: (thatAngle cos) ) ifFalse: [ result := false ].
	^result.
]

{ #category : #arithmetic }
HumMeasure >> cos [
	self assert: (self isRadian).
	^ quantity cos.
]

{ #category : #arithmetic }
HumMeasure >> cubed [
	| x  result |
	x := self.
	result := x * x * x.
	^result.
]

{ #category : #accessing }
HumMeasure >> dimensions [
	"Tracks units and powers of units -- "
	^ dimensions ifNil: [ dimensions := Dictionary new.]
]

{ #category : #accessing }
HumMeasure >> dimensions: aDictionary [ 
	| calc |
	calc := HumCalculator new.
	calc cases;
		when: [ aDictionary isKindOf: Dictionary ] then: [ dimensions := aDictionary copy ];
		when: [ aDictionary isKindOf: Array ] 
			then: [ dimensions := Dictionary new.
				 aDictionary do: [ :map |  
					 
					 dimensions at: (map key asSymbol) put: (map value)
					]. 
				];
		otherwise:	[ Error signal: 'dimensions should be dictionary-like' ].
]

{ #category : #'user interface' }
HumMeasure >> displayUnits [
	| displayUnits |
	displayUnits := (self units).
	(self dimensions = (Dictionary newFrom: {'kilogram'->1. 'meter'->1. 'second'->(-2).}) )	
		ifTrue: [displayUnits := 'Newton'].
	(self dimensions = (Dictionary newFrom: {'kilogram'->1. 'meter'->(-1). 'second'->(-2).}) )	
		ifTrue: [displayUnits := 'Pascal'].
	(self dimensions = (Dictionary newFrom: {'kilogram'->1. 'meter'->2. 'second'->(-2).}) )
		ifTrue: [displayUnits := 'Joule'].
	(self dimensions = (Dictionary newFrom: {'kilogram'->1. 'meter'->2. 'second'->(-3).}) )
		ifTrue: [displayUnits := 'Watt'].
	(self dimensions = (Dictionary newFrom: {'pound'->1. 'foot'->1. 'second'->(-1).}) )
		ifTrue: [displayUnits := 'foot pound per second'].
	(self dimensions = (Dictionary newFrom: {'pound'->1. 'foot'->1.}) )
		ifTrue: [displayUnits := 'foot pound'].
	^displayUnits.

]

{ #category : #arithmetic }
HumMeasure >> incrementDimensionsAt: aUnit by: anIncrement [
	"Increment / Decrement dimension exponent by given increment (negative when decrementing).
	"
	| x |
	self assert: (anIncrement isKindOf: SmallInteger ).
	x := (self dimensions) at: aUnit ifAbsent: [0].
	"Remove zeroed dimensions."
	"TODO: THINK: This discards potentially useful information."
	" e.g. meter^0 indicates scale or stress or coeficient of expansion ... " 
	(( x + anIncrement ) = 0 )
				ifTrue:  [ (self dimensions) removeKey: aUnit ]  
				ifFalse: [ (self dimensions) at: aUnit put: ( x + anIncrement )].
				
	"TODO: When units cancel (e.g. length/length), find some way to preserve information.
	Example: L^0 Degree^-1 should find L^1 Degree^1 in a multiplier. 
	Note: The result is the same either way. 
	On reflection, I probably allowed units to disappear 
	so that dimensions interpreted as Energy would be easier to recognize.
	"
	
]

{ #category : #testing }
HumMeasure >> isDimensionless [
	"Is the current measure dimensionless?"
	| result |
	result := self dimensions = (Dictionary new).
]

{ #category : #testing }
HumMeasure >> isPixels [
	| result |
	result := (self units) = 'px'.
	^result.
]

{ #category : #testing }
HumMeasure >> isRadian [
	| result |
	result := (self units) = 'radian'.
	^result.
]

{ #category : #arithmetic }
HumMeasure >> negated [
	| result |
	result := self deepCopy.
	result quantity: (self quantity) negated.
	^result.
]

{ #category : #'user interface' }
HumMeasure >> printOn: aStream [
	"Append to the argument, aStream, a sequence of characters that  
	identifies the receiver."

	| title |
	title := self class name.
	aStream
		nextPutAll: title;
		nextPutAll: ( '( ', (self asString), ' )' ).
]

{ #category : #accessing }
HumMeasure >> quantity [
	"Return the quantity that was observed for this instance."
	| |
	"Raise an error if caller attempts to access without a previous set."
	^ quantity ifNil: [ Error signal: 'measure quantity not set.' ].
]

{ #category : #accessing }
HumMeasure >> quantity: aNumber [ 
	quantity := aNumber
]

{ #category : #accessing }
HumMeasure >> quantity: aNumber per: denominatorUnits [
	"Set instance denominator units.
	 Use this method when the quantity is something like coefficient of expansion.
	 coefficient := HumMeasure quantity: 6.5e-6 per: #degreeCentigrade.
	"
	| exponent standardName numeratorExponent |
	quantity := aNumber.
	
	exponent := -1.
	(denominatorUnits beginsWith: 'square' ) ifTrue: [ exponent := -2 ].
	(denominatorUnits beginsWith: 'cubic' ) ifTrue: [ exponent := -3 ].
	standardName := self standardNameFor: denominatorUnits.
	(self dimensions) at: standardName put: exponent.
	 
	 
]

{ #category : #accessing }
HumMeasure >> quantity: aNumber units: numeratorUnits [ 
	"Set instance numerator units
	"
	|  exponent |
	quantity := aNumber.
	
	( numeratorUnits asString = 'none' ) ifTrue: [  ^self ]. "Dimensionless measure."
	
	exponent := 1.
	(numeratorUnits beginsWith: 'square' ) ifTrue: [ exponent := 2 ].
	(numeratorUnits beginsWith: 'cubic' ) ifTrue: [ exponent := 3 ].

	(self dimensions) at: (self standardNameFor: numeratorUnits ) put: ( exponent ).
	 
	 
]

{ #category : #accessing }
HumMeasure >> quantity: aNumber units: numeratorUnits per: denominatorUnits [
	"Set instance numerator and denominator units.
	Example1:
	   milesPerHour := HumMeasure2 quantity: 65 units: 'miles' per: 'hour'.
	   feetPerMile := HumMeasure2 quantity: 5280 units: 'feet' per: 'mile'.
	   feetPerHour := milesPerHour * feetPerMile.
		 secondsPerHour := HumMeasure2 quantity: 3600 units: 'seconds' per: 'hour'.
		 feetPerSecond := feetPerHour / secondsPerHour.
	"
	| exponent standardName numeratorExponent |
	quantity := aNumber.
	exponent := 1.
	(numeratorUnits beginsWith: 'square' ) ifTrue: [ exponent := 2 ].
	(numeratorUnits beginsWith: 'cubic' ) ifTrue: [ exponent := 3 ].
	(self dimensions) at: (self standardNameFor: numeratorUnits) put: ( exponent ).
	
	exponent := -1.
	(denominatorUnits beginsWith: 'square' ) ifTrue: [ exponent := -2 ].
	(denominatorUnits beginsWith: 'cubic' ) ifTrue: [ exponent := -3 ].
	standardName := self standardNameFor: denominatorUnits.
	"Get matching numerator exponent, if any, so that we correctly handle ratios 
	 such as 'length per length' and 'dollars per dollar' "
	numeratorExponent := (self dimensions) at: standardName ifAbsent: [0].
	(self dimensions) at: standardName put: ( numeratorExponent + exponent ).
	 
	 
]

{ #category : #'user interface' }
HumMeasure >> quantityAsString [
	"Return the quantity that was observed for this instance."
	| result |
	result := self quantityAsString: (self quantity).
	^result.
]

{ #category : #'user interface' }
HumMeasure >> quantityAsString: q [
	"Return the quantity that was observed for this instance."
	 | result |
		self assert: (q isKindOf: Number).
		( q = (q truncated) ) 
		ifTrue:[ result := ((q truncated) asString). 	
					  ^result. 
					 ].
	((q abs) between: 0.001 and: 99999.0 )
		ifTrue:  [ result := ( ( q printShowingDecimalPlaces: 3) )  ]
		ifFalse: [ result := ( ( q asString                    ) )  ].
	^result.
]

{ #category : #arithmetic }
HumMeasure >> sin [
	self assert: (self isRadian).
	^ quantity sin.
]

{ #category : #arithmetic }
HumMeasure >> sqrt [
	| instance |
	instance := HumMeasure new.
	instance quantity: (self quantity sqrt).
	(self dimensions) 
		keysAndValuesDo:  [ :dimension :exponent | 
			(instance dimensions) at: dimension put: (exponent/2). 
			].
	^instance.
]

{ #category : #'user interface' }
HumMeasure >> standardNameFor: aString [ 
	"Fix up names of units to assure consistency."
	| unitsString |
	unitsString := aString asString trimBoth.
	"Remove square- cubic-"
	(unitsString beginsWith: 'square' ) ifTrue: [ unitsString := unitsString copyReplaceTokens: 'square' with: ''].
	(unitsString beginsWith: 'cubic' ) ifTrue: [ unitsString := unitsString copyReplaceTokens: 'cubic' with: ''].
	unitsString := unitsString trimBoth.
	"Standardize terms"

	unitsString := (self unitsSynonyms) at: unitsString ifAbsent: [ unitsString ].
	
	
	self assert: ( unitsString endsWith: 's' ) not.
	^unitsString.
]

{ #category : #converting }
HumMeasure >> units [
	"Render dimensions as a string"
	| string append prefix  secondPassNeeded |
	append := Dictionary new.
	append 
		at: 2 put: 'square ';
		at: 3 put: 'cubic '.
	string := String new.
	secondPassNeeded := false.
	(self dimensions)
		keysAndValuesDo: [ :unit :exponent |
					( exponent > 0 ) 
						ifTrue: [ 
							prefix := append at: exponent ifAbsent: [''].
							string := string, prefix, unit, ' '.		
							]
						ifFalse: [ (exponent < 0 ) ifTrue: [ secondPassNeeded := true ] ].
					].
	secondPassNeeded 
		ifTrue: [ 
			string := string, 'per '.
			(self dimensions)
				keysAndValuesDo: [ :unit :exponent |
					( exponent < 0 ) 
						ifTrue: [ 
							prefix := append at: (exponent negated) ifAbsent: [''].
							string := string, prefix, unit, ' '.		
							]
					].
			].	
	^string trimBoth.
	
]

{ #category : #accessing }
HumMeasure >> unitsSynonyms [
	^ self class unitsSynonyms
]
