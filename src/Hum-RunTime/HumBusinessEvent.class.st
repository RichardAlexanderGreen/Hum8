"
A business event attributes are W5: who, what, when, where
 (Who said/saw what, when, where, why.)
. Who is an actor. (client/VR actor/. . .)
. What is a statement.	(assertion)
. When is a timestamp.	(world time or host time?)
. Where is a frame.  (NOTE: Assumes we are interpreting frame at run-time.)
. Why is a job-ticket.	(Job-ticket identifies a plan = a run-time goal.)

"
Class {
	#name : #HumBusinessEvent,
	#superclass : #HumEntity,
	#instVars : [
		'who',
		'what',
		'when',
		'where',
		'why'
	],
	#category : #'Hum-RunTime'
}

{ #category : #accessing }
HumBusinessEvent >> what: aString [
	"What is the cause/actor doing in the business event?"
	what := aString
]

{ #category : #accessing }
HumBusinessEvent >> when: aTimeStamp [
	"When (at what date-time) is business event happening?"
	when := aTimeStamp
]

{ #category : #accessing }
HumBusinessEvent >> where: aString [
	"Where (at what location/context) is business event happening?"
	where := aString
]

{ #category : #accessing }
HumBusinessEvent >> who: aString [
	"Who is the cause/actor in the business event"
	who := aString
]

{ #category : #accessing }
HumBusinessEvent >> who: aWho what: aWhat when: aTimeStamp where: aWhere why: aJobTicket [
	"Set the business event attributes."
	self who: aWho; what: aWhat; when: aTimeStamp; where: aWhere; why: aJobTicket.
	"TODO: Curiously, there are no senders other than test cases."
]

{ #category : #accessing }
HumBusinessEvent >> why: aJobTicket [
	"Why (job-ticket) is business event happening?"
	why := aJobTicket
]
