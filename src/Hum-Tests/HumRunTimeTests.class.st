"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Run-Time Test Cases
--- See also: HumCalculatorTests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A. Messenger
   1. The actors (agents) communicate via the Messenger.
   2. Messenger is addressed via a URI.
   3. Messenger records each message in a log file.
   4. In test mode, 
         the messenger can replay the messages 
         that were sent to an actor during some period of time. 
         (This capability enables simulations.)
   5. In test mode, 
         messages can only be communicated 
         between actors that are also in test mode.

B. Resource Manager (RM) - assigns tasks to actors.
   1. Actor checks-in (announces availability to perform specific roles).
   2. Assign task (action-statement) to actor.
      a) Job-ticket contains action-statement, noun-values, 
            request context (requesting actor, and instruction-pointer).
      b) The RM assigns an available actor.
      c) The RM sends the job-ticket to the assigned actor. 
            (via Messenger)
   3. Actor has completed task.
      a) The resources consumed (actor’s time, etc) are recorded on the job ticket.
      b) Any computed results are added to the job-ticket.
            (Convention: Actions with results have a ""giving"" clause.)
      c) RM sends resource consumption data to Bookkeeper.
      d) Task complete notice (with job-ticket) is sent to requester.
            (The requester resumes execution of the plan.)

C. Bookkeeper - tracks resource consumption
   1. Job-ticket resource consumption is recorded.
   2. Resource dimensions include job, resource, 
         provider (actor, role), consumer (actor, role), and date-time.
   3. Actors may decrement, increment inventories.
   4. Actors may set inventory level (initialization, audit).

D. Supervisor - controls execution of plans and dialogs.
   1. Delegate task.
         (The current actor has delegated a task to another role.)
      a) Send delegated task to Resource Manager. (RM)
         (The RM will assign the task to an available actor.) 
   2. Resume suspended action.
         (When a task is delegated to another role, 
            the current task execution is suspended.)
   3. 

E. Blackboard + WorldBase
   1. Blackboard sends new values to attached WorldBase with event-stamp.
   2. WorldBase stores and returns value

"
Class {
	#name : #HumRunTimeTests,
	#superclass : #HumTestCase,
	#instVars : [
		'setupMessenger',
		'setupDispatcher',
		'setupBookkeeper',
		'setupWorker',
		'setupEnvironment',
		'setupConfiguration'
	],
	#category : #'Hum-Tests'
}

{ #category : #'setup and helpers' }
HumRunTimeTests >> aReadMe [
	"See the class description for the intended (future) tests."
	^'See the class description for the intended (future) tests.'
	
]

{ #category : #'setup and helpers' }
HumRunTimeTests >> expect: actualValue is: expectedValue [ 
	""
	^ self
		assert: (expectedValue = actualValue)
		description: ( self comparingStringBetween: expectedValue and: actualValue ).
]

{ #category : #'setup and helpers' }
HumRunTimeTests >> expected:  expectedValue actual: actualValue [ 
	""
	^ self
		assert: (expectedValue = actualValue)
		description: ( self comparingStringBetween: expectedValue and: actualValue ).
]

{ #category : #'setup and helpers' }
HumRunTimeTests >> setUp [
	"This setup is used by many run-time tests. 
	It initializes: setupConfiguration setupMessenger setupDispatcher setupBookkeeper setupWorker "
	| |
	self setUpDefaultStore.
	"Set the ID"
	"Define a Hum configuration."
	setupConfiguration := HumConfiguration messengerID: 'mock messenger ID' 
	                                         dispatcherID: 'mock Dispatcher ID' 
	                                      bookkeeperID: 'mock bookkeeper ID'
                                         worldbaseID: 'mock worldbase ID'. "Mentioned but not instantiated?"
	"Attach local messenger (Mock)".
	setupMessenger := HumMessenger new.
	setupMessenger id: 'mock messenger ID';
								uri: 'mock messenger URI'.	
	setupConfiguration messenger: setupMessenger.
	"Create worldbase instance and check-in."
	setupConfiguration openWorldBase.
	"A resource Dispatcher must know a messenger and a bookkeeper."
	setupDispatcher := HumActor dispatcherID: 'mock Dispatcher ID'  
	                                     uri: 'mock Dispatcher URI'  
	                           configuration: setupConfiguration.						
	"A bookkeeper must know a messenger and a world base."					
	setupBookkeeper := HumActor bookkeeperID: 'mock bookkeeper ID' 
	                                   uri: 'mock bookkeeper URI'  
	                         configuration: setupConfiguration.	
	"A worker must know a messenger and a Dispatcher and some roles"
	setupWorker := HumActor workerID: 'test workerID'  
	                           uri: 'mock worker URI' 
	                         roles: #( 'serf' 'cook' 'singer' 'composer')   
	                 configuration: setupConfiguration.	
	"Messenger needs to know bookkeeper and Dispatcher"
	setupMessenger registerActor: setupBookkeeper atURI: setupBookkeeper uri. 
	setupMessenger registerActor: setupDispatcher atURI: setupDispatcher uri.
	"Check in."
	setupWorker checkIn.

]

{ #category : #initialization }
HumRunTimeTests >> setUpDefaultStore [
	"Specify a default store for these tests."	
	HumStore defaultDirectory:  './Developer/Smalltalk/Hum8'.
]

{ #category : #'setup and helpers' }
HumRunTimeTests >> setUpKnockKnockOnOntology: anOntology [
	| viewFrame dictionaryFrame |
	self assert: (anOntology isKindOf: HumOntology ).
	"Provide a view frame."
	viewFrame := HumFrame4View ontology: anOntology viewEntity: 'Knock'.
	viewFrame addMarkUp: '!!Knock, knock, who`s there?'.
	viewFrame addMarkUp: '  Please enter first name: [first-name]'.

	"Provide a dictionary frame."
	dictionaryFrame := HumFrame4Dictionary ontology: anOntology title: 'Knock attributes'.
	dictionaryFrame addDictionaryLine: 'Knock attributes include first-name.'.
	
	dictionaryFrame compileToOntology: anOntology .
	viewFrame       compileToOntology: anOntology.

]

{ #category : #'setup and helpers' }
HumRunTimeTests >> tearDown [
	"Transcript cr; show: 'completed: ', (testSelector asString)."
]

{ #category : #'Configuration Tests' }
HumRunTimeTests >> test000ApplicationConfigurationReadMe [
	"An application has a run-time configuration."
	|  |
	"
System	/Application Configuration:
	A typical system will include these 'singleton' components: 
	. Messenger: Assure messages are received and logged.
	. Dispatcher: Assign actions to actors. (Tracks current system work-in-progress at actor level. )
	. Bookkeeper: Record resource utilization as tasks complete.
	. WorldBase: Record events, maintain entity state data. 
	An active user / client session will also include session-bound instances of a:
	. Dialog Agent: Conduct dialog with user / client actor. 
	. Scribe: Mediate between Dialog and User Interface technology. 
	. Ontology: A Dialog Agent interprets dialog vignettes found in a specific ontology.
	Each running plan will also include an instance of a:
	. Coordinator: Coordinate plan execution. (Tracks work-in-progress at plan level.)
	. Ontology: An ontology must be present at the time the plan is built.
Actor Configuration:
	An Actor`s (minimal) configuration includes a Messenger and a Dispatcher.	
	During execution, most Actors have a BlackBoard where run-time data is persisted.
	The BlackBoard may require the services of a WorldBase when the Actor`s actions affect the World. (typical)	
"
	self skip.
]

{ #category : #'Configuration Tests' }
HumRunTimeTests >> test005ApplicationConfigurationSetup [
	"This setup is used by several tests. "
	"Define a Hum configuration."
	| |
	"#setUp creates a shared configuration."
	self assert: ( setupMessenger uri  sameAs: 'mock messenger URI' ).

	self assert: ( setupConfiguration messenger == setupMessenger ).

	self assert: ( setupDispatcher isKindOf: HumDispatcher ).
	self assert: ( setupDispatcher id sameAs: 'mock Dispatcher ID' ).
	self assert: ( setupDispatcher uri sameAs: 'mock Dispatcher URI'  ).

	self assert: ( setupBookkeeper isKindOf: HumBookkeeper ).
	self assert: ( setupBookkeeper id sameAs: 'mock bookkeeper ID' ).
	self assert: ( setupBookkeeper uri sameAs: 'mock bookkeeper URI'  ).
 
	self assert: ( setupWorker isKindOf: HumActor ).
	self assert: ( setupWorker uri sameAs:  'mock worker URI'  ).
	self assert: ( setupWorker id  sameAs: 'test workerID').
	self assert: ( setupWorker roles = ( #('serf' 'cook' 'singer' 'composer')  )   ).

	self assert: ( setupMessenger isKindOf: HumMessenger ).
	self assert: ( setupMessenger ping: 'mock Dispatcher URI' ) == setupDispatcher id.
	self assert: ( setupMessenger ping: 'mock bookkeeper URI' ) == setupBookkeeper id.
	self assert: ( setupMessenger ping: 'mock worker URI' ) == setupWorker id.

]

{ #category : #'Actor Tests' }
HumRunTimeTests >> test100ActorReadMe [
	"
Jobs and Tasks:	
	An Hum Actor executes action statements assigned by the Resource Dispatcher.
	Action assignments include a JobTicket to which resources are added as used, including the actor`s time.
	A JobTicket is started when a Plan is started. It is associated with the plan goal (instance).

Messenger:
	Actors communicate via the Messenger which provides a wrapper around some communication technology.
	The Messenger also logs messages for diagnosis and replay purposes. 
  (The actor need not bother with that level of logging.)

Roles:	
	Action Statements procedures are defined in Ontology Action Frames that are collected under a Role.
	When an Actor 'checks-in' with its Resource Dispatcher, it claims to 'know' one or more Roles.
	The Resource Dispatcher may then assign an Action to an Actor that knows the associated Role.
	
Delegation:
	An Actor may delegate an instruction`s action to another Role.
	While the other role is executing, the current execution is suspended. 
	When the other role 'returns', 
	. the message-receiver interface restores state (via BlackBoard) 
	. and resumes execution.
	
Actor Configuration:
	The Actor`s (minimal) configuration includes a Messenger and a Resource Dispatcher.	
	During execution, most Actors have a BlackBoard where run-time data is persisted.
	The BlackBoard typically requires the services of a WorldBase:
	. when Actor delegates an instruction (action) to another role (because current state must be peristed)
	. when the Actor`s actions affect the World. 
	. . (WorldBase retention rules define what is remembered, what is forgotten.)
	
System	/Application Configuration:
	A typical system will include these 'singleton' components: 
	. Messenger: Assure messages are received and logged.
	. Resource Dispatcher: Assign actions to actors. (Tracks current system work-in-progress at actor level. )
	. Bookkeeper: Record resource utilization as tasks complete.
	. WorldBase: Record events, maintain entity state data. 
	An active user / client session will also include session-bound instances of a:
	. Dialog Agent: Conduct dialog with user / client actor. 
	. Scribe: Mediate between Dialog and User Interface technology. 
	. Ontology: A Dialog Agent interprets dialog vignettes found in a specific ontology.
	Each running plan will also include an instance of a:
	. Coordinator: Coordinate plan execution. (Tracks work-in-progress at plan level.)
	. Ontolog: An ontology must be present at the time the plan is built.
	"
	self skip.
]

{ #category : #'Network Tests' }
HumRunTimeTests >> test100ReadMe [
	"Network is a wrapper on whatever technology is used to communicate between Actors."
	|    |
	self skip.
"Features:"
	"The Network sends/receives messages (wrapping the communication technology)."	
	"The Network component provides serialization and de-serialization of Message instances (see HumMessage)."
	"Design Note: The serialization strategy assumes 'payload' is not sensitive to communication stack."
	
	"TBD: Consider Erlang strategy and interface. Assume most tests will be on the Erlang side."

]

{ #category : #'Actor Tests' }
HumRunTimeTests >> test105actorConfiguration [
	"A Hum Actor is configured with the address of a messenger node.
	Actors communicate by sending predefined message types via the messenger.
	"
	|   messenger worker dispatcher   bookkeeper |
	true ifFalse: [ Transcript cr; show: 'test105actorConfiguration is TURNED OFF'; cr. ^self].
	"Create the (mock) messenger service"
	messenger := HumMessenger uri: 'mock messenger URI'.
	self assert: ( messenger uri  sameAs: 'mock messenger URI' ).
	
	"A resource dispatcher must know a messenger and a bookkeeper."
	dispatcher := HumActor dispatcherID: 'test dispatcher'  
	                        uri: 'mock dispatcher URI' 
	              configuration: setupConfiguration.
	self assert: ( dispatcher isKindOf: HumDispatcher ).
	self assert:  dispatcher uri sameAs: 'mock dispatcher URI'.
	
	"A bookkeeper must know a messenger and a world base."					
	bookkeeper := HumActor bookkeeperID: 'test bookkeeper'  
	                              uri: 'mock bookkeeper URI' 
	                    configuration: setupConfiguration.
	self assert: bookkeeper uri sameAs: 'mock bookkeeper URI'.		
						
	"A worker must know a messenger and a dispatcher and some roles"
	worker := HumActor workerID: 'test cook ID' uri: 'test cook URI' roles: #( 'cook' 'bottle-washer' 'bar-tender' 'psych' ) configuration: setupConfiguration. 
	self assert: worker uri sameAs:  'test cook URI'.
	
	
	
	
]

{ #category : #'Actor Tests' }
HumRunTimeTests >> test110workerChecksIn [
	"Worker checks-in, announcing roles."
	"The check-in protocol has the worker-side and the resource dispatcher side."
	"Worker says:
	. dispatcher: Check-in worker W with roles R.
	The dispatcher adds the worker to its (role -> worker) knowledge."
	|  worker dispatcher |
	
	"Get the worker from the setup."
	worker := setupWorker.
	self assert: ( worker isKindOf: HumActor ).
	self assert: ( worker roles include: 'serf' ).
	
	"Get the resource dispatcher from the setup."
	dispatcher := setupDispatcher.
	self assert: ( dispatcher isKindOf: HumDispatcher ).
	
	"Execute the check-in directly."
	dispatcher checkInActor: 'worker id' at: 'worker uri' withRoles: worker roles.
	
	"dispatcher now includes worker in set of those who know that role."
	self assert: ( dispatcher roleActor includes: ( 'serf' -> 'worker id' ) ).
	
	
	
]

{ #category : #'Actor Tests' }
HumRunTimeTests >> test120workerCheckInMessage [
	"Worker checks-in, announcing roles."
	"The check-in protocol has the worker-side and the resource dispatcher side."
	"Worker says:
	. dispatcher: Check-in worker W with roles R.
	The dispatcher adds the worker to its (role -> worker) knowledge."
	|  worker dispatcher message |
	
	"Get the worker from the setup."
	worker := setupWorker.
	self assert: ( worker isKindOf: HumActor ).
	self assert: ( worker roles include: 'serf' ).
	
	"Get the resource dispatcher from the setup."
	dispatcher := setupDispatcher.
	self assert: ( dispatcher isKindOf: HumDispatcher ).

	"Use a Smalltalk coded message to tell dispatcher."
	"To: Execute the check-in directly, we would say:"
	"dispatcher checkInActor: worker name at: 'worker uri' withRoles: worker roles."
	
	message := 'self checkInActor: ', ('worker id') quoted, ' at: ', ('worker uri') quoted, ' withRoles: #(', ('cook') quoted, ').'.
	HumCompiler evaluate: message for: dispatcher logged: false.
	
	"dispatcher now includes worker in set of those who know that role."
	self assert: ( dispatcher roleActor includes: ( 'cook' -> 'worker id' ) ).
	

]

{ #category : #'Actor Tests' }
HumRunTimeTests >> test130workerChecksInViaMessenger [
	"Worker checks-in, announcing roles."
	"The check-in protocol has the worker-side and the resource dispatcher side."
	"Worker says:
	. dispatcher: Check-in worker W with roles R.
	The dispatcher adds the worker to its (role -> worker) knowledge."
	|  worker dispatcher |
	
	"Get the worker from the setup."
	worker := setupWorker.
	
	"Get the resource dispatcher from the setup."
	dispatcher := setupDispatcher.
	self assert: ( dispatcher isKindOf: HumDispatcher ).

	"Tell the worker to check-in."
	worker checkIn.
	
	"dispatcher now includes worker in set of those who know that role."
	self assert: ( dispatcher roleActor includes: ( 'serf' -> worker id ) ).
	
]

{ #category : #'Actor Tests' }
HumRunTimeTests >> test135workerChecksOutViaMessenger [
	"Worker checks-in, announcing roles."
	"The check-in protocol has the worker-side and the resource dispatcher side."
	"Worker says:
	. dispatcher: Check-in worker W with roles R.
	The dispatcher adds the worker to its (role -> worker) knowledge."
	|  worker dispatcher |
	
	"Get the worker from the setup."
	worker := setupWorker.
	
	"Get the resource dispatcher from the setup."
	dispatcher := setupDispatcher.
	self assert: ( dispatcher isKindOf: HumDispatcher ).

	"Tell the worker to check-in."
	worker checkIn.
	
	"dispatcher now includes worker in set of those who know that role."
	self assert: ( dispatcher roleActor includes: ( 'serf' -> worker id ) ).
	
	"Tell the worker to check-out."
	worker checkOut.
	self assert: ( dispatcher roleActor includes: ( 'serf' -> worker id ) ) not.
	
]

{ #category : #'Dispatcher Tests' }
HumRunTimeTests >> test200DispatcherReadMe [
"The Dispatcher (RM) - assigns tasks to actors.
   1. Actor checks-in (announces availability to perform specific roles).
   2. Assign task (action-statement) to actor.
      a) Job-ticket contains action-statement, noun-values, 
            request context (requesting actor, and instruction-pointer).
      b) The RM assigns an available actor.
      c) The RM sends the job-ticket to the assigned actor. 
            (via Messenger)
   3. Actor has completed task.
      a) The resources consumed (actor’s time, etc) are recorded on the job ticket.
      b) Any computed results are added to the job-ticket.
            (Convention: Actions with results have a 'giving' clause.)
      c) RM sends resource consumption data to Bookkeeper.
      d) Task complete notice (with job-ticket) is sent to requester.
            (The requester resumes execution of the plan.)
   4. Delegate task.
         (The current actor has delegated a task to another role.)
      a) Send delegated task to Dispatcher. (RM)
         (The RM will assign the task to an available actor.) 
      b) If an actor delegates to a role which it also knows, 
           the delegated action is assigned to the same actor.
      c) Persist actor state during a delegation
         (Since delegations may be long-running, 
          we need a way to persist actor state during a delegation.)
					Q: Where is the push-down stack in this context? Does the RM maintain it? (A: Basically, yes.)
					Q: Does the actor persist its own state while suspended or does the RM maintain it? (A: Actor via BB)
					Solution-1: If the target framework (e.g. Erlang OTP) maintains state, we do not need to.
					Solution-2: Perhaps, the RM should maintain caller`s state during a delegation. 
					Solution-2.1: This has the advantage of being able to survey the complete application state in one place.
					Solution-2.2: But we could also do that by querying the WorldBase or active actors. (See solution-3 next.)
					Solution-3: The Hum persistence framework (BlackBoard plus WorldBase) persists the actor`s state.    <<<
					Solution-3.1: State is in the actor`s BlackBoard (BB), and the BB implements a 'resume' capability.  <<<
					Solution-3.2: This implies: RM sees delegate return ==> sends resume to actor ==> BB is persistent.  <<<
					Solution-3.3: BB saves/fetches (snapshots) to/from WorldBase (WB). ==> Lots of eggs in WB !!!!
					solution-3.4: The actor supertype message-receive interface will activate the BB, et cetera.
   5. Resume suspended action.
         When a instruction is delegated to another role, the current task execution is suspended.
         When the delegation (call) completes, the requestor resumes execution.
   6. Maintain model of all the known actors` assignment-state. 
			Actors may be idle, engaged, suspended. 
			(Note: Actor instances are 'single-threaded' but may delegate instructions to self.)
			. Idle: No action assigned. (Actor is available for suitable assignments.)
			. Engaged: An action is assigned but not yet completed. (Action is in-progress)
			. Suspended: An action instruction has been delegated to another actor. (This actor is waiting for other actor.)
			
"
]

{ #category : #'Dispatcher Tests' }
HumRunTimeTests >> test210DispatcherAssignsAction [
	"Some actor delegates a task to a role.
	The Dispatcher assigns the task to an actor that advertises that role
	and sends the task (work order) to the assigned actor.
	"
	| baker  bookkeeper oven ontology frameEditor jobTicket actionInstruction dispatcher frameEditor2 |
	true ifFalse: [ Transcript cr; show: 'test210DispatcherAssignsAction turned off'; cr. ^self].
	
	"Get the Dispatcher from the setup."
	dispatcher := setupDispatcher.
	self assert: ( dispatcher isKindOf: HumDispatcher ).

	"Create a baker worker"
	baker := HumActor workerID: 'bakerId' uri: 'bakerURI' roles: #('baker') configuration: setupConfiguration.
	self assert: (baker uri sameAs: 'bakerURI').
	"Create another actor to be oven. " 
	oven := HumActor workerID: 'ovenID' uri: 'ovenURI' roles: #( 'oven' ) configuration: setupConfiguration.
	self assert: (oven uri sameAs:  'ovenURI' ).

	"Tell the actors to check-in."
	baker checkIn.
	oven checkIn.
	
	"======= Set up the action frame  =========="
	ontology := setupConfiguration ontology.
	
	"Initialize for an Action Frame."
	frameEditor := HumFrameUpdater ontology: ontology  
	                                   role: 'Baker' 
	                                 action: 'Bake the pan in the oven for the time given in the recipe.'.
	"Append an instruction that is delegated"
	frameEditor 
			appendInstructionRole: 'Oven' statement: 'Bake for the time given in recipe.';
	 		storeFrameInOntology .
	"We need at least one noun."
	ontology addNoun: 'recipe'.
	
	frameEditor2 := HumFrameUpdater ontology: ontology
	 																	role: 'Oven'
																		action: 'Bake for the time given in recipe.'.
	frameEditor2
			appendInstructionStatement: ' Set oven timer to the time given in recipe.';
			appendInstructionStatement: ' Set oven temperature to the temperature given in recipe.';
			appendInstructionStatement: ' Start.';
			storeFrameInOntology.
			
	"============== ================="
	"We will pretend to be Coordinator running a plan.
	There will be a Job Ticket for the plan.
	The Coordinator will ask the Dispatcher to assign an actor to run the action.
	"
	jobTicket := HumJobTicket title: 'test210DispatcherAssignsAction'.
	self assert: ( jobTicket isKindOf: HumEntity ).
	actionInstruction := HumInstructionLine role: 'Baker' statement: 'Bake the pan in the oven for the time given in the recipe.'.
  	actionInstruction statement noun: 'recipe' value: 'white cake'.
	actionInstruction jobTicket: jobTicket.
	dispatcher assignRole: 'Baker' action: actionInstruction.
	"After the task is done, a resource usage entry will be sent to the bookkeeper."
	bookkeeper := setupBookkeeper.
	self assert: ( bookkeeper isKindOf: HumBookkeeper ).
	self assert: ( bookkeeper jobTickets size > 0 ).
	"See also: Bookkeeper tests."
	

]

{ #category : #'Coordinator Tests' }
HumRunTimeTests >> test300CoordinatorReadMe [
"Coordinator - controls execution of plans and dialogs.
   1. Execute Plans.
			a) When a plan is evaluated, 
			   the coordinator scans plan frames to find those whose actions are executable.
			b) When a plan frame is executable, its action instructions are executed. (Sent to Dispatcher)
			c) After the last plan action is executed, the plan frame`s post condition is asserted.
			d) If an post-condition is the plan`s goal, we are done.
			e) Iterate.
			
	2. Provide a viewable model showing the execution state of each (every) plan frame in a running plan.
			The State of plan frame may be pending / executing / suspended / fulfilled.
			. Pending: The pre-conditions have not been satisfied.
			. Executing: The plan actions statement/s are executing.
			. Suspended: The execution of the action statements has been extended (Some business exception occurred.).
			. Fulfilled: The post-condition has been asserted.		
			
			"
]

{ #category : #'Coordinator Tests' }
HumRunTimeTests >> test310coordinatorRunsPlan [
	"Dialog:
	 . Coordinator to Dispatcher: Run action A for job J.
	 . Dispatcher to Coordinator: Action A completed on job J.
	"
	| ontology planFrame dictionaryFrame  actionFrame coordinator dialogAgent |
		
	true ifFalse: [ Transcript cr; show: 'test310coordinatorRunsPlan turned off'; cr. ^self].
	"Create an ontology."
	ontology := setupConfiguration ontology.

	"Define a few nouns."
	dictionaryFrame := HumFrame4Dictionary ontology: ontology title: 'Song vocabulary'.
	dictionaryFrame addDictionaryLine: 'Song attributes include title, lyrics, melody-notes.'.
	"Compile it"
	dictionaryFrame compileToOntology: ontology.

	"Define a simple plan."
	setupConfiguration ontology: ontology.
	planFrame := HumFrame4Plan ontology: ontology goal: 'Plan has one frame with no preconditions.'.
	planFrame appendRole: 'cook' action: 'Sing song called title.'.
	
	"Create the corresponding action frame."
	actionFrame := HumFrame4Action ontology: ontology role: 'cook' action: 'Sing song called title.'.
	actionFrame 
			appendInstructionStatement: ' Open music book to given song title.';
			appendInstructionStatement: ' Read song melody-notes and lyrics.';
			appendInstructionStatement: ' Sing song melody-notes and lyrics.'.
			
	"Store it in the ontology."
	ontology storeFrame: planFrame.
	ontology storeFrame: actionFrame.
	
	"Compile it."
	planFrame compileToOntology: ontology.
	actionFrame compileToOntology: ontology.
	""
	dialogAgent := HumActor dialogID: 'test dialog ID' 
	                           uri: 'test dialog URL' 
	                        client: 'client ID' 
	                 configuration: setupConfiguration.
	dialogAgent checkIn.
	
	"Create a running instance of the plan and a coordinator to run it."
	coordinator := HumActor coordinatorID: 'test coordinator ID' 
	                              uri: 'test coordinator URL' 
	                             goal: 'Plan has one frame with no preconditions.'
								            dialog: dialogAgent
	                    configuration: setupConfiguration.
	self assert: (coordinator isKindOf: HumCoordinator ).			
	coordinator checkIn.	
	
	"Run the plan."
	coordinator runPlan.
		
	"After that plan has run. The goal will be fulfilled."
	 self assert: ( coordinator remainingConditions isEmpty ).

	"Now there should be at least one change on the job ticket."
	self assert: ( coordinator jobTicket charges notEmpty ) description: 'Job Ticket should not be empty'.
	 
]

{ #category : #'Coordinator Tests' }
HumRunTimeTests >> test320coordinatorInvokesAction [
	"Goal: Plan has one frame with no preconditions.
	 Action:
	 . Cook: Sing song called title.
	"
	| ontology planFrame dictionaryFrame  actionFrame coordinator dialogAgent charges |
	true ifFalse: [ Transcript cr; show: 'test320coordinatorInvokesAction turned off'; cr. ^self].

	ontology := HumOntology new.	

	"Define a few nouns."
	dictionaryFrame := HumFrame4Dictionary ontology: ontology title: 'Song vocabulary'.
	dictionaryFrame addDictionaryLine: 'Song attributes include title, lyrics, melody-notes.'.
	"Compile it"
	dictionaryFrame compileToOntology: ontology.

	"Define a simple plan."
	setupConfiguration ontology: ontology.
	planFrame := HumFrame4Plan ontology: ontology goal: 'Plan has one frame with no preconditions.'.
	planFrame appendRole: 'cook' action: 'Sing song called title.'.
	
	"Create the corresponding action frame."
	actionFrame := HumFrame4Action ontology: ontology role: 'cook' action: 'Sing song called title.'.
	actionFrame 
			appendInstructionStatement: ' Open music book to given song title.';
			appendInstructionStatement: ' Read song melody-notes and lyrics.';
			appendInstructionStatement: ' Sing song melody-notes and lyrics.'.

	"Store it in the ontology."
	ontology storeFrame: planFrame.
	ontology storeFrame: actionFrame.
	
	"Compile it."
	planFrame compileToOntology: ontology.
	actionFrame compileToOntology: ontology.
	""
	dialogAgent := HumActor dialogID: 'test dialog ID' 
	                           uri: 'test dialog URL' 
	                        client: 'client ID' 
	                 configuration: setupConfiguration.
	"Create a running instance of the plan and a coordinator to run it."
	setupConfiguration ontology: ontology.
	coordinator := HumActor coordinatorID: 'test coordinator ID' 
	                              uri: 'test coordinator URL' 
	                             goal: 'Plan has one frame with no preconditions.'
								            dialog: dialogAgent
	                    configuration: setupConfiguration.
	self assert: (coordinator isKindOf: HumCoordinator ).			
	coordinator checkIn.	
	
	"Run the plan."
	coordinator runPlan.
		
	"After that plan has run. The goal will be fulfilled."
	 self assert: ( coordinator remainingConditions isEmpty ).

	"Now there should be at least one change on the job ticket."
	charges := coordinator jobTicket charges.
	self expect: 3 actual: ( charges size ) description: 'Expecting 3 charges.'
	
	 

	


]

{ #category : #'Coordinator Tests' }
HumRunTimeTests >> test330twoPlanFrames [
	"Test with two plan frames.
	"
	| coordinator ontology  planFrameA planFrameB dictionaryFrame actionFrameA actionFrameB charges |
	ontology := HumOntology new.
	"Root frame has one prereq and one action"
	planFrameA := HumFrame4Plan ontology: ontology goal: 'Complete the whole plan.'.
	planFrameA 
			appendPrecondition: 'Have song with title.';
	 		appendRole: 'Singer' action: 'Sing song with title.'; 	   
	 		compileToOntology: ontology.
	"Create the corresponding action frame."
	actionFrameA := HumFrame4Action ontology: ontology role: 'Singer' action: 'Sing song with title.'.
	actionFrameA 
			appendInstructionStatement: ' Open music book to given song title.';
			appendInstructionStatement: ' Read song melody-notes and lyrics.';
			appendInstructionStatement: ' Sing song melody-notes and lyrics.';
			compileToOntology: ontology.
	
	"Second level frame with no prereq and one action"	
	planFrameB := HumFrame4Plan ontology: ontology goal: 'Have song with title.'.
	planFrameB 
			appendRole: 'Composer' action: 'Compose song with title.';
		 	compileToOntology: ontology.
		"Create the corresponding action frame."
	actionFrameB := HumFrame4Action ontology: ontology role: 'Composer' action: 'Compose song with title.'.
	actionFrameB 
			appendInstructionStatement: ' Publish music book with given song title.';
			compileToOntology: ontology.
	
	"We need at least one noun."
	dictionaryFrame := HumFrame4Dictionary ontology: ontology title: 'Song has title, composer, et cetera'.
	dictionaryFrame 
			addDictionaryLine: 'Song attributes include title, composer, melody.';
	 		compileToOntology: ontology.
		
	setupConfiguration ontology: ontology.
	coordinator := HumCoordinator coordinatorID: 'coordinator ID' 
																		uri: 'myURI' 
																		goal: 'Complete the whole plan.' 
																		dialog: (HumDialogAgent new) 
																		configuration: setupConfiguration. 
																	
	coordinator checkIn.
	coordinator runPlan.
	
	self assert: (coordinator jobTicket notNil ).
	charges := coordinator jobTicket charges.
	self expect: 4 actual: ( charges size )description: 'Expecting N charges.'.

]

{ #category : #'Coordinator Tests' }
HumRunTimeTests >> test340planTreeBranches [
	"Test a plan tree with several levels and significant branching.
	"
	| coordinator ontology  planFrameA planFrameB1 planFrameB2 planFrameB3 planFrameC dictionaryFrame baker mixer oven actionFrameA actionFrameB1 actionFrameB2 actionFrameB3 actionFrameC |
	ontology := HumOntology new.

	"The root frame of this plan tree has several preconditions."
	planFrameA := HumFrame4Plan ontology: ontology goal: 'Cake is baked per recipe.'.
	planFrameA 
		appendPrecondition: 'Oven is preheated per recipe.';
	 	appendPrecondition: 'Cake batter is mixed per recipe.';
	 	appendPrecondition: 'Cake-pan is greased.';
	 	appendRole: 'baker' action: 'Bake cake batter in cake pan for recipe time.';
	 	compileToOntology: ontology.
	"Corresponding action frame:"
	actionFrameA := HumFrame4Action ontology: ontology role: 'baker' action: 'Bake cake batter in cake pan for recipe time.'.
	actionFrameA 
		appendInstructionStatement: 'Dummy statement.'; 
		compileToOntology: ontology.

	"Second level frame -- This frame has a precondition, therefore a third level will be needed."
	planFrameB1 := HumFrame4Plan ontology: ontology goal: 'Cake batter is mixed per recipe.'.
	planFrameB1 appendPrecondition: 'Cake ingredients, per recipe, are assembled on mixing counter.'.
	planFrameB1 appendRole: 'mixer' action: 'Mix ingredients per recipe.'.	
	planFrameB1 compileToOntology: ontology.
	"Corresponding action frame:"
	actionFrameB1 := HumFrame4Action ontology: ontology role: 'mixer' action: 'Mix ingredients per recipe.'.
	actionFrameB1 
		appendInstructionStatement: 'Dummy statement.'; 
		compileToOntology: ontology.
	
	"Another second level frame - has no precondtions at this time."
	planFrameB2 := HumFrame4Plan ontology: ontology goal: 'Oven is preheated per recipe.'.
	planFrameB2 appendRole: 'oven' action: 'Preheat to temperature given by recipe.'.
	planFrameB2 compileToOntology: ontology.
	"Corresponding action frame:"
	actionFrameB2 := HumFrame4Action ontology: ontology role: 'oven' action: 'Preheat to temperature given by recipe.'.
	actionFrameB2 
		appendInstructionStatement: 'Dummy statement.'; 
		compileToOntology: ontology.
	
	"Still another second level frame - has no preconditions at this time."
	planFrameB3 := HumFrame4Plan ontology: ontology goal: 'Cake-pan is greased.'.
	planFrameB3 appendRole: 'mixer' action: 'Grease a cake-pan.'.
	planFrameB3 compileToOntology: ontology.
	"Corresponding action frame:"
	actionFrameB3 := HumFrame4Action ontology: ontology role: 'mixer' action: 'Grease a cake-pan.'.
	actionFrameB3 
		appendInstructionStatement: 'Dummy statement.'; 
		compileToOntology: ontology.
	
	"Third level frame - has no preconditions at this time."
	planFrameC := HumFrame4Plan ontology: ontology 
	                                goal: 'Cake ingredients, per recipe, are assembled on mixing counter.'.
	planFrameC appendRole: 'mixer' action: 'Assemble cake ingredients per recipe on mixing counter.'.
	planFrameC compileToOntology: ontology.
	"Corresponding action frame:"
	actionFrameC := HumFrame4Action ontology: ontology role: 'mixer' action: 'Assemble cake ingredients per recipe on mixing counter.'.
	actionFrameC 
		appendInstructionStatement: 'Dummy statement.'; 
		compileToOntology: ontology.
	
	"We need at least one noun."
	dictionaryFrame := HumFrame4Dictionary ontology: ontology title: 'Cake recipe vocabulary'.
	dictionaryFrame addDictionaryLine: 'Recipe attributes include title, ingredients, steps.'.
	dictionaryFrame addDictionaryLine: 'Cake-Recipe attributes include oven-temperature, oven-time.'.
	dictionaryFrame addDictionaryLine: 'A pan is a container.'.
	dictionaryFrame addDictionaryLine: 'A bowl is a container.'.
	dictionaryFrame addDictionaryLine: 'A cake-pan is a baking-pan.'.
	dictionaryFrame compileToOntology: ontology.
		
	setupConfiguration ontology: ontology.
	coordinator := HumCoordinator coordinatorID: 'coordinator ID' 
																		uri: 'myURI' 
																		goal: 'Cake is baked per recipe.' 
																		dialog: (HumDialogAgent new) 
																		configuration: setupConfiguration.
	coordinator checkIn.
	
	baker := HumActor workerID: 'bakerID' uri: 'bakerURI' roles: #('baker') configuration: setupConfiguration.
	baker checkIn.
	mixer := HumActor workerID: 'mixerID' uri: 'mixerURI' roles: #('mixer') configuration: setupConfiguration.
	mixer checkIn.
	oven := HumActor workerID: 'ovenID' uri: 'ovenURI' roles: #('oven') configuration: setupConfiguration.
	oven checkIn.
	
	coordinator runPlan.
	
	self assert: (coordinator jobTicket notNil ).
	self assert: (coordinator jobTicket charges notEmpty ) description: 'Job ticket should show charges.'.
	self assert: (coordinator jobTicket charges size = 5 ).
	"
	Transcript cr; show: 'test340planTreeBranches'.
	coordinator getActionSequence do: [:action | Transcript cr; show: action ].
	Transcript cr.
	"

]

{ #category : #'Bookkeeper Tests' }
HumRunTimeTests >> test400BookkeeperReadMe [
	"A Bookkeeper tracks resource utilization.
	It maintains resource utilization accounts, but at a fundamental level, 
	those accounts are denominated in resource measures, not monetary measures.
	This enables detailed cost accounting. 
	However, most industries and companies have their own unique monetization rules;
	so, we do not attempt to build those into the Bookkeeper.
	But the Bookkeeper can be extended to include monetization rules. 
	TODO: Experiment with a subtype that prices the resource utilization.
	"
]

{ #category : #'Bookkeeper Tests' }
HumRunTimeTests >> test410BookkeeperRecordsJobTickets [
	"If we ask the bookkeeper to 'run' a jobTicket, it stores it in its jobTickets collection.'"
	| ticket bookie |
	ticket := HumJobTicket title: 'test410BookkeeperRecordsJobTickets'.
	bookie := setupBookkeeper.
	bookie recordJobTicket: ticket.
	self assert: ( bookie jobTickets includes: ticket ) .
]

{ #category : #'Bookkeeper Tests' }
HumRunTimeTests >> test420BookkeeperSums [
	"The bookkeeper tracks utilization of an actor by action, actor, role, job.
	"
	| ticket bookie action  aJobID |
	
	ticket := HumJobTicket title: 'test420BookkeeperSums'.
	action := 'This is only a test of the bookkeeper.'.
	aJobID := UUID new.
	
	"Measures are tracked by action, role, actor, and job."
	#( 1 3 5 ) 
		do: [ :q | 
			| m anID aRoleName |
			m := HumMeasure quantity: q units: #step.
			anID := 'test actor ID', q asString.
			aRoleName := 'tester', q asString.
			ticket appendCharge: m forAction: action byActor: anID inRole: aRoleName onJob: aJobID . 
			m := HumMeasure quantity: q*10 units: #kilometer.
			ticket appendCharge: m forAction: action byActor: anID inRole: aRoleName onJob: aJobID . 
			].
  
  "Send to bookkeeper."
	bookie := setupBookkeeper.
	bookie recordJobTicket: ticket.
	self assert: ( bookie jobTickets includes: ticket ) .
	
	"Bookkeeper tracks utilization by Action."
	self assert: ( bookie chargesByAction size = 2).
	"Bookkeeper tracks utilization by Actor."
	self assert: ( bookie chargesByActor size = 6).
	"Bookkeeper tracks utilization by Role."
	self assert: ( bookie chargesByRole size = 6).
	"Bookkeeper tracks utilization by Job."
	self assert: ( bookie chargesByJob size = 2).
	"Sum by metric (calls, steps, gross counts)"
	self assert: ( bookie chargesByMetric size = 2).
	self assert: ( bookie chargesByMetric at: 'total:step') = (HumMeasure quantity: 9 units: #step).
	self assert: ( bookie chargesByMetric at: 'total:kilometer') = (HumMeasure quantity: 90 units: #kilometer).
	
	false ifTrue: [ "Inspect result"
		| sums |
		sums := bookie chargesByRole.
		sums inspect.
		].
	
]

{ #category : #'WorldBase Tests' }
HumRunTimeTests >> test600WorldBaseReadMe [
	"
	A WorldBase implements the 'corporate memory' of an enterprise.
	It is a kind of temporal database 
	 which means each record is related to a business (world) event.
	
	BlackBoards provide fast-memory persistence for Actors.
	The WorldBase provides fail-back memory for BlackBoards.
	The WorldBase implements an Entity-Attribute model of the world.
	Entities have Attributes. Attributes have values which are time-stamped.
	The time-stamps are associated with world events. (as observed by Hum Actors)
	
	The basic persistence strategy is 'Remember everything short-term, forget some things later.'
	(Short-form: 'Persist now, purge later.')
	
	Retention rules are defined in terms of how-long (minutes, days, years) old attribute values are retained.
	Many corporate legal departments prefer that old data be 'purged' to reduce 'discovery' costs and risks.
	To be 'purged' means the data is erased from main repositories and archives.
	The implementation of retention rules is currently low-priority. (We have to remember before we can forget.)
	"
]

{ #category : #'WorldBase Tests' }
HumRunTimeTests >> test610CreateWorldBaseInstance [
	"Create an instance of a Hum World Base (a database to be shared by multiple actors)."
	| worldBase |
	worldBase := HumWorldBase openWorldBase: 'test610CreateWorldBaseInstance'.
	self assert: worldBase notNil.
	self assert: ( worldBase title = 'test610CreateWorldBaseInstance' ).
]

{ #category : #'WorldBase Tests' }
HumRunTimeTests >> test615CreateUniqueIdentifier [
	"Create an instance of a Hum World Base (a database to be shared by multiple actors)."
	|  id |
	id := HumIdentifier createUniqueIdentifierForEntityName: 'test615' inContext: 'test615CreateUniqueIdentifier'.
	self assert: (id isKindOf: HumIdentifier).
	
	
]

{ #category : #'WorldBase Tests' }
HumRunTimeTests >> test616CreateUniqueIdentifierDoesNotBreak [
	"Create an instance of a Hum World Base (a database to be shared by multiple actors)."
	|  id newerID nTrial |
	id := HumIdentifier createUniqueIdentifierForEntityName: 'test616CreateUniqueIdentifierDoesNotBreak' inContext: 'test616CreateUniqueIdentifierDoesNotBreak'.
	self assert: (id isKindOf: HumIdentifier).
	
	"Make sure it can handle high rate."
	nTrial := 1000.
	newerID := Array new: nTrial.
	( 1 to: nTrial ) 
		do: [:i | newerID at: i put: ( HumIdentifier createUniqueIdentifierForEntityName: ('try:',(nTrial asString) ) inContext: ('try:',(nTrial asString) ) ).].
	
	self assert: (( id = (newerID at: nTrial) ) not).
]

{ #category : #'WorldBase Tests' }
HumRunTimeTests >> test620setAndGet [
	"set entity-attribute value"
	| worldBase entity value |
	worldBase := HumWorldBase openWorldBase: 'WorldBase for test620setAndGet'.
	self assert: worldBase notNil.
	self assert: ( worldBase title = 'WorldBase for test620setAndGet' ).
	
	entity := HumEntity title: 'Entity for test620setAndGet'.
	worldBase setEntityID: (entity id) attribute: #description toValue: 'This is only a test.'.
	value := worldBase getEntityID: (entity id) attribute: #description.
	self assert: ( value == 'This is only a test.').
]

{ #category : #'WorldBase Tests' }
HumRunTimeTests >> test630setGetReplace [
	"set entity-attribute value"
	| worldBase entity value |
	worldBase := HumWorldBase openWorldBase: 'test630setGetReplace'.
	self assert: worldBase notNil.
	self assert: ( worldBase title = 'test630setGetReplace' ).
	
	entity := HumEntity title: 'Entity for test630setGetReplace'.
	worldBase setEntityID: (entity id) attribute: #description toValue: 'This is only a test.'.
	value := worldBase getEntityID: (entity id) attribute: #description.
	self assert: ( value == 'This is only a test.').
	
	worldBase setEntityID: (entity id) attribute: #description toValue: 'This WAS only a test.'.
	value := worldBase getEntityID: (entity id) attribute: #description.
	self assert: ( value == 'This is only a test.') not.
	self assert: ( value == 'This WAS only a test.').
	
	
]

{ #category : #'WorldBase Tests' }
HumRunTimeTests >> test640FindWhere [
	"set entity-attribute value"
	| worldBase entityA entityB entitySet |
	worldBase := HumWorldBase openWorldBase: 'test640FindWhere'.
	self assert: worldBase notNil.
	self assert: ( worldBase title = 'test640FindWhere' ).
	
	"Insert two entity instances with attribute vlaues."
	entityA := HumIdentifier createUniqueIdentifierForEntityName: 'Person:A' inContext: 'test640FindWhere'.
	worldBase setEntityID: entityA attribute: 'first-name' toValue: 'Tessie'.	
	worldBase setEntityID: entityA attribute: 'last-name'  toValue: 'Tester'.	
	
	entityB := HumIdentifier createUniqueIdentifierForEntityName: 'Person:B' inContext: 'test640FindWhere'.
	worldBase setEntityID: entityB attribute: 'first-name' toValue: 'Terry'.	
	worldBase setEntityID: entityB attribute: 'last-name'  toValue: 'Terrence'.	
	
	"Return a set of entity identifiers satisfying my criteria."
	entitySet := worldBase whereAttribute: 'first-name' satisfies: [:name | name beginsWith: 'T'].
	self expect: 2 actual: (entitySet size).
	
	"entitySet sorted asArray inspect."
	
	"TODO: Decide: EntityType is innate. EntityType is an attribute."
	
	
]

{ #category : #'Blackboard Tests' }
HumRunTimeTests >> test700BlackBoardReadMe [
	"
	Each active actor records its state on a BlackBoard instance.
	The BlackBoard instance may persist its data on a WorldBase singleton.
	"
	"
	Hum BlackBoard client situations (use cases):
	A Coordinator is operating a plan. The plan has context and state.
	A Dispatcher tracks a number of Actors, their Roles, and their execution state.
	A Dialog Agent may have a long-running Dialog with associated data.
	A Messenger must remember the URI (network addresses) associated with actor IDs.
	When an actor delegates an instruction to another actor, (like RMI)
	  the 'caller' must persist its state until the delegation 'returns' 
	  so that the caller can resume execution with saved state and instruction-pointer.
	  Note: The saved state may be 'updated/amended' if the delegation has a 'giving' clause.
	"
]

{ #category : #'Blackboard Tests' }
HumRunTimeTests >> test710setAndGet [
	"set entity-attribute value"
	| blackboard entity value |
	blackboard := HumBlackBoard new.
	blackboard worldbase: ( HumWorldBase new ).
	blackboard businessEvent: 'test710setAndGet'.
	entity := HumEntity title: 'Entity for test710setAndGet'.
	"Set entity-attribute value."
	blackboard setEntityID: (entity id) attribute: #description toValue: 'This is only a test.'.
	value := blackboard getEntityID: (entity id) attribute: #description.
	self assert: ( value == 'This is only a test.').
]

{ #category : #'Blackboard Tests' }
HumRunTimeTests >> test720setGetReplace [
	"Update entity-attribute value"
	| blackboard entity value |
	blackboard := HumBlackBoard new.
	blackboard worldbase: ( HumWorldBase new ).
	blackboard businessEvent: 'test720setGetReplace'.
	entity := HumEntity title: 'Entity for test720setGetReplace'.

	blackboard setEntityID: (entity id) attribute: #description toValue: 'This is only a test.'.
	value := blackboard getEntityID: (entity id) attribute: #description.
	self assert: ( value == 'This is only a test.').
	
	blackboard setEntityID: (entity id) attribute: #description toValue: 'This WAS only a test.'.
	value := blackboard getEntityID: (entity id) attribute: #description.
	self assert: ( value == 'This is only a test.') not.
	self assert: ( value == 'This WAS only a test.').

]

{ #category : #'Blackboard Tests' }
HumRunTimeTests >> test730clearEntity [
	"Update entity-attribute value"
	| blackboard value worldbase |
	
	self skip. "Why would we need to clear a real-world entity`s attribute values? "
	
	blackboard := HumBlackBoard new.
	worldbase := HumWorldBase openWorldBase: 'worldbase for test730clearEntity'.
	blackboard worldbase: worldbase.
	blackboard businessEvent: 'test730clearEntity'.
	
	blackboard setEntityName: 'Tester' attribute: #description toValue: 'This is only a test.'.
	value := blackboard getEntityName: 'Tester' attribute: #description.
	self assert: ( value == 'This is only a test.').
	blackboard clearEntity: 'Tester'.
	
	self expect: 0 actual: (blackboard entityIdentifiers size).
	self expect: 0 actual: (blackboard quads size).
	self expect: 1 actual: (worldbase quads size).
	self expect: 0 actual: (worldbase history size).
	
	blackboard setEntityName: 'Tester' attribute: #description toValue: 'This WAS only a test.'.
	self expect: 1 actual: (blackboard entityIdentifiers size).
	self expect: 1 actual: (blackboard quads size).
	self expect: 2 actual: (worldbase quads size).
	self expect: 0 actual: (worldbase history size).
	
	value := blackboard getEntityName: 'Tester' attribute: #description.
	self assert: ( value == 'This is only a test.') not.
	self assert: ( value == 'This WAS only a test.').

]

{ #category : #'Dialog Tests' }
HumRunTimeTests >> test800DialogAgentReadMe [
	"
Dialogs:
	A Dialog Agent instance is associated with each active dialog.
  Active dialogs are long-running; 
	so the state of the dialog must be persisted indefinitely.
Session:
	A session is defined by a connection to some client/user interface (UI) technology.
	Between sessions, the state of the dialog is persisted.
	When a new session begins, 
	 the state is restored to assure continuity in the conversation.
	(The user should feel that we remember them and what was said in the prior session.)
Scribes:
	When a dialog session is initiated, a Scribe is already present.
	The Scribe mediates between the Dialog (Dialog Agent) and the user interface.
	The Scribe translates user gestures into dialog vignette 'speech' inputs.
	See: The Scribe ReadMe for more detail about the scribe.
Clients:
	It is generally assumed that the client actor will be human user.
	However, dialogs may also be written for automated actors.
	"
]

{ #category : #'Dialog Tests' }
HumRunTimeTests >> test810createSimpleVignette [
	"Create a vignette frame."
	| vignetteFrame ontology pattern response |
	ontology := HumOntology new.
	setupConfiguration ontology: ontology.
	pattern := 'Hello *.'.
	vignetteFrame := HumFrame4Vignette 
											ontology: ontology 
											vignetteContext: 'Start.' 
											pattern: pattern. 
	response := 'Hello yourself.'.
	vignetteFrame addVignetteResponse: response.
	vignetteFrame compileToOntology: ontology.
 
]

{ #category : #'Dialog Tests' }
HumRunTimeTests >> test820createDialogAgent [
	"Create a dialog agent."
	| dialogAgent |
	dialogAgent := HumDialogAgent 
										dialogID: 'Dialog Agent ID' 
										uri: 'Dialog Agent URI' 
										client: 'clientURI' 
										configuration: setupConfiguration.

]

{ #category : #'Dialog Tests' }
HumRunTimeTests >> test825DialogAgentHasScribe [
	"When a dialog agent is activated, a Scribe is already present."
	| dialogAgent |
	"How is the scribe`s presence evidenced?
	This constructor assumes that a Scribe mediates the URI.
	We can assume that the Scribe is calling the constructor?
General dataflow / workflow:
	User authenticates via web application.
	Web Application: ( Inform scribe that user connected.)
	==> Scribe: ( Identify on-going dialog, if any. Set context. Operate vignette. )
Thinking out loud:
	Using a URI to identify the client makes several assumptions about the environment.
	Q: Should this be a client ID instead? That would be more consistent with other constructors.
	"
	dialogAgent := HumDialogAgent 
										dialogID: 'Dialog Agent ID' 
										uri: 'Dialog Agent URI' 
										client: 'clientURI' 
										configuration: setupConfiguration.
	self assert: (dialogAgent scribeProxy isKindOf: HumScribe ).

]

{ #category : #'Dialog Tests' }
HumRunTimeTests >> test830dialogAgentMatchesInputToVignette [
	"Pattern 'Hello *.' matches 'Hello.'.
	 Given: a set of vignettes (in an ontology)
	 When: Scribe sends a user statement - clientSays: 'Hello.'
	 Then: Dialog Agent matches user statement to available vignette patterns.
	"
	| vignetteFrame ontology pattern response dialogAgent  match |
	ontology := HumOntology new.
	setupConfiguration ontology: ontology.
	pattern := 'Hello *.'.
	vignetteFrame := HumFrame4Vignette 
											ontology: ontology 
											vignetteContext: 'Start.' 
											pattern: pattern. 
	response := 'Hello yourself.'.
	vignetteFrame addVignetteResponse: response.
	vignetteFrame compileToOntology: ontology.
	
	dialogAgent := HumDialogAgent 
										dialogID: 'Dialog Agent ID' 
										uri: 'Dialog Agent URI' 
										client: 'clientURI' 
										configuration: setupConfiguration.
	"Simulate call from Scribe."
	match := dialogAgent clientSays: 'Hello.'.
	self assert: ( match isKindOf: HumFrame4Vignette ).
	self assert: ( match responseLines notEmpty ).
	self assert: (( match responseLines at: 1 ) sameAs: 'Hello yourself.').


]

{ #category : #'Dialog Tests' }
HumRunTimeTests >> test832dialogAgentMatchesInputToVignette2 [
	"Pattern 'Hello *.' matches 'Hello Ms. Robot.'
	 Given: a set of vignettes (in an ontology)
	 When: Scribe sends a user statement -- clientSays: 'Hello Ms. Robot.'.
	 Then: Dialog Agent matches user statement to vignette with wildcard. -- pattern := 'Hello *.'.
	"
	| vignetteFrame ontology pattern response dialogAgent  match responseLines |
	ontology := HumOntology new.
	setupConfiguration ontology: ontology.
	pattern := 'Hello *.'.
	vignetteFrame := HumFrame4Vignette 
											ontology: ontology 
											vignetteContext: 'Start.' 
											pattern: pattern. 
	response := 'Hello yourself.'.
	vignetteFrame addVignetteResponse: response.
	vignetteFrame compileToOntology: ontology.
	
	dialogAgent := HumDialogAgent 
										dialogID: 'Dialog Agent ID' 
										uri: 'Dialog Agent URI' 
										client: 'clientURI' 
										configuration: setupConfiguration.
	"Simulate call from Scribe."
	match := dialogAgent clientSays: 'Hello Ms. Robot.'.
	self assert: ( match isKindOf: HumFrame4Vignette ).
	responseLines := match responseLines.
	self expect: 1 actual: ( responseLines size ).
	self expect: 'Hello yourself.' actual: ( responseLines at: 1 ) source.


]

{ #category : #'Dialog Tests' }
HumRunTimeTests >> test833dialogAgentMatchesInputToVignette3 [
	"Pattern ('Hello *.' 'Hi *.') matches 'Hi there.'.
	 Given: a set of vignettes (in an ontology)
	 When: Scribe sends a user statement
	 Then: Dialog Agent matches user statement to available vignette patterns.
	"
	| vignetteFrame ontology pattern response dialogAgent  match |
	ontology := HumOntology new.
	setupConfiguration ontology: ontology.
	pattern := 'Hello *.'.
	vignetteFrame := HumFrame4Vignette 
											ontology: ontology 
											vignetteContext: 'Start.' 
											pattern: pattern. 
	vignetteFrame addPattern: 'Hi *.'.										
	response := 'Welcome.'.
	vignetteFrame addVignetteResponse: response.
	vignetteFrame compileToOntology: ontology.
	
	dialogAgent := HumDialogAgent 
										dialogID: 'Dialog Agent ID' 
										uri: 'Dialog Agent URI' 
										client: 'clientURI' 
										configuration: setupConfiguration.
	"Simulate call from Scribe."
	match := dialogAgent clientSays: 'Hi there.'.
	self assert: ( match isKindOf: HumFrame4Vignette ).
	self assert: ( match responseLines notEmpty ).
	self assert: (( match responseLines at: 1 ) source) equals: response.


]

{ #category : #'Dialog Tests' }
HumRunTimeTests >> test834dialogAgentMatchesInputWithAlternatePunctuations [
	"Pattern ('Hello *.' 'Hi *.' 'Hi *!' 'Hello * ?') matches 'Hi there.'.
	 Given: a set of vignettes (in an ontology)
	 When: Scribe sends a user statement
	 Then: Dialog Agent matches user statement to available vignette patterns.
	"
	| vignetteFrame ontology pattern response dialogAgent  match |
	ontology := HumOntology new.
	setupConfiguration ontology: ontology.
	pattern := 'Hello *.'.
	vignetteFrame := HumFrame4Vignette 
											ontology: ontology 
											vignetteContext: 'Start.' 
											pattern: pattern. 
	vignetteFrame addPattern: 'Hi *.'.
	vignetteFrame addPattern: 'Hi *!'.
	vignetteFrame addPattern: 'Hello * ?'.	
											
	response := 'Welcome.'.
	vignetteFrame addVignetteResponse: response.
	vignetteFrame compileToOntology: ontology.
	
	dialogAgent := HumDialogAgent 
										dialogID: 'Dialog Agent ID' 
										uri: 'Dialog Agent URI' 
										client: 'clientURI' 
										configuration: setupConfiguration.
	"Simulate call from Scribe."
	match := dialogAgent clientSays: 'Hi there.'.
	self assert: ( match isKindOf: HumFrame4Vignette ).
	self assert: ( match responseLines notEmpty ).
	self assert: (( match responseLines at: 1 ) source) equals: response.


]

{ #category : #'Dialog Tests' }
HumRunTimeTests >> test840dialogAgentSorry [
	"Stimulus 'Help' returns 'Sorry ...'
	 Given: a set of vignettes (in an ontology)
	 When: Scribe sends a user statement
	   Then: Dialog Agent attempts to match user statement to available vignette patterns.
	 When: There is no match
	   Then: The agent returns a 'sorry . . .' response
	"
	| vignetteFrame ontology pattern response dialogAgent  match |
	ontology := HumOntology new.
	setupConfiguration ontology: ontology.
	pattern := 'Hello *.'.
	vignetteFrame := HumFrame4Vignette 
											ontology: ontology 
											vignetteContext: 'Start.' 
											pattern: pattern. 
	response := 'Hello yourself.'.
	vignetteFrame addVignetteResponse: response.
	vignetteFrame compileToOntology: ontology.
	
	dialogAgent := HumDialogAgent 
										dialogID: 'Dialog Agent ID' 
										uri: 'Dialog Agent URI' 
										client: 'clientURI' 
										configuration: setupConfiguration.
	"Simulate call from Scribe."
	match := dialogAgent clientSays: 'Help.'.
	self assert: ( match isKindOf: HumFrame4Vignette ).
	self assert: ( match responseLines notEmpty ).
	self assert: (( match responseLines at: 1 ) sameAs: 'Hello yourself.') not.
	self assert: (( match responseLines at: 1 ) source beginsWith: 'Sorry').
	self assert: (( match responseLines at: 1 ) source sameAs: 'Sorry, { Help.} is not understood.').
	


]

{ #category : #'Dialog Tests' }
HumRunTimeTests >> test850dialogAgentMatchesInputWithAlternatePunctuations [
	"Pattern ('Hello *.' 'Hi *.') matches 'Hi!'.
	 Given: a set of vignettes (in an ontology)
	 When: Scribe sends a user statement
	 Then: Dialog Agent matches user statement to available vignette patterns.
	"
	| vignetteFrame ontology pattern response dialogAgent  match responseLines |
	ontology := HumOntology new.
	setupConfiguration ontology: ontology.
	pattern := 'Hello *.'.
	vignetteFrame := HumFrame4Vignette 
											ontology: ontology 
											vignetteContext: 'Start.' 
											pattern: pattern. 
	vignetteFrame addPattern: 'Hi *.'.
											
	response := 'Welcome.'.
	vignetteFrame addVignetteResponse: response.
	vignetteFrame compileToOntology: ontology.
	
	dialogAgent := HumDialogAgent 
										dialogID: 'Dialog Agent ID' 
										uri: 'Dialog Agent URI' 
										client: 'clientURI' 
										configuration: setupConfiguration.
	"Simulate call from Scribe."
	match := dialogAgent clientSays: 'Hi!'.
	self assert: ( match isKindOf: HumFrame4Vignette ).
	responseLines := match responseLines. 
	self expect: 1 actual: ( responseLines size ).
	self expect: response actual: (( responseLines at: 1 ) source ).


]

{ #category : #'Dialog Tests' }
HumRunTimeTests >> test860dialogAgentMatchesInputWithNounSlot [
	"Pattern ('My name is [full-name].') matches 'My name is Tessie Tester.'.
	 Given: a set of vignettes (in an ontology)
	 When: Scribe sends a user statement
	 Then: Dialog Agent matches user statement to available vignette patterns.
	"
	| vignetteFrame ontology pattern response dialogAgent  match responseLines stepLog |
	ontology := HumOntology new.
	ontology addEntity: 'user' attribute: 'name'.  
	setupConfiguration ontology: ontology.
	pattern := 'My name is [user name].'.
	vignetteFrame := HumFrame4Vignette 
											ontology: ontology 
											vignetteContext: 'Start.' 
											pattern: pattern. 
											
	response := 'Welcome [user name].'.
	vignetteFrame addVignetteResponse: response.
	vignetteFrame compileToOntology: ontology.
	
	dialogAgent := HumDialogAgent 
										dialogID: 'Dialog Agent ID' 
										uri: 'Dialog Agent URI' 
										client: 'clientURI' 
										configuration: setupConfiguration.
	"Simulate call from Scribe."
	match := dialogAgent clientSays: 'My name is Tessie Tester.'.
	self assert: ( match isKindOf: HumFrame4Vignette ).
	responseLines := match responseLines. 
	self expect: 1 actual: ( responseLines size ).
	self assert: ('*Sorry*' match: ( responseLines at: 1 ) source) not description: 'Don`t be sorry.'.
	self expect: 'Welcome [user name].' actual: (( responseLines at: 1 ) source ).
	"Was slot filled-in?"
	stepLog := dialogAgent stepLog.
	self expect: 'S: Welcome Tessie Tester.' actual: (stepLog at: 2).


]

{ #category : #'Messenger Tests' }
HumRunTimeTests >> testM110MessengerRemembersActors [
	| messenger cook server |
	"Create an actor -- The actor automatically registers itself with the messenger in its configuration."
	cook := HumActor workerID: 'cook ID' uri: 'mock cook URI' roles: #('cook')  configuration: setupConfiguration.
	cook checkIn.
	messenger := setupConfiguration messenger.
	self assert: ( messenger ping: 'mock cook URI' ) equals: cook id.
	"One more should make no problem."
	server := HumActor workerID: 'server ID' uri: 'server URI' roles: #('server') configuration: setupConfiguration.
	server checkIn.
	self assert: ( messenger ping: 'server URI' )= server id.
	self assert: ( messenger ping: 'mock cook URI' ) == cook id.
	
]

{ #category : #'Messenger Tests' }
HumRunTimeTests >> testM120MessageAttributes [
	"The components of a message include sender, receiver, when sent, statement, and noun-values. "
	| message |
	message := HumMessage title: 'message in testM120MessageAttributes'.
	message sender: 'sender ID';
	        receiver: 'receiver ID';
	        whenSent: (Duration seconds: 120);
	        statement: (HumStatement source: 'Bake a cake per recipe.');
	        nounValues: #( 'recipe'->'Recipe M120' ).
]

{ #category : #'Scribe Tests' }
HumRunTimeTests >> testS100ScribeReadMe [
	"These Scribe tests generally involve a Scribe that is independent of Seaside.
	If the client is running in HTML context, the HTML scribe will be invoked.
	If the client is running in a VR context, the appropriate VR scribe will be invoked.
	See: HumScribe>>about for more detail about Scribe interactions.
	"
	| |
	"
	When a dialog session is initiated, a Scribe is already present.
	The Scribe mediates between the Dialog Agent and the user interface.
	The Scribe translates user gestures into dialog vignette 'speech' inputs.
	The user/client interface may be one of many technologies including:
	 HTML forms,
	 HTTP / AJAX / XMPP, 
	 software embedded with hardware sensors,
	 voice recognition,
	 hand-gesture / body-language interpreters,
	 virtual reality sensors,
	 an automated agent message framework,
	 or an internal unit-test user-simulator.

	The first UI-connected Scribe will be built around HTML forms
	 as that is a popular technology at this time (June 2014)."
	
	"A Scribe is a HumActor that interprets user gestures seen by some set of sensors."
	"In this set of tests, the Scribe interprets HTTP requests."
	
	"General dataflow / workflow:
	User authenticates via web application.
	Web Application: ( Inform scribe that user connected.)
	****
	==> Dialog Agent: ( Identify on-going dialog, if any. Initialize context stack. Operate 'Hello' vignette. )
	****
	==> Vignette: (Ask viewName) 
	==> Dialog Agent: ( Delegate view operation to Scribe.)
	==> Scribe: ( Translate view to HTML page. ) 
	==> Scribe: ( Send HTML page to web browser.)
	==> Browser: ( User fills in blanks and presses [[Submi`t Button]].)
	==> Scribe: ( Captures data from Http Response and returns data to Dialog Agent in task-completion message. )
	==> Dialog Agent: ( Registers data on blackboard and completes current vignette.)
	"
	"TODO: How does the Dispatcher know what kind of Scribe to delegate 'Ask viewName.' ???"
	"Thinking Out Loud:
	. Scribe is wrapper around a suite of sensors.
	. That means it is determined by the user`s UI context. 
	. . HTML: If Scribe is resident on Browser, it can be associated directly with HTML user/client.
	. . HTML: If Scribe is server-side, it is associated with a session, and thus with an HTML client.
	. . XMPP: If client is communicating via XMPP, Scribe can be an XMPP receiver.
	. . Virtual World: Scribe must reside in the virtual world ??
	. The Scribe and the user/client are indistinguishable from the PoV of other actors.
	* Therefore: 
	* . *** The Scribe must start the session and configure the Dialog Agent.***
	* . The Dialog Agent must override or finess the Dispatcher to assign the correct Scribe instance.
	* . . Perhaps we should think of the Dispatcher as part of a session configuration
	* . . . and the session configuration includes the right kind of Scribe.
	* . Alternate: Add suitable 'back-door' methods to the Dispatcher. (JobTicket not relevant to Scribe.)
	* . Alternate: The Dialog Agent by-passes the Dispatcher and delegates to Scribe actor directly.
  * . . 	'( self messenger ) sendStatement: aMessageObject toID: recipientID fromID: myID.'
	* . Alternate: Scribe instance role-name is unique. (Works if Dispatcher does not check against Ontology.)
	"
	
	"Summary - Restatement:
	- When a session is instantiated BUT client is UNKNOWN, (anonymous/guest client) 
	. . a Scribe and a Dialog Agent MAY be instantiated, 
	. . BUT the Dialog  will have no history and a temporary context stack.
	- When a session is instantiated AND the client is identified,
	. . a Scribe and a Dialog Agent will be instantiated, 
	. . AND the Dialog will have history and context stack fetched from ??? WorldBase ???.
	- Assuming the Dialog Agent is server-side,
	. . we will instatiate it on the same server as the Dispatcher.
	. . (In Erlang OTP, it will be ??? )
	. . (In Java web server, it will be attached to the session.) 
	. . (In Seaside web server, session (WASession subtype) will delegate to Dialog Agent.)
	. . (In Smalltalk without Seaside, a response handler (HTTP/XMPP) will delegate to Dialog Agent.)
	"

]

{ #category : #'Scribe Tests' }
HumRunTimeTests >> testS110SetupScribe [
	"A scribe is attached to a dialogAgent Agent.
	The dialogAgent Agent is configured with a Blackboard.
	"
	| dialogAgent configuration scribe |
	configuration := HumConfiguration messengerID: 'IDMessenger' 
	                                 dispatcherID: 'IDDispatcher' 
	                                 bookkeeperID: 'IDBookkeeper' 
	                                  worldbaseID: 'IDWorldbase'. 
	configuration messenger: HumMessenger new.
	configuration openWorldBase.
	dialogAgent := HumDialogAgent dialogID: 'dialogID' uri: 'dialogURI' client: 'clientURI' configuration: configuration.
	scribe := HumScribe dialogAgent: dialogAgent. 
	"Scribe is attached to a Dialog Agent."
	self expect: HumDialogAgent actual: (scribe dialogAgent class).
	"The Dialog Agent has a Blackboard."
	self expect: HumBlackBoard  actual: (scribe dialogAgent blackboard class).
]

{ #category : #'Scribe Tests' }
HumRunTimeTests >> testS131ScribeHandlesHttpPostRequest [
	"Scribe: Captures data from Http Response and returns data to Dialog Agent in task-completion message. "
	| scribe request dialogAgent  |
	"Setup the Dialog actor and the Scribe actor."
	dialogAgent := HumDialogAgent
				dialogID: 'dialogID'
				uri: 'dialogURI'
				client: 'clientURI'
				configuration: setupConfiguration.
	dialogAgent blackboard businessEvent: 'testS131ScribeHandlesHttpPostRequest'.
	
	scribe := HumScribe dialogAgent: dialogAgent.
	request := HumHttpRequest new.
	"Set Http Request form to include this input - name:value pair."
	request atField: 'entityName:attributeName' put: 'test value'.	
	"Ask Scribe to handle the request."
	scribe handleHttpPostRequest: request.	
	"We should see data in Scribe`s Blackboard and a change in scribe state."
	self expected: 'test value' actual: ( scribe blackboard getEntityName: 'entityName' attribute: 'attributeName').	
	"We should also see data in the Dialog Agent`s blackboard"
	self expected: 'test value' actual: ( dialogAgent blackboard getEntityName: 'entityName' attribute: 'attributeName').
	
]

{ #category : #'Scribe Tests' }
HumRunTimeTests >> testS132ScribeHandlesViewReturn [
	"Scribe: Captures data from Http Response and returns data to Dialog Agent in task-completion message. "
	| baseOntology dialogAgent scribe viewFrame |
	"Scenario:
	1. Dialog matches vignette.
	2. Vignette response contains 'Ask viewname.'
	3. Dialog gets ViewFrame from Ontology.
	4. Dialog delegates 'Ask' to Scribe.
	5. HTML-Scribe generates HTML page/frame with needed HTML form elements.
	6. HTML-Scribe sends HTML page/frame via a Session?
	7. HTML-Scribe receives HTML-response from Session.
	8. HTML-Scribe parses HTML-response and populates Dialog blackboard.
	9. *** Form return is a Dialog Pattern???? ***"
	true ifFalse: [Transcript cr; show: 'testS132ScribeHandlesViewReturn is turned off.'. ^self skip].
	
	"Dialog delegates 'Ask' to Scribe"
	baseOntology := HumOntology baseOntology.
	self setUpKnockKnockOnOntology: baseOntology.
	dialogAgent := HumDialogAgent dialogID: 'dialogID' 
	                                   uri: 'dialogURI' 
	                                client: 'clientURI' 
	                         configuration: setupConfiguration.
	scribe := HumScribe dialogAgent: dialogAgent.
	viewFrame := baseOntology getViewFrame: 'Knock'.
	dialogAgent blackboard businessEvent: 'Ask Knock'.
	scribe askView: viewFrame withBlackBoard: (dialogAgent blackboard). 
	
	self expect: 'sendView: {	<form action="View: Knock." class="Ask" enctype="application/x-www-form-urlencoded" id="View: Knock." method="POST" >

	
<h2>Knock, knock, who`s there?</h2>
  Please enter first name: 
<input type="text" name="knock:first-name" value=""/>
 <input type="submit" value="Go!"   style="color:WHITE; background:GREEN"/>
 <input type="submit" value="NoGo!" style="color:WHITE; background:RED"/>
	</form>
}'
			actual: (scribe log at: 1 ifAbsent: ['']).
	"htmlSent := scribe log at: 2.
	 htmlSent inspect."
	
	

]

{ #category : #'Scribe Tests' }
HumRunTimeTests >> testS134ScribeMocksViewDataEntry [
	"Scribe: Captures data from Http Response and returns data to Dialog Agent in task-completion message. "
	| baseOntology dialogAgent scribe viewFrame userEntries blackboard |
	true ifFalse: [Transcript cr; show: 'testS134ScribeMocksViewDataEntry is turned off.'. ^self skip].
	
	"Dialog delegates 'Ask' to Scribe"
	dialogAgent := HumDialogAgent dialogID: 'dialogID' 
	                                   uri: 'dialogURI' 
	                                client: 'clientURI' 
	                         configuration: setupConfiguration.
  dialogAgent blackboard businessEvent: 'testS133ScribeMocksViewDataEntry'.
	scribe := HumScribe dialogAgent: dialogAgent.
	userEntries := Dictionary new.
	userEntries
		at: 'knock:first-name' put: 'Testy'.
	scribe mockDataEntry: userEntries.
	"The blackboard should now match data entered."
	blackboard := dialogAgent blackboard.
	self expect: 'Testy' actual: (blackboard getEntityName: 'knock' attribute: 'first-name').
	"And the worldbase has also been updated"
	self expect: 1 actual: (blackboard worldbase quads size).
	
	

]

{ #category : #'HumVector Tests' }
HumRunTimeTests >> testV100ReadMe [
	"Test HumVector - which is a subclass of FloatArray"
	"Test vector arithmetic v + v, v - v, v dot: v, v cross: v. v * scalar. v / scalar."
	| v |
	v := HumVector newFrom: { 1. 2. 3. }.
	self expect: HumVector actual: (v class).
	self assert: (v isKindOf: HumMeasure).
]

{ #category : #'HumVector Tests' }
HumRunTimeTests >> testV105GetPutXYZ [
	"Test HumVector - which is a subclass of HumMeasure"
	"Test vector arithmetic v + v, v - v, v dot: v, v cross: v. v * scalar. v / scalar."
	| v |
	v := HumVector newFrom: { 1. 2. 3. }.
	self expect: HumVector actual: (v class).
	self assert: (v isKindOf: HumMeasure).
	
	self expect: 1.0 meter actual: (v x).	
	self expect: 2.0 meter actual: (v y).	
	self expect: 3.0 meter actual: (v z).
]

{ #category : #'HumVector Tests' }
HumRunTimeTests >> testV110TestVplusV [
	"Test HumVector - which is a subclass of . . ."
	"Test vector arithmetic v + v, v - v, v dot: v, v cross: v. v * scalar. v / scalar."
	 | a b c |
	a := HumVector newFrom: { 1. 2. 3. }.
	b := HumVector newFrom: { 5. 7. 11. }.
	c := a + b.
	self expect: (HumVector newFrom: {  6. 9. 14. } ) actual: c.	
]

{ #category : #'HumVector Tests' }
HumRunTimeTests >> testV120TestVminusV [
	"Test HumVector - which is a subclass of . . ."
	"Test vector arithmetic v + v, v - v, v dot: v, v cross: v. v * scalar. v / scalar."
	 | a b c |
	a := HumVector newFrom: { 1. 2. 3. }.
	b := HumVector newFrom: { 5. 7. 11. }.
	c := b - a.
	self expect: (HumVector newFrom: {  4. 5. 8. } ) actual: c.	
]

{ #category : #'HumVector Tests' }
HumRunTimeTests >> testV130TestVdotV [
	"Test HumVector - which is a subclass of . . ."
	"Test vector arithmetic v + v, v - v, v dot: v, v cross: v. v * scalar. v / scalar."
	 | a b c |
	a := HumVector newFrom: { 1. 2. 3. }.
	b := HumVector newFrom: { 5. 7. 11. }.
	c := b dot: a.
	self expect: ( HumMeasure quantity: (5.0 + 14.0 + 33.0)  units: 'square meter' ) actual: c.	
]

{ #category : #'HumVector Tests' }
HumRunTimeTests >> testV140TestVcrossV [
	"Test HumVector - which is a subclass of . . ."
	"Test vector arithmetic v + v, v - v, v dot: v, v cross: v. v * scalar. v / scalar."
	 | a b c |
	"Test with unit vectors."
	a := HumVector newFrom: { 1. 0. 0. }.
	b := HumVector newFrom: { 0. 1. 0. }.
	c := a cross: b.
	self expect: (HumVector newFrom: {  0. 0. 1. } units: 'square meter') actual: c.	
	c := b cross: a.
	self expect: (HumVector newFrom: {  0. 0. -1. } units: 'square meter') actual: c.	
		
	"Text with some numbers."
	a := HumVector newFrom: { 3. 0. 0. }.
	b := HumVector newFrom: { 0. 5. 0. }.
	c := a cross: b.
	self expect: (HumVector newFrom: {  0. 0. 15. } units: 'square meter' ) actual: c.	
	c := b cross: a.
	self expect: (HumVector newFrom: {  0. 0. -15. } units: 'square meter' ) actual: c.	
		
	
]

{ #category : #'HumVector Tests' }
HumRunTimeTests >> testV150TestVtimesScalar [
	"Test HumVector - which is a subclass of . . ."
	"Test vector arithmetic v + v, v - v, v dot: v, v cross: v. v * scalar. v / scalar."
	 | a scalar c |
	a := HumVector newFrom: { 1. 2. 3. }.
	scalar := 5.
	c := a * scalar.
	self expect: (HumVector newFrom: {  5. 10. 15. } ) actual: c.	
]

{ #category : #'HumVector Tests' }
HumRunTimeTests >> testV160TestVdividedByScalar [
	"Test HumVector - which is a subclass of . . ."
	"Test vector arithmetic v + v, v - v, v dot: v, v cross: v. v * scalar. v / scalar."
	 | a scalar c |
	a := HumVector newFrom: { 1. 2. 3. }.
	scalar := 4.
	c := a / scalar.
	self expect: (HumVector newFrom: {  0.25. 0.50. 0.75. } ) actual: c.	
]
