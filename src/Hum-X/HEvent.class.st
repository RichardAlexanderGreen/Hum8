"
a business event (not to be confused with a data event)	
Events serve as a kind of log. 
Events give data values a business (causality) context.
'	
	instance
		id: (HTime timeStamp); ""Unique identifier.""
		who: aWho;				""who is associated with the cause - e.g. client-id/actor-id""
		what: aWhat; 		""What is happening - e.g. Action statement""
		where: aWhere;  	""Where: a host""
		why: aWhy;				""Why: a job or seesion""
		when: aTimeStamp. ""Observer`s clock. May be simulator clock.""
'
Although data events may be the framework`s way of remembering/recording a business event,
the two concepts should not be confused.

In the run-time framework,
business-events are automatically recorded when:
- a post-condition is satisfied in a running plan.
- a client/user provides a value for a noun
- - via ""Ask view-name""
- - by matching parameters in a vignette pattern.
- an action procedure executes a 'giving' instruction. (Perhaps this should be limited in some way.)

Examples:
- Post-condition satisfied.
- - who: client-id  what: post-condition  where: host-URI  why: job-id (top-goal, client, authorization)
- Instruction giving persistent noun-value.
- - who: actor-id   what: instruction     where: host-URI  why: job-id
- Noun value entered.
- - who: client-id  what: vignette	where: host-URI  why: session-id 
- - who: client-id  what: view		where: host-URI  why: session-id 
 
"
Class {
	#name : #HEvent,
	#superclass : #HEntity,
	#instVars : [
		'who',
		'what',
		'where',
		'why',
		'when'
	],
	#category : #'Hum-X'
}

{ #category : #'instance creation' }
HEvent class >> who: aWho what: aWhat when: aTimeStamp where: aWhere why: aWhy [  
	| instance |
	instance := self basicNew.
	instance
		who: aWho;				"Who is associated with the event? - client-id/actor-id"
		what: aWhat; 			"What is happening? - statement / vignette / view"
		when: aTimeStamp; 	"Observer`s clock. May be simulator clock."
		where: aWhere;  		"Where? - a host-URI"
		why: aWhy;				"Why?   - a job ticket or session identifier"
		id: (HTime timeStamp). "Unique identifier for the event."
	^instance.

"
Examples:
- Post-condition satisfied.
- - who: client-id  what: post-condition  where: host-URI  why: job-id (top-goal, client, originating-session-id)
- Instruction giving persistent noun-value.
- - who: actor-id   what: instruction     where: host-URI  why: job-id
- Noun value/s entered.
- - who: client-id  what: vignette+pattern        where: host-URI  why: session-id 
- - who: client-id  what: vignette+view            where: host-URI  why: session-id 
See: Class documentation.
"
]

{ #category : #comparing }
HEvent >> > otherEvent [ 
	| result |
	result := (self when) > (otherEvent when).
	^result.
]

{ #category : #accessing }
HEvent >> attributes [
	| dict |
	dict := (super attributes).
	dict
		at: 'who' put: who;
		at: 'what' put: what;
		at: 'when' put: when;
		at: 'where' put: where;
		at: 'why' put: why.

]

{ #category : #accessing }
HEvent >> id: aLargePositiveInteger [ 
	id := aLargePositiveInteger.
]

{ #category : #accessing }
HEvent >> what: aWhat [ 
	"What happened? (Relate to business process event.)"
	what := aWhat.
]

{ #category : #accessing }
HEvent >> when [
	^ when
]

{ #category : #accessing }
HEvent >> when: aTimeStamp [ 
	"When did the event occur? Real clock or simulated clock"
	when := aTimeStamp
]

{ #category : #accessing }
HEvent >> where: aWhere [ 
	"Where did event occur? - Test/Simulation/Host/Application/Service"
	where := aWhere
]

{ #category : #accessing }
HEvent >> who: aWho [ 
	"Who caused the event? - User/Robot/Actor/Test"
	who := aWho.
]

{ #category : #accessing }
HEvent >> why: aWhy [ 
	"Why did the event occur? - Authorization/JobTicket"
	why := aWhy.
]
