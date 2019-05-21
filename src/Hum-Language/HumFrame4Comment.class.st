"
A comment frame has no executable code. 
It is a place to put generic comment lines.
Comments that apply to a specific frame should be placed in that frame instead.
"
Class {
	#name : #HumFrame4Comment,
	#superclass : #HumFrame,
	#category : #'Hum-Language'
}

{ #category : #'as yet unclassified' }
HumFrame4Comment >> appendFrameLine: aLine [
	| frameLine calc | 
	calc := HumCalculator new.
	calc cases;
		when: [  aLine isKindOf: HumCommentLine ] then: [ frameLine := aLine ];
		when: [ aLine isKindOf: String ] then: [ frameLine := HumCommentLine new. frameLine source: aLine ];
		otherwise: [ Error signal: 'Comment value is not of expected type.' ].
	self assert: (frameLine isKindOf: HumCommentLine).
	self frameLines add: frameLine.
]
