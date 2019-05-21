"
Turtle commands are mostly relative to the current position and direction.

The initial turtle position is at origin 0@0 
facing North - turtle heading: 0 degrees.

tail = #up means no paint, otherwise lines are drawn with tailColor.


"
Class {
	#name : #HumTurtle,
	#superclass : #HumCanvas,
	#instVars : [
		'position',
		'heading',
		'speed',
		'tail',
		'tailColor'
	],
	#category : #'Hum-UI'
}

{ #category : #commands }
HumTurtle >> headEast [
	self heading: (90 degrees).
]

{ #category : #commands }
HumTurtle >> headNorth [
	self heading: (0 degrees).
]

{ #category : #commands }
HumTurtle >> headSouth [
	self heading: (180 degrees).
]

{ #category : #commands }
HumTurtle >> headWest [
	self heading: (-90 degrees).
]

{ #category : #access }
HumTurtle >> heading [
	^heading ifNil: [ heading := (0 degrees) ].
]

{ #category : #access }
HumTurtle >> heading: compassHeading [
	"North is 0 degrees. East is 90 degrees. West is minus 90. South is 180."
	self assert: ( compassHeading isKindOf: HumMeasure ).
	heading := compassHeading.
]

{ #category : #access }
HumTurtle >> initialize [
	"The initial turtle position is at origin (0@0) facing North."
	|   |
	self assert: self position = (0.0@0.0).
	self assert: self heading = (0 degrees).
	"The distance per step is the speed."
	self assert: self speed = 1.0. 
	"Tail is up - so the turtle is not painting."
	self assert: self tail = #up.
	self assert: self tailColor = (Color black).
	
]

{ #category : #access }
HumTurtle >> position [
	^ position ifNil: [ position := 0.0@0.0. ]
]

{ #category : #access }
HumTurtle >> position: aPoint [
	"Move turtle to aPoint without painting."
	position := aPoint.
	self moveBrushTo: aPoint.
]

{ #category : #access }
HumTurtle >> speed [
	"Distance traveled on each step."
	^ speed ifNil: [ speed := 1.0 ]
]

{ #category : #access }
HumTurtle >> speed: aFloat [
	"Distance traveled on each step."
	speed := aFloat
]

{ #category : #commands }
HumTurtle >> step [
	"Move forward one step"
	| newPosition stepVector stepX stepY |
	stepX := speed * ( heading  sin ).
	stepY := speed * ( heading  cos ).
	stepVector := stepX @ stepY.
	newPosition := position + stepVector.
	"Paint using super methods"
	( tail = #up )
		ifTrue: [ self moveBrushTo: newPosition ]
		ifFalse: [ self paintTo: newPosition ].
	"Update position"
	position := newPosition.
	
]

{ #category : #access }
HumTurtle >> tail [
	^ tail ifNil: [ tail := #up ].
]

{ #category : #access }
HumTurtle >> tail: aSymbol [
	"tail = #up means no paint, otherwise lines are drawn with tailColor."
	tail := aSymbol.
	
]

{ #category : #access }
HumTurtle >> tailColor [
	"What color am I painting at this time?"
	^ self brushColor. 	"Note: I am a subclass of HumCanvas."
]

{ #category : #access }
HumTurtle >> tailColor: aColor [
	"What color am I painting at this time?"
	^ self brushColor: aColor. 	 "Note: I am a subclass of HumCanvas."
]

{ #category : #commands }
HumTurtle >> turn: degreeIncrement [
	"Change heading by given amount."
	| newHeading |
	self assert: ( degreeIncrement isKindOf: HumMeasure ).
	newHeading := heading + degreeIncrement.
	self heading: newHeading.
	
]

{ #category : #commands }
HumTurtle >> turnLeft [
	self turn: (90.0 degrees) negated.
]

{ #category : #commands }
HumTurtle >> turnRight [
	self turn: (90.0 degrees).
]
