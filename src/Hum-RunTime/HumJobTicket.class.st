"
A job ticket records the resources consumed by a job.

A job is initiated when a goal is set running.
When actions are delegated by the one actor to other actors, they get jobtickets also.
The resulting resource data is consolidated on the parent-level job-tickets
so that the costs are rolled-up to each level and eventually to the job as a whole.

When each Action is completed, the Dispatcher reports new resource entries to the Bookkeeper.
Hence a running account is maintained for the job, for each resource, for each actor, for each role, for each action.
---
Dictionary: Job Vocabulary.
. Job attributes include goal-invocation, resource-usage.
. Goal-invocation attributes include invocation-event, goal.
. Resource-usage has a list of usage-notes.
. Usage-note attributes include resource, quantity-used, by-actor, in-role, performing-action.
---

Note that resource accounting only sums resource quantities.
It does not attempt to monetize (price) the resources used because that is a very specialized process.
For example, withdrawals from inventory might be priced using LIFO, FIFO, or some other accounting practice.

"
Class {
	#name : #HumJobTicket,
	#superclass : #HumEntity,
	#instVars : [
		'ontology',
		'charges'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'as yet unclassified' }
HumJobTicket class >> new [
	| instance |
	"Catch cases where instances are created without titles."
	self halt.
	instance := self basicNew.
	instance initialize.
	^instance
]

{ #category : #accessing }
HumJobTicket >> appendCharge: aHumMeasure forAction: action byActor: anID inRole: aRoleName onJob: aJobID [ 
	| charge debug |
	"Use a dictionary to represent a charge."
	
	charge := Dictionary new.
	charge 
		at: 'measure' put: aHumMeasure "asString";
		at: 'action'  put: action asString;
		at: 'ID'      put: anID asString;
		at: 'role'    put: aRoleName asString;
		at: 'job'     put: aJobID asString.

	debug := false. 
	debug 
		ifTrue: [ 
			Transcript cr.
			charge keysAndValuesDo: [:k :v | Transcript show: ' ',k,': ', v asString.]
			].
		
	"Append this charge to ticket`s charges."	
  ( self charges ) add: charge.
	
]

{ #category : #accessing }
HumJobTicket >> charges [
	^charges ifNil: [ charges := OrderedCollection new.]
]

{ #category : #accessing }
HumJobTicket >> getActionSequence [
	"Parse the job ticket to show the sequence of actions."
	| listOfActions |
	listOfActions := OrderedCollection new.
	self charges
		do:[:charge |
			listOfActions add: (charge at: 'action') source.
			].
	^listOfActions.
]

{ #category : #accessing }
HumJobTicket >> printOn: aStream [
	|  |
	
	aStream nextPutAll: ( 'Job:(',title asString,')' ).

]
