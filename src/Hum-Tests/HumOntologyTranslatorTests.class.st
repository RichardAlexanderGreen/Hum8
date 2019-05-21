Class {
	#name : #HumOntologyTranslatorTests,
	#superclass : #HumTestCase,
	#category : #'Hum-Tests'
}

{ #category : #utility }
HumOntologyTranslatorTests >> assertExpectedTokensIn: expected matchesTokensIn: actual [
	"Compare the two strings as a stream of tokens.
	If they are the same, 
	. return self.
	If they are not the same, 
	. signal failure and show where match fails.
	This is patterned after TestCase>>assert:equals:
	"
	| whitespace specials delimiters expectedTokens actualTokens |
	self assert: ( expected isKindOf: String ).
	self assert: ( actual isKindOf: String ).
	whitespace := String space, String tab, String crlf.
	specials := '~!@#$%^&*()_+`-={}|[]\:";''<>?,./'.
	delimiters := whitespace, specials.
	expectedTokens := ( expected withBlanksCondensed ) findTokens: delimiters keep: specials.
	actualTokens   := (   actual withBlanksCondensed ) findTokens: delimiters keep: specials.
	
	( 1 to: expectedTokens size )
		do: [ :i |
			| expectedToken actualToken |
			expectedToken := expectedTokens at: i.
			actualToken := actualTokens at: i.
			self assert: ( expectedToken = actualToken ) description: 'expected: "',expectedToken,'" at: ',i asString,' actual: "', actualToken,'"'.
			"Note failing this assert will halt the loop."
			].
	^ self
		assert: ( expectedTokens = actualTokens )
		description: 'tokens do not match '.
]

{ #category : #'z generated Smalltalk' }
HumOntologyTranslatorTests >> bakeThePanInTheOvenForTheTimeGivenInTheRecipeQpan: aPan oven: aOven time: aTime recipe: aRecipe [ 
	 | aDoor |
	"Open the oven door. "
	self openTheOvenDoorQoven: aOven door: aDoor . 
	"Place the pan in the oven. "
	 self placeThePanInTheOvenQpan: aPan oven: aOven . 
	"Close the oven door. "
	 self closeTheOvenDoorQoven: aOven door: aDoor . 
	"Oven: Heat for the time given in the recipe.We have a smart oven."
	 aOven heatForTheTimeGivenInTheRecipeQtime: aTime recipe: aRecipe . "We have a smart oven."

]

{ #category : #'z generated Smalltalk' }
HumOntologyTranslatorTests >> fulfillOrderQorder: aOrder [ 
	"For each order-item in the order: "
	( self blackboard entity: 'order' attribute: 'orderItem' ) do: [ :orderItem | 
     | aOrderItem |
     aOrderItem := orderItem.
		"Pull order-item from stock and place on cart. "
		 self pullOrderItemFromStockAndPlaceOnCartQorderItem: aOrderItem . 
		].
	"Ship the order to the order-address. "
	 self shipTheOrderToTheOrderAddressQorder: aOrder . 

]

{ #category : #utility }
HumOntologyTranslatorTests >> test010AssertExpectedTokensInAMatchesTokensInB [
	"Test the utility with the cases that matter to me."
	| failcase |
	
	"Two cases that differ only in white space will match"
	self assertExpectedTokensIn: '  (  { } )' matchesTokensIn: '({})'.
	"Two cases that differ in substance will fail"
	failcase := [self assertExpectedTokensIn: '( { } )' matchesTokensIn: '( { somethingdifferent } )'].
	self should: failcase raise: TestFailure.


]

{ #category : #'Generic Translation Strategy' }
HumOntologyTranslatorTests >> test110AttachMethodToClass [
	"Attach a method to a class."
	| translator aMethodName aClassName aSource |
	translator := HumOntologyTranslator new.
	"Example in Java syntax with Hum accounting"
	aSource := '	
		/** Move portable-object to location. */
		public Expense movePortableObjectToLocation( PortableObject portableObject, Location location ) {
			// TBD - The body of the method goes here.
			Timer timer = new Timer.start();
			timer.tick( self.randomDuration() );  // Fuzzy number for simulation.
			return new Expense( self.class(), self.id(), timer.stop() );
		}
						'.
	aMethodName := 'Move portable-object to location.'.
	aClassName := 'MaterialTransporter'.
	translator attachAction: aMethodName toActorClass: aClassName fromSource: aSource.
	
	"TODO: Need some asserts."
	self assert: ( translator methodsForClasses isEmpty) not.

]

{ #category : #'Generic Translation Strategy' }
HumOntologyTranslatorTests >> test111GetMethodsForClass [
	"Attach a method and get it back."
	| translator aMethodName aClassName aSource methods source |
	translator := HumOntologyTranslator new.
	"Example in Java syntax with Hum accounting"
	aSource := '	
		/** Move portable-object to location. */
		public Expense movePortableObjectToLocation( Entity portableObject, Entity location ) {
			// TBD - The body of the method goes here.
			Timer timer = new Timer.start();
			timer.tick( self.averageDuration() );  // Use average duration for fairness.
			return new Expense( self.class(), self.id(), timer.stop() );
		}
						'.
	aMethodName := 'Move portable-object to location.'.
	aClassName  := 'MaterialTransporter'.
	translator attachAction: aMethodName toActorClass: aClassName fromSource: aSource.
	
	"Now get it back."
	methods := translator getMethodsForClass: aClassName.
	self assert: ( methods size = 1 ).
	source := methods at: aMethodName.
	self assert: aSource equals: source.
	

]

{ #category : #'Generic Translation Strategy' }
HumOntologyTranslatorTests >> test120AttachClassPrologue [
	"Attach prologue source lines to an actor class.
	Language-specific translators will generate prologue code.
	The prologue will contain boiler-plate and infrastructure.
	"
	| translator  aClassName aSource |
	translator := HumOntologyTranslator new.
	aClassName := 'MaterialTransporter'.
	
	"Example in Java syntax with Hum accounting.
	Eventually, the Ontology Translator will generate the prologue."
	aSource := '// Hum Actor: ', aClassName,'.
// Actor supertype implements BlackBoard and Messenger interfaces.
include hum.actor.Actor;  
// On receipt of a message, the supertype copies data into local blackBoard and jobTicket variables.
include hum.actor.BlackBoard;
include hum.actor.JobTicket;
// Many nouns are of these datatypes: 
include hum.datatypes.Measure;
include hum.datatypes.TimeStamp;
		
public class ',aClassName,' extends Actor {

	private BlackBoard blackBoard;
	private JobTicket jobTicket;
'.
	translator attachPrologToActorClass: aClassName fromSource: aSource.
	
	self assert: ( translator prologues isEmpty ) not.
	"An Actor`s implementation in Java or Erlang must reside in a file of the same name.
	We can adopt the same convention for JavaScript and Smalltalk implementations.
	"
	

]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslatorTests >> test370forStatementAsSmalltalk [
	"Translate for . . .    to Smalltalk"
	|     forStatement   smalltalkCode ontology |
	true ifFalse: [ Transcript cr; show: 'test370forStatementAsSmalltalk skipped'; cr. ^self.].
	"---
	Dictionary: Order.
	An order has a list of order-items.
	---
	"
	ontology := HumOntology new.
	"Add entity-attribute relation."
	ontology addEntity: 'order' attribute: 'order-items'.

	"Translate the Hum 'For . . . '   statement into Smalltalk."
	forStatement := HumStatement source: 'For each order-item in the order:'.
	"smalltalkCode := forStatement asSmalltalkWithOntology: ontology."
  smalltalkCode := ontology codeGenerator generateSmalltalkForStatement: forStatement.
	"Expect: 
	( blackboard entity: order attribute: 'orderItems' ) do: [ :orderItem |
	"
	self pattern: '*do:*' matches: smalltalkCode.
	self pattern: '*self blackboard entity: ''order'' attribute: ''orderItem''*' matches: smalltalkCode.
	self pattern: '*:orderItem |*' matches: smalltalkCode.
	self assert: ( '*self ( self*' match: smalltalkCode ) not.
	"
	Transcript cr; show: 'from test370forStatementAsSmalltalk: '; 
			     cr; show: smalltalkCode; cr.
	"
	
	
	
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslatorTests >> test380ifStatementAsSmalltalk [
	"Translate if . . .   to  Smalltalk"
	| ifStatement     ifSmalltalk     ontology |
	true ifFalse: [ Transcript cr; show: 'test380ifStatementAsSmalltalk skipped'; cr. ^self.].
	ifStatement := HumStatement from: 'If account balance is greater than account last-invoice-total :'.
	ontology := HumOntology new.
	ontology addNouns: #( 'account' 'balance' 'last-invoice-total').
	ifSmalltalk := ontology codeGenerator generateSmalltalkForStatement: ifStatement.
	self expect:  '(  ( blackboard entity: ''account'' attribute: ''balance'' ) > ( blackboard entity: ''account'' attribute: ''lastInvoiceTotal'' ) )  ifTrue: [' actual: ifSmalltalk .
	
	
	
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslatorTests >> test381ifStatementAsSmalltalk [
	"Translate if . . .   to  Smalltalk"
	| ifStatement     ifSmalltalk     ontology |
	true ifFalse: [ Transcript cr; show: 'test381ifStatementAsSmalltalk skipped'; cr. ^self.].
	ifStatement := HumStatement from: 'If account balance > account last-invoice-total :'.
	ontology := HumOntology new.
	ontology addNouns: #( 'account' 'balance' 'last-invoice-total').
	ifSmalltalk := ontology codeGenerator generateSmalltalkIfFor: ifStatement.
	self expect: '(  ( blackboard entity: ''account'' attribute: ''balance'' ) > ( blackboard entity: ''account'' attribute: ''lastInvoiceTotal'' ) )  ifTrue: [' actual: ifSmalltalk .
	
	
	
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslatorTests >> test382ifStatementAsSmalltalk [
	"Translate if . . .   to  Smalltalk"
	| ifStatement     ifSmalltalk     ontology |
	true ifFalse: [ Transcript cr; show: 'test382ifStatementAsSmalltalk skipped'; cr. ^self.].
	ifStatement := HumStatement from: 'If account balance = account last-invoice-total :'.
	ontology := HumOntology new.
	ontology addNouns: #( 'account' 'balance' 'last-invoice-total').
	ifSmalltalk := ontology codeGenerator generateSmalltalkIfFor: ifStatement.
	self expect: '(  ( blackboard entity: ''account'' attribute: ''balance'' ) = ( blackboard entity: ''account'' attribute: ''lastInvoiceTotal'' ) )  ifTrue: [' actual: ifSmalltalk.
	
	
	
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslatorTests >> test383ifStatementAsSmalltalk [
	"Translate if . . .   to  Smalltalk"
	| ifStatement     ifSmalltalk     ontology |
	true ifFalse: [ Transcript cr; show: 'test381ifStatementAsSmalltalk skipped'; cr. ^self.].
	ifStatement := HumStatement from: 'If account balance is equal to account last-invoice-total :'.
	ontology := HumOntology new.
	ontology addNouns: #( 'account' 'balance' 'last-invoice-total').
	ifSmalltalk := ontology codeGenerator generateSmalltalkIfFor: ifStatement.
	self expect: '(  ( blackboard entity: ''account'' attribute: ''balance'' ) = ( blackboard entity: ''account'' attribute: ''lastInvoiceTotal'' ) )  ifTrue: [' actual: ifSmalltalk.
	
	
	
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslatorTests >> test384ifStatementAsSmalltalk [
	"Translate if . . .   to  Smalltalk"
	| ifStatement     ifSmalltalk     ontology |
	true ifFalse: [ Transcript cr; show: 'test384ifStatementAsSmalltalk skipped'; cr. ^self.].
	ifStatement := HumStatement from: 'If account last-invoice-total is less than  account balance :'.
	ontology := HumOntology new.
	ontology addNouns: #( 'account' 'balance' 'last-invoice-total').
	ifSmalltalk := ontology codeGenerator generateSmalltalkIfFor: ifStatement.
	self expect:  '(  ( blackboard entity: ''account'' attribute: ''lastInvoiceTotal'' ) < ( blackboard entity: ''account'' attribute: ''balance'' ) )  ifTrue: [' actual: ifSmalltalk .
	
	
	
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslatorTests >> test385ifStatementAsSmalltalk [
	"Translate if . . .   to  Smalltalk"
	| ifStatement     ifSmalltalk     ontology |
	true ifFalse: [ Transcript cr; show: 'test385ifStatementAsSmalltalk skipped'; cr. ^self.].
	ifStatement := HumStatement from: 'If account last-invoice-total < account balance :'.
	ontology := HumOntology new.
	ontology addNouns: #( 'account' 'balance' 'last-invoice-total').
	ifSmalltalk := ontology codeGenerator generateSmalltalkIfFor: ifStatement.
	self expect:  '(  ( blackboard entity: ''account'' attribute: ''lastInvoiceTotal'' ) < ( blackboard entity: ''account'' attribute: ''balance'' ) )  ifTrue: [' actual: ifSmalltalk.
	
	
	
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslatorTests >> test390elseStatementAsSmalltalk [
	"Translate if . . .  else . . .  to Smalltalk"
	| ifStatement elseStatement   ifSmalltalk elseSmalltalk  ontology |
	
	false ifFalse: [ Transcript cr; show: '*** test390elseStatementAsSmalltalk is INCOMPLETE ***'; cr. ^self.].
	
	ifStatement := ''.
	elseStatement := ''.
	ontology := HumOntology new.
	ontology addNouns: #().
	ifSmalltalk := ifStatement asSmalltalkWithOntology: ontology.
	elseSmalltalk := elseStatement asSmalltalkWithOntology: ontology.
	"TODO: Figure out how to translate 'Else:' from Hum to Smalltalk."
	self shouldBeImplemented.
	self assert: ( '**' match: ifSmalltalk ).
	self assert: ( '**' match: elseSmalltalk ).
	
	
	
]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslatorTests >> test710translateFrame4ActionToSmalltalk [
	"Given: a Hum action frame.
	When: translated to Smalltalk
	Then: the resulting code is usable.
	"
	| frameEditor ontology code |
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameEditor := HumFrameUpdater ontology: ontology  
	                                  role: 'Cook' 
	                                action: 'Bake the pan in the oven for the time given in the recipe.'.
	frameEditor appendInstructionStatement: 'Open the oven door.'.
	frameEditor appendInstructionStatement: 'Place the pan in the oven.'.
	frameEditor appendInstructionStatement: 'Close the oven door.'.
	frameEditor appendInstructionRole: 'Oven' 
	                     statement: 'Heat for the time given in the recipe.' 
	                       comment: 'We have a smart oven.'.
	
	ontology storeFrame: ( frameEditor frame ).
	ontology addNouns: #( 'pan' 'oven' 'recipe' 'time' 'door' ).
	code := ontology codeGenerator generateSmalltalk.
	
	"Test: Title line is rendered."
	self assert: ( '*bakePanInOvenForTimeGivenInRecipeQpan: aPan oven: aOven time: aTime recipe: aRecipe*' match: code ).
	
	"First instruction is rendered."
	self assert: ( '*openOvenDoorQoven: aOven door: aDoor*' match: code ).	
	"2nd instruction is rendered."
	self assert: ( '*placePanInOvenQpan: aPan oven: aOven*' match: code ).
	"3rd instruction is rendered."
	self assert: ( '*closeOvenDoorQoven: aOven door: aDoor*' match: code ).
	"4th (delegated) inststruction is rendered"
	self assert: ( '*heatForTimeGivenInRecipeQtime: aTime recipe: aRecipe*' match: code ).
	"Comment is rendered"
	self assert: ( '*smart oven*' match: code ).
	"Role is rendered."
	self assert: ( '*Oven:*' match: code ).
	
	"Transcript cr; show: 'Generated Smalltalk:'; cr; show: code; cr."
	
	"TODO: Review the translation methods to assure consistency in how nouns are handled.
	Question: Is the blackboard used in a consistent way? 
	*** blackboard is not used above, but is seen in Java translation. ***
	"
	"code inspect."
	

]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslatorTests >> test720translateFrame4ActionToSmalltalk [
	"Given: a Hum action frame.
	When: translated to Smalltalk
	Then: the resulting code is usable.
	(This test is like the last test (test710) but 'door' is not in the list of nouns, 
	and we get a slightly different result.)
	"
	| frameEditor ontology code |
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameEditor := HumFrameUpdater ontology: ontology  
	                                               role: 'Cook' action: 'Bake the pan in the oven for the time given in the recipe.'.
	frameEditor appendInstructionStatement: 'Open the oven door.'.
	frameEditor appendInstructionStatement: 'Place the pan in the oven.'.
	frameEditor appendInstructionStatement: 'Close the oven door.'.
	frameEditor appendInstructionRole: 'Oven' 
	                                    statement: 'Heat for the time given in the recipe.' 
	                                       comment: 'We have a smart oven.'.
	
	ontology storeFrame: ( frameEditor frame ).
	ontology addNouns: #( 'pan' 'oven' 'recipe' 'time' ).
	code := ontology codeGenerator generateSmalltalk.
	"Transcript cr; show: 'Generated Smalltalk:'; cr; show: code; cr."
	
	"Test: Title line is rendered."
	self assert: ( '*bakePanInOvenForTimeGivenInRecipeQpan: aPan oven: aOven time: aTime recipe: aRecipe*' match: code ).
	
	"First instruction is rendered."
	self assert: ( '*openOvenDoorQoven: aOven*' match: code ).	
	"2nd instruction is rendered."
	self assert: ( '*placePanInOvenQpan: aPan oven: aOven*' match: code ).
	"3rd instruction is rendered."
	self assert: ( '*closeOvenDoorQoven: aOven*' match: code ).
	"4th (delegated) inststruction is rendered"
	self assert: ( '*aOven heatForTimeGivenInRecipeQtime: aTime recipe: aRecipe*' match: code ).
	"Comment is rendered"
	self assert: ( '*smart oven*' match: code ).
	"Role is rendered."
	self assert: ( '*Oven:*' match: code ).
	
	
	

]

{ #category : #'translate to Smalltalk' }
HumOntologyTranslatorTests >> test730translateFrame4ActionToSmalltalkExdentToBlockEnd [
	"Given: a Hum action frame.
	When: translated to Smalltalk
	Then: the resulting code reflects the block structure as indicated by indentation.
	"
	| frameEditor ontology code |
	
	true ifFalse: [ Transcript cr; show: 'test730translateFrame4ActionToSmalltalkExdentToBlockEnd is turned off'; cr. ].
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameEditor := HumFrameUpdater ontology: ontology  
	                                               role: 'Cook' action: 'Fulfill order.'.
	"Enter an iteration statement."
	frameEditor appendInstructionStatement: '. For each order-item in the order: '.
	"Enter some inside the loop. (It should be indented when rendered.)"
	"THINK: Should we require indentation here."
	frameEditor appendInstructionStatement: '. . Pull order-item from stock and place on cart.'.
	"Next statement has no indent. That signals end of the iteration block."
	frameEditor appendInstructionStatement: '. Ship the order to the order-address.'.
		
	ontology storeFrame: ( frameEditor frame ).
	ontology addEntity: 'order' attributes: #(  'order-items' 'order-address' customer ).
	ontology addEntity: 'order-item' attributes: #( 'catalog-id' 'product-label' 'quantity' 'unit-price'  ).
	ontology addNoun: 'quantity' isA: 'measure'.
	ontology addEntity: 'address' attributes: #( 'street-line1' 'street-line2' 'postal-code' ).
	ontology addEntity: 'postal-code' attributes: #( 'code-string' 'city' ).
	ontology addEntity: 'city' attributes: #( 'city-name' 'province' 'state' 'nation' ).
	ontology addNouns: #( 'order' 'order-item' 'order-address'  ).
	
	code := ontology codeGenerator generateSmalltalk.
	"
	Transcript cr; 
		show: 'test730translateFrame4ActionToSmalltalkExdentToBlockEnd'; 
		cr; show:' Generated Smalltalk:'; 
		cr; show: code; cr.
	"
	"Test: Title line is rendered."
	self assert: ( '*fulfillOrderQorder: aOrder*' match: code ).
	"For is implemented by do:"
	self assert: ( '*do:*' match: code ).
	self assert: ( '*:orderItem*' match: code ).
	self assert: ( '*aOrderItem := orderItem*' match: code).
	self assert: ( '*Item: aOrderItem*' match: code).
	self assert: ( '*blackboard entity: ''order'' attribute: ''orderItem''*' match: code ).
	"Look for opening and closing ']' on the block."
	self assert: ('*[*' match: code ).
	"Watch for proper close on the do: []. "
	self assert: ('*].*' match: code ).
	"Watch for proper position for closing ']'"
	self assert: ( code trimBoth endsWith: ']' ) not.
	self assert: ( code trimBoth endsWith: '].' ) not.
	self assert: ( '*self ( self*' match: code ) not.
	
	"code inspect."
	
	
	
	
	

]

{ #category : #'translate to Erlang' }
HumOntologyTranslatorTests >> testE210translateActionHeaderToErlang [
	"Translate Hum action header to Erlang do pattern.
	An actor (role) is implemented as an Erlang process. (?)
	When the Dispatcher assigns a task,
	  it will send a message of the form { role, ActionStatement, NounValues }
	  to the assigned actor (process).
	The actor will implement a mailbox dispatcher 
	  that invokes 'do( {ActionStatement, NounValues} )'
	and a do() method that matches the specific action statement.
	"
	|  ontology humSource actionStatement erlangSource expectedSource quote |
	actionStatement := 'Move portable-object from this-location to that-location.'.
	humSource := 'Action: ', actionStatement.
	"Our strategy involves a generic do( ... ) pattern that receives the message."
	"Given: ontology knows which words are nouns"
	ontology := HumOntology new.
	ontology addNouns: #('portable-object' 'this-location' 'that-location').
	"When: Action header is translated to Erlang do header"
	erlangSource := ontology codeGenerator generateErlangForActionHeader: humSource.
	"Then: The do header looks like 'do( { action-statement, noun-values } )' "
	quote := $' asString.
	expectedSource := 'do( { ', quote, actionStatement, quote, ',*[*]*} ) ->'.
	self assertPattern: ( '*', expectedSource, '*' ) matches: erlangSource.
	
	"TODO: The Erlang boiler plate must assure that the do() will be invoked 
	 for the message { ActionStatement, NounValues}"
	
]

{ #category : #'translate to Erlang' }
HumOntologyTranslatorTests >> testE220translateActionCallToErlang [
	"Translate a Hum action call to an Erlang call."
	|  ontology humSource actionStatement erlangSource expectedMessage expectedSource quote |
	actionStatement := 'Move portable-object from this-location to that-location.'.
	humSource := 'Mover: ', actionStatement.
	"Our strategy involves a generic calling pattern that sends the message."
	"Given: The ontology knows which words are nouns"
	ontology := HumOntology new.
	ontology addNouns: #('portable-object' 'this-location' 'that-location').
	"When: Action call is translated to Erlang call"
	erlangSource := ontology codeGenerator generateErlangForActionCall: humSource.
	"Then: The message passed to the Dispatcher looks like { roleAtom, ActionStatement, NounValues }."
	quote := $' asString.
	expectedMessage := 'mover,', quote, actionStatement, quote, ',*[*]*'.
	"Note: The role is translated to an Erlang atom."
	"self assert: (( '*', expectedMessage, '*' ) match: erlangSource )."

	"Then: The call looks like '?CALL({Role,Action,NounValues}).'"
	"?CALL is an Erlang macro that will probably become 'gen_supervisor:call( dispatcher, ' 
	 -- which invokes an OTP gen_supervisor method"
	expectedSource := '?CALL( mover,', quote, actionStatement, quote, ',*[*]* ),'.
	"Transcript cr; show: 'in test220translateActionCallToErlang';
	           cr; show: 'expected: ',expectedSource;
	           cr; show: ' getting: ',erlangSource; cr."
	self assertPattern: ( '*', expectedSource, '*' ) matches: erlangSource.
]

{ #category : #'translate to Erlang' }
HumOntologyTranslatorTests >> testE230translateInstructionToErlang [
	"Translate Hum instruction (invoke) to Erlang do()."
	|  ontology humSource actionStatement erlangSource   |
	actionStatement := 'Move portable-object from this-location to that-location.'.
	humSource := '. ', actionStatement.
	"Our strategy involves a generic calling pattern that sends the message."
	"Given: ontology knows which words are nouns."
	"TODO: In the actual instruction the nouns may be replaced by subtypes.
	 TODO: Some process is needed to match the instruction instance to the appropriate action header.
	 TODO: Could that process be outside the pure 'translate to Erlang' ?
	 TODO: This is also where polymorphism comes into the picture.
	"
	ontology := HumOntology new.
	ontology addNouns: #('portable-object' 'this-location' 'that-location').
	"When: Action call is translated to Erlang call"
	erlangSource := ontology codeGenerator generateErlangForSelfCall: humSource.
	self assertPattern: ( '*do( { ''Move portable-object from this-location to that-location.'',*[*]*}*),' ) matches: erlangSource.
	
]

{ #category : #'translate to Erlang' }
HumOntologyTranslatorTests >> testE310translatePlanFramesToErlang [
	"TODO: Decide how to do this.
	Alternative-A:
	1. The plan is data. 
	   It can be represented as a dictionary/table in ETS.
	2. The plan`s run-time state includes 
	   conditions that have been asserted,
	   actions currently in-progress,
	   current job-ticket charges,
	   and the plan`s blackboard.
	3. The Coordinator has actions/methods:
	   - Assert condition. (Update state and trigger actions.)
	   - What is current state? (Return run-time state. See #2 above.)
	   - Cancel goal. (Send cancels to Dispatcher.)
	---
	Alternative-B:
	1. Each plan-frame is a finite-state-machine (FSM).
	   The state includes a list of unsatisfied preconditions
	   which is set via init()
	   A private performActions method sends {action, Role, Statement, Nouns } to Dispatcher.
	   The performActions method code (containing those sends) is generated. 
	2. When a condition is satisfed, an event is broadcast to the set of FSM. 
	   Each frame FSM removes matched preconditions from the list of unsatisfied preconditions.
	   If there are no more unsatisfied preconditions, the FSM calls its own private performActions method.
	Alternative-C:
	- Same as B, but there is a single frame module that is data-driven with no frame-specific code.
	  It is given the list of preconditions and list of action messages via the initialization process
	  by a higher level process translated from the whole plan.
	Discussion:
	- I like C best because 
	(1) It places the entire plan in a single, reasonably readable place.
	(2) Debug should be easier.
	(3) There is less code (at most one module) to generate.
	    In fact, the plan-level module can be data-driven. 
	    We only need to generate a data packet in Erlang format.
	"
	"*** TODO: Write the HumCoordinator agent in Erlang. *** (Confirm that Alternative-C is workable.)"
	"*** See: HumCoordinator>>runPlanFrameForCondition: aGoalString ***"
	
]

{ #category : #'translate to Erlang' }
HumOntologyTranslatorTests >> testE311translatePreconditionsToErlangList [
	"Translate a plan-frame`s preconditions to an Erlang list.
	A Hum coordinator instance (an Erlang FSM?) will match notifications of conditions asserted
	against its list of preconditions
	and when all of the precondiditions have been asserted will run the action statement.
	When the action completes, the coordinator asserts its goal and terminates itself.
	"
	| erlangCode expected preconditionA preconditionB planFrame  ontology |
	
	ontology := HumOntology new.

	"A plan frame should have a goal and at least two preconditions."
	
	planFrame := HumFrame4Plan  ontology: ontology goal: 'Bake a cake per recipe'.
	preconditionA := 'Oven is preheated per recipe.'.
	planFrame appendPrecondition: preconditionA.
	preconditionB := 'Batter is in bake-pan per recipe.'.
	planFrame appendPrecondition: preconditionB.
	planFrame appendRole: 'Baker' action: 'Bake bake-pan in the oven per recipe.'.
	
	ontology storeFrame: planFrame.
	expected := '[',preconditionA quoted,',',preconditionB quoted,']'. 
	erlangCode := ontology codeGenerator generateErlangForPlanFrame: planFrame.
	self assert: ( erlangCode isKindOf: String ).
	self assert: ( erlangCode size > 1 ).
	self assert: ( '*{*[*]*,*[*]*}*' match: erlangCode ).
	self assert: ( ('*',preconditionA,'*') match: erlangCode ).
	self assert: ( ('*',preconditionB,'*') match: erlangCode ).
	"erlangCode inspect."
	
]

{ #category : #'translate to Erlang' }
HumOntologyTranslatorTests >> testE400ReadMe [
	self skip.
	"Thinking Out Loud:
	Entities are translated to Erlang records.
	Entity values are passed as Erlang data structures.
	By implication, this means that attributes are passed by value.
	But how should we handle supertypes and attributes that are also entities?
	If we pass them by reference (passing a primary-key identifier), 
		the recieving entity will have to fetch them from World Base.
	But, otherwise the caller may have to fill-in (and perhaps fetch).
	Alternative-B:
	- Perhaps I would just forget about Erlang records and just pass a subset of the BlackBoard.
	- Example: [ { noun, noun-value },  { noun, noun-value } ]
	Alternative-C:
	- The Blackboard is also an Erlang process (or could be).  And we pass its process-ID with statement.
	- If we do that, the BlackBoard will become responsible for deciding what data to provide the delegate.
	
	DECIDED (2015-06-25) -- Alternative-B is appropriate solution.
	Rationale: What was I thinking when I started on Erlang records?
	 I've originally intended to pass noun-value pairs in the calling message block.
	There is no reason to do that differently in Erlang.
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	The Run-Time will generate calling message structure appropriate to Erlang.
	Look for a test in the run-time. 
	Implementation will probably be responsibility of HumMessage.
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	"
]

{ #category : #'translate to Erlang' }
HumOntologyTranslatorTests >> testE410translateEntityToErlang [
	"An entity is translated into an Erlang record structure.
	-record( entity, { attribute, attribute, etc })."
	|  erlangCode ontology |
	self skip. "I've decided that this idea is not a correct design. See testE400ReadMe."
	"I will keep this code around for a little while."
	ontology := HumOntology new.
	ontology addEntity: 'party' attributes: #(  'party-name' 'alphabetized-name' 'address'  ).
	ontology addEntity: 'address' attributes: #( 'street-direction' 'street-number' 'street-name' 'postal-code' ).
	ontology addEntity: 'postal-code' attributes: #( 'city' 'state-province' 'nation' ).

	ontology addNoun: 'person' isA: 'party'.
	ontology addEntity: 'person' attributes: #( 'primary-phone-number'   ).

	erlangCode := ontology codeGenerator generateErlangForEntity: 'person'.
	
	self assert: ('-record(*person,*{*}*).' match: erlangCode ).
	
	self assert: ('-record(*person,*{*primaryPhoneNumber*}*).' match: erlangCode ) description: 'expect immediate atttribute'.
	self assert: ('-record(*person,*{*party*}*).' match: erlangCode ) description: 'expect super-type attribute'.
	"Note: This implies that we have records nested in records. 
	TODO: Decide if we nest records or refer to the inner supertype entity via an identifier."
	
	erlangCode := ontology codeGenerator generateErlangForEntity: 'party'.
	self assert: ('-record(*party,*{*partyName*}*).' match: erlangCode ) description: 'expect immediate attribute'.
	self assert: ('-record(*party,*{*address*}*).' match: erlangCode ) description: 'expect attribute that is also an entity'.
	"TODO: Decide if we nest records or refer to the inner attribute entity via an identifier."
	"TODO: . . . If so, it means that every entity has a hidden attribute . . . <entity name>-identifier."
	"TODO: Decide how to pass attribute values. -- That will partially resolve the question above."

	"TODO: Current implementation does not order the attributes."
	"erlangCode inspect."
	
]

{ #category : #'translate to Erlang' }
HumOntologyTranslatorTests >> testE500RoleReadMe [
	"Strategy: Each each role becomes an Erlang module."
	self skip.
]

{ #category : #'translate to Erlang' }
HumOntologyTranslatorTests >> testE510RoleModuleHeader [
	"A role becomes a module. Here we check the module declaration."
	| erlangCode ontology generator updater instruction01 |
	"Create a role-action frame in an ontology."
	ontology := HumOntology new.
	updater := HumFrameUpdater ontology: ontology  role: 'cook' action: 'Bake a cake per recipe.'.
		"Instruction for self."
	instruction01 := 'Place cake-pan in oven.'.
	updater addActionLine: instruction01.
	"Delegated instruction."
	updater addActionLine: 'Oven: Bake for bake-time.'.
	ontology addNouns: #('cake' 'recipe' 'cake-pan' 'bake-time').
	"Define subtype supertype relation."
	ontology addNoun: 'bake-time' isA: 'measure'.
	updater storeFrameInOntology.

	generator := ontology codeGenerator.
	self expect: (HumOntologyTranslator) actual: generator class.
	erlangCode := generator generateErlangForRole: 'cook'.
	self assert: (erlangCode beginsWith: '-module(cook).').
	
]

{ #category : #'translate to Erlang' }
HumOntologyTranslatorTests >> testE520RoleModuleHeaderExport [
	"A role becomes a module. Here we check the module header export declarations."
	| erlangCode ontology generator updater instruction01 |
	"Create a role-action frame in an ontology."
	ontology := HumOntology new.
	updater := HumFrameUpdater ontology: ontology  role: 'cook' action: 'Bake a cake per recipe.'.
	"Instruction for self."
	instruction01 := 'Place cake-pan in oven.'.
	updater addActionLine: instruction01.
	"Delegated instruction."
	updater addActionLine: 'Oven: Bake for bake-time.'.
	ontology addNouns: #('cake' 'recipe' 'cake-pan' 'bake-time').
	"Define subtype supertype relation."
	ontology addNoun: 'bake-time' isA: 'measure'.
	updater storeFrameInOntology.

	generator := ontology codeGenerator.
	self expect: (HumOntologyTranslator) actual: generator class.
	erlangCode := generator generateErlangForRole: 'cook'.
	self assert: (erlangCode beginsWith: '-module(cook).').
	"Erlang action calls invoke do( {  statementString, NounValues } )."
	self pattern: '*-export([do/1]).*' matches: erlangCode. 
	"TODO: Confirm OTP exports if OTP is used."
	
]

{ #category : #'translate to Erlang' }
HumOntologyTranslatorTests >> testE525RoleModuleHeaderMacros [
	"When a role delegates an action, a ?CALL macro is invoked. "
	| erlangCode ontology generator updater instruction01 |
	"Create a role-action frame in an ontology."
	ontology := HumOntology new.
	updater := HumFrameUpdater ontology: ontology  role: 'cook' action: 'Bake a cake per recipe.'.
	"Instruction for self."
	instruction01 := 'Place cake-pan in oven.'.
	updater addActionLine: instruction01.
	"Delegated instruction."
	updater addActionLine: 'Oven: Bake for bake-time.'.
	ontology addNouns: #('cake' 'recipe' 'cake-pan' 'bake-time').
	"Define subtype supertype relation."
	ontology addNoun: 'bake-time' isA: 'measure'.
	updater storeFrameInOntology.

	generator := ontology codeGenerator.
	self expect: (HumOntologyTranslator) actual: generator class.
	erlangCode := generator generateErlangForRole: 'cook'.
	self assert: (erlangCode beginsWith: '-module(cook).').
	"Erlang action calls invoke do( {  statementString, NounValues } )."
	self pattern: '*-export([do/1]).*' matches: erlangCode. 
	"TODO: Confirm OTP exports if OTP is used."
	"Check for CALL macro define."
	self pattern: '*-define( CALL(*,*,*),*(*,*,*)*)*' matches: erlangCode.
	"-define( CALL( Role, Statement, NounValues ), ?TBD( Role, Statement, NounValues )."
	"Call is routed to a role-qualified actor via Hum Dispatcher and Hum Messenger."
	
]

{ #category : #'translate to Erlang' }
HumOntologyTranslatorTests >> testE530RoleModuleActionFrames [
	"A role becomes a module. Here we check the module header export declarations."
	| erlangCode ontology generator updater quote statementAtom actionString instruction01 instruction02 statement02 |
	"Create a role-action frame in an ontology."
	ontology := HumOntology new.
	actionString :=  'Bake a cake per recipe.'.
	updater := HumFrameUpdater ontology: ontology  role: 'cook' action: actionString.
	"Instruction for self."
	instruction01 := 'Place cake-pan in oven.'.
	updater addActionLine: instruction01.
	"Delegated instruction."
	statement02 := 'Bake for recipe`s bake-time.'.
	instruction02 := 'Oven: ', statement02.
	updater addActionLine: instruction02.
	ontology addNouns: #('cake' 'recipe' 'cake-pan' 'bake-time').
	"Define subtype supertype relation."
	ontology addNoun: 'bake-time' isA: 'measure'.
	"TODO: Noun bake-time is attribute of recipe."
	ontology addEntity: 'recipe' attribute: 'bake-time'.
	updater storeFrameInOntology.
	generator := ontology codeGenerator.
	self expect: (HumOntologyTranslator) actual: generator class.
	erlangCode := generator generateErlangForRole: 'cook'.
	self assert: (erlangCode beginsWith: '-module(cook).').
	"Erlang action calls invoke do( {  statementStringAtom, NounValues } )."
	self pattern: '*-export([do/1]).*' matches: erlangCode. 
	"Expect to see function definition corresponding to action statement."
	quote := $' asString.
	statementAtom := quote, actionString, quote.
	self pattern: '*do( { ', statementAtom, ', [*] } ) ->*' matches: erlangCode.
	"NounValues become: [ {'cake', Cake}, {'recipe', Recipe} ] -- Note: single-quotes are doubled here."
	self pattern: '*do( { ', statementAtom, ', [ {''cake'', Cake}, {''recipe'', Recipe} ] } ) ->*' matches: erlangCode.
	"Expect to see self-call corresponding to instruction."
	self pattern: '*do( { ', quote, instruction01, quote, ', [*] } ),*' matches: erlangCode.
	"NounValues become: [ {'cake-pan', CakePan} ]"
	self pattern: '*do( { ', quote, instruction01, quote, ', [ {''cake-pan'', CakePan} ] } ),*' matches: erlangCode.
	"Expect to see delegated call via macro."
	statementAtom := quote, statement02, quote.
	self pattern: '*?CALL( oven,', statementAtom, ', [*] ),*' matches: erlangCode.
	"NounValues becomes: [ {'recipe bake-time', BakeTime} ] -- NOTE: Noun bake-time is attribute of recipe."
	self pattern: '*?CALL( oven,', statementAtom, ', [ {''*bake-time'', * BakeTime} ] ),*' matches: erlangCode.
	"Entity attribute needs a slightly different noun-value key."
	self pattern: '*?CALL( oven,', statementAtom, ', [ {''recipe bake-time'', Recipe BakeTime} ] ),*' matches: erlangCode.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH110tranlateEmphasis [
	"*text* becomes bold, ~text~ becomes italic, _text_ becomes underline, ^text^ becomes superscript"
	| ontology aBlackBoard aMarkupString result code |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	aMarkupString := 'This text is *bold*. This is ~italic~. This will be _underlined_. And this will be ^superscript^. '.
	result := ontology codeGenerator generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard.
	self expect: '' actual: result.
	code := ontology codeGenerator html contents.
	self expect: 'This text is 
<b>bold</b>. This is 
<i>italic</i>. This will be 
<u>underlined</u>. And this will be 
<sup>superscript</sup>. ' 
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH115tranlateEmphasisAtEnd [
	"*text* becomes bold, ~text~ becomes italic, _text_ becomes underline, ^text^ becomes superscript"
	| ontology aBlackBoard aMarkupString result code |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	aMarkupString := '*To boldly go all the way to the end of line.*'.
	result := ontology codeGenerator generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard.
	self expect: '' actual: result.
	code := ontology codeGenerator html contents.
	self expect: '
<b>To boldly go all the way to the end of line.</b>' 
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH120tranlatePageWidget [
	"Translate [page:text] into HTML anchor element"
	| ontology aBlackBoard aMarkupString result code |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	aMarkupString := 'To learn more, go to [page:This is only a test].'.
	result := ontology codeGenerator generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard.
	self expect: '' actual: result.
	code := ontology codeGenerator html contents.
	self expect: 'To learn more, go to 
<a href="ThisIsOnlyATest.html">This is only a test</a>.' 
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH125tranlatePageWidgetAtEnd [
	"Translate [page:text] into HTML anchor element - test for bug when widget is at line end."
	| ontology aBlackBoard aMarkupString result code |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	aMarkupString := '[page: menu item ]'.
	result := ontology codeGenerator generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard.
	self expect: '' actual: result.
	code := ontology codeGenerator html contents.
	self expect: '
<a href="MenuItem.html"> menu item </a>'
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH130tranlateLinkWidget [
	"Translate [link: text | URL ] into HTML anchor element"
	| ontology aBlackBoard aMarkupString result code |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	aMarkupString := 'To learn more, go to [link: Test Driven Development | http://c2.com/cgi/wiki?TestDrivenDevelopment].'.
	result := ontology codeGenerator generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard.
	self expect: '' actual: result.
	code := ontology codeGenerator html contents.
	self expect: 'To learn more, go to 
<a href="http://c2.com/cgi/wiki?TestDrivenDevelopment">Test Driven Development</a>.'
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH140tranlateImageWidget [
	"Translate [link: text | URL ] into HTML anchor element"
	| ontology aBlackBoard aMarkupString result code |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	aMarkupString := 'Here is a pretty picture: [image: Pretty Picture | images/PrettyPicture.bmp ].'.
	result := ontology codeGenerator generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard.
	self expect: '' actual: result.
	code := ontology codeGenerator html contents.
	self expect: 'Here is a pretty picture: 
<img src="images/PrettyPicture.bmp" alt="Pretty Picture"/>.'
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH210tranlateButtonWidget [
	"Translate [[label]] into HTML button element"
	| ontology aBlackBoard aMarkupString result code |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	aMarkupString := '[[Submit]] [[Reset]] [[Preview]] '. "<<<< space at end allows defect to proceed"
	result := ontology codeGenerator generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard.
	self expect: '' actual: result.
	code := ontology codeGenerator html contents.
	self expect: '
<button name="Submit" type="submit">Submit</button> 
<button name="Reset" type="reset">Reset</button> 
<button name="Preview" type="button">Preview</button> '
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH215tranlateButtonWidgetAtLineEnd [
	"Translate [[label]] into HTML button element -- Test for bug when widget is at end of line."
	| ontology aBlackBoard aMarkupString result code |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	aMarkupString := 'some preceeding content and then [[Preview]]'. 
	result := ontology codeGenerator generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard.
	self expect: '' actual: result.
	code := ontology codeGenerator html contents.
	self expect: 'some preceeding content and then 
<button name="Preview" type="button">Preview</button>'
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH216tranlateButtonWidgetAtLineEnd [
	"Translate [[label]] into HTML button element -- Test for bug when widget is at end of line."
	| ontology aBlackBoard aMarkupString result code |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	aMarkupString := 'some [[Middle Button]] and then [[Edge Button]]'. 
	result := ontology codeGenerator generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard.
	self expect: '' actual: result.
	code := ontology codeGenerator html contents.
	self deny: ('*[[*]]*' match: code).
	self expect: 'some 
<button name="Middle Button" type="button">Middle Button</button> and then 
<button name="Edge Button" type="button">Edge Button</button>'
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH220tranlateCheckBox [
	"Translate [z] into HTML checkbox element."
	| ontology aBlackBoard aMarkupString result code |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	aMarkupString := '[a] Yes, I am lonely. Send me spam.'. 
	result := ontology codeGenerator generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard.
	self expect: '' actual: result.
	code := ontology codeGenerator html contents.
	self deny: ('*[*]*' match: code).
	self expect: '
<input type="checkbox" name="a"/> Yes, I am lonely. Send me spam.'
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH230tranlateRadioButtons [
	"Translate (a) into HTML radio-button element."
	| ontology aBlackBoard aMarkupString result code |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	aMarkupString := 'Are you a member?  (y) Yes.  (n) No.  (d) Not sure.'. 
	result := ontology codeGenerator generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard.
	self expect: '' actual: result.
	code := ontology codeGenerator html contents.
	self deny: ('*(*)*' match: code).
	self expect: 'Are you a member?  
<input name="y" type="radio"/> Yes.  
<input name="n" type="radio"/> No.  
<input name="d" type="radio"/> Not sure.'
      actual: code.
"TODO: FIGURE OUT HOW TO GROUP RADIO BUTTONS."

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH310tranlateTableRow [
	"Translate | ... | ... | into table elements."
	| ontology aBlackBoard aMarkupString  code  viewFrame |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	viewFrame := HumFrame4View new.
	aMarkupString := '| column one | column two |'. 
	viewFrame addMarkUp: aMarkupString.
	code := ontology codeGenerator generateHTMLforMarkupLines: viewFrame frameLines blackboard: aBlackBoard.
	self deny: ('*|*' match: code).
	self expect: '
<tr>
<td> column one </td>
<td> column two </td>
</tr>'
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH320tranlateTableRowWithEmphasis [
	"Translate | ... | ... | into table elements."
	| ontology aBlackBoard aMarkupString code  viewFrame |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	viewFrame := HumFrame4View new.
	aMarkupString := '| *Product* | *Description* |'. 
	viewFrame addMarkUp: aMarkupString.
	code := ontology codeGenerator generateHTMLforMarkupLines: viewFrame frameLines blackboard: aBlackBoard.
	self deny: ('*|*' match: code).
	self expect: '
<tr>
<td> 
<b>Product</b> </td>
<td> 
<b>Description</b> </td>
</tr>'
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH330tranlateHeading [
	"Translate !!! into HTML heading"
	| ontology aBlackBoard aMarkupString code  viewFrame |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	viewFrame := HumFrame4View new.
	aMarkupString := '!!! Heading Level 3'. 
	viewFrame addMarkUp: aMarkupString.
	code := ontology codeGenerator generateHTMLforMarkupLines: viewFrame frameLines blackboard: aBlackBoard.
	self deny: ('*!*' match: code).
	self assert: ('*<h3>*Heading*</h3>*' match: code).
	self expect: '
<h3> Heading Level 3</h3>' trimBoth
      actual: code trimBoth.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH340tranlateHeadingWithEmphasis [
	"Translate !!! into HTML heading"
	| ontology aBlackBoard aMarkupString code  viewFrame |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	viewFrame := HumFrame4View new.
	aMarkupString := '!!! Heading Level _3_'. 
	viewFrame addMarkUp: aMarkupString.
	code := ontology codeGenerator generateHTMLforMarkupLines: viewFrame frameLines blackboard: aBlackBoard.
	self deny: ('*!*' match: code).
	self assert: ('*<h3>*Heading*<u>3</u>*</h3>*' match: code).
	self expect: '
<h3> Heading Level 
<u>3</u></h3>' trimBoth
      actual: code trimBoth.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH350tranlateListItem [
	"Translate !!! into HTML heading"
	| ontology aBlackBoard aMarkupString code  viewFrame |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	viewFrame := HumFrame4View new.
	aMarkupString := '--- Item at indent level 3'. 
	viewFrame addMarkUp: aMarkupString.
	code := ontology codeGenerator generateHTMLforMarkupLines: viewFrame frameLines blackboard: aBlackBoard.
	self deny: ('*!*' match: code).
	self assert: ('*<item3>*Item*</item3>*' match: code).
	self expect: '
<item3> &bull;  Item at indent level 3</item3>'
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH360tranlateListItemWithEmphasis [
	"Translate !!! into HTML heading"
	| ontology aBlackBoard aMarkupString code  viewFrame |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard new.
	viewFrame := HumFrame4View new.
	aMarkupString := '--- Item at indent level _3_.'. 
	viewFrame addMarkUp: aMarkupString.
	code := ontology codeGenerator generateHTMLforMarkupLines: viewFrame frameLines blackboard: aBlackBoard.
	self deny: ('*!*' match: code).
	self assert: ('*<item3>*Item*<u>3</u>*</item3>*' match: code).
	self expect: '
<item3> &bull;  Item at indent level 
<u>3</u>.</item3>'
       actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH410tranlateAttributeWidget [
	"Translate [attribute] into input tag."
	| ontology aBlackBoard aMarkupString code  result |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard worldbase: 'none'.
	aBlackBoard businessEvent: 'testH410tranlateAttributeWidget'.
	aMarkupString := ' name: [user-name]'. 
	ontology addEntity: 'user' attribute: 'user-name'.
	aBlackBoard setEntityName: 'user' attribute: 'user-name' toValue: 'Billy Buyer'.
	ontology codeGenerator contextEntity: 'user'.
	result := ontology codeGenerator generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard.
	code := ontology codeGenerator html contents.
	self assert: ( '*name:*<input*' match: code ).
	self expect: ' name: 
<input type="text" name="user:user-name" value="Billy Buyer"/>'
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH420tranlateTextAreaWidget [
	"Translate [attribute 9] into textarea tag."
	| ontology aBlackBoard aMarkupString code  result |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard worldbase: 'none'.
	aBlackBoard businessEvent: 'testH420tranlateTextAreaWidget'.
	aMarkupString := ' description: [description 5]'. 
	ontology addEntity: 'user' attribute: 'description'.
	aBlackBoard setEntityName: 'user' attribute: 'description' toValue: 'This text
	has more than one line.
	It could go on for many lines.
	But five lines should be enough most of the time.
	'.
	ontology codeGenerator contextEntity: 'user'.
	result := ontology codeGenerator generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard.
	code := ontology codeGenerator html contents.
	self assert: ( '*description:*<textarea*rows="5"*' match: code ).
	self expect: ' description: 
<textarea type="text" name="description" rows="5">This text
	has more than one line.
	It could go on for many lines.
	But five lines should be enough most of the time.
	</textarea>'
      actual: code.

]

{ #category : #'translate markup to HTML' }
HumOntologyTranslatorTests >> testH430tranlateEntityAttributeWidget [
	"Translate [entity`s attribute] into input tag."
	| ontology aBlackBoard aMarkupString code  result |
	ontology := HumOntology new.
	aBlackBoard := HumBlackBoard worldbase: 'none'.
	aBlackBoard businessEvent: 'testH430tranlateEntityAttributeWidget'.
	aMarkupString := ' name: [user`s name]'. 
	ontology addEntity: 'user' attribute: 'name'.
	aBlackBoard setEntityName: 'user' attribute: 'name' toValue: 'Billy Buyer'.
	ontology codeGenerator contextEntity: 'user'.
	result := ontology codeGenerator generateHTMLforMarkupString: aMarkupString blackboard: aBlackBoard.
	code := ontology codeGenerator html contents.
	self assert: ( '*name:*<input*' match: code ).
	self expect: ' name: 
<input type="text" name="user:name" value="Billy Buyer"/>'
      actual: code.

]

{ #category : #'translate to Java' }
HumOntologyTranslatorTests >> testJ805translateStatementToCamelcase [
	"A statement is translated directly to CamelCase."
	| ontology statement s |
	ontology := HumOntology new.
	statement := HumStatement from: 'Add incoming-count to stock-count, giving updated-stock-count.'.
	ontology addNouns: #( 'incoming-count' 'stock-count' 'updated-stock-count' ).
	s := statement asCamelCaseWithOntology: ontology.
	self assert: ( s = 'addIncomingCountToStockCountGivingUpdatedStockCount' ).
]

{ #category : #'translate to Java' }
HumOntologyTranslatorTests >> testJ806translateStatementToCamelcase [
	"A statement is translated directly to CamelCase, but articles are dropped."
	| ontology statement s |
	ontology := HumOntology new.
	statement := HumStatement from: 'Add the incoming-count to the stock-count, giving the updated-stock-count.'.
	ontology addNouns: #( 'incoming-count' 'stock-count' 'updated-stock-count' ).
	s := statement asCamelCaseWithOntology: ontology.
	self assert: ( s = 'addIncomingCountToStockCountGivingUpdatedStockCount' ).
]

{ #category : #'translate to Java' }
HumOntologyTranslatorTests >> testJ810translateFrame4ActionToJava [
	"Given: a Hum action frame.
	When: translated to Java
	Then: the resulting code is usable.
	"
	| frameEditor ontology code |
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameEditor := HumFrameUpdater ontology: ontology  
	                                  role: 'Cook' 
								action: 'Bake the pan in the oven for the time given in the recipe.'.
	frameEditor appendInstructionStatement: 'Open the oven door.'.
	frameEditor appendInstructionStatement: 'Place the pan in the oven.'.
	frameEditor appendInstructionStatement: 'Close the oven door.'.
	frameEditor appendInstructionRole: 'Oven' 
	                     statement: 'Heat for the time given in the recipe.' 
	                       comment: 'We have a smart oven.'.
	
	ontology storeFrame: ( frameEditor frame ).
	ontology addNouns: #( 'pan' 'oven' 'recipe' 'time' 'door' ).
	ontology compileAllFrames.
	code := ontology codeGenerator asJava.
	
	"Transcript cr; show: 'test810translateFrame4ActionToJava Generated Java'; cr; show: code; cr."
		
	"Test: Title line is rendered."
	self assert: ( '*bakePanInOvenForTimeGivenInRecipe( Pan aPan, Oven aOven, Time aTime, Recipe aRecipe ) {*' match: code ).
	
	"TODO: The generated Java code (see below) will not compile because 'aDoor' is not defined."
	"QUESTION: Is 'aDoor' a noise-word in this context? Do we really need it?"
	"QUESTION: Should we/Could we fix the problem by adding a local variable declaration where needed?"	
	"First instruction is rendered."
	self assert: ( '*this.openOvenDoor( aOven, aDoor );*' match: code ).	
	"2nd instruction is rendered."
	self assert: ( '*this.placePanInOven( aPan, aOven );*' match: code ).
	"3rd instruction is rendered."
	self assert: ( '*this.closeOvenDoor( aOven, aDoor );*' match: code ).
	"4th (delegated) inststruction is rendered"
	self assert: ( '*aOven.heatForTimeGivenInRecipe( aTime, aRecipe ); *' match: code ).
	"Comment is rendered"
	self assert: ( '*smart oven*' match: code ).
	"Code ends with a bracket"
	self assert: ( code endsWith: ( '} // Actor: Cook', String cr ) ).
	"Code should not contain doubled semi-colon.  (Test for bug)"
	self assert: ( '*;   ;*' match: code ) not.
	
	"code inspect."
		

	
	

]

{ #category : #'translate to Java' }
HumOntologyTranslatorTests >> testJ811translateFrame4ActionToJava [
	"Given: a Hum action frame with a hyphenated noun.
	When: translated to Java
	Then: the resulting code is usable.
	"
	| frameEditor ontology code |
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameEditor := HumFrameUpdater ontology: ontology  
	                                  role: 'Cook' 
								action: 'Bake the cake-pan in the oven for the time given in the recipe.'.
	frameEditor appendInstructionStatement: 'Open the oven door.'.
	frameEditor appendInstructionStatement: 'Place the cake-pan in the oven.'.
	frameEditor appendInstructionStatement: 'Close the oven door.'.
	frameEditor appendInstructionRole: 'Oven' 
	                                 statement: 'Heat for the time given in the recipe.' 
	                                   comment: 'We have a smart oven.'.
	
	ontology storeFrame: ( frameEditor frame ).
	ontology addNouns: #( 'cake-pan' 'oven' 'recipe' 'time' 'door' ).
	code := ontology codeGenerator asJava.
	
	"Transcript cr; show: 'testJ811translateFrame4ActionToJava Generated Java'; cr; show: code; cr."
		
	"Test: Title line is rendered."
	self assert: ( '*bakeCakePanInOvenForTimeGivenInRecipe( CakePan aCakePan, Oven aOven, Time aTime, Recipe aRecipe ) {*' match: code ).
	
	"TODO: The generated Java code (see below) will not compile because 'aDoor' is not defined."	
	"First instruction is rendered."
	self assert: ( '*this.openOvenDoor( aOven, aDoor );*' match: code ).	
	"2nd instruction is rendered."
	self assert: ( '*this.placeCakePanInOven( aCakePan, aOven );*' match: code ).
	"3rd instruction is rendered."
	self assert: ( '*this.closeOvenDoor( aOven, aDoor );*' match: code ).
	"4th (delegated) inststruction is rendered"
	self assert: ( '*aOven.heatForTimeGivenInRecipe( aTime, aRecipe ); *' match: code ).
	"Comment is rendered"
	self assert: ( '*smart oven*' match: code ).
	"Code ends with a bracket"
	self assert: ( code endsWith: ( '} // Actor: Cook', String cr ) ).
	"Code should not contain doubled semi-colon.  (Test for bug)"
	self assert: ( '*;   ;*' match: code ) not.
	
	"TODO: Test for case where noun is a hyphenated term."
	"code inspect."
	

	
	

]

{ #category : #'translate to Java' }
HumOntologyTranslatorTests >> testJ820translateDictionaryToJava [
	"Entity becomes class. Attribute becomes String, Category, ..."

	| ontology code |
	ontology := HumOntology new.
	"Define a few relations."
	ontology addEntity: 'party' attributes: #(  'party-name' 'alphabetized-name' 'address'  ).
	ontology addEntity: 'address' attributes: #( 'street-direction' 'street-number' 'street-name' 'postal-code' ).
	ontology addEntity: 'postal-code' attributes: #( 'city' 'state-province' 'nation' ).

	ontology addNoun: 'person' isA: 'party'.
	ontology addEntity: 'person' attributes: #( 'primary-phone-number'   ).

	ontology addNoun: 'organization' isA: 'party'.
	ontology addEntity: 'organization' attributes: #('organization-type').
	ontology categoriesOf: 'organization-type' include: #('internal' 'external').

	ontology addNoun: 'contact' isA: 'person'.
	ontology addEntity: 'contact' attributes: #( 'process-role' 'represents-organization' ).
	
	code := ontology codeGenerator asJava.

	"Transcript cr; show: 'test820translateDictionaryToJava'; cr; show: code; cr; show: '%%%%%%%%%%'; cr."
		
	"Expect each entity to become a class declaration."
	self assert: ( '*class Party*' match: code ).
	self assert: ( '*class Address*' match: code ).
	self assert: ( '*class PostalCode*' match: code ).
	self assert: ( '*class Person*' match: code ).
	
	"Entities extend their Hum supertype."
	self assert: ( '*Person extends Party*' match: code ).
	self assert: ( '*PostalCode extends Entity*' match: code ).
	self assert: ( '*Address extends Entity*' match: code ).
	
	"Attributes with no supertype are Strings by default"
	self assert: ( '*public String streetDirection*' match: code).
	self assert: ( '*public String streetNumber*' match: code).
	self assert: ( '*public String stateProvince*' match: code).
	self assert: ( '*public String nation*' match: code).
	self assert: ( '*public String city*' match: code).
	self assert: ( '*public String primaryPhoneNumber*' match: code).
	
	"Attributes with supertypes declare accordingly"
	self assert: ( '*public PostalCode postalCode*' match: code).
	self assert: ( '*public Address address*' match: code).
	self assert: ( '*public Organization representsOrganization;*' match: code). 
	
	"Classes have closing brace."
	self assert: ( '*} // Entity: Party*' match: code).
	
	"Expect 'extends' clauses for subtypes."
	self assert: ( '*class Contact*' match: code ) . 
	self assert: ( '*class Organization*' match: code ) .
	self assert: ( '*Contact extends Person*' match: code ) .
	self assert: ( '*Organization extends Party*' match: code ) .
	
	"Expect 'category' to be detected."
	self assert: ('*public Category organizationType;*' match: code).
	
	"Check for bug:"
	self assert: ('*String ,;*' match: code) not.
	
	"code inspect."
	
	
	
	
	
	
	
	

	
]

{ #category : #'translate to Java' }
HumOntologyTranslatorTests >> testJ825translateCollectionNounToJava [
	"Test a more complicated dictionary with a collection and recursive structure."

	| ontology code |
	ontology := HumOntology new.
	"Define a few relations."
	ontology addEntity: 'location' attributes: #( 'latitude' 'longitude' ).
	ontology addEntity: 'route' attributes: #('route-name' 'from-location' 'to-location' 'route-segments').
	ontology addNoun: 'route-segment' isA: 'route'.  "RECURSIVE !!!"
	ontology addEntity: 'route-segment' attributes: #('segment-name' 'segment-length').
	ontology addNoun: 'segment-length' isA: 'measure'.
	"Translate to Java"	
	code := ontology codeGenerator asJava.

	"Expect each entity to become a class declaration."
	self assert: ( '*class Route*' match: code ).
	self assert: ( '*class RouteSegment*' match: code ).
	
	"Entities extend their Hum supertype."
	self assert: ( '*RouteSegment extends Route*' match: code ).
	
	"Attributes with no supertype are Strings by default"
	self assert: ( '*public Measure segmentLength*' match: code).
	
	"Attributes with supertypes declare accordingly"
	self assert: ( '*public Location fromLocation*' match: code).
	
	"Classes have closing brace."
	self assert: ( '*} // Entity: Route*' match: code).
	
	"TODO: By default a collection is a Bag<Entity>. 
	 TODO: It might work better if Hum run-time handles the collection."
	self assert: ( '*public Bag<RouteSegment> routeSegments;*' match: code ) description: 'Collection not handled'.
		
	"code  inspect."
	
	
	
	
	
	
	
	

	
]

{ #category : #'translate to Java' }
HumOntologyTranslatorTests >> testJ830translateFrame4ActionToJavaExdentToBlockEnd [
	"Given: a Hum action frame.
	When: translated to Java
	Then: the resulting code is usable.
	Then: the resulting code reflects the block structure as indicated by indentation.
	"
	| frameEditor ontology code tab |
	
	true ifFalse: [ Transcript cr; show: 'test830translateFrame4ActionToJavaExdentToBlockEnd is turned off'; cr. ].
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameEditor := HumFrameUpdater ontology: ontology role: 'Cook' action: 'Fulfill order.'.
	"Enter an iteration statement."
	frameEditor appendInstructionStatement: '. For each order-item in the order: '.
	"Enter some inside the loop. (It should be indented when rendered.)"
	"THINK: Should we require indentation here."
	frameEditor appendInstructionStatement: '. . Pull order-item quantity from stock and place on cart.'.
	"Next statement has no indent. That signals end of the iteration block."
	frameEditor appendInstructionStatement: '. Ship the order to the order-address.'.
		
	ontology storeFrame: ( frameEditor frame ).
	ontology addEntity: 'order' attributes: #(  'order-items' 'order-address' customer ).
	ontology addEntity: 'order-item' attributes: #( 'catalog-id' 'product-label' 'quantity' 'unit-price'  ).
	ontology addNoun: 'quantity' isA: 'measure'.
	ontology addEntity: 'address' attributes: #( 'street-line1' 'street-line2' 'postal-code' ).
	ontology addEntity: 'code' attributes: #( key value ).
	ontology addEntity: 'postal-code' attributes: #( city ).
	ontology addEntity: 'city' attributes: #( name province state nation ).
	ontology addNouns: #( 'order' 'order-item' 'order-address'  ).
	
	code := ontology codeGenerator asJava.
	
"	Transcript cr; 
		show: 'test830translateFrame4ActionToJavaExdentToBlockEnd'; 
		cr; show:' Generated Java:'; 
		cr; show: code; cr.
"	
	"Test: Title line is rendered."
	self assert: ( '*fulfillOrder( Order aOrder ) {*' match: code ).
	
	"Test: 'For each order-item in the order:' "
	self assert: ( '*for (*:*)*' match: code ).
	self assert: ( '*aOrderItem*' match: code).
	self assert: ( '*OrderItem orderItem*' match: code ).
	self assert: ( '*for ( OrderItem orderItem : order.orderItems )*' match: code ).
	                          	
	"Look for opening and closing '} // for' on the block."
	self assert: ('*{*' match: code ).
	tab := String tab.
	self assert: ('*',tab,'}*' match: code ).
	
	"code inspect."
	
	
	
	
	
	
	

]

{ #category : #'translate to Java' }
HumOntologyTranslatorTests >> testJ840translatePlanFrameToJava [
	"The plan is data, so translation involves translating each goal frame into a series of Java setters.
	/* prologue */
	public HumPlan plan = new HumPlan();
	public HumPlanFrame frame = new HumPlanFrame();
	/* for each goal frame in the ontology */
	frame.setGoal('...')
		.addPrecondition('...')
		.addPrecondition('...')
		.addAction('...');
	plan.addGoalFrame(frame);	
	"
	| ontology planFrame javaCode |
	ontology := HumOntology new.
	planFrame := HumFrame4Plan ontology: ontology goal: 'Bake a cake per recipe.'.
	planFrame 
		appendPrecondition: 'Oven is preheated per recipe.';	
		appendPrecondition: 'Batter is mixed per recipe ingredients.';
		appendPrecondition: 'Batter is in cake-pan per recipe pan-size.';
		appendRole: 'Baker' action: 'Bake the cake-pan per recipe baking-time.' comment: ''.
	ontology addPlanFrame: planFrame ForGoal: 'Bake a cake per recipe.'.
	
	javaCode := ontology codeGenerator generateJavaForPlanFrame: planFrame.
	
	self assert: ( javaCode isKindOf: String ).
	self assert: ( '*planFrame.setGoal("Bake a cake per recipe.")*' match: javaCode ).
	self assert: ( '*planFrame*.addPrecondition("Oven is preheated per recipe.")*' match: javaCode ).
	self assert: ( '*planFrame*.addPrecondition("Batter is mixed per recipe ingredients.")*' match: javaCode ).
	self assert: ( '*planFrame*.addPrecondition("Batter is in cake-pan per recipe pan-size.")*' match: javaCode ).
	self assert: ( '*planFrame*.addAction("Baker: Bake the cake-pan per recipe baking-time.")*' match: javaCode ).
	"javaCode inspect."
	
	
	
	
	
]
