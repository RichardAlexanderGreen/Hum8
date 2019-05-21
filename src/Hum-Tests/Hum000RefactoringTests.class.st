"
Collaborative Roles and Responsibilities

Top-Level Roles
===============

Role: Ontology.
	Goal: Maintain and access frames.
		Action: Add frame.
		Action: Get frame where title = string.
		Action: Add frame-line.
	Goal: Maintain and access noun relationships.
		Action: Add noun attributes.
		Action: Note noun supertype.
		Action: Get all supertypes for noun.
		Action: Get all subtypes for noun.
	
Role: Ontology Translator
	Goal: Translate ontology into other languages.
		Action: Pretty-point ontology via HTML markup.
		Action: Translate ontology role to Erlang process.
		Action: Translate ontology role to Java interface and class files.
		Action: Render Hum view as JavaScript interactive.

Role: Programmers Assistant. (subtype Ontology or Dialog ???)
	Goal: Display and update ontology frames and diagrams.
		Action: Layout IDE view frames.
		Action: Notify user-interface listeners.
		Action: Respond to user-interface (scribe) events.

Role: Run-Time.
	Goal: Operate plans, views, and dialogs.

Role: Run-Time User-Interface.
	Goal: Translate to/from user-interface framework (e.g. HTML browser)
		Action: Translate Hum view to HTML.
		Action: Capture and forward view update event data. (to Scribe / Blackboard ???)
		* Dialog: Operate Hum dialog.
		* Dialog: Operate Hum view.
		* Dialog: Ask client for data needed to operate plan.
		Action: Track 2-D surface coordinates.
		Action: Track 3-D solid coordinates.
		Action: Draw diagram from graph-data.
		* Painter: Render surfaces as SVG.
		* Painter: Render diagram as SVG.
		* Sculptor: Render 3-D solid assembly as SVG/JavaScript. (Use WebGL wrapper)

Role: Run-Time Calculator.
	Goal: VM provides data processing services, operates on datatype primitives.
	   Measure Operations:
		Action: Add/Subtract/Multiply/Divide measure-A with measure-B giving measure-C.
		Action: Add/Subtract/Multiply/Divide distribution-A and distribution-B giving distribution-C.
	   Distribution Operations:
		Action: From distribution select value at Z. (Z between 0.0 and 1.0. Interpolating to give value.)
		Action: From collection analyze attribute frequency giving distribution.
	   String Operations:
		Action: Extract substring from string-A . . . giving string-B.
		Action: Insert  substring into string-A . . . giving string-B.
		Action: Format xml with . . . giving xml-string.
		Action: Fill in template from dictionary.
		Action: Match pattern to string giving dictionary.
	   Date  Operations:
		Action: Compare date-A with date-B giving duration.
		Action: Add duration to date-A giving date-B.
	   Collection Operations:
		Action: In collection-A return entities where <boolean expression> giving collection-B.
		Action: From collection return size (count).
	   Persistence Operations:
		Action: Save/Restore actor`s state {blackboard, IP, job-ticket}. (On call to another actor)
		Action: Notify World-Base when blackboard changes.
		Action: Populate blackboard from action-call {requester, action, noun-values, job-ticket}.
		Action: Forward action-call to Messenger.


. . . Run-Time Work-Flow Roles . . .
- - - - - - - - - - - - - - - - - - -
Role: Supervisor.
	Goal: Operate plans.
		Action: Populate plan with data from blackboard.
		Action: Evaluate preconditions and invoke actions that are ready.
		Action: Assert precondition. (when action completes)
		Action: Notify client and bookkeeper when plan is complete.
		* Dialog: Ask for data needed to operate plan.

Role: Resource Manager.
	Goal: Manage actors.
		* Dispatcher: Assign actor to perform role action on job.
		* Bookkeeper: Tally resource usage for job.
		* DangerMan: Handle problem reported by actor performing action for job.

Role: Bookkeeper.
	Goal: Track resource utilization.
		Action: Record resources used by actor performing action on job.
		Action: Sum resource utilized by actor/job/client/action/resource-type/inventory.
		Action: Select . . .

Role: Messenger.
	Goal: Deliver messages. Provide log, audit-trail, replay, security services. 
		Action: Deliver message from sender to receiver.
		Action: Remember actor is at address.
		Action: Replay messages to/from actor since date-time.
		Action: Record each action-type in audit-trail.
		Action: Remember/Forget that action-type requires privilege-type.


	
"
Class {
	#name : #Hum000RefactoringTests,
	#superclass : #HumTestCase,
	#category : #'Hum-Tests'
}

{ #category : #'200 View Ontology' }
Hum000RefactoringTests >> givenOntology [
	| ontology planFrame1 planFrame2 planFrame3 frameUpdater |
		ontology := HumOntology new.
	ontology title: 'givenOntology'.
		
	planFrame1 := HumFrame4Plan ontology: ontology goal: 'Bake a cake per recipe.'.
	planFrame1 appendPrecondition: 'Oven is preheated per recipe.'.	
	planFrame1 appendPrecondition: 'Batter is in bake-pan per recipe.'.
	planFrame1 appendRole: 'Baker' action: 'Bake bake-pan in the oven per recipe.'.
	ontology storeFrame: planFrame1.
		
	planFrame2 := HumFrame4Plan ontology: ontology goal: 'Oven is preheated per recipe.'.
	planFrame2 appendPrecondition: 'Oven is cleared out.'.
	planFrame2 appendPrecondition: 'Oven is on.'.
	planFrame2 appendPrecondition: 'Oven temperature is set per recipe.'.
	planFrame2 appendRole: 'Timer' action: 'Wait 5 minutes.'.
	ontology storeFrame: planFrame2.
	
	planFrame3 := HumFrame4Plan ontology: ontology goal: 'Batter is in bake-pan per recipe.'.
	planFrame3 appendPrecondition: 'Batter fully mixed per recipe.'.
	planFrame3 appendPrecondition: 'Bake-pan is greased per recipe.'.
	planFrame3 appendRole: 'Baker' action: 'Pour batter into bake-pan per recipe.'.
	ontology storeFrame: planFrame3.

	
	"Create an Action Frame."
	frameUpdater := HumFrameUpdater ontology: ontology  
	                                   role: 'baker' 
																	action: 'Bake the pan in the oven for the time given in the recipe.'.
	frameUpdater appendInstructionStatement: 'Open the oven door.'.
	frameUpdater appendInstructionStatement: 'Place the pan in the oven.'.
	frameUpdater appendInstructionStatement: 'Close the oven door.'.
	frameUpdater appendInstructionRole: 'Oven' statement: 'Bake for the baking-time given in the recipe.' comment: 'We have a smart oven.'.	
	ontology storeFrame: ( frameUpdater frame ).
	
	"Create a Dictionary Frame."
	frameUpdater := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.
	frameUpdater addDictionaryLine: 'Recipe attributes include recipe-name, description, ingredients, steps.'.
	frameUpdater addDictionaryLine: 'Recipe includes a list of ingredients.'.
	frameUpdater addDictionaryLine: 'Recipe includes a list of steps.'.
	frameUpdater addDictionaryLine: 'Ingredient attributes include ingredient-name, quantity, alternate-ingredient.'.
	frameUpdater addDictionaryLine: 'Step attributes include step-number, step-description'.
	frameUpdater addDictionaryLine: 'Bakery attributes include oven, mixer, counter.'.
	frameUpdater addDictionaryLine: 'Recipe attributes include baking-time.'.
	ontology storeFrame: ( frameUpdater frame ).

	"Create a View Frame."
	frameUpdater := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	frameUpdater addMarkUp: '!! Recipe'.
	frameUpdater addMarkUp: ' recipe-name: [name]'.
	frameUpdater addMarkUp: '   description: [description 5]'.
	frameUpdater addMarkUp: '   ingredients: [ingredients]'.
	frameUpdater addMarkUp: '  Do _not_ forget to ~preheat~ the *oven*.'.  "Test emphasis."
	frameUpdater addMarkUp: '            steps: [steps]'.
	ontology storeFrame: ( frameUpdater frame ).
	
	"Frames must be compiled if nouns are to be marked."
	ontology compileAllFrames.
	
	^ontology

]

{ #category : #'000 Class Responsibiltiy Collaboration' }
Hum000RefactoringTests >> humClassResponsiblityCollaboration [
^'Collaborative Roles and Responsibilities

TODO: Does this "Purpose:" hierarchy has a place in Hum Action Frames?
Top-Level Roles
===============

Role: Ontology.
	Purpose: Maintain and access frames.  
		Action: Add frame.        (Other tests will also cover.)
		Action: Add frame-line.   (Depends on the kind of frame. Other tests will cover as by-product.)
		Action: Get frame where . . .  (tests12x ... 13x )
		Action: . . . where goal is planned.
		Action: . . . where action is defined.
		Action: . . . where view is defined.
		Action: Get frames where . . .
		Action: . . . where precondition is used. (A goal-frame has a set of preconditions.)
		Action: . . . where action is invoked.    (Actions may be invoked in goal, action, and vignette frames.)
		Action: . . . where view is invoked.      (A view may be invoked in view and vignette frames.)
		Action: . . . where context is defined. 	(Each context vignette is a frame.)
		Action: . . . where context is invoked.  	(Scan the vignette instructions at compile time?)
	Purpose: Maintain and access noun relationships. (These are covered in old HumOntologyTests)
		Action: Add noun attributes.
		Action: Note noun supertype.
		Action: Get all supertypes for noun.
		Action: Get all subtypes for noun.
		Action: Get frame-lines where noun is used.  (Skipped -- 12 Feb 2014)
	
Role: Ontology Viewer. (subtype Ontology   *** REFACTORING ***)
	Purpose: Provide visualizations of the ontology.
		Action: Pretty-print ontology via HTML markup.
		Action: Translate ontology relationships to graph. (UI may render graph as SVG).
		Action: . . . goal dependencies . . .
		Action: . . . noun dependencies . . .
		Action: . . . role dependencies . . .
		Action: . . . dialog context paths . . .
		Action: . . . view hierarchy . . .
		
Role: Ontology Translator (subtype Ontology  *** REFACTORING ***)
	Purpose: Translate ontology into other programming languages.
		Action: Translate ontology role to Erlang process.
		Action: Translate ontology goal-frame to Erlang FSM.
		Action: Translate ontology role to Java interface and class files.
		Action: Translate Hum view to Smalltalk Seaside (+ Hum Run-Time).
	   Futures?
		Action: Translate ontology role to Python class.
		Action: Translate ontology role to Javascript class. (prototype)
		
Role: Programmers Assistant. (subtype Dialog)
	Purpose: Display and update ontology frames and diagrams.
		Action: Respond to user gestures by invoking ontology and user-interface actions.
		Action: Layout IDE view frames.
		Action: Parse frame-line source code.

	Purpose: Identify potential problems, missing code. (Code Critic)
		Action: Statement has no known nouns.  (Implies that the only parameter is the job.)
		Action: Noun lacks antecedent.         (There is no way to populate it at run-time.)
		Action: Spellcheck frame-line.         (Words should be in natural dictionary or local jargon.)
		Action: Identify undefined preconditions as pending.
		Action: Identify undefined actions as pending. 
		Action: Identify noun-graph cycles as warning.
		Action: Identify precondition-graph cycles as error.
		Action: Identify action-graph cycles as warning.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Run-Time Layer
==============

Role: Run-Time.
	Purpose: Operate plans, views, and dialogs.   (Ontology is active on the run-time layer.)
		* Coordinator: Operate plans.
		* User-Interface: Operate views.
		* Dialog-Agent: Operate dialogs.
		* Messenger: Provide agent-to-agent communication infrastructure.
		* Resource-Manager: Assign agents to tasks. (actions on jobs)
		* Bookkeeper: Record resource utilization.
		* Calculator: Implement traditional data-processing operations.
		* World-Base: Implement temporal database.

Role: Run-Time User-Interface. (Hum-UI package)
	Purpose: Translate to/from user-interface framework (e.g. HTML browser)
		Action: Capture and forward view update event data. (to Scribe / Blackboard ???)
		* Dialog: Operate Hum dialog.
		* Dialog: Operate Hum view.
		* Dialog: Ask client for data needed to operate plan.
		Action: Track 2-D surface coordinates.
		* Painter: Render surfaces as SVG.
		Action: Draw diagram from graph-data.
		* Painter: Render diagram as SVG. 
		 (TODO: Should HumGraph or Painter position the nodes in virtual space?)
		 (TODO: Use an external product for dynamic interactive positioning.)
		Action: Track 3-D solid coordinates.
		* Sculptor: Render 3-D solid assembly as SVG/JavaScript. (Use WebGL wrapper)

Role: Run-Time Calculator.  (HumCalculator class)
	Purpose: VM provides data processing services, operates on datatype primitives.
	   (Measure Operations)
		Action: Add/Subtract/Multiply/Divide measure-A with measure-B giving measure-C.
		Action: Add/Subtract/Multiply/Divide distribution-A and distribution-B giving distribution-C.
	   (Distribution Operations)
		Action: From distribution select value at Z. (Z between 0.0 and 1.0. Interpolating to give value.)
		Action: From collection analyze attribute frequency giving distribution.
	   (String Operations)
		Action: Extract substring from string-A . . . giving string-B.
		Action: Insert  substring into string-A . . . giving string-B.
		Action: Format xml with . . . giving xml-string.
		Action: Fill in template from dictionary.
		Action: Match pattern to string giving dictionary.
	   (Date  Operations)
		Action: Compare date-A with date-B giving duration.
		Action: Add duration to date-A giving date-B.
	   (Collection Operations)
		Action: In collection-A return entities where <boolean expression> giving collection-B.
		Action: From collection return size (count).
	   (Persistence Operations)
		Action: Save/Restore actor`s state {blackboard, IP, job-ticket}. (On call to another actor)
		Action: Notify World-Base when blackboard changes.
		Action: Populate blackboard from action-call {requester, action, noun-values, job-ticket}.
		Action: Forward action-call to Messenger.
		 (String, Date, Collection, Persistence support bootstrap and user extensions.)

- - - - - - - - - - - - - - - - - - -
. . . Run-Time Work-Flow Roles . . .
- - - - - - - - - - - - - - - - - - -
Role: Coordinator.
	Purpose: Operate plans.
		Action: Populate plan with data from blackboard.
		* Dialog: Ask for data needed to operate plan.
		Action: Evaluate preconditions and invoke actions that are ready.
		Action: Assert precondition. (when action completes)
		Action: Notify client and bookkeeper when plan is complete.
		* 

Role: Dispatcher.
	Purpose: Manage actors.
		* Dispatcher: Assign actor to perform role action on job.
		* Bookkeeper: Tally resource usage for job.
		* Intervener: Handle problem reported by actor performing action for job.
		* Monitor: Identify over-long action-duration.

Role: Bookkeeper.
	Purpose: Track resource utilization.   (Bookkeeper does not monetize utilization or inventory. See Accounting role for that.)
		Action: Record resource-utilized by actor performing action on job.
		Action: Sum/Select resource-utilized by actor/job/client/action/resource-type/inventory.   (12 slightly different actions)

Role: Messenger.
	Purpose: Deliver messages. Provide log, audit-trail, replay, security services. 
		Action: Deliver message from sender to receiver.
		Action: Remember actor is at address.
		Action: Replay messages to/from actor since date-time.
		Action: Record each action-type in audit-trail.
		Action: Remember/Forget that action-type requires privilege-type.

Role: World-Base.
	Purpose: Remember what happened and why.	(Corporate long-term memory.)
		Action: Record event. (Event <==> Timestamp.)
		Action: Record entity attribute-values due to event.
		Action: Fetch current state.
		Action: Fetch entity event-history.
		Action: Fetch state at time-T.
	Purpose: Forget what happened and why. 	(Reduce short-term memory burden.)
		Action: Purge data in category-C prior to time-T.
		Action: . . . event records . . .
		Action: . . . entity values . . .

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Shown to clarify separation of responsibility)
======================
Role: Accountant.   
	Purpose: Maintain monetary accounts.   		(Traditional accounting functions go here.)
		* Costing: Assign costs to resources.
		* Pricing: Assign prices to products.
		* Ledger: Categorize expenses, revenues, assets, liabilities, cash-flows.
		* Accounts: Track counter-party obligations.
		* Receivables: Track customer obligations.	(Send invoices and statements to customers.)
		* Purchasing: Purchase resources as needed.
		* Payables: Track supplier obligations.	(Pay suppliers for resources delivered.)
		* Taxables: Track tax authority obligations.
		* Banking: Track actual receipts, payments, balances.

Role: Relations. 
	Purpose: Track who-we-know and why. 
		Action: Track counter-party roles. 	(customers, suppliers, workers, governments)
		Action: Track knowledge/capability.	(“knowledge management” ???)
		Action: Track contracts.   				(promises, pricing, future dates)
		Action: Follow-up intent/obligation/claim.		(campaign, promise, agenda, order, claim)
		Action: Notify counter-party of relevant events. 
		* Coordinator: Operate order-fulfillment plans.
		* Dialog: Initiate order-fulfillment plans from sales-orders.
		* Dialog: Operate automated correspondence. 	(via post, e-mail, Messenger, . . .)
		* Archive: Record correspondence.

Role: Archive. (These functions may use the WorldBase but are not implemented there.)
	Purpose: Manage enterprise documents / files.
		Action: Record correspondence.  		(Correspondence is also Dialog and World-Base Event)
		Action: Archive product brochures, catalogs, manuals.  (Products and Documents are World-Base entities)
		Action: Manage engineering documents.  	(Versions, reviews, approvals, releases are also World-Base Events)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Run-Time Implementations:
	Erlang:
		Advantages:
			Erlang OTP is a robust and mature actor framework.
			==> Hum translates nicely to OTP distributed actors.
			==> Hum world-base translates nicely to Erlang databases. (e.g. Riak)
			May Enable a large audience for Erlang OTP. 	<<< Open OTP to enterprise audience? <<<
		Disadvantages:
			Some host limitations.
			Different Paradigm ==> Smaller audience.  (But it might be a thought-leader audience.)

	JVM ==> Java/Scala/Groovy:
		Advantages:
			Runs almost everywhere.
			Large audience.
		Disadvantages:
			Immature actor framework. (But I am told Scala OTP is okay.)

	ECMAscript / JavaScript:
		Advantages:
			Runs in web browsers.
			Large audience.
			Enables a large web-oriented constituency.  	<<< This could be a GAME-CHANGER. <<<<
			Includes strong 3D support via webGL.
		Disadvantages:
			NO MATURE ACTOR FRAMEWORK.
			JavaScript frameworks are very diverse and not well documented.
			WebGL wrappers are immature. (But that might not be a problem by the time I get to doing 3D.)
	'.
]

{ #category : #running }
Hum000RefactoringTests >> setUp [
	"set default store for these tests"			
	| defaultStoreDirectoryName |
	defaultStoreDirectoryName  := './Developer/Smalltalk/Hum8/data'.
	HumStore defaultDirectory: defaultStoreDirectoryName .
	
]

{ #category : #'000 Class Responsibiltiy Collaboration' }
Hum000RefactoringTests >> strategyForSeaside [
^'TBD -- Currently considering subtyping HumWidgets as WAComponents
See: WAInputElementContainer for some code examples.
See: WAInputGetFunctionalTest
See: WAModelFunctionalTest
see: WAHtml5InputTest
see: 
'
]

{ #category : #running }
Hum000RefactoringTests >> tearDown [ 
	"Reset the default store to null"			
	|  |
	HumStore defaultStore:  nil.
]

{ #category : #'100 Maintain and access frames' }
Hum000RefactoringTests >> test110addFrame [
	"Add frame to ontology"
	| planFrame ontology |
	
	ontology := HumOntology new.

	"A plan frame should have a goal and at least two preconditions."
	
	planFrame := HumFrame4Plan  ontology: ontology goal: 'Bake a cake per recipe'.
	planFrame appendPrecondition: 'Oven is preheated per recipe.'.	
	planFrame appendPrecondition: 'Batter is in bake-pan per recipe.'.
	planFrame appendRole: 'Baker' action: 'Bake bake-pan in the oven per recipe.'.
	
	ontology storeFrame: planFrame.
	
	self assert: (ontology frames size) = 1.	
	self assert: (ontology framesByIdentifier size) = 1.	
	self assert: (ontology framesByName size) = 1.
]

{ #category : #'100 Maintain and access frames' }
Hum000RefactoringTests >> test121getFrameForGoal [
	"Get the plan frame that defines a goal."
	| planFrame ontology result |
	
	ontology := HumOntology new.

	"A plan frame should have a goal and at least two preconditions."
	
	planFrame := HumFrame4Plan  ontology: ontology goal: 'Bake a cake per recipe.'.
	planFrame appendPrecondition: 'Oven is preheated per recipe.'.	
	planFrame appendPrecondition: 'Batter is in bake-pan per recipe.'.
	planFrame appendRole: 'Baker' action: 'Bake bake-pan in the oven per recipe.'.
	
	ontology storeFrame: planFrame.
	
	result := ontology getPlanFrameForGoal: 'Bake a cake per recipe.'.
	
	self assert: planFrame equals: result.
]

{ #category : #'100 Maintain and access frames' }
Hum000RefactoringTests >> test122getFrameForAction [
	"Get frame where action statement is defined."
	| ontology frameUpdater result |
		ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameUpdater := HumFrameUpdater ontology: ontology  
	                                   role: 'Baker' 
	                                 action: 'Bake the pan in the oven for the time given in the recipe.'.
	frameUpdater appendInstructionStatement: 'Open the oven door.'.
	frameUpdater appendInstructionStatement: 'Place the pan in the oven.'.
	frameUpdater appendInstructionStatement: 'Close the oven door.'.
	frameUpdater appendInstructionRole: 'Oven' 
	                     statement: 'Bake for the baking-time given in the recipe.' 
	                       comment: 'We have a smart oven.'.
	
	ontology storeFrame: ( frameUpdater frame ).
	
	result := ontology getFrameForRole: 'Baker' action: 'Bake the pan in the oven for the time given in the recipe.'.
	
	self expect: ( frameUpdater frame ) actual: result.

]

{ #category : #'100 Maintain and access frames' }
Hum000RefactoringTests >> test123getFrameForView [
	"Get frame where view is defined."
	| frame result ontology |
	ontology := HumOntology new.
	frame := HumFrame4View ontology: ontology viewEntity: 'Street-Address'.
	self assert: (frame isKindOf: HumFrame4View ).
	
	frame addMarkUp: '! This is a 1sd level title.'.
	frame addMarkUp: '!! This is a 2nd level title.'.
	frame addMarkUp: '!!! This is a 3rd level title.'.
	
	ontology storeFrame: frame.
	
	result := ontology getViewFrame: 'Street-Address'.
	
	self assert: frame equals: result.	
]

{ #category : #'100 Maintain and access frames' }
Hum000RefactoringTests >> test131getFramesInvokingPrecondition [
	"Get the goal frames that invoke a given precondition."
	| frames ontology planFrameA planFrameB |
	ontology := HumOntology new.
	
	planFrameA := HumFrame4Plan  ontology: ontology goal: 'Bake a cake per recipe.'.
	planFrameA appendPrecondition: 'Oven is preheated per recipe.'.	
	planFrameA appendPrecondition: 'Batter is prepared per recipe.'.   "Redundant. See below."
	planFrameA appendPrecondition: 'Batter is in bake-pan per recipe.'.
	planFrameA appendRole: 'Baker' action: 'Bake bake-pan in the oven per recipe.'.
	ontology storeFrame: planFrameA.
	
	planFrameB := HumFrame4Plan ontology: ontology goal: 'Batter is in bake-pan per recipe.'.
	planFrameB appendPrecondition: 'Batter is prepared per recipe.'.
	planFrameB appendPrecondition: 'Cake-pan is prepared per recipe.'.   "Is it greased?"
	planFrameB appendRole: 'Mixer' action: 'Pour batter into cake-pan.'.
	ontology storeFrame: planFrameB.
	
	ontology compileAllFrames. "Compile creates index as a by-product."
	
	frames := ontology getFramesThatInvokePrecondition: 'Batter is prepared per recipe.'.
	
	
	self assert: (frames size) equals: 2.
]

{ #category : #'100 Maintain and access frames' }
Hum000RefactoringTests >> test132getFramesInvokingAction [
	"Get the frames that invoke a given action."
	| frames ontology goalFrame actionFrame vignetteFrame instruction |
	ontology := HumOntology new.
	"Actions may be invoked in goal-frames, action-frames, and vignettes."
	
	"Create a goal frame. "
	goalFrame := HumFrame4Plan ontology: ontology goal: 'Dishes are clean and dry.'.
	goalFrame appendRole: 'Dishwasher' action: 'Clean and dry the dishes.'.
	ontology storeFrame: goalFrame.
	
	"Create an action frame."
	actionFrame := HumFrame4Action ontology: ontology role: 'Chef' action: 'Boss KP.'.
	actionFrame appendInstructionRole: 'Dishwasher' statement: 'Clean and dry the dishes.'.
	ontology storeFrame: actionFrame.
	
	"Create a vignette."
	vignetteFrame := HumFrame4Vignette ontology: ontology vignetteContext: 'KP' pattern: '* allowance *'.
	vignetteFrame addVignetteResponse: 'Okay. I will load the dishwasher.'.
	instruction := (HumInstructionLine role: 'Dishwasher' statement: 'Clean and dry the dishes.').
	vignetteFrame addVignetteInstruction: instruction.
	ontology storeFrame: vignetteFrame.
	
	ontology compileAllFrames. "Compile creates index as a by-product."
	
	frames := ontology getFramesThatInvokeAction: 'Dishwasher: Clean and dry the dishes.'.
	
	self expect: 3 actual: (frames size) description: 'Goal frame, action frame, and vignette all invoke instruction.'.
]

{ #category : #'100 Maintain and access frames' }
Hum000RefactoringTests >> test133getFramesInvokingView [
	"Get views frames and vignettes that invoke a view."
	| ontology  viewFrame  vignette resultSet |
	
	"Create an ontology"
	ontology := HumOntology new.
	
	"Create a view that invokes another view."
	viewFrame := HumFrame4View ontology: ontology viewEntity: 'Party'. 
	viewFrame addMarkUp: '!! Party'.
	viewFrame addMarkUp: ' name: [name]'.
	viewFrame addMarkUp: ' address: [pane: Address]'.
	ontology storeFrame: viewFrame.
	
	"Create a vignette that invokes a view."
	vignette := HumFrame4Vignette ontology: ontology vignetteContext: 'Order Entry' pattern: '* delivered *'.
	vignette addVignetteResponse: 'Where do you want it delivered?'.
	vignette addVignetteInstruction: 'Ask Address.'.
	ontology storeFrame: vignette.
	
	ontology compileAllFrames. "Create indexes."
	
	resultSet := ontology getFramesThatInvokeView: 'Address'.
	
	self assert: ( resultSet size ) equals: 2.
	
]

{ #category : #'100 Maintain and access frames' }
Hum000RefactoringTests >> test134getFramesDefiningContext [
	"Get vignettes that define a context."
	| ontology  vignetteA vignetteB resultSet |
	
	"Create an ontology"
	ontology := HumOntology new.
		
	"Create a vignette that defines part of a context."
	vignetteA := HumFrame4Vignette ontology: ontology vignetteContext: 'Order-Entry' pattern: '* delivered *'.
	vignetteA addVignetteResponse: 'Where do you want it delivered?'.
	vignetteA addVignetteInstruction: 'Ask Address.'.
	ontology storeFrame: vignetteA.
	
	"Create another vignette in the same context."
	vignetteB := HumFrame4Vignette ontology: ontology vignetteContext: 'Order-Entry' pattern: '* pick up *'.
	vignetteB addVignetteResponse: 'When do you expect to pick up?'.
	vignetteB addVignetteInstruction: 'Push context pick-up-time.'.
	ontology storeFrame: vignetteB.
	
	ontology compileAllFrames. "Create indexes."

	"Test: Make this not case-sensitive."
	resultSet := ontology getFramesThatDefineContext: 'order-entry'.
	
	self assert: ( resultSet size ) equals: 2.
	
]

{ #category : #'100 Maintain and access frames' }
Hum000RefactoringTests >> test135getFramesInvokingContext [
	"Get vignettes that define a context."
	| ontology  vignetteA vignetteB resultSet |
	
	"Create an ontology"
	ontology := HumOntology new.
		
	"Create a vignette that defines part of a context."
	vignetteA := HumFrame4Vignette ontology: ontology vignetteContext: 'Order-Entry' pattern: '* delivered *'.
	vignetteA addVignetteResponse: 'Where do you want it delivered?'.
	vignetteA addVignetteInstruction: 'Ask Address.'.
	ontology storeFrame: vignetteA.
	
	"Create another vignette in the same context."
	vignetteB := HumFrame4Vignette ontology: ontology vignetteContext: 'Order-Entry' pattern: '* pick up *'.
	vignetteB addVignetteResponse: 'When do you expect to pick up?'.
	vignetteB addVignetteInstruction: 'Push context pick-up-time.'.
	ontology storeFrame: vignetteB.
	
	ontology compileAllFrames. "Create indexes."

	"Test: Make this not case-sensitive."
	resultSet := ontology getFramesThatInvokeContext: 'pick-up-time'.
	
	self assert: ( resultSet size ) equals: 1.
	
]

{ #category : #'200 View Ontology' }
Hum000RefactoringTests >> test210prettyPrintOntologyAsHTML [
	"Refactor so that this function is view OntologyViewer"
	| html ontology |
	ontology := self givenOntology.
	"Call via a OntologyViewer instance."
	html := ontology view asHTML5.
	
]

{ #category : #'200 View Ontology' }
Hum000RefactoringTests >> test211prettyPrintOntologyAsHTMLonFile [
	"Pretty print the given ontology on an HTML file."
	| html ontology |
	ontology := self givenOntology.
	"Call via a OntologyViewer instance."
	html := ontology view renderAsHTMLonFileNamed: 'test211.html'.
	
]

{ #category : #'200 View Ontology' }
Hum000RefactoringTests >> test220renderCollectionAsHtmlTable [
	"A plural noun indicates a collection.
	When a view contains a plural attribute: '[ingredients]' ... '[steps]',
	it should be rendered as a table of ingredients.
	"
	| html ontology |
	ontology := self givenOntology.
	"Call via a OntologyViewer instance."
	html := ontology view asHTML5.
	"Should see two tables"
	self assert: ( '*<table*</table>*<table*</table>*' match: html ).
	"Should see attributes of steps."
	self assert: ( '*<th>*step-*</th>*' match: html ).
	"Should see attributes of ingredients."
	self assert: ( '*<th>*ingredient-name*</th>*' match: html ).
	"html inspect."
	
]

{ #category : #'200 View Ontology' }
Hum000RefactoringTests >> test221renderCollectionAsHtmlTableOnFile [
	"A plural noun indicates a collection.
	When a view contains a plural attribute: '[ingredients]' ... '[steps]',
	it should be rendered as a table of ingredients.
	"
	| html ontology |
	ontology := self givenOntology.
	"Call via a OntologyViewer instance."
	html := ontology view renderAsHTMLonFileNamed: 'test221.html'.
	"Should see two tables"
	self assert: ( '*<table*</table>*<table*</table>*' match: html ).
	"Should see attributes of steps."
	self assert: ( '*<th>*step-*</th>*' match: html ).
	"Should see attributes of ingredients."
	self assert: ( '*<th>*ingredient-name*</th>*' match: html ).
	
	
]

{ #category : #'200 View Ontology' }
Hum000RefactoringTests >> test230renderEmphasisAsHTML [
	"Render emphasis in the markup as underscore, italic, bold. 
	  'Do _not_ forget to ~preheat~ the *oven*.''
	"
	| html ontology frameUpdater |
	ontology := HumOntology new.
		"Create a View Frame."
	frameUpdater := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	frameUpdater addMarkUp: '!! Heading 2'.
	frameUpdater addMarkUp: '- List1'.
	frameUpdater addMarkUp: '-- List2'.
	frameUpdater addMarkUp: '  Do _not_ forget to ~preheat~ the *oven*.'.  "Test emphasis."
	ontology storeFrame: ( frameUpdater frame ).
	
	"Frames must be compiled if nouns are to be marked."
	ontology compileAllFrames.
	"Call via a OntologyViewer instance."
	html := ontology view renderAsHTMLonFileNamed: 'test230.html'.

	"Expect _not_ to become <u>not</u> "
	self assert: ('*<u>not</u>*' match: html).

	"Expect ~preheat~ to become <i>preheat</i> "
	self assert: ('*<i>preheat</i>*' match: html).

	"Expect *oven* to become <b>oven</b> "
	"Note: Might also see noun <n> tags."
	self assert: ('*<b>*oven*</b>*' match: html).
	
	
]
