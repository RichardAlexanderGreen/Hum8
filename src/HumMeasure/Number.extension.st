Extension { #name : #Number }

{ #category : #'*HumMeasure' }
Number >> acre [
	"Historically, a 'perfect acre' is 660 feet by 66 feet 
	- amount of land that can be plowed in a day using a yoke of oxen.
	Note: There are 640 acres in a square mile."
	| measure |
	measure := ( self * 43560 ) squareFeet.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> amu [
	" atomic mass unit "
	| m |
	m := self atomicMassUnit.
	^m
]

{ #category : #'*HumMeasure' }
Number >> astronomicalUnit [
	"average distance between Earth and Sun"
	| measure |
	measure :=   (self * 149597870700 ) meter.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> atmosphere [
	"Standard atmospheric pressure pressure = 101325 pascal = 101.325 kPa"
	^ (self * 101325.0) pascal
]

{ #category : #'*HumMeasure' }
Number >> atomicMassUnit [
	" atomic mass unit "
	| m |
	m := HumMeasure new.
	m quantity: (self * 1.66053873e-27) units: #kilogram.
	^m.
]

{ #category : #'*HumMeasure' }
Number >> au [
	"astronomical units"
	| measure |
	measure := self astronomicalUnit.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> avogadro [
	"Avogadro`s number is something per mole.
	- So we return it as a number rather than a Measure."
   ^HumMeasure quantity: (self * 6.0221413e23) per: #mole.
]

{ #category : #'*HumMeasure' }
Number >> bar [
	"1 barr = 100 kPa  (slightly less than one standard atmospher 101325)"
	^(self * 100) kPa.
]

{ #category : #'*HumMeasure' }
Number >> britishThermalUnit [
	"Energy - British Thermal Unit (ISO)"
	| measure |
	measure := HumMeasure quantity: ( self * 1.0545) units: #joule.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> btu [
	"Energy - British Thermal Unit (ISO)"
	| measure |
	measure := self britishThermalUnit.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> centi [
	^ self / 100.0.
]

{ #category : #'*HumMeasure' }
Number >> centimeter [
	| measure |
	measure := HumMeasure quantity: ( self / 100.0 ) units: #meter.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> cosmicConstant [
	" on the order of 1e-29 grams / cubic centimeter "
	| m q kg g cubicCentimeter cubicMeter|
	kg := 1.
	g := 1.
	cubicCentimeter := 1.
	cubicMeter := 1.
	q := 1.0e-29 * ( 1 * kg / 1000 * g ) * ( 1e6 * cubicCentimeter / 1* cubicMeter ).
	self assert: (q closeTo: 1.0e-26).
	m := HumMeasure quantity: (self * 1.0e-26) units: #kilogram per: 'cubic meter'.
	^m.
]

{ #category : #'*HumMeasure' }
Number >> cosmicScale [
	"on the order of 10e25 meters"
	| m |
	m := HumMeasure quantity: (self * 1.0e25) units: #meter.
	^m.
]

{ #category : #'*HumMeasure' }
Number >> cubicCentimeter [
	| edge cube measure |
	edge := 1.0 centimeter.
	cube := edge * edge * edge.
	measure := cube * self.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> cubicFoot [
	| edge cube measure |
	edge := 1.0 foot.
	cube := edge * edge * edge.
	measure := cube * self.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> cubicInch [
	| edge cube measure |
	edge := 1.0 inch.
	cube := edge * edge * edge.
	measure := cube * self.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> cubicMeter [
	| edge cube measure |
	edge := 1.0 meter.
	cube := edge * edge * edge.
	measure := cube * self.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> deci [
	^ self / 10.0.
]

{ #category : #'*HumMeasure' }
Number >> degree [
	"Return as a HumMeasure - angular degree ==> radian is SI unit for angles "
	"See also degreeCentigrade, degreeKelvin, degreeFahrenheit"
	| measure |
	measure :=  ((self * (Float pi)) / 180.0) radian.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> degreeCentigrade [
	"return as a HumMeasure"
	| measure |
	measure := (self + 273.15) degreeKelvin.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> degreeFahrenheit [
	"return as a HumMeasure"
	| measure |
	measure := ( ( self - 32.0 ) / 1.8 ) degreeCentigrade.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> degreeKelvin [
	"return as a HumMeasure"
	| measure |
	measure := HumMeasure quantity: (self) units: #degreeKelvin.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> degrees [
	"return as a HumMeasure - angular degree "
	| measure |
	measure := self degree.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> dyne [
	"force"
	| measure |
	measure := HumMeasure quantity: ( self * 1e-5 ) units: #newton.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> electronVolt. [
	"electron volt"
	^ (self * 1.60217657e-19) joule.
	
]

{ #category : #'*HumMeasure' }
Number >> erg [
	| measure |
	measure := HumMeasure quantity: ( self * 1e-7 ) units: #joule.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> ev [
	"electron volt"
	^ self electronVolt.
	
]

{ #category : #'*HumMeasure' }
Number >> feet [
	| measure |
	measure := self foot.
	^ measure.
]

{ #category : #'*HumMeasure' }
Number >> foot [
	| measure |
	measure := HumMeasure quantity: (self * 0.304799735) units: #meter.
	^ measure.
]

{ #category : #'*HumMeasure' }
Number >> footH2O [
	"foot of water - pressure"
	| measure |
	measure := HumMeasure quantity: ( self * 2.98898e3 ) units: #pascal.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> giga [
	^ self * 1e9.
]

{ #category : #'*HumMeasure' }
Number >> gigaHertz [
	| measure |
	measure := HumMeasure quantity: (self * 1e9) per: #second.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> gigajoule [
	
	^( self * 1e9) joule.
]

{ #category : #'*HumMeasure' }
Number >> gram [
	| measure |
	measure := (self / 1000.0 ) kilogram.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> gravitationalConstant [   
	"6.67428e-11 m^3 kg^-1 s^-2  plusOrMinus: (1e-11)/(1e5) - source: 'PhysicalConstants.pdf' in my eBooks"
	| bigG |
	bigG := HumMeasure new.
	bigG 
		quantity: 6.67428e-11; 
		dimensions: (Dictionary newFrom: { #meter -> 3. #kilogram -> -1.  #second -> -2. }).
	^bigG. 
]

{ #category : #'*HumMeasure' }
Number >> gravity [
	| measure |
	measure := HumMeasure quantity: (self * 9.80665) units: 'meter' per: 'square second'.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> hectare [
	"area equivalent to 100 meter by 100 meter = 10 thousand square meters"
	| measure oneHectare |
	oneHectare := ( 10e3 squareMeter ).
	measure := oneHectare * self.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> hertz [
	"frequency = x per second"
	| measure |
	measure := HumMeasure new.
	measure
		quantity: (self);
		dimensions: { #second -> -1. }.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> horsePower [
	| measure |
	measure := HumMeasure quantity: ( self * 735.49875 ) units: #watt.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> hp [
	"horse-power"
	| measure |
	measure := self horsePower.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> inch [
	| measure |
	measure := (self * 0.0254) meter.
	^ measure.
]

{ #category : #'*HumMeasure' }
Number >> inches [
	| measure |
	measure := self inch.
	^ measure.
]

{ #category : #'*HumMeasure' }
Number >> joule [
	"Energy or Work equal to 1 Newton-meter"
	| measure |
	measure := HumMeasure joule: self.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> kPa [
	| m |
	m :=  (self * 1000) pascal.
	^m.
]

{ #category : #'*HumMeasure' }
Number >> kg [
	| m |
	m := self kilogram.
	^m.
]

{ #category : #'*HumMeasure' }
Number >> kilo [
	^ self * 1000.
]

{ #category : #'*HumMeasure' }
Number >> kilogram [
	| m |
	m := HumMeasure new.
	m quantity: (self) units: #kilogram.
	^m.
]

{ #category : #'*HumMeasure' }
Number >> kilometer [
	| m |
	m :=  (self * 1000) meter.
	^m.
]

{ #category : #'*HumMeasure' }
Number >> kilometerPerSecond [
	"kilometers per second"
	| measure |
	measure := HumMeasure quantity: (self * 1000) units: 'meter' per: 'second'.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> kilometers [
	| m |
	m := self kilometer.
	^m.
]

{ #category : #'*HumMeasure' }
Number >> kilowatt [
	| measure |
	measure := (self * 1000) watt.
	^measure
]

{ #category : #'*HumMeasure' }
Number >> km [
	^ self kilometer.
]

{ #category : #'*HumMeasure' }
Number >> knots [
	"Nautical miles (ISO) = 1852 meter by definition, approximately 6076 feet"
	| measure |
	measure := HumMeasure quantity: (self * 1852.0) units: #meter.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> kps [
	"kilometers per second"
	| measure |
	measure := self kilometerPerSecond.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> lbf [
	"pound force"
	"See also: pound mass ==> Number>>pound"
	| measure |
	measure := HumMeasure quantity: ( self * 4.448222 ) units: #newton.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> lightSecond [
	"Distance a photon travels in one second (in vacuum)."
	| measure |
	measure := HumMeasure quantity: (self * 2.99792458e8) units: #meter.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> lightSpeed [
	"Speed of light"
	| measure |
	measure := HumMeasure quantity: (self * 2.99792458e8) units: #meter per: #second.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> lightYear [
	"Distance a photon travels in one year."
	| measure |
	measure := HumMeasure quantity: (self * 9.4607304725808e15) units: #meter.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> litre [
	| measure |
	measure := HumMeasure quantity: (self * 0.001) units: 'cubic meter'.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> mega [
	^ self * 1e6.
]

{ #category : #'*HumMeasure' }
Number >> megaWatt [
	"one million watts"
	^ ( self * 1e6 ) watt.
]

{ #category : #'*HumMeasure' }
Number >> meter [
	| measure |
	measure := HumMeasure quantity: (self) units: #meter.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> meterPerSecond [
	"meter per second"
	| measure |
	measure := HumMeasure quantity: (self) units: 'meter' per: 'second'.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> meters [
	| measure |
	measure := self meter.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> mev [
	"MeV = 1 million electron volts"
	^ ( self * 1e6 ) electronVolt.
	
]

{ #category : #'*HumMeasure' }
Number >> micro [	
	^ self / 1e6.
]

{ #category : #'*HumMeasure' }
Number >> mile [
	"miles to meters"
	| measure |
	measure := 5280 feet. 
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> miles [
	| measure |
	measure := self mile.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> milesPerHour [
	"miles per hour - converted to meters per second"
	| measure factor |
	factor := (1 mile quantity)/3600.0.
	measure := HumMeasure quantity: ( self * factor ) units: 'meter' per: 'second'.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> milli [
	^ self / 1000.0.
]

{ #category : #'*HumMeasure' }
Number >> milligram [
	| measure |
	measure := (self / 1000.0 ) gram.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> millimeter [
	| measure |
	measure := HumMeasure quantity: ( self / 1000.0 ) units: #meter.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> mmHg [
	"millimeters of mercury - pressure"
	| measure |
	measure := HumMeasure quantity: ( self * 133.3224 ) units: #pascal.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> mph [
	"miles per hour - converted to meters per second"
	| measure factor |
	measure := self milesPerHour.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> mps [
	"meters per second"
	| measure |
	measure := self meterPerSecond.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> nano [
	^ self / 1e9.
]

{ #category : #'*HumMeasure' }
Number >> newton [
	"unit of force in Newtons -- 1 kg·m/s^2"
	| measure |
	measure := HumMeasure quantity: ( self ) units: #newton.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> parsec [
"Wikipedia: One parsec equals about 3.26 light-years or 30.9 trillion kilometres (19.2 trillion miles). 
All known stars (except the Sun) are more than one parsec away, 
with Proxima Centauri showing the largest parallax of 0.7687 arcsec, 
making the distance 1.3009 parsec (4.243 light years.)
[1] Most of the visible stars in the nighttime sky lie within 500 parsecs of the Sun.
(500 parsec as: #lightYear) ==> '1630.000 lightYear'
"
	| measure |
	measure := (self lightYear) * 3.26.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> pascal [
	"pressure - Pascal"
	| measure |
	measure := HumMeasure quantity: ( self ) units: #pascal.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> percent [
	"See NumberTest>>testPercent -- Do not override this method."
	^self / 100.
]

{ #category : #'*HumMeasure' }
Number >> peta [
	^ self * 1e15.
]

{ #category : #'*HumMeasure' }
Number >> pixel [
	"pixels"
	| measure |
	"Need to abbreviate because that is how SVG and HTML expects to see it."
	measure := HumMeasure quantity: self units: 'px'.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> planksConstant [
	"Planck's constant = h = 6.62606957 × 10-34 m2 kg / s  or (Joule * second)"
	| measure |
	measure := HumMeasure new.
	"measure
		quantity: 6.62606957e-34;
		dimensions: { #meter -> 2.  #kilogram -> 1.  #second -> -1.}."
	measure := ( ( self *6.62606957e-34 ) joule  ) * ( 1 second ).
	"(1 planksConstant dimensions) ==> a Dictionary('kilogram'->1 'meter'->2 'second'->-1 )"
	^measure
]

{ #category : #'*HumMeasure' }
Number >> pound [
	" pound mass 
	Note: lbf is pound force"
	| m |
	m := HumMeasure new.
	m quantity: (self * 0.45359237) units: #kilogram.
	^m.
]

{ #category : #'*HumMeasure' }
Number >> poundMass [
	" pound mass - lbm"
	| m |
	m := HumMeasure new.
	m quantity: (self * 0.45359237) units: #kilogram.
	^m.
]

{ #category : #'*HumMeasure' }
Number >> poundPerSquareInch [
	"pound per square inch - pressure"
	| measure |
	measure := HumMeasure quantity: ( self * 6.894757e3 ) units: #pascal.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> psi [
	"pound per square inch - pressure"
	| measure |
	measure := self poundPerSquareInch.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> px [
	"pixels"
	| measure |
	measure := self pixel.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> radian [
	"return as a HumMeasure - angular degree - radian is SI unit for angles "
	| measure |
	measure :=  HumMeasure quantity: self units: #radian.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> rpm [
	"Revolutions per minute ==> radians per second"
	| measure |
	measure := HumMeasure quantity: (  (self * (2.0* Float pi)) / 60.0  ) units: #radian per: #second.
	"60 rpm ==> HumMeasure( 6.283 radian per second )"
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> rps [
	"Revolutions per second ==> radians per second"
	| measure |
	measure := HumMeasure quantity: ( self * (2.0* Float pi) ) units: #radian per: #second.
	"1 rps ==> HumMeasure( 6.283 radian per second )"
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> screenInch [
	| measure |
	measure := HumMeasure quantity: self units: 'screenInch'.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> squareFeet [
	| edge square measure |
	edge := 1.0 foot.
	square := edge * edge.
	measure := square * self.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> squareFoot [
	| edge square measure |
	edge := 1.0 foot.
	square := edge * edge.
	measure := square * self.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> squareInch [
	| edge square measure |
	edge := 1.0 inch.
	square := edge * edge.
	measure := square * self.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> squareMeter [
	| edge square measure |
	edge := 1.0 meter.
	square := edge * edge.
	measure := square * self.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> sunMass [
	"Sun`s mass in kg"
	| mass |
	mass := 1.98855e30 kg.
	^mass.
]

{ #category : #'*HumMeasure' }
Number >> tera [
	^ self * 1e12.
]

{ #category : #'*HumMeasure' }
Number >> tonne [
	"metric ton -- as a mass"
	| m |
	m := HumMeasure new.
	m quantity: (self * 1000) units: #kilogram.
	"Note: The dimension here is mass, not weight. "
	^m.
]

{ #category : #'*HumMeasure' }
Number >> torr [
	"1 torr = 1/760 standard atmospheric pressure. 
	Standard atmospheric pressure pressure = 101325 pascal."
	^ (self atmosphere) / 760.
]

{ #category : #'*HumMeasure' }
Number >> watt [
	" 1 Joule per second := 1e7 erg per second"
	| measure |
	measure := (self joule) / (1 second).
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> yard [
	| measure |
	measure := HumMeasure quantity: (self * 0.9144) units: #meter.
	^measure.
]

{ #category : #'*HumMeasure' }
Number >> yards [
	| measure |
	measure := self yard.
	^measure.
]
