"
The bookkeeper records resource utilization and expenditure statistics.
It provides the basic data needed for cost accounting and system utilization analysis.

Instance Variables:
	jobTickets	<OrderedCollection>
"
Class {
	#name : #HumBookkeeper,
	#superclass : #HumActor,
	#instVars : [
		'jobTickets'
	],
	#category : #'Hum-RunTime'
}

{ #category : #sums }
HumBookkeeper >> chargesBy: attribute [
	"Produce dictionary of sums for given subdivision type."
	| sums |
	sums := Dictionary new.
	jobTickets 
		do: [ :ticket |
			| charges |
			charges := ticket charges.
			
			charges do: [:charge |
				| key sumBy units amount x |
				amount := charge at: 'measure'.
				sumBy := charge at: attribute.
				units := amount units.
				key := sumBy,':',units.
				x := sums at: key 
				    ifAbsent: [ |q| q := amount copy quantity: 0. q].
				x := x + amount.
				sums at: key put: x.
				].
			].
		^sums.
]

{ #category : #sums }
HumBookkeeper >> chargesByAction [
	"Produce dictionary of sums keyed by action."
	| sums |
	sums := self chargesBy: 'action'.
	^sums.
]

{ #category : #sums }
HumBookkeeper >> chargesByActor [
	"Produce dictionary of sums keyed by actor."
	| sums |
	sums := self chargesBy: 'ID'.
		^sums.
]

{ #category : #sums }
HumBookkeeper >> chargesByJob [
	"Produce dictionary of sums keyed by job."
	| sums |
	sums := self chargesBy: 'job'.
	^sums.
]

{ #category : #sums }
HumBookkeeper >> chargesByMetric [
	"Produce dictionary of sums keyed by unit of measure. "
	| sums |
	sums := Dictionary new.
	jobTickets 
		do: [ :ticket |
			| charges |
			charges := ticket charges.
			charges do: [:charge |
				| key sumBy units amount x |
				amount := charge at: 'measure'.
				units := amount units.
				sumBy := 'total'.
				key := sumBy,':',units.
				x := sums at: key 
				    ifAbsent: [ |q| q := amount copy quantity: 0. q].
				x := x + amount.
				sums at: key put: x.
				].
			].
		^sums.
]

{ #category : #sums }
HumBookkeeper >> chargesByRole [
	"Produce dictionary of sums keyed by role-name.."
	| sums |
	sums := self chargesBy: 'role'.
	^sums.
]

{ #category : #accessing }
HumBookkeeper >> jobTickets [
	^ jobTickets ifNil: [ jobTickets := OrderedCollection new. ].
]

{ #category : #accessing }
HumBookkeeper >> recordJobTicket: aHumJobTicket [ 
	"Add the given job ticket to my collection of job tickets."
	(self jobTickets) add: aHumJobTicket.
]
