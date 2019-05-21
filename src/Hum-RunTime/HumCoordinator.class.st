"
The coordinator tracks the execution state of a plan.
The state includes which conditions are satisfied, which plan frames have been completed, the accumulated resource utilization associated with the execution, and any exceptions that were encounterd or are currently pending resolution.

Instance Variables:
	ontology	<HumOntology>
	goal	<ProtoObject | PseudoContext>
	context	<Object>
	remainingConditions	<Integer>
	dialogAgent	<ProtoObject | PseudoContext>
	planFrames	<Collection | PTEnumerable | PragmaCollector>
"
Class {
	#name : #HumCoordinator,
	#superclass : #HumActor,
	#instVars : [
		'goal',
		'context',
		'remainingConditions',
		'dialogAgent',
		'planFrames',
		'jobTicket'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'events-registering' }
HumCoordinator >> conditionIsSatisfied: precondition [ 
	"Note that condition is satisfied.
	Then runnable frames may change.
	If all conditions have been satisfied, the goal is achieved.
	THINK: Should the goal itself be in remainingConditions collection?
	"
	| debug |
	(debug := false) ifTrue: [Transcript cr; show: 'HumCoordinator conditionIsSatisfied: ', precondition asString. ].
	self assert: ( precondition isKindOf: HumStatement ).	
	precondition isSatisfied: true.
	(self remainingConditions) 
		remove: precondition 
		ifAbsent: [Error signal: 'absent condition: ', precondition "statement" source]
]

{ #category : #accessing }
HumCoordinator >> context: aHumActor [
	context := aHumActor.
]

{ #category : #accessing }
HumCoordinator >> coordinatorID: anID uri: aURI goal: aGoalStatementString dialog: aHumDialogAgent configuration: aHumConfiguration [

	self configuration: aHumConfiguration.	

	self id: anID.
	self uri: aURI.
	self goal: aGoalStatementString.
	self dialogAgent: aHumDialogAgent.
	

	
	^self.
	
]

{ #category : #accessing }
HumCoordinator >> dialogAgent: aHumDialogAgent [ 
	"Concept: The dialog agent provides noun values 
	 as needed to populate plan and action statements."
	self assert: ( aHumDialogAgent isKindOf: HumDialogAgent ).
	dialogAgent := aHumDialogAgent.
]

{ #category : #logging }
HumCoordinator >> getActionSequence [
	"Parse the job ticket to show the sequence of actions."
	| listOfActions |
	listOfActions := self jobTicket getActionSequence.
	^listOfActions.
]

{ #category : #accessing }
HumCoordinator >> goal: aStatement [
	goal := nil.
	(aStatement isKindOf: HumStatement ) ifTrue: [ goal := aStatement. ^self ].
	( aStatement isKindOf: String )
		ifTrue: [ "Get the goal statement from the root frame."
			| rootFrame statement |
			rootFrame := (self ontology) getPlanFrameForGoal: aStatement.
			statement := rootFrame goal.
			self assert: (statement isKindOf: HumStatement).
			goal := statement.
			^self.
			].
	

]

{ #category : #accessing }
HumCoordinator >> goalStatement [
	"Translate goal string to goal statement"
	"TODO: THERE IS SOMETHING WRONG HERE."
	| rootFrame statement |
	rootFrame := ((self ontology) getPlanFrameForGoal: goal).
	statement := rootFrame goal.
	self assert: (statement isKindOf: HumStatement ).
	^ statement. 

]

{ #category : #evaluating }
HumCoordinator >> isPlanFrameRunnable: aHumFrame4Plan [
	"Determine if the given plan frame is runnable.
	To be runnable, it`s preconditions must all be satisfied.
	TODO: This implementation is only correct where the noun values do not affect.
	WARNING: Assumes: All instances of the condition have the same noun values.
	" 
	(aHumFrame4Plan preconditions)
		do: [ :precondition | 
				((self remainingConditions) includes: (precondition statement) )	
					ifTrue: [^false]	
					].
		^true
				
]

{ #category : #accessing }
HumCoordinator >> jobTicket [
	^ jobTicket ifNil: [ jobTicket := HumJobTicket title: goal ].
]

{ #category : #evaluating }
HumCoordinator >> planIsRunnable [
	"TODO: ADD NEEDED CHECKS TO THIS STUB."
	| |
	context := dialogAgent.
	self assert: ( context isKindOf: HumDialogAgent ).
	self assert: ( goal isKindOf: HumStatement ).
	"	
	Additional Preconditions:
	. All nouns in the goal statement have values on the dialog agent's' blackboard.
	. The frame collection is complete.
	. All the roles in the action statements are known (checked-in) to the Dispatcher.
	. All action statements are defined in the ontology.
	"
	"TODO: DANGER -- THIS IS A STUB!!!"
	^true.
]

{ #category : #accessing }
HumCoordinator >> remainingConditions [
	^ remainingConditions ifNil: [ remainingConditions := Set new.] .
]

{ #category : #'events-triggering' }
HumCoordinator >> runAction: anInstructionLine [ 
	"Run the given action statement."
	| debug |
	debug := false. 
	debug ifTrue: [ Transcript cr; show: 'HumCoordinator ',myID,' is running { ', anInstructionLine source, ' }'.].
	"TODO: Track work-in-progress so that run-time instrumentation can view."
	anInstructionLine jobTicket: (self jobTicket).
	(self messenger) sendAction: anInstructionLine toID: (self configuration dispatcherID) fromID: myID.


	
]

{ #category : #'events-triggering' }
HumCoordinator >> runPlan [
	"Run my plan.
	"
	|  result |
	self runPlanSetup.
	result := self runPlanFrameForCondition: goal.
	result 
		ifFalse: [ Error signal: 'Attempt to run plan for goal: {',goal,'} has failed.'].
]

{ #category : #'events-triggering' }
HumCoordinator >> runPlanFrameForCondition: aGoalString [
	"This visits the subtree and runs each frame that is ready to run.
	TODO: RUN ACTIONS IN PARALLEL.
	TODO: Track work in progress.
	TODO: Write several tests.
	"
	| rootFrame result |
	"If the condition is already satisfied (not in remainingConditions set), we can skip and return immediately."
	remainingConditions detect: [:condition | condition sameAs: aGoalString ] ifNone: [  ^true.].
	"Get the root of this subtree."
	rootFrame := (self ontology) getPlanFrameForGoal: aGoalString.
	"REFACTOR: The rootFrame does not know if it is runnable. But the Coordinator knows."
	( self isPlanFrameRunnable: rootFrame )
		ifTrue: ["Run its actions and then declare the goal satisfied"
			"Run actions"
			(rootFrame actionStatements) 
				do: [ :action | self runAction: action.  ].
			"Declare goal satisfied"
			self conditionIsSatisfied: rootFrame goal.
			^true.	 "Indicates something was runnable. See check below."
			] "ifTrue"
		ifFalse: [ "Try to satisfy the preconditions."
			result := false.
			( rootFrame preconditions )
					do: [ :precondition |
						| preconditionString stepResult |
						preconditionString := precondition statement source.
						"Call recursively on preconditions."
						stepResult := self runPlanFrameForCondition: preconditionString.
						result := result | stepResult.  "Boolean"
						]. "do"
					"Check post condition 
					-- At least one precondition in the tree should be runnable on each iteration."
					result ifFalse: [ Error signal: 'Nothing in the subtree was runnable!']
					]."ifFalse"
				
		"Fall through to here when goal frame is not runnable and we ran preconditions.
		Now try again."
		((self remainingConditions ) isEmpty) 
			ifTrue: [ Error signal: 'Remaining conditions should not be empty in this recursive loop.'.
				"In this context,
				 the remaining conditions should include the original goal, 
				 and therfore, not be empty yet."
				].
		result := self runPlanFrameForCondition: aGoalString.
		^result.
		
	

]

{ #category : #'events-triggering' }
HumCoordinator >> runPlanSetup [
	"Setup to run a plan:
	1. Assure plan is runnable.
	2. Populate the remaining conditions collection. ()
	3. Initialize the job ticket?
	TODO: WATCH OUT: instance variables passed via the back-door 
	"
	| |
	self assert: (goal isKindOf: HumStatement ).
	self planIsRunnable ifFalse: [ Error signal: 'Plan is not runnable for goal: ', goal ].
	planFrames := self ontology collectPlanFramesForGoal: (self goalStatement).
  "Populate the remaining conditions collection"
	(self remainingConditions) add: goal.
	jobTicket := HumJobTicket title: goal.
	planFrames
		do: [ :frame |
				( frame preconditions )
						do: [ :precondition |
								remainingConditions add: (precondition statement).
							].
			].

]
