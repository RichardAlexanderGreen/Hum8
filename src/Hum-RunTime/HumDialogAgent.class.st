"
A Dialog Agent in a subtype of Actor.
For that reason, it is in the Hum-RunTime package rather than the Hum-UI package.

A Dialog-Agent responds to client/user inputs 
according to the dialog vignettes in an ontology.

A Scribe implements a (physical) user interface.
A Scribe interprets user interface input (gestures)
  and sends those inputs to the Dialog Agent
  as standardized vignette inputs. 
See HumScribe documentation.

A Dialog has a history.
The history may be represented by a sequence of User Inputs with corresponding system responses.
The history has also caused the context 'stack' to be what it is.

Hence:
. A Dialog has a contextStack.
. A Dialog has a (log?) history of prior stimulus->response events.
. ?? Do the response entries include goals that were started or just text-replies ??

Design Question: Is the Dialog a separate class from the Dialog Agent?

The Scribe and Dialog-Agent communicate via the Messenger.
The Scribe may be client-side or server-side.
In an HTML environment, the Scribe will act like an HTML web servlet.
The Dialog-Agent will typically be server-side.

The Messenger maintains its own logs for replay and debug purposes.
But that log should not be confused with the Dialog history because it has different semantics.
"
Class {
	#name : #HumDialogAgent,
	#superclass : #HumActor,
	#instVars : [
		'clientURI',
		'clientID',
		'contextStack',
		'scribeProxy',
		'dialogAgentOntology'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'user interface' }
HumDialogAgent >> askView: aViewName [
	| ontology viewFrame |
	ontology := self ontology. 
	viewFrame := ontology getViewFrame: aViewName.
	"Delegate display to my scribe."
	(self scribeProxy) askView: viewFrame withBlackBoard: (self blackboard).
]

{ #category : #'user interface' }
HumDialogAgent >> buildDialogAgentOntology [
	"Return ontology with Dialog Agent actions defined and executable in Smalltalk."
	| ontology pa |
	
	pa := HumProgrammersAssistant new.
	ontology := pa loadOntologyFromTextStream: (self dialogOntologySourceStream).
	^ontology. 
]

{ #category : #'events-triggering' }
HumDialogAgent >> clearEntity: entityType [
	"Clear prior data in my blackboard for the given entity type."
	"WARNING: Assumes dialogs vignettes only address one instance of an entity-type at a time."
	"NOTE: Our working assumption is that different ROLES seen in the UI/Model will have separate entity-types."
	"TODO: I think there is a UX problem here. This behavior may confuse users."
	"NOTE It makes no sense to clear a real-world entity. 
	             This idea only makes sense in the context of a data-entry pane where the dialog suggests a *RESET* back to blank data."
	self blackboard clearEntity: entityType. 
]

{ #category : #accessing }
HumDialogAgent >> client: aString [ 
	clientID := aString.
	clientURI := 'URI:',aString. "STUB!"
]

{ #category : #'events-triggering' }
HumDialogAgent >> clientSays: aString [ 
	"Match user utterance to vignette patterns in the ontology
	and return the vignette frame with the best match.
	"
	| bestMatch |

	"We need a context stack to define the best match."
	self assert: ( self contextStack isKindOf: Stack ).
	self assert: ( self contextStack notEmpty ).
	"Delegate the search to the ontology."
	bestMatch := self ontology findBestMatchingVignetteForInput: aString inContextStack: (self contextStack).
	"TODO: Now that I've got a vignette (or not), what do I do with it?"
	self assert: ( bestMatch isKindOf: HumFrame4Vignette ).
	(self stepLog) add: (clientID asString,': ', aString).
	(self blackboard) businessEvent: (clientID asString,' says: ', aString). 
	"TODO: We need a stronger (W5: who, what, when, where, why) business-event representation."
	"who = clientID, what = says: ___, when = date-stamp, where = dialog, why = vignette"
	self interpretVignette: bestMatch withInput: aString.
	
	"*** Return vignette for DEBUG? *** "
	"TODO: THINK -- Should test cases examine my step log instead?"
	^ bestMatch.
]

{ #category : #accessing }
HumDialogAgent >> contextStack [
	^ contextStack ifNil: [ contextStack := Stack new. self pushContext: 'Start.'. contextStack ].
]

{ #category : #'user interface' }
HumDialogAgent >> dialogAgentOntology [
	"Return ontology with Dialog Agent actions defined and executable in Smalltalk."
	^ dialogAgentOntology ifNil: [dialogAgentOntology := self buildDialogAgentOntology].
]

{ #category : #'user interface' }
HumDialogAgent >> dialogOntologySourceStream [
	"Return a stream of frames defining Dialog Agent actions."
	| string stream peekCharacter |
	string := '===
Role: DialogAgent.
Action: Ask view-name.
. Get view-name from callers-ontology.
. Translate view-name giving html-form-panel.
. Scribe: Send html-form-panel to client-browser.
. (DialogAgent black board will be updated.)

To: Get view-name from callers-ontology.
.

To: Translate view-name giving html-string.
.
===

'.
	stream := ReadWriteStream with: string.
	stream position: 0.
	peekCharacter := stream peek.
	self assert: (peekCharacter = $= ).
	^stream.
]

{ #category : #'user interface' }
HumDialogAgent >> extractFieldValuesFromUserInput: inputString pattern: patternString [ 
	"Extract values from user input and post to my blackboard. 
	"
	| inputTokens patternTokens xInput xPattern calc input pattern entityName attributeName attributeValue |
	
	(patternString includes: $[ ) ifFalse: ["There is no slot in this pattern." ^self].
	
	inputTokens := HumCalculator findTokensInString: inputString.
	inputTokens := HumCalculator removeNoiseWordTokensFrom: inputTokens.
	 
	patternTokens := HumCalculator findTokensInString: patternString.
	patternTokens := HumCalculator removeNoiseWordTokensFrom: patternTokens.
	
	xInput := 1.
	xPattern := 1.
	calc := HumCalculator new.
	[ (xInput <= inputTokens size) and: [xPattern <= patternTokens size] ]
		whileTrue: [
				input := inputTokens at: xInput.
				pattern := patternTokens at: xPattern.
				calc cases;
					when: [ input sameAs: pattern] 
						then: [ xInput := xInput + 1. xPattern := xPattern + 1.];
					when: [ pattern = '[' ] 
						then: [ "Extract input value and push into blackboard."
							entityName := patternTokens at: xPattern + 1.
							attributeName := patternTokens at: xPattern + 2.
							self assert: ( ']' = (patternTokens at: xPattern + 3)).
							xPattern := xPattern + 4. 
							pattern := patternTokens at: xPattern.
							attributeValue := ''.
							[(xInput <= inputTokens size) and: [input ~= pattern]] 
								whileTrue: [attributeValue := attributeValue, ' ', input.
									xInput := xInput + 1.
									input := inputTokens at: xInput.
									].
							 self blackboard setEntityName: entityName 
							                     attribute: attributeName 
							                       toValue: (attributeValue trimBoth).
							];
					when: [ pattern = '*'] then: [self shouldBeImplemented];
					otherwise: [Error signal: 'How did we get here?'].
			].
	
]

{ #category : #'user interface' }
HumDialogAgent >> fillInSlotIn: aMarkupString [ 
	" Fill-in first [entity attribute] dialog-response-slot with data from blackboard.
	  Dialog Agent (myself) will call me until all slots are filled.
	"
	| fieldName entityName attributeName fieldValue result before after |
	fieldName := (HumCalculator given: aMarkupString extractBetween: '[' and: ']') withSeparatorsCompacted.
	"Break the field name into entityName and attributeType."
	self assert: (fieldName includes: $  ) description: 'In this context, the entity must always be named.'.
	entityName := (HumCalculator given: fieldName extractUpto: ' ') trimBoth.
	attributeName := (HumCalculator given: fieldName extractAfter: ' ') trimBoth.
	fieldValue := self blackboard getEntityName: entityName attribute: attributeName.
	"Insert field-value into markup string."
	before := HumCalculator given: aMarkupString extractUpto: '['.
	after  := HumCalculator given: aMarkupString extractAfter: ']'.
	result := before, (fieldValue ifNil: ['*** Unknown ***']), after.
	^result.
]

{ #category : #'user interface' }
HumDialogAgent >> interpretVignette: aHumFrame4Vignette withInput: aUserInput [
	"Send response lines. Execute response instructions."
	| responseLines responseInstructions jobTicket calc |
	responseLines := aHumFrame4Vignette responseLines.
	self assert: (responseLines size > 0).
	responseInstructions := aHumFrame4Vignette instructionLines.
	self assert: (responseInstructions size >= 0).
	"Extract any values in user input and update blackboard.
	NOTE: The all patterns must have identical slots."
	self extractFieldValuesFromUserInput: aUserInput pattern: (aHumFrame4Vignette patterns at: 1).
	"Interpret the response lines (fill in any value slots as needed)."
	responseLines 
		do: [ :responseLine | 
			"Interpret markup."
			self sayToClient: responseLine. ].
	"If there are no instructions in the response, we are done."	
	responseInstructions 
		ifEmpty: [^self].
	"TODO: What is the rationale for job-ticket in this context?"	
	jobTicket := HumJobTicket title: 'jobTicket who:',clientID,' when:', (self clock asString),' why: ',#dialog.
	"Interpret any instructions found in the response."
	calc := HumCalculator new.
	responseInstructions
		do: [ :instructionLine |
			| role |
			role := instructionLine role.
			calc cases;
				when: [ role isNil ] "TODO: Using nil value as a signal is dangerous."
					then: ["Dialog Agent instruction - I do it."
						Error signal: 'Why is this different from blank role?'.
						self runInstruction: instructionLine inRole: role onJob: jobTicket.];
				when: [ role = '' ] 
					then: ["Dialog Agent instruction - I do it."
						self runAction: instructionLine inRole: 'DialogAgent' onJob: jobTicket.];
				when: [ role sameAs: 'Goal' ] 
					then: ["Start a plan running"
						| coordinator |
						coordinator := HumActor 
															coordinatorID: myID,'-coordinator' "TODO: Distinguish multiple coordinators"
															uri: myURI 
															goal: (instructionLine statement) 
															dialog: self 
															configuration: (self configuration).
						coordinator checkIn. 
						coordinator runPlan. "TODO: [1] Fork this. [2] Figure out: What if the dialog agent goes down?"
								];
				when: [ role > '' ]
					then: ["Delegated instruction"
						self delegateAction: instructionLine toRole: role onJob: jobTicket.];
			  otherwise: [ Error signal: 'How did we get here?'].
			].
]

{ #category : #'events-triggering' }
HumDialogAgent >> newEntity: anEntityType [ 
	"Create a new entity to be associated with the given entity-type/entity-name."
	"TODO: If the blackboard already contains an entity of that type, 
				it should be saved before the new one is instantiated."
	"TODO: Think about the interaction between business process roles, entity-type, and views."
	| |
	(self blackboard) makeEntityOfType: anEntityType.
	"Advice: New business entities are created in the blackboard when a dialog requires them.
	The blackboard (HumBlackBoard) will handle persistence by calling a World-Base.
	Note: The world-base can be configured to purge data quickly. But why would you do that?
	"
	
]

{ #category : #accessing }
HumDialogAgent >> pushContext: aString [ 
	( self contextStack ) push: aString.
]

{ #category : #'user interface' }
HumDialogAgent >> runAction: anAction inRole: aRole onJob: aHumJobTicket [
	"Dialog Agent knows: 'Ask view', 'Show view', 'Push context ...'" 
	| calc source |
	self assert: (aRole = 'DialogAgent').
	(anAction isKindOf: String) 
		ifTrue: [source := anAction].
	(anAction isKindOf: HumInstructionLine)
		ifTrue: [source := anAction statement source].
	self assert: (source isKindOf: String).
	( source trimBoth = '' ) ifTrue: [ ^self ].
	self stepLog add: ('DialogAgent: {', myID,'} is doing: {',source,'}' ).
	calc := HumCalculator new.
	calc cases;
		when: [source sameAs: '' ] then: ["Blank line or comment line."];
		when: [source beginsWith: 'Ask ']
			then: [ self askView: (calc given: source extractAfter: 'Ask ' ).];
		when: [source beginsWith: 'Show ']
			then: [ self showView: (calc given: source extractAfter: 'Show ' ).];
		when: [source beginsWith: 'New ']
			then: [ self newEntity: (calc given: source extractAfter: 'New ' ).];
		"TODO: Give some thought to the interaction of business process roles and views."
		when: [source beginsWith: 'Push context ']
			then: [ self pushContext: (calc given: source extractAfter: 'Push context ' ).];
		when: [source beginsWith: 'Push ']
			then: [ self pushContext: (calc given: source extractAfter: 'Push ' ).];
		otherwise: [Error signal: 'Action not recognized: {',source,'}'].
	
			
]

{ #category : #'user interface' }
HumDialogAgent >> sayToClient: aHumMarkupLine [ 
	"Say something to the client. 
	 Subtypes will override."
	| systemResponse |
	systemResponse := aHumMarkupLine source. 
	[systemResponse includes: $[ ]
			whileTrue: [ systemResponse := self fillInSlotIn: systemResponse ].
	self assert: (systemResponse includes: $[) not.
	(self stepLog) add: ('S: ', systemResponse ).
	"Delegate actual UI to my Scribe."
	(self scribeProxy) systemSays: systemResponse. 
	
]

{ #category : #accessing }
HumDialogAgent >> scribeProxy [
	"Return an instance that understands #systemSays:
	"
	^scribeProxy 
		ifNil: [ "TODO: When we have more than one kind of Scribe, this needs to be refactored."
			scribeProxy := HumScribe dialogAgent: self. 
			].
]

{ #category : #'user interface' }
HumDialogAgent >> showView: aViewName [
	| ontology viewFrame |
	ontology := self ontology. 
	viewFrame := ontology getViewFrame: aViewName.
	"Delegate display to my scribe."
	(self scribeProxy) showView: viewFrame withBlackBoard: (self blackboard).

]
