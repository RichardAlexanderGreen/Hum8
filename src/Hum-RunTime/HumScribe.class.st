"
A Scribe in a subtype of Actor.
For that reason, it is in the Hum-RunTime package rather than the Hum-UI package.
However, we expect most scribe implementations to provide a communication path 
between HumWidget and HumDialogAgent instances.
Notes: 
(2014-11-8) 
. Scribe and Dialog Agent will be running on same VM and do not need Messenger for communication.
(2014-12-23)
. I am not so sure about that.
. A Scribe, not needing ontology or blackboard, could be implemented client-side.
. A more flexible arrangement will allow for a client-side Scribe.

A Scribe translates client/user inputs (sensors, gestures, keyboard, messages)
into a form usable by a Dialog Agent.
The Dialog Agent responds to user inputs 
according to dialog vignettes seen in an ontology.
The response is returned to the client/user via the Scribe.
The Scribe translates vignette responses into the form required by the client/user interface framework.

See: documentation for Dialog Agents, Vignette Frames.
(HumDialogAgent, HumFrame4Vignette)

Q: How/When/Where/Why is a Scribe instantiated? 
A: A Scribe instance must be in the channel when a client/user is communicating.
. . A Scribe is basically a sensor-interpreter.
. . In a web/chat application, a simple scribe would simply operate a chat pane.
. . When a view frame is operated, a web scribe would translate it into an HTML form.
. Therefore:
. . A web application server will create a Scribe instance when it initiates a connection.
. . In the Java vocabulary, the Scribe may be a kind of servlet or applet.
. Also: A dialog-history is associated with a client/user.
. Therefore: 
. . When a server establishes client/user identity, 
. . . the dialog-history must be fetched (from World Base).
. . The dialog-history is needed to properly revive a .
. . . So. that is when we need to instantiate the Dialog Agent.
. . . The Dialog Agent is configured with Scribe, Ontology, World Base.
. . . 

Q: What is the relation between Sensor, Scribe, Widget, Canvas, ViewPort.
A: The Scribe interprets inputs from the Sensor and updates a Widget.
The Widget is drawn on a Canvas - which may be painted on a Surface.
The Surface may be painted on a Solid that is in some Scene; or it may be self standing.
Note: A Surface is not rendered if it is not visible to the Viewport`s Camera. 

The flow is Sensor >> Scribe >> Widget >> Canvas >> Surface >> ViewPort (Camera).

"
Class {
	#name : #HumScribe,
	#superclass : #HumActor,
	#instVars : [
		'dialogAgent',
		'clientConnection',
		'jobID',
		'dialogAgentURI',
		'instructionInProgress',
		'htmlSession'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'instance creation' }
HumScribe class >> dialogAgent: aHumDialogAgent [
	"Create an instance attached to the given Dialog Agent."
	| instance |
	instance := self basicNew.
	instance dialogAgent: aHumDialogAgent;
		roles: #('scribe');
		blackboard: aHumDialogAgent blackboard;
		configuration: aHumDialogAgent configuration.
	^instance.
]

{ #category : #'user interface' }
HumScribe >> about [
"See also: HumRunTimeTests>>testS100ScribeReadMe"
"
Q: What is the relation between Sensor, Scribe, Widget, Canvas, Solid, ViewPort.
A: The Scribe interprets inputs from the Sensor and updates a Widget.
The Widget is drawn on a Canvas which is painted on a Surface.
A Surface might be painted on a Solid within a Scene.
Note: A Surface is not rendered if it is not visible to the Viewport`s Camera. 

The flow is Sensor >> Scribe >> Widget >> Canvas >> Surface >> ViewPort (Camera)."
"
Q: What is the relationship between Sensor, Scribe, Widget, Blackboard, Dialog?
A: The Scribe interprets Sensor inputs and updates both the view and the Dialog.
The update of a Dialog might wait until form data is submitted."
"
“THINK: Perhaps an Avatar is a type of widget. 
It is visible in the 3D view and may interact with the user.
Hence it has behavior that is similar to a widget.
However, it may be more convenient to treat an Avatar 
as a kind of role 
- a role to be assigned to an agent at run-time
- an agent that happens to be active in a scene."
"“
A Scene is mostly decoration, but it may also trigger interaction via proximity triggers.
A proximity sensor is part of the scribe`s sensorium.
Examples:
U: User-Avatar enters the conference room.
U: User-Avatar is facing the receptionist."

"SUMMARY?
A scribe has a sensorium.
The sensorium includes 
. direct user-interface channels (keyboard, voice-to-text, pointer, touch, etc.)
. indirect user-interface widgets (widgets are probably provided by the visualization framework)
. scene-interface channels (proximity sensors, user-avatar location coordinates, inter-user text)
"
]

{ #category : #'events-triggering' }
HumScribe >> askView: viewFrame withBlackBoard: aBlackBoard [
	"Current implementation assumes user interface is a HTML browser."
	"TODO: HTML stuff belongs in a subtype of Scribe."
	|  htmlForm html |
	self assert: (viewFrame isKindOf: HumFrame4View).
	"Generate an HTML form for the view."
	htmlForm := self ontology codeGenerator generateHTMLforViewFrame: viewFrame blackboard: aBlackBoard.
	"Wrap the view with HTML prolog, navigation, epilog, etc."
	html := self sendView: htmlForm.
	"TODO: Associate an event with the ask-view data-entry."


]

{ #category : #'events-triggering' }
HumScribe >> askViewCompleted [
	"Inform caller that the 'Ask viewName' task 
	 that was delegated from dialog agent (caller)
	 to scribe (this instance) has been completed."
	| |
	"Skip this if there was no dialog caller."
	instructionInProgress ifNil: [^self].
	"Send results back to my Dialog Agent"
	"TODO: ?? Do we return results in completion message ?? 
	  -OR- ?? Do we send a separate message ?? 
	  -OR- ??"
	"Get current task context and send task complete message."
	self completedInstruction: instructionInProgress inRole: 'Scribe' onJob: jobID. 
	
	
]

{ #category : #accessing }
HumScribe >> blackboard [
	"This instance variable should be set by the instance-creation logic. "
	^blackboard ifNil: [Error signal: 'Scribe blackboard should point to Dialog Agent blackboard.']
]

{ #category : #accessing }
HumScribe >> client: aClientConection [ 
	"synonym"
	self clientConnection: aClientConection.
]

{ #category : #accessing }
HumScribe >> clientConnection [
	^ clientConnection ifNil:[ clientConnection := myURI ].
]

{ #category : #accessing }
HumScribe >> clientConnection: aConnectionOfSomeKind [ 
	"How does the Scribe connect to the user/client sensors?"
	"TODO: THIS NEEDS DEEPER/MORE DETAILED THOUGHT."
	self assert: ( aConnectionOfSomeKind isKindOf: ZnUrl ).
	clientConnection := aConnectionOfSomeKind 
]

{ #category : #'events-triggering' }
HumScribe >> clientSays: aString [ 
	"After a client sensor input is interpreted,
	 this method is called with the equivalent speech act input.
	The Scribe (me) then passes this to the dialog agent to stimulate a system response.
	"
	| vignette  |
	(self stepLog) add: ('U: ', aString).
	"*** Following is here for DEBUG? -- Scribe need not be coupled to ontology."
	vignette := self sendToDialogAgent: aString.
	self assert: (vignette isKindOf: HumFrame4Vignette ).
	(vignette responseLines)
		do: [:line |
			(self stepLog) add: 'S: ', line source.
			].
	^vignette.
	
]

{ #category : #accessing }
HumScribe >> dialogAgent [
	"Returns the Dialog Agent that was attached to this Scribe when the Scribe was instantiated."
	^dialogAgent ifNil: [ Error signal: 'Scribe {',myID asString,'} has no dialog agent.']
	
]

{ #category : #accessing }
HumScribe >> dialogAgent: aHumDialogAgent [
	self assert: (aHumDialogAgent isKindOf: HumDialogAgent).
	dialogAgent := aHumDialogAgent. 

]

{ #category : #accessing }
HumScribe >> dialogAgentURI [
	"Returns an instance of HumDialogAgent."
	^dialogAgentURI
]

{ #category : #accessing }
HumScribe >> dialogAgentURI: aHumDialogAgentURI [ 
	self assert: (aHumDialogAgentURI isKindOf: String).
	dialogAgentURI := aHumDialogAgentURI.

]

{ #category : #'user interface' }
HumScribe >> handleHttpPostRequest: aHumHttpRequest [ 
	"The scribe handles the post request by 
	. placing data on a HumDataFrame
	. and returning the data frame as a completion of the 'Ask viewName' task.
	TODO: Eventually, this should be in a subtype 
	      because we will probably also have XMPP, and virtual world interfaces.
	"
	| calc |
	calc := HumCalculator new.
	self assert: (aHumHttpRequest isKindOf: HumHttpRequest).
	"TODO: Should I clear the blackboard before placing these (new/replacement) values?
	 How do I know if they are new versus update?
	"
	aHumHttpRequest
		fields 
			keysAndValuesDo: [:key :value |  
				| entityName attributeName |
				entityName := calc given: key extractUpto: ':'.
				attributeName := calc given: key extractAfter: ':'.
				"Put the data on my blackboard. 
				 It will be sent back to caller in job-completion message. "
			  (self blackboard) setEntityName: entityName attribute: attributeName toValue: value.
			  ].
	"I am ready to send data back to the dialog agent 
	 that delegated 'Ask viewName.' task to me."
	self assert: (dialogAgent blackboard == self blackboard).
	self askViewCompleted.  
	
]

{ #category : #'user interface' }
HumScribe >> htmlStyle [
	"Return CSS style element."
	| styleElement calc cssString |
	cssString := '
		body {background: beige;}
		'.
	calc := HumCalculator new.
	calc indentLevel: 1. "Zero is no indent."
	styleElement := calc xml: 'style' with: [cssString].
	^styleElement.
	
]

{ #category : #accessing }
HumScribe >> initialize [
	"DEBUG Check: Scribe should be initialized with a dialogAgent at creation."
	self dialogAgent ifNil: [Error signal: 'Scribe initiated without a Dialog Agent'].
	self assert: ((self worldbase) = 'none').
]

{ #category : #testing }
HumScribe >> mockDataEntry: userData [ 
	"Mock the user entering given data into view.
	Use this for regression testing.
	"
	| httpRequest |
	self assert: (userData isKindOf: Dictionary).
	"HTML/HTTP magic places data into HTTP Request."
	httpRequest := HumHttpRequest new.
	userData
		keysAndValuesDo: [:key :value | 
			httpRequest atField: key put: value.
			].
	self handleHttpPostRequest: httpRequest. 
]

{ #category : #'events-triggering' }
HumScribe >> runAction: anAction inRole: aRole onJob: aHumJobTicket [
	"Over-ride HumActor to handle Scribe actions."
	self assert: ( aRole sameAs: 'scribe' ).
	self runInstruction: anAction inRole: aRole onJob: aHumJobTicket.
]

{ #category : #'events-triggering' }
HumScribe >> runInstruction: anInstruction inRole: aRole onJob: aJobID [
	"Override the HumActor -- (Why?)"
	| source debug |
	"We cannot accept statement strings here because we need noun values."
	self assert: ( anInstruction isKindOf: HumInstructionLine ).
	debug := false.
	debug
		ifTrue: [ Transcript cr; show: 'Scribe {',myID,'} called with instruction: {',anInstruction source,'}'.].
	
	instructionInProgress := anInstruction "statement".
	jobID := aJobID.
	"We are expecting 'Ask viewName.' or 'Show viewName.'"
	source := instructionInProgress statement source.
	( source beginsWith: 'Ask ') 
		ifTrue: [ "Send an active form for the given view to the attached client interface."
			|  viewFrame   |
			viewFrame := self ontology getViewFrame: (HumCalculator given: source extractBetween: 'Ask ' and: '.' ).
			self askView: viewFrame withBlackBoard: (self dialogAgent blackboard).
			self askViewCompleted.
			].
	( source beginsWith: 'Ask: ') 
		ifTrue: [ "Send an active form for the given view to the attached client interface."
			|  viewFrame   |
			viewFrame := self ontology getViewFrame: (HumCalculator given: source extractBetween: 'Ask: ' and: '.' ).
			self askView: viewFrame withBlackBoard: (self dialogAgent blackboard).
			self askViewCompleted.
			].
	( source beginsWith: 'Show ') ifTrue: [ self shouldBeImplemented ].
	^self.
	
	
	
		
]

{ #category : #'events-triggering' }
HumScribe >> sendToDialogAgent: aClientSpeechString [ 
	"Send the string to my Dialog Agent."
	| myAgent vignette |
	myAgent := self dialogAgent.
	vignette := myAgent clientSays: aClientSpeechString.
	^vignette.
	
	
	
	
]

{ #category : #'user interface' }
HumScribe >> sendView: htmlView [
	"Wrap the view element with HTML header, navigation, epilog, etc." 
	| head  body foot menu htmlResult calc |
	"TODO: When we more than one kind of scribe, this method will be abstract."
	self log add: 'sendView: {',htmlView,'}'.
	calc := HumCalculator new.
	head := calc xml: 'head' with: [ (calc xml: 'title' with: ['Hum Dialog']), (self htmlStyle)].
	foot := calc xml: 'foot' with: [ 'Generated by Hum' ].
	menu := calc xml: 'menu' with: [ calc xml: 'menuItem' list: {''.}].
	body := calc xml: 'body' with: [ menu, htmlView, foot ].
	htmlResult := calc xml: 'html' with: [ head, body ].
	self htmlAgent sendHTML: htmlResult to: (self clientConnection).
	^htmlResult.
]

{ #category : #'events-triggering' }
HumScribe >> systemSays: aString [ 
	"The Dialog Agent has responded with this String.
	Implementations will display the response via the client/user interface. (e.g. chat diary)
	But this (supertype) only logs the response for test-ability.
	"
	"*** Subtype implementations will override this method. ***"
	(self stepLog) add: 'System: ', aString.
]

{ #category : #accessing }
HumScribe >> zdialogAgent: aHumDialogAgent [ 
	self assert: (aHumDialogAgent isKindOf: HumDialogAgent).
	dialogAgent := aHumDialogAgent. 

]
