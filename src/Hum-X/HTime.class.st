"
HTime is a singleton whose purpose is to return a unique time-stamp.
The time-stamp is monotonically increasing over time.

It is guranteed unique within the context where the singleton executes.

"
Class {
	#name : #HTime,
	#superclass : #Object,
	#classInstVars : [
		'clock'
	],
	#category : #'Hum-X'
}

{ #category : #accessing }
HTime class >> new [
	self shouldNotImplement.
]

{ #category : #accessing }
HTime class >> now [
	^ self timeStamp.
]

{ #category : #accessing }
HTime class >> reset [
	clock := 0.
]

{ #category : #accessing }
HTime class >> seconds [
	"Return number of seconds since beginning of epoc"
	| ticks tickDays tickSeconds seconds |
	DateAndTime now.
	ticks := DateAndTime now asUTC ticks copy.
	tickDays := ticks at: 1.
	tickSeconds := ticks at: 2.
	"
	tickNanos := ticks at: 3.
	self assert: (tickNanos = 0).
	"
	"WARNING: tickNanos is not really nano-seconds. 
	 The actual meaning depends on context.
	 Context = TimeStamp class and Operating System implementation."
	
	seconds := ( tickDays * 86400 ) + tickSeconds. 
	^seconds
]

{ #category : #accessing }
HTime class >> timeStamp [
	"Return a large positive integer representing the number of nanoseconds since ..."
	| priorClock microSeconds |
	priorClock := clock. "Clock is CLASS VARIABLE"
	microSeconds := 0. "Replace this if you find something that works."
	clock := ( ( self seconds ) * 1e6 ) + microSeconds. 
	[ clock <= priorClock ] 
		whileTrue: [ clock := priorClock + 1 ]. "We can get away with this because of nanos implementation."
	"If you tinker with this method, call (HTime reset) to reset clock to zero/nil."
	^clock.
 
]
