"
Action frames define the steps (instructions) in an action.

An action belongs to a role.
Actors may be assigned to a role at run-time.
Such actors have a set of action-statements as their external interface.
In that sense, they ""know"" the role.

The format of an action frame looks like this:
---
Role: Cook.

Action: Preheat oven to recipe temperature.
. (Delegate to oven's robot.)
. Oven: Set temperature to recipe temperature.
. (Proceed with other actions while oven comes up to heat.)

Action: Mix ingredients per recipe.
. For each ingredient in recipe ingredients:
. . Add ingredient quantity to mixing-bowl.
. Stir contents of mixing-bowl for 5 minutes.

To: Add ingredient quantity to mixing-bowl.
. Select device appropriate to ingredient`s type and quantity giving selected-metering-device.
. Meter the ingredient into the mixing-bowl using selected-metering-device.
---
Action frames may be public (Action: prefix) or private (To: prefix).

Instance Variables:
	role	<String>
	actionStatement	<HumStatement>
	instructions	<OrderedCollection>
"
Class {
	#name : #HumFrame4Action,
	#superclass : #HumFrame,
	#instVars : [
		'role',
		'actionStatement',
		'instructions'
	],
	#category : #'Hum-Language'
}

{ #category : #'instance creation' }
HumFrame4Action class >> ontology: aHumOntology role: aRole action: anActionStatement [ 
 	| frame |
	frame := HumFrame4Action new.
	frame ontology: aHumOntology; 
		role: aRole;
		actionStatement: anActionStatement.
	^frame.
	
]

{ #category : #accessing }
HumFrame4Action >> actionStatement [
	^ actionStatement ifNil:[ Error signal: 'Action frame must have an action statement']. 
]

{ #category : #accessing }
HumFrame4Action >> actionStatement: anObject [
	actionStatement := nil.
	(anObject isKindOf: String)             ifTrue: [ actionStatement := HumStatement from: anObject ].
	(anObject isKindOf: HumStatement )      ifTrue: [ actionStatement := anObject ].
	(anObject isKindOf: HumInstructionLine) ifTrue: [ actionStatement := anObject statement].
	self assert: ( actionStatement isKindOf: HumStatement ).
	
]

{ #category : #accessing }
HumFrame4Action >> appendInstructionRole: aRole statement: aStatement [ 
	| frameLine |
	frameLine := ( HumInstructionLine role: aRole statement: aStatement ).
	self instructionLines add: frameLine.
	self frameLines add: frameLine.
]

{ #category : #accessing }
HumFrame4Action >> appendInstructionRole: aRole statement: aStatement comment: aComment [	

	| actionInstruction |
	
	actionInstruction := HumInstructionLine new.
	actionInstruction role: aRole; statement: aStatement; comment: aComment.
	
	self instructionLines add: actionInstruction.
	self frameLines add:  actionInstruction .
]

{ #category : #accessing }
HumFrame4Action >> appendInstructionStatement: aSource [ 
	| actionInstruction |
	
	actionInstruction := HumInstructionLine new.
	actionInstruction role: ''; statement: aSource; comment: ' '.
	
	self instructionLines add: actionInstruction.
	self frameLines add:  actionInstruction .
]

{ #category : #testing }
HumFrame4Action >> checkSyntaxWithOntology: anOntology [ 
	"Critique the instructions for this role action."
	|  critique lineCritique action actionNouns |
		
	"Return the critique as a sequence of strings."
	critique := OrderedCollection new.
	
	"The action should contain at least one noun."
	action := self actionStatement.
	actionNouns := anOntology nounsInStatement: action.
	( actionNouns size > 0 ) 
		ifFalse: [ critique add: ( 'Action statement {',( action asString ),'} has no known nouns!' ) ].
		
	"There should be at least one instruction for the action statement."		
	( self instructionLines size > 0 )
		ifFalse: [ critique add: 'Action {', self titleLine,'} has no instructions.'. ].
			
	"Nouns in the instructions should find antecedants in the action statement."
	(self instructionLines) 
		do: [ :instruction | 
			lineCritique := ( instruction checkSyntaxWithOntology: anOntology defaultRole: (self role)).
			critique := critique, lineCritique.
			lineCritique := ( instruction checkForAntecedantsIn: (self actionStatement) withOntology: anOntology ).
			critique := critique, lineCritique.			
			]. 
	"TODO: The line after  'For . . .  : ' or  'If . . .  : '  or 'Else:' should be indented."	
	"TODO: Think about how indentation should be assured. -- This goal belongs to the EDITOR.
	In the editor context, the indentation should be automatic.
	Note: Indentation is an attribute of an instruction line.
	"
	^critique.
]

{ #category : #testing }
HumFrame4Action >> compileToOntology: aHumOntology [ 
	"Compile the frame into the ontology."
	| nLinesIn nLinesOut |
	"Make sure frame is stored."
	aHumOntology storeFrame: self.
	"Index the role-action"	
	aHumOntology indexRole: self role action: self actionStatement.
	nLinesIn := self frameLines size.
	"Add the instruction sequence"
	( self instructionLines )
		 do: [ :instruction |
			"aHumOntology appendInstruction: instruction toRole: (self role) action: (self actionStatement)."
			(instruction role sameAs: '') 
				ifFalse: [ aHumOntology indexFrame: self relation: #invokesAction object: (instruction title). ].
			].
	nLinesOut := self frameLines size.
	self assert: (nLinesOut = nLinesIn ) description: 'compileToOntology affects source.'.
	"Return no errors."	
	^ (self checkSyntaxWithOntology:  aHumOntology ).
	
	 
	
]

{ #category : #accessing }
HumFrame4Action >> instructionLines [
	^ instructions ifNil: [ instructions := OrderedCollection new ].
]

{ #category : #accessing }
HumFrame4Action >> instructions [
	^ instructions ifNil: [ instructions := OrderedCollection new. ].
]

{ #category : #accessing }
HumFrame4Action >> instructions: anObject [
	instructions := anObject
]

{ #category : #accessing }
HumFrame4Action >> role [
	^ role.
]

{ #category : #accessing }
HumFrame4Action >> role: anObject [
	role := anObject
]

{ #category : #accessing }
HumFrame4Action >> titleLine [
	"Format a cannonical title line."
	^ 'Role: ', ( self role asString capitalized), ' -- ', ( self actionStatement asString ).
]
