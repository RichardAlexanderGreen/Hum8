Class {
	#name : #HumViewPortMorph,
	#superclass : #AlphaImageMorph,
	#instVars : [
		'viewPort'
	],
	#category : #'Hum-UI'
}

{ #category : #access }
HumViewPortMorph >> camera [
	| camera |
	camera := self viewPort camera.
	^camera.
]

{ #category : #'event handling' }
HumViewPortMorph >> handleKeystroke: anEvent [
	| keyValue keyCharacter calc dJump |
	self assert: ( anEvent isKindOf: KeyboardEvent ).
	dJump := 1 meter.
	calc := HumCalculator new.
	keyValue := anEvent keyValue.
	keyCharacter := anEvent keyCharacter. 
	calc cases;
		when: [ keyCharacter asLowercase  = $q  ] then: [ self delete ];
		when: [ keyCharacter asLowercase = $f ] then: [ self camera slideForward: dJump ];
		when: [ keyCharacter asLowercase = $b ] then: [ self camera slideBackward: dJump ];
		when: [ keyCharacter asLowercase = $l ] then: [ self camera slideLeft: dJump ];
		when: [ keyCharacter asLowercase = $r ] then: [ self camera slideRight: dJump ];
		
		when: [ anEvent commandKeyPressed ] 
			then: [ | calc2 dTilt newTilt |
				dTilt := (5 degrees). 
				newTilt := (self camera tilt) + (5 degreesToRadians).
				calc2 := HumCalculator new.
				calc2 cases;
					when: [ keyValue = 30 "arrowUp" ] 		then: [ self camera tiltUp: dTilt ];  			"Pitch up."
					when: [ keyValue = 31 "arrowDown" ] 	then: [ self camera tiltDown: dTilt ];
					when: [ keyValue = 28 "arrowLeft" ] 		then: [ self camera rotateLeft: dTilt ];		"Yaw to the left."
					when: [ keyValue = 29 "arrowRight" ] 	then: [ self camera rotateRight: dTilt ];
					"TODO: Add ability to roll the camera."
					otherwise: [ Transcript cr; show: anEvent keyString, ' keyValue not handled.' ].
				];
		when: [ keyValue = 30 "arrowUp" ] 		then: [ self camera slideUp: dJump ];
		when: [ keyValue = 31 "arrowDown" ] 	then: [ self camera slideDown: dJump ];
		when: [ keyValue = 28 "arrowLeft" ] 		then: [ self camera slideLeft: dJump ];
		when: [ keyValue = 29 "arrowRight" ] 	then: [ self camera slideRight: dJump ];		
		otherwise: [ Transcript cr; show: anEvent keyString, ' keyValue not handled.' ].
	self changed.
]

{ #category : #'event handling' }
HumViewPortMorph >> handlesMouseOver: evt [
	^true.
]

{ #category : #'event handling' }
HumViewPortMorph >> mouseEnter: anEvent [
	anEvent hand newKeyboardFocus: self.
]

{ #category : #'event handling' }
HumViewPortMorph >> mouseLeave: anEvent [
	anEvent hand newKeyboardFocus: nil.
]

{ #category : #access }
HumViewPortMorph >> viewPort [
	^ viewPort
]

{ #category : #access }
HumViewPortMorph >> viewPort: aHumViewPort [ 
	viewPort := aHumViewPort.
]
