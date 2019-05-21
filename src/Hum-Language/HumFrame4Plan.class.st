"
Plan frames define plan-fragments.
A plan frame has a goal-statement (a post condition) and a set of preconditions.
The action list defines zero or more actions that implement the transition from the preconditions to the post condition.
The action list will not execute until the preconditions are all met.

Instance Variables:
	goal	<HumStatement>
	preconditions	<Set>
	planActions	<Set>
"
Class {
	#name : #HumFrame4Plan,
	#superclass : #HumFrame,
	#instVars : [
		'goal',
		'preconditions',
		'planActions'
	],
	#category : #'Hum-Language'
}

{ #category : #'instance creation' }
HumFrame4Plan class >> ontology: aHumOntology goal: aGoalStatement [
	| frame | 
	frame := HumFrame4Plan new.
	frame ontology: aHumOntology;
			goal: aGoalStatement.
			^frame.
]

{ #category : #accessing }
HumFrame4Plan >> actionStatements [
	^self planActions.
]

{ #category : #accessing }
HumFrame4Plan >> appendInstructionRole: aRole statement: aStatement [ 
	| instruction |
	instruction :=  ( HumInstructionLine role: aRole statement: aStatement ).
	self planActions add: instruction.
	self frameLines add:  instruction.
]

{ #category : #accessing }
HumFrame4Plan >> appendPrecondition: aSource [ 
	| precondition |
	precondition := (HumConditionLine new) statement: aSource.
	self assert: ( precondition isKindOf: HumConditionLine ).
	self preconditions add: precondition.
	self frameLines add: precondition.
]

{ #category : #accessing }
HumFrame4Plan >> appendPrecondition: aStatement annotation: anAnnotation [
	| precondition |
	precondition := (HumConditionLine new) statement: aStatement.
	precondition annotation: anAnnotation.
	self assert: ( precondition isKindOf: HumConditionLine ).
	self preconditions add: precondition.
	self frameLines add: precondition.
]

{ #category : #accessing }
HumFrame4Plan >> appendRole: aRole action: aSource [ 
	"Add 'role: action-statement' to plan-frame"
	| |
	
	self appendRole: aRole action: aSource comment: nil.
]

{ #category : #accessing }
HumFrame4Plan >> appendRole: aRole action: aSource comment: aComment [
	"Add 'role: action-statement. (comment)' to plan-frame"

	| actionInstruction |
	
	actionInstruction := HumInstructionLine new.
	actionInstruction role: aRole; statement: aSource; comment: aComment.
	
	self planActions add: actionInstruction.
	self frameLines add:  actionInstruction .
]

{ #category : #testing }
HumFrame4Plan >> check [
	"Check the basic integrity of the plan frame."
	| problems |
	"The callers sees the problems in the same order we do."
	problems := OrderedCollection new.
	"The plan frame must have a goal."
	( self goal isNil ) 
		ifTrue: [ problems add: 'A plan frame must have a goal.']
		ifFalse: [ ( self goal source size > 5 ) 
						ifFalse: [ problems add: 'A plan frame must have a goal.' ].
				 ].
	
	"A plan frame should have at least two preconditions."
	(( self preconditions size ) > 1) ifFalse: [ problems add: 'A plan frame should have at least two preconditions.' ].

	^problems.

]

{ #category : #testing }
HumFrame4Plan >> checkSyntaxWithOntology: anOntology [
	| frameErrors lineErrors  checkLines  |
	frameErrors := OrderedCollection new.
	"Check stand-alone syntax.
	Detect statements with no nouns.
	Detect statements that have not been defined.
	"
	checkLines := (self preconditions), (self planActions).
	checkLines
		do: [ :frameLine | 
			( frameLine isKindOf: HumInstructionLine )
				ifTrue: [ lineErrors := (frameLine checkSyntaxWithOntology: anOntology defaultRole: (frameLine role)).]
				ifFalse: [lineErrors := (frameLine checkSyntaxWithOntology: anOntology).].
			
			(lineErrors isEmpty) ifFalse: [ frameErrors := frameErrors, lineErrors ].
			].
	"Check data flow. 
	Each statement's nouns must have antecedants in the goal statement."
	checkLines
		do: [ :frameLine |
			lineErrors := (frameLine checkForAntecedantsIn: (self goal) withOntology: anOntology ).
			(lineErrors isEmpty) ifFalse: [ frameErrors := frameErrors, lineErrors ].
			].
	^frameErrors.
]

{ #category : #testing }
HumFrame4Plan >> compileToOntology: aHumOntology [ 
	"Check the basic integrity of the plan frame.
	If it is viable, put it into ontology."
	| problems |
	"Make sure frame is stored."
	aHumOntology storeFrame: self.

	"The callers sees the problems in the same order we do."
	problems := self checkSyntaxWithOntology: aHumOntology.
		
	"A plan frame should have at least two preconditions. (should not must)"
	(( self preconditions size ) > 1) 
		ifFalse: [ problems add: 'No preconditions.'.
			(planActions size > 0) 
				ifTrue: [problems add:' Action will be taken as soon as plan starts.'] 
				ifFalse: [problems add: 'Plan frame is empty.']
			].
	
	"The plan frame must have a goal."
	( self goal isNil ) 
		ifTrue: [ problems add: 'A plan frame must have a goal.']
		ifFalse: [ ( self goal source size > 5 ) 
						ifFalse: [ problems add: 'A plan frame must have a goal.']
						ifTrue: [ "Looks like we have a goal"
							aHumOntology addPlanFrame: self ForGoal: (self goal source).
								"If the frame has a goal, store the frame regardless of errors."
							aHumOntology storeFrame: self.
							] .
				].
	"Compile the preconditions"		
	(self preconditions)
		do: [ :precondition | 
				| thisProblem |
				 thisProblem := precondition compileLineToOntology: aHumOntology.
				 problems := problems, thisProblem. 
				"Index the precondition"
				 "aHumOntology frameRelations add: { (self title). #precondition. (precondition statement asString). }."
				ontology indexFrame: self relation: #precondition object: (precondition statement asString).
				"TODO: Decide if we want the title or the frame itself. (frame reference)"
				"Note: The title may change when the goal statement is edited. However, recompile should fix."
				"Note: Our structure could enable changing definition, changes all references."
				].	
	"Compile the actions"		
	( self actionStatements )
		do: [ :action | 
				| thisProblem |
				 thisProblem := action compileLineToOntology: aHumOntology.
				 problems := problems, thisProblem. 
				"Index the precondition"
				 "aHumOntology frameRelations add: { (self title). #invokesAction. ( action titleLine ). }."
				 ontology indexFrame: self relation: #invokesAction object: (action titleLine).
				 ].	
	^problems.
]

{ #category : #accessing }
HumFrame4Plan >> goal [
	"Get the plan frame's goal statement."
	^ goal
]

{ #category : #accessing }
HumFrame4Plan >> goal: aSource [ 
	"This instance variable contains the plan frame's goal statement."
	| goalStatement |
  ( aSource isKindOf: String ) ifTrue: [ goalStatement := HumStatement from: aSource.].
  ( aSource isKindOf: HumStatement ) ifTrue: [ goalStatement := aSource.].

	goal := goalStatement.
	titleLine := 'Goal: ', goalStatement source.
]

{ #category : #testing }
HumFrame4Plan >> isNoPlan [
	"Frame is no plan if there are no preconditions and no actions.
	Either the preconditions or the action may be empty, but not both.
	However, both could have the statement: 'None.' to indicate that the programmer
	has not simply forgotten this frame.
	Comment: If goal appears as a precondition elsewhere,
	. but has no preconditions and no action needed to make it true,
	. it could be annotated as [Assumed.] where it appears as a precondition
	. and then no frame would be required for it.
	TODO: Think about a feature 
	. where a precondition marked [Assumed] in one context 
	. is automatically marked [Assumed] everywhere.
	"
	self preconditions isEmpty
		ifFalse: [ ^false ].
	self planActions isEmpty
		ifFalse: [ ^false ].
	^true.
]

{ #category : #accessing }
HumFrame4Plan >> planActions [
  "A sequence of actions to be performed after preconditions are satisfied.
   Generally, a single action is better form, but multiple actions are allowed.
   Multiple actions will be performed in the sequence given by the author.
  "
	^ planActions ifNil: [ planActions := OrderedCollection new. ].
]

{ #category : #accessing }
HumFrame4Plan >> preconditions [
	"Preconditions are ordered to preserve the author`s sequence,
	and to make locally-run unit test sequences repeatable. 
	However, during actual runtime execution, 
	  preconditions will be executed asynchronously
	  with dynamic scheduling.
	Required sequences should be indicated by the plan tree structure or via Action procedure.
	"
	^ preconditions ifNil: [ preconditions := OrderedCollection new ].
]
