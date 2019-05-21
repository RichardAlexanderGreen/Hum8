"
Deliberately removed from test sets.
"
Class {
	#name : #HTimeTests,
	#superclass : #Object,
	#category : #'Hum-X'
}

{ #category : #'as yet unclassified' }
HTimeTests >> test110timestampIsBigInteger [
	""
	| t |
	t := HTime timeStamp.
	self assert: ( t isKindOf: Integer ).
]

{ #category : #'as yet unclassified' }
HTimeTests >> test120timestampIsUnique [
	""
	| a  n |
	n := 1e4. 
	"n = 1e4 resembles a database transaction rate.
	 n = 1e5 runs in about 2 seconds. 
	     1e6 requires 20-25 seconds."
	a := Array new: n.
	( 1 to: n )
		do: [ :i | a at: i put: (HTime timeStamp) ].
	self assert: (( a at: 1 ) < ( a at: 2 )).	
	self assert: (( a at: 1 ) < ( a atRandom )) description: 'Can trip if atRandom happens to pull (a at: 1)'.
	self assert: (( a at: 1 ) < ( a at: n )).
]
