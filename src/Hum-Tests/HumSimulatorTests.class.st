Class {
	#name : #HumSimulatorTests,
	#superclass : #HumTestCase,
	#category : #'Hum-Tests'
}

{ #category : #'Simulator tests' }
HumSimulatorTests >> aDesignNoteEventQueue [
	"The Simulator provides the means for 'regression testing'.
	Hum dialogs / protocols may be exercised by sending a series of messages to one or more Dialog Agents.
	Hum plans are initiated via such dialogs.
	Evidence of successful execution may be found via the Bookkeeper.
	The Simulator simulates steps a simulated clock.
	Simulations 'load' the system under test by sending dialog sequences 
	. at random intervals as seen by the simulated clock.
	The simulator emulates a human response rate 
	. of approximating 1 keystroke (or button press) per second of simulated clock time.
	. Since Hum is not currently intended for embedded systems, 
	. . faster sensor rates are not needed at this time.
	The simulated clock runs at some convenient multiple of real-time. 
  . This multiple is a configuration option. 
	. 'Convenience' may be a combination of 
	. . what the run-time can produce, and 
	. . what the user wishes to monitor.
	"
	"Design Analysis:
	Typically, one of two mechanisms are used to simulate clock-time:
	a. The simulation loads 'events' into a time-sorted queue and sends the events asynchronously.
	. . . Agent/Actors respond to events by adding events of their own to the queue.
	b. The simulation 'steps' a simulated clock 
	. . . and sends 'step' messages with a simulated clock timestamp to all actors simultaneously.
	. . . Actor/Agents respond make some 'move' when each 'step' message arrives.
	. . . The 'move' may be 'do nothing' if the agent is simulating an idle state, wait time, or task duration.
	"
	"When events are sparse, or the actual system response time is highly variable, method 'a' is preferred.
	However, a human monitor may perceive the simulation as 'jerky'. 
	But where simulation results are primarily examined after the 'run', the 'jerks' are not irrelevant.
	Method 'a' can also be used when agents are scripted to perform certain actions at certain times of day.
	The dialog stimulus may be a time-of-day notice in that case. 
	"
	"Method 'b' is typically more convenient for animations where the concept of frame-rate applies.
	Note that method 'a' can also be applied to real-time animation 
	  by sending a 'frame' event triggered by the real-time clock.
	A recorded animation where the rendering work-flow time is relatively long, can also be driven by method 'a'.
	"
	"On the whole, method 'a' appears to be more flexible. So that is what we will implement.
	Consequence: This requires that the timestamps in the Messenger may be over-ridden by simulated timestamps.
	"
]

{ #category : #running }
HumSimulatorTests >> setUp [
	"Specify base directory for this series of tests."	
	HumStore defaultDirectory:  './Developer/Smalltalk/Hum8'.
]

{ #category : #setup }
HumSimulatorTests >> setUpBasicConfigurationOn: aHumSimulator [ 
	| configuration actors dispatcher messenger bookkeeper worldBase setup  |
	configuration := aHumSimulator.
	messenger := (HumMessenger uri: 'messengerURI').
	messenger clock: aHumSimulator.
	configuration messenger: messenger.
	configuration messengerID: 'messengerID' dispatcherID: 'dispatcherID' bookkeeperID: 'bookkeeperID' worldbaseID: 'worldbaseID'. 
	dispatcher := HumActor dispatcherID: 'dispatcherID' uri: 'dispatcherURI' configuration: configuration.
	bookkeeper := HumActor bookkeeperID: 'bookkeeperID' uri: 'bookkeeperURI' configuration: configuration.
	worldBase := HumWorldBase openWorldBase: 'worldbase for HumSimulatorTests'.
	worldBase id: 'worldbaseID'; uri: 'worldbaseURI'; configuration: configuration; clock: aHumSimulator.
	actors := { dispatcher. bookkeeper. worldBase. }.
	actors do: [ :actor | actor checkIn. ].
	setup := Dictionary new.
	setup
		at: 'worldbase' put: worldBase;
		at: 'bookkeeper' put: bookkeeper;
		at: 'dispatcher' put: dispatcher;
		at: 'messenger' put: messenger.
	^setup. "Return dictionary of actors to simplify test and debug."		
]

{ #category : #setup }
HumSimulatorTests >> setUpDogAndPonyConfigurationOn: aHumSimulator [ 
	| configuration actors dispatcher messenger bookkeeper worldBase dog pony band myActors |
	"Attach the configuration to the Simulator. "
	configuration := aHumSimulator.
	"Instantiate the infrastructure agents."
	messenger := (HumMessenger uri: 'messengerURI').
	messenger clock: aHumSimulator.  "Use the simulated clock in place of the system clock."
	configuration messenger: messenger.
	configuration messengerID: 'messengerID' dispatcherID: 'dispatcherID' bookkeeperID: 'bookkeeperID' worldbaseID: 'worldbaseID'. 
	dispatcher := HumActor dispatcherID: 'dispatcherID' uri: 'dispatcherURI' configuration: configuration.
	bookkeeper := HumActor bookkeeperID: 'bookkeeperID' uri: 'bookkeeperURI' configuration: configuration.
	worldBase := HumWorldBase openWorldBase: 'HumRunTimeTests:setUpDogAndPonyConfigurationOn'.
	worldBase 
		id: 'worldbaseID'; 
		uri: 'worldbaseURI';
		configuration: configuration;
		clock: aHumSimulator.
	"Instantiate the worker agents."
	dog  := HumActor workerID: 'dogID' uri: 'dogURI' roles: #('dog') configuration: configuration.
	pony := HumActor workerID: 'ponyID' uri: 'ponyURI' roles: #('pony') configuration: configuration.
	band := HumActor workerID: 'bandID' uri: 'bandURI' roles: #('band') configuration: configuration.
	
	actors := { dispatcher. bookkeeper. worldBase. dog. pony. band. }.
	actors do: [ :actor | actor checkIn. ].
	
	"Return a dictionary of actors for test convenience."
	myActors := Dictionary new.
	myActors
		at: 'bookkeeper' put: bookkeeper;
		at: 'dog' put: dog;
		at: 'pony' put: pony;
		at: 'band' put: band.
	^myActors.
	
]

{ #category : #setup }
HumSimulatorTests >> setUpDogAndPonyOntology [
	"When this ontology runs,
	 the vignette triggers the goal, and
	 the plan should guides the sequence."
	| testOntology frame4Plan planFrame2 planFrame3 actionFrame1 actionFrame2 actionFrame3 vignette1 |
	testOntology := HumOntology new.
	""
	vignette1 := HumFrame4Vignette ontology: testOntology vignetteContext: 'Start.' pattern: 'Hello *.'.
	vignette1 addVignettePattern: '* Hi*.'.
	vignette1 addVignettePattern: '* Eh? *.'.
	
	vignette1 addVignetteResponse: 'For your entertainment! Doggy Dog and Prancing Pony!'. 
	vignette1 addVignetteInstruction: 'Goal: Run dog and pony show.'.
	testOntology addVignette: vignette1 toContext: (vignette1 vignetteContext). 
	"Root of plan"
	frame4Plan := HumFrame4Plan ontology: testOntology goal: 'Run dog and pony show.'.
	frame4Plan appendPrecondition: 'Dog is on pony`s back.'.
	frame4Plan appendPrecondition: 'Pony is running in circle.'.
	frame4Plan appendRole: 'Band' action: 'Play show music.'.
	""
	planFrame2 := HumFrame4Plan ontology: testOntology goal: 'Dog is on pony`s back.'.
	planFrame2 appendPrecondition: 'Pony is running in circle.'.
	planFrame2 appendRole: 'Dog' action: 'Jump on pony`s back.'.
	""
	planFrame3 := HumFrame4Plan ontology: testOntology goal: 'Pony is running in circle.'.
	"planFrame3 addPrecondition: 'Pony is in the ring.' annotation: 'assumed'."
	planFrame3 appendRole: 'Pony' action: 'Run in circle.'.
	""
	actionFrame1 := HumFrame4Action ontology: testOntology role: 'Band' action: 'Play show music.'.
	actionFrame1
			appendInstructionStatement: 'For each note in music:';
			appendInstructionStatement: '	Read note.';
	 		appendInstructionStatement: '	Play note.'.
	""
	actionFrame2 := HumFrame4Action ontology: testOntology role: 'Dog' action: 'Jump on pony`s back.'.
	actionFrame2 
			appendInstructionStatement: 'Bark twice. (to warn the pony)';
			appendInstructionStatement: 'Jump and balance on pony`s back.'.
	""
	actionFrame3 := HumFrame4Action ontology: testOntology role: 'Pony' action: 'Run in circle.'.
	actionFrame3
			appendInstructionStatement: 'Enter ring.';
			appendInstructionStatement: 'Run in circles until dog jumps off.'.
	{ frame4Plan. planFrame2. planFrame3. actionFrame1. actionFrame2. actionFrame3.} 
			do: [:frame | frame compileToOntology: testOntology.].
	testOntology compileAllFrames.
	"testOntology inspect.
	self halt."
	^testOntology.
	
	
	
]

{ #category : #setup }
HumSimulatorTests >> setUpHotelOntology [
	| testOntology vignette1 vignette2 vignette3 view1 |
	"Provide a set of vignettes."
	testOntology := HumOntology baseOntology.
	vignette1 := HumFrame4Vignette ontology: testOntology vignetteContext: 'Start.' pattern: 'Hello *.'.
	vignette1 addVignettePattern: '* Hi *.'.
	vignette1 addVignetteResponse: 'Welcome to the Hotel California.'. 
	testOntology addVignette: vignette1 toContext: (vignette1 vignetteContext). 

	vignette2 := HumFrame4Vignette ontology: testOntology vignetteContext: 'Start.' pattern: '* reservation *.'.
	vignette2 addVignettePattern: '* check in *.'.
	vignette2 addVignetteResponse: 'Everyone has a reservation here. Please check-in.'.
	vignette2 addVignetteInstruction: 'Ask Guest.' . 
	testOntology addVignette: vignette2 toContext: (vignette2 vignetteContext). 

	vignette3 := HumFrame4Vignette ontology: testOntology vignetteContext: 'Start.' pattern: '* check-out *.'.
	vignette3 addVignettePattern: '* check out *.'.
	vignette3 addVignettePattern: '* check-out *.'.
	vignette3 addVignettePattern: '* checkout *.'.
	vignette3 addVignetteResponse: 'You can check-out anytime. But you can never leave.'.
	testOntology addVignette: vignette3 toContext: (vignette3 vignetteContext). 
	
	view1 := HumFrame4View ontology: testOntology viewEntity: 'Guest'.
	view1 addMarkUp: '! Guest Registry'.
	view1 addMarkUp: ' name: [name]'.
	testOntology storeFrame: view1.
	
	testOntology addNoun: 'guest' isA: 'person'.
	
	^testOntology.   
]

{ #category : #setup }
HumSimulatorTests >> setUpKnockKnockOnOntology: anOntology [
	| viewFrame dictionaryFrame |
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

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX100SimulatorReadMe [
	"The Simulator provides the means for 'regression testing'.
	Hum dialogs / protocols may be exercised by sending a series of messages to one or more Dialog Agents.
	Hum plans are initiated via such dialogs.
	Evidence of execution may be found via the Bookkeeper, Messenger logs, and Agent logs.
	"
	"Simulations 'load' the system under test by starting dialog sequences 
	. at random intervals as seen by the simulated clock.
	==> We need a way to represent dialog sequences.
	==> We need a way to represent random intervals.
	==> We need a way to identify the number of dialogs to be run simultaneously.
	==> Ideally, we will run the dialogs in independent threads.
	"
	"The simulator (Scribe?) emulates a human response rate 
	. of approximating 1 keystroke (or button press) per second of simulated clock time.
	. It is not necessary to simulate the sensor, just the time between vignette inputs.
	"
	"A simulation loads 'events' into a time-sorted queue and sends the events asynchronously.
	. Agent/Actors respond to events by adding events of their own to the queue. 
	. The timestamp on each event indicates its order, 
	. . but does not determine the real-time duration of the simulation.
	. There is no need to create real-time wait-times during the simulation.
	"
	self skip.
	

]

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX101RepresentDialogSequence [
	"Simulations 'load' the system under test by starting dialog sequences 
	. at random intervals as seen by the simulated clock.
	==> We need a way to represent dialog sequences."
	| simulator |
	simulator := HumSimulator ontology: (HumOntology new).
	"Represent a dialog sequence as an sequencable collection or array."
	simulator dialogSequence: #( 'Hello.' 'Goodbye.').
	
]

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX102RepresentRandomIntervals [
	"Simulations 'load' the system under test by starting dialog sequences 
	. at random intervals as seen by the simulated clock.
	==> We need a way to represent random intervals.
	"
	| simulator distribution |
	"Express the distribution as an S-curve in seconds."
	distribution := Dictionary new.
	distribution
		at: 0.0 put: 100.0;
		at: 50.0 put: 1000.0;
		at: 100.0 put: 8000.0.
	simulator := HumSimulator new.
	simulator randomStartingIntervals: distribution.
	"TODO: This random execution concept has not been implemented yet."
]

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX103RepresentNumberOfDialogs [
	"Simulations 'load' the system under test by starting dialog sequences 
	. at random intervals as seen by the simulated clock.
	==> We need a way to identify the number of dialogs to be run simultaneously.
	"
	| simulator |
	simulator := HumSimulator new.
	simulator numberOfDialogs: 3.
	"TODO: This parallel execution concept has not been implemented yet."
]

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX110AddEventToQueue [
	"A simulation loads client speech-acts into a queue with a specified delay.
	. Each speech-act is sent to the dialog-agent that is attached to the simulator. 
	. The timestamp on each event indicates its order, 
	. . but does not determine the real-time duration of the simulation.
	. The speech-act is sent when the simulation clock reaches the time indicated by the given delay.
	"
	| simulator anActor statement |
	simulator := HumSimulator new.
	"Speech acts are interpreted by dialog vignettes in an ontology."
	simulator ontology: (self setUpHotelOntology).
	simulator after: (30 seconds) sendSpeech: 'Hello.' from: 'client A'.
	self assert: ( simulator queue size = 1 ).
	self assert: ( ( simulator queue at: 1 ) isKindOf: Array).
	self expect: { Duration seconds: 30.  #speech. 'client A'. 'Hello.'.} actual: ( simulator queue at: 1 ).
	
]

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX112AddTwoEventsToQueue [
	"A simulation loads client speech-acts into a queue with a specified delay.
	. Each speech-act is sent to the dialog-agent that is attached to the simulator. 
	. The timestamp on each event indicates its order, 
	. . but does not determine the real-time duration of the simulation.
	. The speech-act is sent when the simulation clock reaches the time indicated by the given delay.
	"
	| simulator anActor statement |
	simulator := HumSimulator new.
	"Speech acts are interpreted by dialog vignettes in an ontology."
	simulator ontology: (self setUpHotelOntology).
	simulator after: (10 seconds) sendSpeech: 'Hello there.' from: 'client A'.
	simulator after: (20 seconds) sendSpeech: 'Hi there.' from: 'client B'.
	self assert: ( simulator queue size = 2 ).
	self expect: { Duration seconds: 10.  #speech. 'client A'. 'Hello there.'.} actual: ( simulator queue at: 1 ).
	self expect: { Duration seconds: 20.  #speech. 'client B'. 'Hi there.'.} actual: ( simulator queue at: 2 ).
	
]

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX120Step [
	"A simulation loads client speech-acts into a queue with a specified delay.
	. Each speech-act is sent to the dialog-agent that is attached to the simulator. 
	. The timestamp on each event indicates its order, 
	. . but does not determine the real-time duration of the simulation.
	. The speech-act is sent when the simulation clock reaches the time indicated by the given delay.
	"
	| simulator ontology  dialogAgent stepLog |
	"set up"
	ontology := self setUpHotelOntology.
	simulator := HumSimulator new.
	simulator ontology: (ontology).
	self setUpBasicConfigurationOn: simulator.
	
	"Speech acts are interpreted by dialog vignettes in an ontology."
	simulator after: (30 seconds) sendSpeech: 'Hello.' from: 'client A'.
	self assert: ( simulator queue size = 1 ).
	self assert: ( ( simulator queue at: 1 ) isKindOf: Array).
	self expect: { Duration seconds: 30.  #speech. 'client A'. 'Hello.'.} actual: ( simulator queue at: 1 ).
	simulator step.
	self assert: ( simulator queue size = 0 ).
	
	"Examine log for expected event and values."
	dialogAgent := simulator getDialogAgentNamed: 'client A'. 
	stepLog := dialogAgent stepLog.
	self expect: 2 actual: stepLog size.
	self expect: #('client A: Hello.' 'S: Welcome to the Hotel California.') actual: stepLog asArray.
	
]

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX122StepStep [
	"A simulation loads client speech-acts into a queue with a specified delay.
	. Each speech-act is sent to the dialog-agent that is attached to the simulator. 
	. The timestamp on each event indicates its order, 
	. . but does not determine the real-time duration of the simulation.
	. The speech-act is sent when the simulation clock reaches the time indicated by the given delay.
	"
	| simulator ontology dialogAgent stepLog scribe scribeLog |
	"set up"
	ontology := self setUpHotelOntology.
	simulator := HumSimulator new.
	simulator ontology: (ontology).
	self setUpBasicConfigurationOn: simulator.

	"Speech acts are interpreted by dialog vignettes in an ontology."
	simulator after: (10 seconds) sendSpeech: 'Hello there.' from: 'client A'.
	simulator after: (20 seconds) sendSpeech: 'I would like to check in.' from: 'client A'.
	self assert: ( simulator queue size = 2 ).
	self expect: { Duration seconds: 10.  #speech. 'client A'. 'Hello there.'.} actual: ( simulator queue at: 1 ).
	self expect: { Duration seconds: 20.  #speech. 'client A'. 'I would like to check in.'.} actual: ( simulator queue at: 2 ).
	simulator step.
	self assert: ( simulator queue size = 1 ).
	self expect: { Duration seconds: 20.  #speech. 'client A'. 'I would like to check in.'.} actual: ( simulator queue at: 1 ).
	simulator step.
	self assert: ( simulator queue size = 0 ).

	"Examine logs for expected event and values."
	dialogAgent := simulator getDialogAgentNamed: 'client A'. 
  scribe := dialogAgent scribeProxy.
	scribeLog := scribe log.
	self assert: ( '*<input type="text" name="Guest:name" value=""/>*' match: (scribeLog at: 1)).
	stepLog := dialogAgent stepLog.
	self expect: #(
		'client A: Hello there.' 
		'S: Welcome to the Hotel California.' 
		'client A: I would like to check in.' 
		'S: Everyone has a reservation here. Please check-in.' 
		'DialogAgent: {client A} is doing: {Ask Guest.}'
		)
	 	actual: stepLog asArray.

]

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX124StepUntilDone [
	"A simulation loads client speech-acts into a queue with a specified delay.
	. Each speech-act is sent to the dialog-agent that is attached to the simulator. 
	. The timestamp on each event indicates its order, 
	. . but does not determine the real-time duration of the simulation.
	. The speech-act is sent when the simulation clock reaches the time indicated by the given delay.
	"
	| simulator ontology dialogAgent stepLog |
	"Given: set up"
	ontology := self setUpHotelOntology.
	simulator := HumSimulator new.
	simulator ontology: (ontology).
	self setUpBasicConfigurationOn: simulator.

	"Speech acts are interpreted by dialog vignettes in an ontology."
	simulator after: (10 seconds) sendSpeech: 'Hello there.' from: 'client A'.
	simulator after: (20 seconds) sendSpeech: 'I would like to check in.' from: 'client A'.
	simulator after: (30 seconds) sendSpeech: 'When is check-out?' from: 'client A'.
	simulator stepUntilDone.
	self assert: ( simulator queue size = 0 ).
	"simulator log4Dialog inspect."
	"Examine logs for expected event and values."
	dialogAgent := simulator getDialogAgentNamed: 'client A'. 
	stepLog := dialogAgent stepLog.
	self expect: #(
		'client A: Hello there.' 
		'S: Welcome to the Hotel California.' 
		'client A: I would like to check in.' 
		'S: Everyone has a reservation here. Please check-in.' 
		'DialogAgent: {client A} is doing: {Ask Guest.}'  
		'client A: When is check-out?' 
		'S: You can check-out anytime. But you can never leave.'
		) 
		actual: stepLog asArray.

]

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX130DialogUsesScribe [
	"There should be a Scribe in the chain.
	A Dialog Agent does not connect directly to a UI framework.
	A Dialog Agent uses a Scribe as an intermediary.
	Simulator ==> Dialog Agent ==> Scribe.
	Q: Where/When/How is the connection between Dialog Agent and Scribe instantiated ?
	"
	| simulator ontology dialogAgent stepLog scribe stepLog2 |
	"setup"
	ontology := self setUpHotelOntology.
	simulator := HumSimulator new.
	simulator ontology: (ontology).
	self setUpBasicConfigurationOn: simulator.

	"Speech acts are interpreted by dialog vignettes in an ontology."
	simulator after: (30 seconds) sendSpeech: 'Hello.' from: 'client A'.
	self assert: ( simulator queue size = 1 ).
	self assert: ( ( simulator queue at: 1 ) isKindOf: Array).
	self expect: { Duration seconds: 30.  #speech. 'client A'. 'Hello.'.} actual: ( simulator queue at: 1 ).
	simulator step.
	self assert: ( simulator queue size = 0 ).
	
	"Examine log for expected event and values."
	dialogAgent := simulator getDialogAgentNamed: 'client A'. 
	stepLog := dialogAgent stepLog.
	self expect: #('client A: Hello.' 'S: Welcome to the Hotel California.') actual: stepLog asArray.
	
	"Verify that a Scribe is involved."
	scribe := dialogAgent scribeProxy.
	stepLog2 := scribe stepLog.
	self expect: #('System: Welcome to the Hotel California.') actual: stepLog2 asArray.
	
]

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX140VignetteTriggersGoal [
	"A vignette may trigger a goal."
	| ontology simulator messenger playback |
	"setup"
	ontology := self setUpDogAndPonyOntology.
	simulator := HumSimulator new.
	simulator ontology: (ontology).
	self setUpDogAndPonyConfigurationOn: simulator.
	"Speech acts are interpreted by dialog vignettes in an ontology."
	simulator after: (10 seconds) sendSpeech: 'Eh?.' from: 'client A'.
	simulator step.
	simulator stepUntilDone.
	( 1 to: 3 ) do: [:i | (Delay forMilliseconds: 1) wait.].  "Give forked processes some time to run."
	"Verify that expected messages were sent."
	messenger := simulator messenger.
	playback := messenger playbackLog.
	self assert: (playback size > 0).
	"Expect logs for coordinator dispatcher bookkeeper worldbase dog pony band."
	self expect: 7 actual: (playback size) 
	     description: 'Expect logs for dispatcher bookkeeper worldbase coordinator dog pony band'. 
	self expect: 9 actual: ( messenger playbackLogToURI: 'dispatcherURI' ) size
		   description: 'Expect 6 check-ins and 3 assignments.'.
	self expect: 1 actual: ( messenger playbackLogToURI: 'dogURI' ) size   description: 'dispatcher assigns to dog'.
	self expect: 1 actual: ( messenger playbackLogToURI: 'ponyURI' ) size  description: 'dispatcher assigns to pony'.
	self expect: 1 actual: ( messenger playbackLogToURI: 'bandURI' ) size  description: 'dispatcher assigns to band'.
	
]

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX142RunClubMech [
	"A vignette may trigger a goal."
	| ontology simulator messenger playback fileName pa dialogAgent stepLog scribe request worldbase request2 blackboard setup |
	"set up"
	fileName := './ontology/ClubMechV02.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	ontology := pa ontology.
	ontology compileAllFrames.
	simulator := HumSimulator new.
	simulator ontology: (ontology).
	setup := self setUpBasicConfigurationOn: simulator.
	messenger := simulator messenger.
	worldbase := messenger getActorInstanceFromID: (simulator worldbaseID).
	worldbase clock: (simulator).
	self assert: ( worldbase isKindOf: HumWorldBase ).
	self expect: ( setup at: 'worldbase') actual: worldbase.
	
	"Speech acts are interpreted by dialog vignettes in an ontology."
	simulator after: ( 1 second ) sendSpeech: 'My name is Testy Tester.' from: 'client A'.
	simulator after: (10 seconds) sendSpeech: 'Enter a topic.' from: 'client A'.
	simulator step.
	simulator stepUntilDone.
	
	"Verify that expected messages were sent."
	playback := messenger playbackLog.
	self expect: 3 actual: (playback size) description: 'Check-in client-A bookkeeper worldbase ???'.
	dialogAgent := simulator getDialogAgentNamed: 'client A'. 
	blackboard := dialogAgent blackboard.
	self expect: 'Testy Tester' actual: (blackboard getEntityName: 'user' attribute: 'name').
	stepLog := dialogAgent stepLog.
	self expect: 8 actual: (stepLog size) description: '???'.
	self expect: #(
	'client A: My name is Testy Tester.' 
	'S:  Hello Testy Tester.' 
	'S:    Please select an activity.' 
	'DialogAgent: {client A} is doing: {Push context "Select an activity.".}' 
	'client A: Enter a topic.' 
	'S:  Please enter a description of the talk you are offering.' 
	'DialogAgent: {client A} is doing: {New topic.}' 
	'DialogAgent: {client A} is doing: {Ask topic.}'
	)
				actual: stepLog asArray.
	"WHEN: Client enters data (speaker, title, description) and presses [Go!] button ... "
	"THEN: WorldBase should have a topic entity with attribute values for speaker, title, description. "
	scribe := dialogAgent scribeProxy.
	request := HumHttpRequest new.
	request 
		atField: 'topic:speaker' put: 'I.M. Speaker';
		atField: 'topic:title' put: 'This is only a test.';
		atField: 'topic:description' put: 'This is line one.',String cr,'This is line two'.
	scribe handleHttpPostRequest: request.
	"WorldBase should contain user`s name, topic`s speaker, title, description"
	self expect: (setup at: 'worldbase') actual: worldbase.
	self expect: 4 actual: ( worldbase quads size ). 
	self expect: 0 actual: ( worldbase history size ).

	"Enter a second topic. Result should be a second topic instance, not an updated version of first topic."
	simulator after: (20 seconds) sendSpeech: 'Enter another topic.' from: 'client A'.
	simulator step.
	simulator stepUntilDone.

	"At this point, 'Clear topic' instruction should have cleared topic entries from blackboard."
	self expect: 3 actual: (blackboard entityIdentifiers size) description:  'Expect identifiers for user, topic, speaker'.
	self expect: 4 actual: (blackboard quads size) description: 'Prior topic attributes are still in blackboard, but only accessible by ID'.

	request2 := HumHttpRequest new.
	request2 
		atField: 'topic:speaker' put: 'I.M. Speaker Too';
		atField: 'topic:title' put: 'This is a second topic.';
		atField: 'topic:description' put: 'This is line one of the second topic.',String cr,'This is line two of it.'.
	scribe handleHttpPostRequest: request2.
	
	self expect: 0 actual: ( worldbase history size ) description: 'Creating a new topic, so history should be empty'.  
	self expect: 7 actual: ( worldbase quads size ) description: 'We expect two topic instances and one user instance'.
	
]

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX143RunBarista [
	"A vignette may trigger a goal."
	| ontology simulator messenger playback fileName pa dialogAgent stepLog worker |
	"set up"
	fileName := './ontology/Barista.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	ontology := pa ontology.
	ontology compileAllFrames.
	simulator := HumSimulator new.
	simulator ontology: (ontology).
	self setUpBasicConfigurationOn: simulator.
	
	worker := HumActor workerID: 'Bobbi' uri: 'URI:Bobbi' roles: #('barista' 'server') configuration: simulator.
	worker checkIn.
	
	"Speech acts are interpreted by dialog vignettes in an ontology."
	simulator after: ( 1 second ) sendSpeech: 'Authenticated 1234567890.' from: 'client A'.
  "2015-01-22: Data is not being passed from order to worker. "
	"TODO: Simulate form fill-in."
  "2015-01-22: Fails because polymorphism is not implemented."
	"TODO: Implement polymorphism."
	simulator step.
	simulator stepUntilDone.
	( 1 to: 3 ) do: [ :i | (Delay forMilliseconds: 9) wait.].  "Give forked processes some time to run."
	
	"Verify that expected messages were sent."
	messenger := simulator messenger.
	playback := messenger playbackLog.
	self expect: 5 actual: (playback size) description: 'Check-in client-A bookkeeper worldbase Bobbi'.
	dialogAgent := simulator getDialogAgentNamed: 'client A'. 
	stepLog := dialogAgent stepLog.
	self assert: ( ('*Sorry*' match: (stepLog at: 2)) not ) 
		description: 'Should not get: "', (stepLog at:2),'" '.
	self expect: #(
		'client A: Authenticated 1234567890.' 
		'S:  Welcome *** Unknown ***.' 
		'S:    Please enter your order.' 
		'DialogAgent: {client A} is doing: {Ask order.}'
		)
			actual: stepLog asArray.

]

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX144RunDonutShop [
	"A vignette may trigger a goal."
	| ontology simulator messenger playback fileName pa dialogAgent stepLog |
	false ifFalse: [Transcript cr; show: 'testX144RunDonutShop turned off.'. ^self skip].
	"set up"
	fileName := 'DonutShopV05.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	ontology := pa ontology.
	ontology compileAllFrames.
	simulator := HumSimulator new.
	simulator ontology: (ontology).
	self setUpBasicConfigurationOn: simulator.
	
	"Speech acts are interpreted by dialog vignettes in an ontology."
	simulator after: ( 1 second ) sendSpeech: 'Customer presents order.' from: 'client A'.
	simulator step.
	simulator stepUntilDone.
	( 1 to: 3 ) do: [ :i | (Delay forMilliseconds: 9) wait.].  "Give forked processes some time to run."
	
	"Verify that expected messages were sent."
	messenger := simulator messenger.
	playback := messenger playbackLog.
	self expect: 3 actual: (playback size) description: 'Check-in client-A bookkeeper worldbase ???'.
	dialogAgent := simulator getDialogAgentNamed: 'client A'. 
	stepLog := dialogAgent stepLog.
	self assert: ( ('*Sorry*' match: (stepLog at: 2)) not ) 
		description: 'Sorry -- {', (stepLog at:2),'}'.
	self expect: #(
		)
			actual: stepLog asArray.

]

{ #category : #'Simulator tests' }
HumSimulatorTests >> testX150RunParallel [
	"A vignette may trigger a goal."
	| ontology simulator messenger playback myActors myBookkeeper |
	ontology := self setUpDogAndPonyOntology.
	simulator := HumSimulator new.
	"Speech acts are interpreted by dialog vignettes in an ontology."
	myActors := self setUpDogAndPonyConfigurationOn: simulator.
	simulator ontology: (ontology).
	simulator after: (10 seconds) sendSpeech: 'Eh?.' from: 'client A'.
	simulator after: (20 seconds) sendSpeech: 'Eh?.' from: 'client B'.
	simulator after: (30 seconds) sendSpeech: 'Eh?.' from: 'client C'.
	
	simulator step.
	simulator stepUntilDone.
	( 1 to: 7 ) do: [:i | (Delay forMilliseconds: 1) wait.]. "Give forked processes some time to run."
	"Verify that expected messages were sent."
	messenger := simulator messenger.
	playback := messenger playbackLog.
	self assert: (playback size > 0) description: 'Messenger play-back-log should not be empty.'.
	"Verify that expected messages were sent."
	"Expect logs for coordinator dispatcher bookkeeper worldbase dog pony band."
	self expect: 9 actual: (playback size) 
		description: 'Expect logs for dispatcher bookkeeper worldbase dog pony band client-A client-B client-C'. 
	self expect: 17  
	     actual: ( messenger playbackLogToURI: 'dispatcherURI' ) size
		description: 'Expect 8 check-ins and 9 assignments.'.
	self expect: 3 actual: ( messenger playbackLogToURI: 'dogURI'  ) size  description: 'dispatcher assigns to dog'.
	self expect: 3 actual: ( messenger playbackLogToURI: 'ponyURI' ) size  description: 'dispatcher assigns to pony'.
	self expect: 3 actual: ( messenger playbackLogToURI: 'bandURI' ) size  description: 'dispatcher assigns to band'.
		
	myBookkeeper := myActors at: 'bookkeeper'.
	self expect: (HumMeasure quantity: 27 units: #step) 
	     actual: (myBookkeeper chargesByRole at: 'Band:step'). 
	
	
]
