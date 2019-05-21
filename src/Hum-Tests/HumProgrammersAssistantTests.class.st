"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Programmer Assistant (PA) User-Dialogs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A. Ontology Actions
   1. New ontology.
   2. Save ontology on file. (Save As on new file)
   3. Load ontology from file
(futures:)
   4. Merge ontology from (TBD: file or another PA).
   5. Test run ontology.
   6. Deploy ontology?  (??? What does ‘deploy’ portend ???)

B. Frame Editor Actions
   1. Usual text edit actions:
      a) commands: (copy, cut, paste, un-do, save, open, print?, close window)
      b) cursor moves: (up, down, left, right, top, bottom, . . .)
   2. PA-specific actions:
      a) [Line updated] event causes the logical-line and frame to be checked.
         (1) The logical-line is rendered. 
	           Keywords and nouns are emphasized. Nouns have links. 
         (2) If the logical-line is not understood (no definition in ontology or DSL), 
               the line is flagged (with a question-mark).
         (3) If a noun lacks an antecedent in the frame, the noun is flagged (color code).
      b) [Insert/Append Instruction] - Instructions are indented.
         (1) In an action frame, 
               the automatic indent matches the preceding statement’s indent 
               unless it was a control statement (ending with a colon). 
                  And then, the indentation is increased by one.
         (2) In plan and dialog frames, 
               instructions have only one level of indent 
               because control statements are not allowed in those contexts.
         (3) In dialog frames, 
               the user indicates an instruction by starting the line with dot [tab].
      c) [Submit frame] command causes the ontology to be 
         (1) updated.
         (2) versioned.
         (3) re-evaluated. (problems flagged)
         (4) re-displayed. (all views rebuilt)
      d) [Test Dialog] - in dialog run-time with mock agents.


"
Class {
	#name : #HumProgrammersAssistantTests,
	#superclass : #HumTestCase,
	#instVars : [
		'eh'
	],
	#category : #'Hum-Tests'
}

{ #category : #'as yet unclassified' }
HumProgrammersAssistantTests >> aReadMe [
	"See the class description for the intended (future) tests."
	^'See the class description for the intended (future) tests.'
	
]

{ #category : #running }
HumProgrammersAssistantTests >> setUp [ 
	"Set the base  directory and store for this series of tests.
	NOTE: tests will need to specify ./ontology/  or ./html/ "	
	HumStore defaultDirectory: './Developer/Smalltalk/Hum8'.
]

{ #category : #'pa610 Store In Ontology' }
HumProgrammersAssistantTests >> storeInOntology: aHumOntology fromFrameUpdater: frameUpdater1 [
	| frame1 identifier frameUpdater2 frame2 frameUpdater3 frame3 |
	"The frame editor receives the command to store the frame from the user interface (Scribe)."
	frameUpdater1 storeFrameInOntology.
	
	"The frame will now have a uniqueIdentifier."
	frame1 := frameUpdater1 frame.
	self assert: ( frame1 isKindOf: HumFrame ).
	identifier := frame1 uniqueIdentifier.
	self assert: ( identifier isKindOf: HumIdentifier ).
	
	"We can use the identifier to fetch the frame into another frameUpdater."
	frameUpdater2 := HumFrameUpdater ontology: aHumOntology loadFrameByIdentifier: identifier.
	self assert: (frameUpdater2 isKindOf: HumFrameUpdater ).
	
	"Check the content."
	frame2 := frameUpdater2 frame.
	self assert: ( frame2 isKindOf:  (frame1 class) ).
	self assert: ( frame1 titleLine = frame2 titleLine ).
	self assert: ( frame1 titleLine sameAs: frame2 titleLine ).
	self assert: ( frame1 frameLines size ) = ( frame2 frameLines size ).
	self assert: ( frame1 frameLines at: 1) = ( frame2 frameLines at: 1 ).
	self assert: (( frame1 frameLines at: 1) sameAs: ( frame2 frameLines at: 1 )).
	
	frameUpdater3 := HumFrameUpdater ontology: aHumOntology loadFrameByName: (frame1 frameName).
	self assert: (frameUpdater2 isKindOf: HumFrameUpdater ).
	
	"Check the content."
	frame3 := frameUpdater3 frame.
	self assert: ( frame3 isKindOf:  (frame1 class) ).
	self assert: ( frame1 titleLine = frame3 titleLine ).
	self assert: ( frame1 titleLine sameAs: frame3 titleLine ).
	self assert: ( frame1 frameLines size ) = ( frame3 frameLines size ).
	self assert: ( frame1 frameLines at: 1) = ( frame3 frameLines at: 1 ).
	self assert: (( frame1 frameLines at: 1) sameAs: ( frame3 frameLines at: 1 )).
	
]

{ #category : #'pa100 Ontology Actions' }
HumProgrammersAssistantTests >> test110newOntology [
	"PA initializes (re-initializes) to an empty ontology."
	| zPA |
	zPA := HumProgrammersAssistant new.
	zPA clearOntology.
	self assert: (zPA ontology nouns isEmpty).
]

{ #category : #'pa100 Ontology Actions' }
HumProgrammersAssistantTests >> test120saveOntology [
	"PA saves (writes) the ontology to a file."
	| zPA |
	false ifFalse: [ Transcript cr; show: 'test120saveOntology turned off - No way to save an ontology!'. ^self ].
	zPA  := HumProgrammersAssistant new.
	zPA clearOntology.
	zPA saveOntologyOnFileNamed: 'HumPA-test.ontology'.
	
]

{ #category : #'pa100 Ontology Actions' }
HumProgrammersAssistantTests >> test130loadOntology [
	"PA loads (reads) the ontology fram a file where it was saved previously."
	| zPA |
	false ifFalse: [ Transcript cr; show: 'test130loadOntology turned off - No way to save an ontology!'. ^self ].
	zPA := HumProgrammersAssistant new.
	zPA clearOntology.
	zPA saveOntologyOnFileNamed: 'HumPA-test.ontology'.
	zPA loadOntologyFromSavedFileNamed: 'HumPA-test.ontology'.
	
]

{ #category : #'pa210 Create frame' }
HumProgrammersAssistantTests >> test200createFrame [
	"There are seven types of frame: (See HumFrame hierarchy)
	. plan frame
	. action frame
	. dictionary frame
	. view frame
	. vignette frame
	. comment frame
	. data frame
	Each type of frame should have suitable constructors.
	"
	self skip.
]

{ #category : #'pa210 Create frame' }
HumProgrammersAssistantTests >> test220createFrame4Plan [
	"Test a plan frame (goal frame).
	---
	Goal: Cake is baked according to recipe.
	Preconditions:
	. Oven is preheated to the temperature given in the recipe.
	. The recipe`s batter is in a prepared cake pan.
	Action:
	. Oven: Bake the pan in the oven for the time given in the recipe.
	---
	"
	| frameUpdater ontology |
	ontology := HumOntology new.
	
	"Initialize for a Plan Frame."
	frameUpdater := HumFrameUpdater ontology: ontology goal: 'Cake is baked according to recipe.'.
	
	"Append precondition lines."
	frameUpdater appendPrecondition: 'Oven is preheated to the temperature given in the recipe.'.
	frameUpdater appendPrecondition: 'The recipe`s batter is in a prepared cake pan.'.

	"Finish with action statement."
	frameUpdater appendRole: 'Oven' action: 'Bake the pan in the oven for the time given in the recipe.' .
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Plan ).
	self assert: ( frameUpdater frame frameLines size = 3 ).
	

]

{ #category : #'pa210 Create frame' }
HumProgrammersAssistantTests >> test230createFrame4Action [
	"The frame editor instance knows what kind of frame it is editing.
	"
	| frameUpdater ontology |
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameUpdater := HumFrameUpdater ontology: ontology  
	                                  role: 'Role' 
																action: 'Bake the pan in the oven for the time given in the recipe.'.

	"Append instruction lines."
	frameUpdater appendInstructionStatement: 'Open the oven door.'.
	frameUpdater appendInstructionStatement: 'Place the pan in the oven.'.
	frameUpdater appendInstructionStatement: 'Close the oven door.'.
	
	"Append an instruction that is delegated"
	frameUpdater appendInstructionRole: 'Oven' statement: 'Bake for the time given.'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Action ).	
	self assert: ( frameUpdater frame frameLines size = 4 ).

	
	

]

{ #category : #'pa210 Create frame' }
HumProgrammersAssistantTests >> test231formatFrame4Action [
  "The frame editor instance knows what kind of frame it is editing.
  "
  | frameUpdater ontology prettyPrint q ideal |
  ontology := HumOntology new.
  
  "Initialize for an Action Frame."
  frameUpdater := HumFrameUpdater ontology: ontology  
                                    role: 'Baker' 
                                action: 'Bake the pan in the oven for the time given in the recipe.'.

  "Append instruction lines."
  frameUpdater appendInstructionStatement: 'Open the oven door.'.
  frameUpdater appendInstructionStatement: 'Place the pan in the oven.'.
  frameUpdater appendInstructionStatement: 'Close the oven door.'.
  
  "Append an instruction that is delegated"
  frameUpdater appendInstructionRole: 'Oven' statement: 'Bake for the time given.'.
  
  self assert: ( frameUpdater notNil ).
  self assert: ( frameUpdater frame isMemberOf: HumFrame4Action ).  
  self assert: ( frameUpdater frame frameLines size = 4 ).
  
  prettyPrint := frameUpdater prettyPrint.
  ideal := '<hr/>
		<HumFrame>
			<ActionFrame>
				<frameTitle>
					Role: Baker -- Bake the pan in the oven for the time given in the recipe.
				</frameTitle>
				<br/><b>Role: </b>
				<role>Baker.</role>
				<br/><b>Action: </b>
				<action>Bake the pan in the oven for the time given in the recipe.</action>
				<br/>
				<InstructionLine class="indent1" >
					<statement>
						Open the oven door.
					</statement>
				</InstructionLine>
				<br/>
				<InstructionLine class="indent1" >
					<statement>
						Place the pan in the oven.
					</statement>
				</InstructionLine>
				<br/>
				<InstructionLine class="indent1" >
					<statement>
						Close the oven door.
					</statement>
				</InstructionLine>
				<br/>
				<InstructionLine class="indent1" >
					<role>Oven</role>
					:
					<statement>
						Bake for the time given.
					</statement>
				</InstructionLine>
			</ActionFrame>
		</HumFrame>
'.
  q := HumCalculator string: prettyPrint isLike: ideal.
  self assert: q description: 'Expecting prettyPrint to match ideal'

  
  

]

{ #category : #'pa210 Create frame' }
HumProgrammersAssistantTests >> test240createFrame4View [
	"The frame editor instance knows what kind of frame it is editing.
	"
	| frameUpdater ontology |
	ontology := HumOntology new.
	
	"Initialize for a View Frame."
	frameUpdater := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	
	"Add markup lines."
	frameUpdater addMarkUp: '!! Recipe'.
	frameUpdater addMarkUp: ' recipe-name: [name]'.
	frameUpdater addMarkUp: '   description: [description 5]'.
	frameUpdater addMarkUp: '   ingredients: [ingredients]'.
	frameUpdater addMarkUp: '            steps: [steps]'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4View ).

	

]

{ #category : #'pa210 Create frame' }
HumProgrammersAssistantTests >> test250createFrame4Dictionary [
	"The frame editor instance knows what kind of frame it is editing.
	"
	| frameUpdater ontology |
	ontology := HumOntology new.
		
	"Initialize for a Dictionary Frame."
	frameUpdater := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.
	
	"Add dictionary lines."
	"attributes"
	frameUpdater addDictionaryLine: 'Recipe attributes include recipe-name, description, ingrediants steps.'.
	"set collection"
	frameUpdater addDictionaryLine: 'Recipe includes a set of ingrediants.'.
	"list collection"
	frameUpdater addDictionaryLine: 'Recipe includes a list of steps.'.
	"Attribute used in  set above is an entity with its own attributes. Entities are members of set."
	frameUpdater addDictionaryLine: 'Ingredient attributes include ingredient-name, quantity, alternate-ingredient.'.
	"Attribute used in list above is an entity. Entity instances are in a list. (OrderedCollection)"
	frameUpdater addDictionaryLine: 'Step attributes include step-number, step-description'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Dictionary ).

	
]

{ #category : #'pa210 Create frame' }
HumProgrammersAssistantTests >> test260createFrame4Vignette [
	"Create a dialog vignette..
	"
	| frameUpdater ontology |
	ontology := HumOntology new.
		
	"Initialize for a Dictionary Frame."
	frameUpdater := HumFrameUpdater ontology: ontology vignetteContext: 'hello' pattern: 'Knock, knock.'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Vignette ).

	
]

{ #category : #'pa210 Create frame' }
HumProgrammersAssistantTests >> test261updateFrame4Vignette [
	"Create a dialog vignette.
	"
	| frameUpdater ontology |
	ontology := HumOntology new.
		
	"Initialize for a Dialog Frame."
	frameUpdater := HumFrameUpdater ontology: ontology vignetteContext: 'Expecting Hello.' pattern: 'Knock, knock.'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Vignette ).
	
	"Add response lines."
	"There are two kinds of resonse, verbal responses and actions."
	frameUpdater addVignetteResponse: 'Who is there?'.
	frameUpdater addVignetteInstruction: 'Next context "Expecting who.".'.
	
	self assert: ( ( frameUpdater frame frameLines at: 1 ) 
									sameAs:  ( HumVignetteResponseLine source: 'S: Who is there?' ) ).
	self assert: ( ( frameUpdater frame frameLines at: 2 ) 
									sameAs:  ( HumInstructionLine statement: 'Next context "Expecting who.".' ) ).
	self assert: ( ( frameUpdater frame responseLines at: 1 ) 
									sameAs:  ( HumMarkupLine source: 'Who is there?' ) ).
	self assert: ( ( frameUpdater frame instructionLines at: 1 ) 
									sameAs:  ( HumInstructionLine statement: 'Next context "Expecting who.".' ) ).
	
	
	
	
	
	

	
]

{ #category : #'pa210 Create frame' }
HumProgrammersAssistantTests >> test270createFrame4Comment [
	"Create with a comment frame..
	"
	| frameUpdater ontology |
	ontology := HumOntology new.
		
	"Initialize for a Comment Frame."
	frameUpdater := HumFrameUpdater ontology: ontology commentTitle: 'This is only a test.' .
	frameUpdater appendFrameLine: 'See test270createFrame4Comment.'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Comment ).

	
]

{ #category : #'pa310 Critique frame' }
HumProgrammersAssistantTests >> test300codeCriticFeatures [
	"The code critic generates errors and warnings for each type of frame."
	
	"General syntax in most frames:
	. Error: Statement should end with a period. (Instruction/Precondition/Action/Dictionary)
	. Error: Statement should end with a colon.  (If/Else/For)
	. Error: Response should end with period or question-mark. (vignette response)
	. Error: Parenthesis is not closed. 
	. Error: Bracket is not closed.
	. Error: Unknown frame-type. (Expecting Comment/Goal/Role/View/Context/Dictionary/Data)
	"
	"For statements in any frame:
	. Warning: Statement has no known nouns.
	. Warning: Noun '___' has no antecedent.
	. Warning: Statement is currently undefined. 
	. Warning: Role '____' is undefined.
	"
	"For plan frames:
	. Warning: Precondition is currently undefined. 
	. . (It is not marked [Assumed] and there is no goal-frame defining it.)
	. Warning: This goal is not invoked anywhere yet.
	. . (No vignette or precondition invokes it.)
	. Warning: This action is currently undefined.
	. Error: Action statements must have role prefix.
	. Error: There is a loop in the plan tree.
	"
	"For dictionary frames:
	. Error: Statement is not recognized. 
	. . (It does not match the Hum Dictionary DSL.)
	. Error: Entity '____' cannot be its own attribute. 
	. . (There is a cycle in the noun graph from this entity back to itself.)
	. Warning: Noun '____' has no known source.
	. . (The noun is not seen in any vignette-pattern, view, or giving-statement.) 
	"
	"For vignette frames:
	. Warning: Context '____' has no content yet.
	. Warning: Goal '____' is currently undefined.
	. Warning: View '____' is currently undefined.
	"
	"For widgets:
	. Error: Widget '[___]' is not recognized. 
	. . (The widget content does not match the Hum Widget DSL.)
	. Warning: Noun '____' is not defined.
	. . (The noun named in a widget does not appear in any dictionary statement.)
	"
	"For text markup in view and vignette:
	. Error: Bolding started with '*' is not closed.
	. Error: Italics started with '~' is not closed.
	. Error: Underline started with '_' is not closed.
	"
	
	
]

{ #category : #'pa310 Critique frame' }
HumProgrammersAssistantTests >> test320critiqueFrame4Plan [
	"Check plan frame - no known nouns - no plans
	"
	| frameUpdater ontology errors |
	ontology := HumOntology new.

	"Initialize for a Plan Frame."
	frameUpdater := HumFrameUpdater ontology: ontology goal: 'Cake is baked according to recipe..'.
	
	"Append precondition lines."
	frameUpdater appendPrecondition: 'Oven is preheated to the temperature given in the recipe.'.
	frameUpdater appendPrecondition: 'The recipe`s batter is in a prepared cake pan.'.
	
	"Finish with action statement."
	frameUpdater appendRole: 'Oven' action: 'Bake the pan in the oven for the time given in the recipe.' .
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Plan ).
	
	"Expect complaints about no nouns."
	errors := frameUpdater checkFrameSyntax.
	self assert: ( errors isEmpty not ).
	self assert: ( errors anySatisfy: [ :error | '*no known nouns*' match: error ] ).
	
	"Expect complaints about preconditions with no plans."
	self assert: ( errors anySatisfy: [ :error | '*no plan*' match: error ] ).
	
	"Transcript cr; show: 'test320critiqueFrame4Plan Errors: ', errors asString; cr."
	
]

{ #category : #'pa310 Critique frame' }
HumProgrammersAssistantTests >> test321critiqueFrame4Plan [
	"Detect: Every precondition has a noun that traces back to the goal statement.
	"
	| frameUpdater ontology errors |
	ontology := HumOntology new.

	"Initialize for a Plan Frame."
	frameUpdater := HumFrameUpdater ontology: ontology goal: 'Cake is baked according to recipe..'.
	
	"Append precondition lines."
	frameUpdater appendPrecondition: 'Oven is preheated to the temperature given in the recipe.'.
	frameUpdater appendPrecondition: 'The recipe`s batter is in a prepared cake pan.'.
	
	"Finish with action statement."
	frameUpdater appendRole: 'Oven' action: 'Bake the pan in the oven for the time given in the recipe.' .
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Plan ).
	
	"Every line has recipe as a noun."
	ontology addNouns: #( 'recipe' ).
	
	"Expect no complaints about no nouns. "
	errors := frameUpdater checkFrameSyntax.
	self assert: ( errors count: [ :error | '*no nouns*' match: error ]  ) = 0.
	

]

{ #category : #'pa310 Critique frame' }
HumProgrammersAssistantTests >> test322critiqueFrame4PlanMissingAntecedant [
	"Detect: One or more preconditions have a noun with no antecedant in the goal statement.
	"
	| frameUpdater ontology errors |
	ontology := HumOntology new.

	"Initialize for a Plan Frame."
	frameUpdater := HumFrameUpdater ontology: ontology goal: 'Cake is baked according to recipe..'.
	
	"Append precondition lines."
	frameUpdater appendPrecondition: 'Oven is preheated to the temperature given in the recipe.'.
	frameUpdater appendPrecondition: 'The recipe`s batter is in a prepared cake pan.'.
	
	"Finish with action statement."
	frameUpdater appendRole: 'Oven' action: 'Bake the pan in the oven for the time given in the recipe.' .
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Plan ).
	
	"Every line has recipe as a noun."
	ontology addNouns: #( 'recipe' 'pan' ).
	
	"Expect 'no antecedant' complaints "
	errors := frameUpdater checkFrameSyntax.
	self assert: ( errors count: [ :error | '*no antecedant*' match: error ]  ) > 0.
	

]

{ #category : #'pa310 Critique frame' }
HumProgrammersAssistantTests >> test330critiqueFrame4Action [
	"Detect: No known nouns.
	"
	| frameUpdater ontology errors |
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameUpdater := HumFrameUpdater ontology: ontology  
	                                  role: 'Role' 
																action: 'Bake the pan in the oven for the time given in the recipe.'.
	"Append instruction lines."
	frameUpdater appendInstructionStatement: 'Open the oven door.'.
	frameUpdater appendInstructionStatement: 'Place the pan in the oven.'.
	frameUpdater appendInstructionStatement: 'Close the oven door.'.
	
	"Append an instruction that is delegated"
	frameUpdater appendInstructionRole: 'Oven' statement: 'Bake for the time given in the recipe.'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Action ).
	
	self assert: ( frameUpdater frame frameLines size = 4 ).
		
	"Expect  complaints about no nouns on every line because the ontology has not been informed."
	errors := frameUpdater checkFrameSyntax.
	
	"Check the simple instructions."
	self assert: (errors includes: 'Statement: {Open the oven door.} has no known nouns!' ).
	self assert: (errors includes: 'Statement: {Place the pan in the oven.} has no known nouns!').
	self assert: (errors includes: 'Statement: {Close the oven door.} has no known nouns!' ).
	
	"Check the last one - It is delegated."
	self assert: (errors includes: 'Statement: {Bake for the time given in the recipe.} has no known nouns!' ).
	
	"The action line should have nouns too."
	self assert: (errors includes: 'Action statement {Bake the pan in the oven for the time given in the recipe.} has no known nouns!' ).
		
	self assert: ( errors count: [ :error | '*no known nouns*' match: error] ) = 5.

	
	

]

{ #category : #'pa310 Critique frame' }
HumProgrammersAssistantTests >> test331critiqueFrame4Action [
	"Detect: Some nouns, but still not enough.
	"
	| frameUpdater ontology errors |
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameUpdater := HumFrameUpdater ontology: ontology  
	                                  role: 'Role' 
																action: 'Bake the pan in the oven for the time given in the recipe.'.
	"Append instruction lines."
	frameUpdater appendInstructionStatement: 'Open the oven door.'.
	frameUpdater appendInstructionStatement: 'Place the pan in the oven.'.
	frameUpdater appendInstructionStatement: 'Close the oven door.'.
	
	"Append an instruction that is delegated"
	frameUpdater appendInstructionRole: 'Oven' statement: 'Bake for the time given.'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Action ).
	
	ontology addNouns: #( 'recipe' 'oven').
	
	"Still expect one complaints about no nouns on the last line."
	errors := frameUpdater checkFrameSyntax.
	self assert: ( errors count: [ :error | '*no known nouns*' match: error ] ) = 1.

]

{ #category : #'pa310 Critique frame' }
HumProgrammersAssistantTests >> test332critiqueFrame4ActionForAntecedants [
	"Detect: 'No known noun' and/or  'no antecedant'
	"
	| frameUpdater ontology errors |
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameUpdater := HumFrameUpdater ontology: ontology  
	                                  role: 'Role' 
																action: 'Bake the pan in the oven for the time given in the recipe.'.
	"Append instruction lines."
	frameUpdater appendInstructionStatement: 'Open the oven door.'.
	frameUpdater appendInstructionStatement: 'Place the pan in the oven.'.
	frameUpdater appendInstructionStatement: 'Close the oven door.'.
	
	"Append an instruction that is delegated"
	frameUpdater appendInstructionRole: 'Oven' statement: 'Bake for the time given.'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Action ).
	
	ontology addNouns: #( 'recipe' 'oven' ).
	
	"Still expect one complaints about no nouns on the last line."
	errors := frameUpdater checkFrameSyntax.
	self assert: ( errors count: [ :error | '*no known nouns*' match: error ] ) = 1.
	
	"Check for antecedants - Happy path: 'door' is not a noun and needs no antecedant."
	self assert: ( errors count: [: error | '*no antecedant*' match: error ] ) = 0.
	
	"But if we make door a noun, it will now lack an antecedant."
	ontology addNoun: 'door'.
	errors := frameUpdater checkFrameSyntax.
	self assert: ( errors count: [: error | '*no antecedant*' match: error ] ) = 2.
	

	
	

]

{ #category : #'pa310 Critique frame' }
HumProgrammersAssistantTests >> test345critiqueFrame4View [
	"Detect: No nouns in a view frame.
	"
	| frameUpdater ontology errors testMe |
	
	"Turn this on/off for now."
	testMe := true.
	testMe ifFalse: [ Transcript cr; show: 'test345critiqueFrame4View is turned off.'; cr. ^self].
	
	ontology := HumOntology new.
	
	"Initialize for a View Frame."
	frameUpdater := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	"Add markup lines.
	These widgets should reference nouns.
	"
	frameUpdater addMarkUp: '!! Recipe'.
	frameUpdater addMarkUp: ' recipe-name: [name]'.
	frameUpdater addMarkUp: '   description: [description 5]'.
	frameUpdater addMarkUp: '   ingredients: [ingredients]'.
	frameUpdater addMarkUp: '            steps: [steps]'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4View ).
		
	"Expect complaints about no nouns."
	errors := frameUpdater checkFrameSyntax.
	self assert: ( errors isEmpty not ).
	
	self assert: (errors size = 4 ).
	
	"Transcript show: errors; cr."



	

]

{ #category : #'pa310 Critique frame' }
HumProgrammersAssistantTests >> test346critiqueFrame4View [
	"When the nouns are defined, there are no complaints. s
	"
	| frameUpdater ontology errors testMe |
	
	testMe := true.
	testMe ifFalse: [ Transcript cr; show: 'test345critiqueFrame4View is turned off.'; cr. ^self].
	
	ontology := HumOntology new.
	
	"Initialize for a View Frame."
	frameUpdater := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.

	"Add markup lines."
	frameUpdater addMarkUp: '!! Recipe'.
	frameUpdater addMarkUp: ' recipe-name: [name]'.
	frameUpdater addMarkUp: '   description: [description 5]'.
	frameUpdater addMarkUp: '   ingredients: [ingredients]'.
	frameUpdater addMarkUp: '            steps: [steps]'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4View ).
	
	ontology addNouns: #( 'recipe' 'name' 'description' 'ingredients' 'steps' ).
		
	"Expect no complaints about no nouns."
	errors := frameUpdater checkFrameSyntax.
	self assert: ( errors isEmpty  ).
	
	"Transcript show: 'test346critiqueFrame4View errors:'; cr; show: errors; cr."



	

]

{ #category : #'pa310 Critique frame' }
HumProgrammersAssistantTests >> test350critiqueFrame4Dictionary [
	"Critique a dictionary frame.
	Before the frame is compiled, the nouns are not recognized.
	This might not be what we want, but it is consistent with other frames.
	Consequences: Nouns will not be rendered (color/underline) 
	              until the frame is compiled (submitted).
	"
	| frameUpdater ontology errors |
	ontology := HumOntology new.
		
	"Initialize for a Dictionary Frame."
	frameUpdater := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.
	"Add dictionary lines."
	"attributes"
	frameUpdater addDictionaryLine: 'Recipe attributes include recipe-name, description, ingrediants steps.'.
	"set collection"
	frameUpdater addDictionaryLine: 'Recipe includes a set of ingrediants.'.
	"list collection"
	frameUpdater addDictionaryLine: 'Recipe includes a list of steps.'.
	"Attribute used in  set above is an entity with its own attributes. Entities are members of set."
	frameUpdater addDictionaryLine: 'Ingredient attributes include ingredient-name, quantity, alternate-ingredient.'.
	"Attribute used in list above is an entity. Entity instances are in a list. (OrderedCollection)"
	frameUpdater addDictionaryLine: 'Step attributes include step-number, step-description'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Dictionary ).

	"Until the frame is compiled, the nouns are not recognized.
	TODO: IS THIS WHAT WE WANT?
	"
	errors := frameUpdater checkFrameSyntax.
	self assert: ( errors isEmpty not ).
	self assert: ( errors size = 5 ).
	
	"Transcript  cr; show: 'test350critiqueFrame4Dictionary'; cr; show: errors; cr."
  errors do: [:error | '*has no known nouns*' match: error. ]


	
]

{ #category : #'pa310 Critique frame' }
HumProgrammersAssistantTests >> test351critiqueFrame4Dictionary [
	"Critique a dictionary frame.
	After a dictionary frame is 'compiled', the nouns are recognized.
	"
	| frameUpdater ontology errors |
	ontology := HumOntology title: 'test351critiqueFrame4Dictionary'.
		
	"Initialize for a Dictionary Frame."
	frameUpdater := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.

	"Add dictionary lines."
	"attributes"
	frameUpdater addDictionaryLine: 'Recipe attributes include recipe-name, description, ingredients, steps.'.
	"set collection"
	frameUpdater addDictionaryLine: 'Recipe includes a set of ingrediants.'.
	"list collection"
	frameUpdater addDictionaryLine: 'Recipe includes a list of steps.'.
	"Attribute used in  set above is an entity with its own attributes. Entities are members of set."
	frameUpdater addDictionaryLine: 'Ingredient attributes include ingredient-name, quantity, alternate-ingredient.'.
	"Attribute used in list above is an entity. Entity instances are in a list. (OrderedCollection)"
	frameUpdater addDictionaryLine: 'Step attributes include step-number, step-description'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Dictionary ).
	
	"ontology addNouns: #( 'recipe' 'name' 'description' 'ingredient' 'step' )."
	frameUpdater compileToOntology: ontology. "Nouns are now added to ontology."
			
	"Expect no complaints about no nouns."
	errors := frameUpdater checkFrameSyntax .
	self assert: ( errors isEmpty  ).
	self assert: ( errors size = 0 ).
	
	"Transcript  cr; show: 'test351critiqueFrame4Dictionary'; cr; show: errors; cr."


	
]

{ #category : #'pa310 Critique frame' }
HumProgrammersAssistantTests >> test361critiqueFrame4Vignette [
	"Critique a dialog vignette.
	"
	| frameUpdater1 frameUpdater2 frameUpdater3 ontology errors1 errors2 errors3 |
	ontology := HumOntology new.
		
	"Initialize for a Dialog Frame."
	frameUpdater1 := HumFrameUpdater ontology: ontology 
													vignetteContext: 'Expecting Hello.' 
																	pattern: 'Knock, knock.'.
	frameUpdater1 addVignetteResponse: 'Who is there?'.
	frameUpdater1 nextVignetteContext: 'Expecting first name.'.
	errors1 := frameUpdater1 checkFrameSyntax.
	self assert: (errors1 isEmpty ) not.
	 
	frameUpdater2 := HumFrameUpdater ontology: ontology 
													vignetteContext: 'Expecting first name.' 
																	pattern: '[first-name]'.
	frameUpdater2 addVignetteResponse: '[first-name] who?'.
	frameUpdater2 nextVignetteContext: 'Expecting whole-name.'.
	errors2 := frameUpdater2 checkFrameSyntax.
	self assert: (errors2 isEmpty ) not.
	
	
	frameUpdater3 :=  HumFrameUpdater ontology: ontology 
													vignetteContext: 'Expecting whole-name.' 
																	pattern: '[first-name] [last-name]'.
	frameUpdater3 addVignetteResponse: 'Hello [first-name] [last-name]. What do you want to do?'.
	frameUpdater3 addVignetteInstruction: 'Ask menu.'.
	errors3 := frameUpdater3 checkFrameSyntax.
	self assert: (errors3 isEmpty ) not.
	
	ontology addNouns: #( 'name' 'first-name' 'last-name' 'menu' ).
	
	frameUpdater1 compileToOntology: ontology.
	frameUpdater2 compileToOntology: ontology.
	frameUpdater3 compileToOntology: ontology.
	
	errors1 := frameUpdater1 checkFrameSyntax.
	self assert: ( errors1 isEmpty ).
	
	errors2 := frameUpdater2 checkFrameSyntax.
	self assert: ( errors2 isEmpty ).
	
	errors3 := frameUpdater3 checkFrameSyntax.
	"{Ask menu.} is not defined in this ontology."
	self assert: ( errors3 isEmpty ) description: 'Action: {Ask menu.} has not been defined?'.
	
	
	
	
	
	
	
	
	
	
	

	
]

{ #category : #'pa410 Compile frame' }
HumProgrammersAssistantTests >> test421compileFrame4Plan [
	"In this context, 'compile' means that the plan frame is inserted into the ontology,
	  and the frame is checked for problems that would prevent the plan from executing.
	"
	| frameUpdater ontology errors goalSourceString frameIn frameOut  |
	ontology := HumOntology new.

	"Initialize for a Plan Frame."
	goalSourceString := 'Cake is baked according to recipe.'.
	frameUpdater := HumFrameUpdater ontology: ontology goal: goalSourceString.

	"Append precondition lines."
	frameUpdater appendPrecondition: 'Oven is preheated to the temperature given in the recipe.'.
	frameUpdater appendPrecondition: 'The recipe batter is in a prepared cake pan.'.

	"Finish with action statement."
	frameUpdater appendRole: 'Oven' action: 'Bake the pan in the oven for the time given in the recipe.' .
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Plan ).
	
	"Every line has recipe as a noun."
	ontology addNouns: #( 'recipe' ).
	
	"Expect no complaints about no nouns. "
	errors := frameUpdater checkFrameSyntax.
	self expect: 0 actual: ( errors count: [ :error | '*no nouns*' match: error ]  ).
	
	errors := frameUpdater compileToOntology: ontology.
	
	self expect: 2 actual: ( errors asSet size ).
	
	"Now we should see frame in the ontology."
	frameIn := frameUpdater frame.
	frameOut := ontology getPlanFrameForGoal: goalSourceString. 
	self expect: frameIn frameLines actual: frameOut frameLines.
	self assert: ( frameOut = frameIn ).
	

]

{ #category : #'pa410 Compile frame' }
HumProgrammersAssistantTests >> test431compileFrame4Action [
	"In this case, 'compile' means adding the frame to the ontology,
	  and the syntax checks for problems that would prevent the frame from executing. 
	"
	| actionSourceString frameUpdater ontology errors instructionSequence |
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	actionSourceString :=  'Bake the pan in the oven for the baking-time given in the recipe.'.
	frameUpdater := HumFrameUpdater ontology: ontology role: 'Baker' action:  actionSourceString.
	"Append instruction lines."
	frameUpdater appendInstructionStatement: 'Open the oven door.'.
	frameUpdater appendInstructionStatement: 'Place the pan in the oven.'.
	frameUpdater appendInstructionStatement: 'Close the oven door.'.
	frameUpdater appendInstructionStatement: 'Set the oven-temperature per recipe.'.
	
	"Append an instruction that is delegated"
	frameUpdater appendInstructionRole: 'Oven' statement: 'Bake for the baking-time given in the recipe.'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Action ).
	self expect: 5 actual: ( frameUpdater frame frameLines size ) description: '5 lines expected'.
	
	ontology addNouns: #( 'recipe' 'oven' 'pan' 'baking-time' 'oven-temperature' ).
	
	errors := frameUpdater checkFrameSyntax.
	self assert: ( errors count: [ :error | '*no known nouns*' match: error ] ) = 0 description: 'All the needed nouns are given.'.
	
	errors := frameUpdater compileToOntology: ontology.
	self expect: 5 actual: ( frameUpdater frame frameLines size ) description: 'should still be 5 lines'.

	self expect: 1 actual: (errors size).	
	self expect: 'The noun: "oven-temperature" has no antecedant.' actual: (errors first).
	
	"Now we can get the action from the ontology"
	self assert: ( ( ontology getRole: 'Baker'  action:  actionSourceString ) isKindOf: HumStatement ).
		
	"Now we can also get the instruction sequence "
	instructionSequence := ( ontology instructionsForRole: 'Baker' action: actionSourceString ).
	self assert: ( instructionSequence isKindOf: OrderedCollection ).
	self expect: 5 actual: ( instructionSequence size ).
	self assert:( ( instructionSequence at: 1) isKindOf: HumInstructionLine ).
	
	"And the role`s actions includes "
	self assert: (( ontology actionsOf: 'Baker' ) include: actionSourceString ).

	
	

]

{ #category : #'pa410 Compile frame' }
HumProgrammersAssistantTests >> test446compileFrame4View [
	"Compile a view frame.
	"
	| frameUpdater ontology errors testMe |
	
	testMe := true.
	testMe ifFalse: [ Transcript cr; show: 'test446compileFrame4View is turned off.'; cr. ^self].
	
	ontology := HumOntology new.
	
	"Initialize for a View Frame."
	frameUpdater := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	"Add markup lines."
	frameUpdater addMarkUp: '!! Recipe'.
	frameUpdater addMarkUp: ' recipe-name: [name]'.
	frameUpdater addMarkUp: '   description: [description 5]'.
	frameUpdater addMarkUp: '   ingredients: [ingredients]'.
	frameUpdater addMarkUp: '            steps: [steps]'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4View ).
	
	ontology addEntity: 'recipe' attributes: #( 'name' 'description' 'ingredients' 'steps' ).
		
	"Expect no complaints about no nouns."
	errors := frameUpdater compileToOntology: ontology.
	self assert: ( errors isEmpty  ).
	



	

]

{ #category : #'pa410 Compile frame' }
HumProgrammersAssistantTests >> test450compileFrame4Dictionary [
	"In this context, 
	'compile' means that the ontology will be updated with nouns and their supertypes.
	"

	| frameUpdater ontology errors nounSubtypes zNouns |
	ontology := HumOntology new.

	"Initialize for a Dictionary Frame."
	frameUpdater := HumFrameUpdater
		ontology: ontology
		dictionaryTitle: 'Recipe vocabulary.'.

	"Add dictionary lines."
	"supertype"
	frameUpdater addDictionaryLine: 'Description is a text.'.
	"attributes"
	frameUpdater
		addDictionaryLine:
			'Recipe attributes include recipe-name, recipe-description, ingredients, steps.'.
	"set collection"
	frameUpdater
		addDictionaryLine: 'Recipe includes a set of ingredients.'.
	"list collection"
	frameUpdater addDictionaryLine: 'Recipe includes a list of steps.'.
	"Attribute used in  set above is an entity with its own attributes. Entities are members of set."
	frameUpdater
		addDictionaryLine: 'Ingredient attributes include ingredient-name, quantity, substitute.'.
	"Attribute used in list above is an entity. Entity instances are in a list. (OrderedCollection)"
	frameUpdater
		addDictionaryLine: 'Step attributes include step-number, step-description'.
	self assert: frameUpdater notNil.
	self assert: (frameUpdater frame isMemberOf: HumFrame4Dictionary).
	frameUpdater storeFrameInOntology.
	self
		expect: 1
		actual: ontology frames size
		description: 'HumFrameUpdater>>storeFrameInOntology should insert frame.'.
	errors := frameUpdater compileToOntology: ontology.
	"There are no syntax errors."
	self assert: errors isEmpty.
	ontology compileAllFrames.
	self
		expect: 1
		actual: ontology frames size
		description: 'Frame should still be in ontology after #compileAllFrames.'.

	"Check that ontology has all that stuff."
	zNouns := ontology nouns.
	self
		expect: 14
		actual: zNouns size
		description: 'Expecting over ten nouns'.
	self
		assert:
			(zNouns
				includesAll:
					#('recipe' 'recipe-name' 'description' 'ingredient' 'step' 'ingredient-name' 'quantity' 'substitute' 'step-number' 'step-description')).

	"Check that the supertypes are recorded also."
	nounSubtypes := ontology nounSubtypes.
	self
		expect:
			{('text' -> 'description').
			('set' -> 'ingredients').
			('list' -> 'steps')}
		actual: nounSubtypes asArray
]

{ #category : #'pa410 Compile frame' }
HumProgrammersAssistantTests >> test461compileFrame4Vignette [
	"Compile a dialog vignette.
	"
	| frameUpdater1 frameUpdater2 frameUpdater3 ontology frame1 frame2 frame3 |
	ontology := HumOntology new.
		
	"Initialize a Vignette Frame."
	frameUpdater1 := HumFrameUpdater ontology: ontology 
												vignetteContext: 'Expecting Hello.' 
																pattern: 'Knock, knock.'.
	frameUpdater1 addVignetteResponse: 'Who is there?'.
	frameUpdater1 nextVignetteContext: 'Expecting first name'.
	frameUpdater1 compileToOntology: ontology.
	 
	frameUpdater2 := HumFrameUpdater ontology: ontology 
													vignetteContext: 'Expecting first name.' 
																	pattern: '[first-name]'.
	frameUpdater2 addVignetteResponse: '[first-name] who?'.
	frameUpdater2 nextVignetteContext: 'Expecting whole-name'.
	frameUpdater2 compileToOntology: ontology.
	
	frameUpdater3 :=  HumFrameUpdater ontology: ontology 
													vignetteContext: 'Expecting whole-name.' 
																	pattern: '[first-name] [last-name]'.
	frameUpdater3 addVignetteResponse: 'Hello [first-name] [last-name]. What do you want to do?'.
	frameUpdater3 addVignetteInstruction: 'Ask menu.'.
	frameUpdater3 compileToOntology: ontology.
	
	"The ontology should have these frames."
	frame1 := frameUpdater1 frame.
	frame2 := frameUpdater2 frame.
	frame3 := frameUpdater3 frame.
	self assert: ( frame1 uniqueIdentifier < frame2 uniqueIdentifier).
	self assert: ( frame2 uniqueIdentifier < frame3 uniqueIdentifier ).
	self assert: ( ( ontology fetchFrameByIdentifier: ( frame1 uniqueIdentifier  )) = frame1 ).
	self assert: ( ( ontology fetchFrameByIdentifier: ( frame2 uniqueIdentifier  )) = frame2 ).
	self assert: ( ( ontology fetchFrameByIdentifier: ( frame3 uniqueIdentifier  )) = frame3 ).
	
	""
	
	
	
	
	
	

	
]

{ #category : #'pa510 Store and fetch frame' }
HumProgrammersAssistantTests >> test510storeFrame [
	"Store the frame in the given ontology.
	The frame may be stored even if it has errors.
	"
	| frameUpdater ontology |
	ontology := HumOntology new.
		
	"Initialize for a Dictionary Frame."
	frameUpdater := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.
	"Add dictionary lines."
	"supertype"
	frameUpdater addDictionaryLine: 'Description is a text.'.
	"attributes"
	frameUpdater addDictionaryLine: 'Recipe attributes include recipe-name, recipe-description, ingredients, steps.'.
	"set collection"
	frameUpdater addDictionaryLine: 'Recipe includes a set of ingredients.'.
	"list collection"
	frameUpdater addDictionaryLine: 'Recipe includes a list of steps.'.
	"Attribute used in  set above is an entity with its own attributes. Entities are members of set."
	frameUpdater addDictionaryLine: 'Ingredient attributes include ingredient-name, quantity, alternate-ingredient.'.
	"Attribute used in list above is an entity. Entity instances are in a list. (OrderedCollection)"
	frameUpdater addDictionaryLine: 'Step attributes include step-number, step-description'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Dictionary ).
	
	"The frame editor receives the command to store the frame from the user interface (Scribe)."
	frameUpdater storeFrameInOntology.
	
	

]

{ #category : #'pa510 Store and fetch frame' }
HumProgrammersAssistantTests >> test520fetchFrameByID [
	"Store a dictionary frame and then get it back using its uniqueIdentifier.
	"
	| frameUpdater1 ontology identifier frameUpdater2 frame1 frame2 |
	ontology := HumOntology new.
		
	"Initialize for a Dictionary Frame."
	frameUpdater1 := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.
	"Add dictionary lines."
	"supertype"
	frameUpdater1 addDictionaryLine: 'Description is a text.'.
	"attributes"
	frameUpdater1 addDictionaryLine: 'Recipe attributes include recipe-name, recipe-description, ingredients, steps.'.
	"set collection"
	frameUpdater1 addDictionaryLine: 'Recipe includes a set of ingredients.'.
	"list collection"
	frameUpdater1 addDictionaryLine: 'Recipe includes a list of steps.'.
	"Attribute used in  set above is an entity with its own attributes. Entities are members of set."
	frameUpdater1 addDictionaryLine: 'Ingredient attributes include ingredient-name, quantity, alternate-ingredient.'.
	"Attribute used in list above is an entity. Entity instances are in a list. (OrderedCollection)"
	frameUpdater1 addDictionaryLine: 'Step attributes include step-number, step-description'.
	
	self assert: ( frameUpdater1 notNil ).
	self assert: ( frameUpdater1 frame isMemberOf: HumFrame4Dictionary ).
	
	"The frame editor receives the command to store the frame from the user interface (Scribe)."
	frameUpdater1 storeFrameInOntology.
	"The frame will now have a uniqueIdentifier."
	frame1 := frameUpdater1 frame.
	self assert: ( frame1 isKindOf: HumFrame4Dictionary ).
	identifier := frame1 uniqueIdentifier.
	self assert: ( identifier isKindOf: HumIdentifier ).
	"We can use the identifier to fetch the frame into another frameUpdater."
	frameUpdater2 := HumFrameUpdater ontology: ontology loadFrameByIdentifier: identifier.
	self assert: (frameUpdater2 isKindOf: HumFrameUpdater ).
	"Check the content."
	frame2 := frameUpdater2 frame.
	self assert: ( frame2 isKindOf: HumFrame4Dictionary ).
	self assert: ( frame1 titleLine = frame2 titleLine ).
	self assert: ( frame1 titleLine sameAs: frame2 titleLine ).
	self assert: ( frame1 frameLines size ) = ( frame2 frameLines size ).
	self assert: ( frame1 frameLines at: 1) = ( frame2 frameLines at: 1 ).
	self assert: (( frame1 frameLines at: 1) sameAs: ( frame2 frameLines at: 1 )).
	
	

]

{ #category : #'pa510 Store and fetch frame' }
HumProgrammersAssistantTests >> test531fetchFrame4PlanByID [
	"Create a plan frame in editor; store it; get it back via its ID.
	"
	| frameUpdater1 frameUpdater2 ontology errors frame1 frame2 identifier |
	ontology := HumOntology new.

	"Initialize for a Plan Frame."
	frameUpdater1 := HumFrameUpdater ontology: ontology goal: 'Cake is baked according to recipe..'.
	"Append precondition lines."
	frameUpdater1 appendPrecondition: 'Oven is preheated to the temperature given in the recipe.'.
	frameUpdater1 appendPrecondition: 'The recipe`s batter is in a prepared cake pan.'.
	"Finish with action statement."
	frameUpdater1 appendRole: 'Oven' action: 'Bake the pan in the oven for the time given in the recipe.' .
	
	self assert: ( frameUpdater1 notNil ).
	self assert: ( frameUpdater1 frame isMemberOf: HumFrame4Plan ).
	
	"Every line has recipe as a noun."
	ontology addNouns: #( 'recipe' ).
	
	"Expect no complaints about no nouns. "
	errors := frameUpdater1 checkFrameSyntax.
	self assert: ( errors count: [ :error | '*no known nouns*' match: error]  ) = 0.
	
		
	self assert: ( frameUpdater1 notNil ).
	self assert: ( frameUpdater1 frame isMemberOf: HumFrame4Plan ).
	
	"The frame editor receives the command to store the frame from the user interface (Scribe)."
	frameUpdater1 storeFrameInOntology.
	"The frame will now have a uniqueIdentifier."
	frame1 := frameUpdater1 frame.
	self assert: ( frame1 isKindOf: HumFrame4Plan ).
	identifier := frame1 uniqueIdentifier.
	self assert: ( identifier isKindOf: HumIdentifier ).
	"We can use the identifier to fetch the frame into another frameUpdater."
	frameUpdater2 := HumFrameUpdater ontology: ontology loadFrameByIdentifier: identifier.
	self assert: (frameUpdater2 isKindOf: HumFrameUpdater ).
	"Check the content."
	frame2 := frameUpdater2 frame.
	self assert: ( frame2 isKindOf: HumFrame4Plan ).
	self assert: ( frame1 titleLine = frame2 titleLine ).
	self assert: ( frame1 titleLine sameAs: frame2 titleLine ).
	self assert: ( frame1 frameLines size ) = ( frame2 frameLines size ).
	self assert: ( frame1 frameLines at: 1) = ( frame2 frameLines at: 1 ).
	self assert: (( frame1 frameLines at: 1) sameAs: ( frame2 frameLines at: 1 )).
	
	

	

]

{ #category : #'pa510 Store and fetch frame' }
HumProgrammersAssistantTests >> test532fetchFrame4PlanByTitle [
	"Create a plan frame in editor; store it; get it back via its title.
	"
	| frameUpdater1 frameUpdater2 frameUpdater3 frameUpdater4 ontology errors frame1 frame2  frame4 name |
	ontology := HumOntology new.

	"Initialize for a Plan Frame."
	frameUpdater1 := HumFrameUpdater ontology: ontology goal: 'Cake is baked according to recipe.'.
	"Append precondition lines."
	frameUpdater1 appendPrecondition: 'Oven is preheated to the temperature given in the recipe.'.
	frameUpdater1 appendPrecondition: 'The recipe`s batter is in a prepared cake pan.'.
	"Finish with action statement."
	frameUpdater1 appendRole: 'Oven' action: 'Bake the pan in the oven for the time given in the recipe.' .
	
	self assert: ( frameUpdater1 notNil ).
	self assert: ( frameUpdater1 frame isMemberOf: HumFrame4Plan ).
	
	"Every line has recipe as a noun."
	ontology addNouns: #( 'recipe' ).
	
	"Expect no complaints about no nouns. "
	errors := frameUpdater1 checkFrameSyntax.
	self assert: ( errors count: [ :error | '*no known nouns*' match: error] ) = 0.
	
	self assert: ( frameUpdater1 notNil ).
	self assert: ( frameUpdater1 frame isMemberOf: HumFrame4Plan ).
	
	"The frame editor receives the command to store the frame from the user interface (Scribe)."
	frameUpdater1 storeFrameInOntology.
	"The frame will now have a uniqueIdentifier."
	frame1 := frameUpdater1 frame.
	self assert: ( frame1 isKindOf: HumFrame4Plan ).
	name := frame1 frameName.
	self assert: ( name isKindOf: String ).
	"We can use the identifier to fetch the frame into another frameUpdater."
	frameUpdater2 := HumFrameUpdater ontology: ontology fetchFrameByName: name.
	self assert: ( frameUpdater2 isKindOf: HumFrameUpdater ).
	"Check the content."
	frame2 := frameUpdater2 frame.
	self assert: ( frame2 isKindOf: HumFrame4Plan ).
	self assert: ( frame1 titleLine = frame2 titleLine ).
	self assert: ( frame1 titleLine sameAs: frame2 titleLine ).
	self assert: ( frame1 frameLines size ) = ( frame2 frameLines size ).
	self assert: ( frame1 frameLines at: 1 ) = ( frame2 frameLines at: 1 ).
	self assert: (( frame1 frameLines at: 1 ) sameAs: ( frame2 frameLines at: 1 )).
	
	"Make sure it still works when there is more than one plan frame."	
	frameUpdater3 := HumFrameUpdater ontology: ontology 
	                                    goal: 'Oven is preheated to the temperature given in the recipe.'.
	frameUpdater3 storeFrameInOntology.
	frameUpdater4 := HumFrameUpdater ontology: ontology fetchFrameByName: name.
	self assert: ( frameUpdater2 isKindOf: HumFrameUpdater ).
	"Check the content."
	frame4 := frameUpdater2 frame.
	self assert: ( frame4 isKindOf: HumFrame4Plan ).
	self assert: ( frame1 titleLine = frame2 titleLine ).
	self assert: ( frame1 titleLine sameAs: frame4 titleLine ).
	self assert: ( frame1 frameLines size ) = ( frame4 frameLines size ).
	self assert: ( frame1 frameLines at: 1 ) = ( frame4 frameLines at: 1 ).
	self assert: (( frame1 frameLines at: 1 ) sameAs: ( frame4 frameLines at: 1 )).

]

{ #category : #'pa510 Store and fetch frame' }
HumProgrammersAssistantTests >> test540fetchFrame4DictionaryByID [
	| frameUpdater1 frameUpdater2 ontology identifier frame1 frame2 |	
	"Initialize for a Dictionary Frame."
	ontology := HumOntology new.
	frameUpdater1 := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.
	
	"Add dictionary lines."
	"attributes"
	frameUpdater1 addDictionaryLine: 'Recipe attributes include recipe-name, description, ingrediants steps.'.
	"set collection"
	frameUpdater1 addDictionaryLine: 'Recipe includes a set of ingrediants.'.
	"list collection"
	frameUpdater1 addDictionaryLine: 'Recipe includes a list of steps.'.
	"Attribute used in  set above is an entity with its own attributes. Entities are members of set."
	frameUpdater1 addDictionaryLine: 'Ingredient attributes include ingredient-name, quantity, alternate-ingredient.'.
	"Attribute used in list above is an entity. Entity instances are in a list. (OrderedCollection)"
	frameUpdater1 addDictionaryLine: 'Step attributes include step-number, step-description'.
	
	self assert: ( frameUpdater1 notNil ).
	self assert: ( frameUpdater1 frame isMemberOf: HumFrame4Dictionary ).
	
		"The frame editor receives the command to store the frame from the user interface (Scribe)."
	frameUpdater1 storeFrameInOntology.
	"The frame will now have a uniqueIdentifier."
	frame1 := frameUpdater1 frame.
	self assert: ( frame1 isKindOf: HumFrame4Dictionary ).
	identifier := frame1 uniqueIdentifier.
	self assert: ( identifier isKindOf: HumIdentifier ).
	"We can use the identifier to fetch the frame into another frameUpdater1."
	frameUpdater2 := HumFrameUpdater ontology: ontology loadFrameByIdentifier: identifier.
	self assert: (frameUpdater2 isKindOf: HumFrameUpdater ).
	"Check the content."
	frame2 := frameUpdater2 frame.
	self assert: ( frame2 isKindOf: HumFrame4Dictionary ).
	self assert: ( frame1 titleLine = frame2 titleLine ).
	self assert: ( frame1 titleLine sameAs: frame2 titleLine ).
	self assert: ( frame1 frameLines size ) = ( frame2 frameLines size ).
	self assert: ( frame1 frameLines at: 1) = ( frame2 frameLines at: 1 ).
	self assert: (( frame1 frameLines at: 1) sameAs: ( frame2 frameLines at: 1 )).
	


	
]

{ #category : #'pa510 Store and fetch frame' }
HumProgrammersAssistantTests >> test541fetchFrame4DictionaryByTitle [
	"Ontology will fetch a dictionary frame given its title."
	| frameUpdater1 frameUpdater2 ontology name frame1 frame2 |	
	"Given: Ontology has several dictionary frames."
	"When: Caller (PA) requests a dictionary frame by its title."
	"Then: Ontology returns the matching frame."
	"--- Otherwise ---"
	"The caller may request a ranked list of nearest matches. (test542 ?)"

	"Initialize for a Dictionary Frame."
	ontology := HumOntology new.
	frameUpdater1 := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.
	
	"Add dictionary lines."
	"attributes"
	frameUpdater1 addDictionaryLine: 'Recipe attributes include recipe-name, description, ingrediants steps.'.
	"set collection"
	frameUpdater1 addDictionaryLine: 'Recipe includes a set of ingrediants.'.
	"list collection"
	frameUpdater1 addDictionaryLine: 'Recipe includes a list of steps.'.
	"Attribute used in  set above is an entity with its own attributes. Entities are members of set."
	frameUpdater1 addDictionaryLine: 'Ingredient attributes include ingredient-name, quantity, alternate-ingredient.'.
	"Attribute used in list above is an entity. Entity instances are in a list. (OrderedCollection)"
	frameUpdater1 addDictionaryLine: 'Step attributes include step-number, step-description'.
	
	self assert: ( frameUpdater1 notNil ).
	self assert: ( frameUpdater1 frame isMemberOf: HumFrame4Dictionary ).
	
		"The frame editor receives the command to store the frame from the user interface (Scribe)."
	frameUpdater1 storeFrameInOntology.
	"The frame will now have a uniqueIdentifier."
	frame1 := frameUpdater1 frame.
	self assert: ( frame1 isKindOf: HumFrame4Dictionary ).
	name := frame1 frameName.
	self assert: ( name isKindOf: String ).
	"We can use the identifier to fetch the frame into another frameUpdater."
	frameUpdater2 := HumFrameUpdater ontology: ontology fetchFrameByName: name.
	self assert: (frameUpdater2 isKindOf: HumFrameUpdater ).
	"Check the content."
	frame2 := frameUpdater2 frame.
	self assert: ( frame2 isKindOf: HumFrame4Dictionary ).
	self assert: ( frame1 titleLine = frame2 titleLine ).
	self assert: ( frame1 titleLine sameAs: frame2 titleLine ).
	self assert: ( frame1 frameLines size ) = ( frame2 frameLines size ).
	self assert: ( frame1 frameLines at: 1) = ( frame2 frameLines at: 1 ).
	self assert: (( frame1 frameLines at: 1) sameAs: ( frame2 frameLines at: 1 )).
	


	
]

{ #category : #'pa510 Store and fetch frame' }
HumProgrammersAssistantTests >> test551fetchFrame4ActionByTitle [
	"The title of an action includes the role and the statement."
		| frameUpdater1 frameUpdater2 ontology frame1 frame2 name |
	"Given: Ontology contains several action frames."
	"When: Caller (PA) requests the action frame with role and statement-string."
	"Then: Ontology returns the matching action frame.
	       Otherwise: The PA may ask the ontology for a ranked list of nearest matches. (test552 ?)"
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameUpdater1 := HumFrameUpdater ontology: ontology  
	                                  role: 'Role' 
																action: 'Bake the pan in the oven for the time given in the recipe.'.

	"Append instruction lines."
	frameUpdater1 appendInstructionStatement: 'Open the oven door.'.
	frameUpdater1 appendInstructionStatement: 'Place the pan in the oven.'.
	frameUpdater1 appendInstructionStatement: 'Close the oven door.'.
	
	"Append an instruction that is delegated"
	frameUpdater1 appendInstructionRole: 'Oven' statement: 'Bake for the time given.'.
	
	self assert: ( frameUpdater1 notNil ).
	self assert: ( frameUpdater1 frame isMemberOf: HumFrame4Action ).	
	self assert: ( frameUpdater1 frame frameLines size = 4 ).
	
	frame1 := frameUpdater1 frame.
	self assert: ( frame1 isKindOf: HumFrame4Action ).
	name := frame1 frameName.
	self assert: ( name isKindOf: String ).
	"We can use the identifier to fetch the frame into another frameUpdater."
	frameUpdater1 storeFrameInOntology.
	frameUpdater2 := HumFrameUpdater ontology: ontology fetchFrameByName: name.
	self assert: (frameUpdater2 isKindOf: HumFrameUpdater ).
	"Check the content."
	frame2 := frameUpdater2 frame.
	self assert: ( frame2 isKindOf: HumFrame4Action ).
	self assert: ( frame1 titleLine = frame2 titleLine ).
	self assert: ( frame1 titleLine sameAs: frame2 titleLine ).
	self expect: ( frame1 frameLines size ) actual: ( frame2 frameLines size ).
	self expect: ( frame1 frameLines at: 1)  actual: ( frame2 frameLines at: 1 ).
	self expect: ( frame1 frameLines at: 1) actual: ( frame2 frameLines at: 1 ).


	
	

]

{ #category : #'pa510 Store and fetch frame' }
HumProgrammersAssistantTests >> test561fetchFrame4ViewByTitle [
	"This should be easy."
	| frameUpdater1 frameUpdater2 ontology name frame1 frame2 |
	"Given: PA or run-time has ontology open with several view frames."
	"When: PA or run-time correctly requests a view by name."
	"Then: Ontology returns the frame containing that view."
	"--- Following can go into another test: ---"
	"When: The name does not match any view,"
	"Then: The PA can ask the ontology for a ranked list of view names. (best match)"
	
	ontology := HumOntology new.
	
	"Initialize for a View Frame."
	frameUpdater1 := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	
	"Add markup lines."
	frameUpdater1 addMarkUp: '!! Recipe'.
	frameUpdater1 addMarkUp: ' recipe-name: [name]'.
	frameUpdater1 addMarkUp: '   description: [description 5]'.
	frameUpdater1 addMarkUp: '   ingredients: [ingredients]'.
	frameUpdater1 addMarkUp: '            steps: [steps]'.
	
	self assert: ( frameUpdater1 notNil ).
	self assert: ( frameUpdater1 frame isMemberOf: HumFrame4View ).
	
	frame1 := frameUpdater1 frame.
	self assert: ( frame1 isKindOf: HumFrame4View ).
	name := frame1 frameName.
	self assert: ( name isKindOf: String ).
	"A view frame must reference a known entity."
	ontology addEntity: 'recipe' attributes: #('name' 'description' 'ingredients' 'steps').
	"We can use the identifier to fetch the frame into another frameUpdater."
	frameUpdater1 storeFrameInOntology.
	frameUpdater2 := HumFrameUpdater ontology: ontology fetchFrameByName: name.
	self assert: (frameUpdater2 isKindOf: HumFrameUpdater ).
	"Check the content."
	frame2 := frameUpdater2 frame.
	self assert: ( frame2 isKindOf: HumFrame4View ).
	self assert: ( frame1 titleLine = frame2 titleLine ).
	self assert: ( frame1 titleLine sameAs: frame2 titleLine ).
	self assert: ( frame1 frameLines size ) = ( frame2 frameLines size ).
	self assert: ( frame1 frameLines at: 1) = ( frame2 frameLines at: 1 ).
	self assert: (( frame1 frameLines at: 1) sameAs: ( frame2 frameLines at: 1 )).
]

{ #category : #'pa510 Store and fetch frame' }
HumProgrammersAssistantTests >> test571fetchFrame4VignetteByTitle [
	"TODO: Think about how vignettes would be identified to users.
	The current design treats vignettes as modules.
	It might make more sense to treat contexts as modules
	because the rule is that the vignettes in a context are tried in the order given.
	If that were the case, 
	  the modules would tend to have too many lines of code, 
	  but they would be easily named.
	Idea: Name the vignette by context plus the first pattern.
	Problem: That does not deal with the ordering of vignettes within a context.
	Question: Is the ordering of vignettes really necessary?
	          In other words, should we demand greater specificity from users?
	Decision: Discard the idea that vignettes are tried in some order and see what happens.
	"
	| frameUpdater1 frameUpdater2 ontology name frame1 frame2 |
	"Given: A context is active."
	"When: Scribe delivers a pattern and run-time looks it up."
	"Then: If the pattern matches one of the vignette`s in the active context, 
	       . Ontology returns that vignette.
	       Otherwise:
	       . Ontology returns nil. (Perhaps we should return a default 'do not understand' vignette.)"
		"Create a dialog vignette.
	"
	ontology := HumOntology new.
		
	"Initialize for a Dialog Frame."
	frameUpdater1 := HumFrameUpdater ontology: ontology vignetteContext: 'Expecting Hello.' pattern: 'Knock, knock.'.
	
	self assert: ( frameUpdater1 notNil ).
	self assert: ( frameUpdater1 frame isMemberOf: HumFrame4Vignette ).
	
	"Add response lines."
	"There are two kinds of resonse, verbal responses and actions."
	frameUpdater1 addVignetteResponse: 'Who is there?'.
	frameUpdater1 addVignetteInstruction: 'Next context "Expecting who.".'.
	
	self assert: ( ( frameUpdater1 frame frameLines at: 1 ) 
									sameAs:  ( HumVignetteResponseLine source: 'S: Who is there?' ) ).
	self assert: ( ( frameUpdater1 frame frameLines at: 2 ) 
									sameAs:  ( HumInstructionLine statement: 'Next context "Expecting who.".' ) ).
	self assert: ( ( frameUpdater1 frame responseLines at: 1 ) 
									sameAs:  ( HumMarkupLine source: 'Who is there?' ) ).
	self assert: ( ( frameUpdater1 frame instructionLines at: 1 ) 
									sameAs:  ( HumInstructionLine statement: 'Next context "Expecting who.".' ) ).
		
	frame1 := frameUpdater1 frame.
	self assert: ( frame1 isKindOf: HumFrame4Vignette ).
	name := frame1 frameName.
	self assert: ( name isKindOf: String ).

	"We can use the identifier to fetch the frame into another frameUpdater."
	frameUpdater1 storeFrameInOntology.
	frameUpdater2 := HumFrameUpdater ontology: ontology fetchFrameByName: name.
	self assert: (frameUpdater2 isKindOf: HumFrameUpdater ).
	"Check the content."
	frame2 := frameUpdater2 frame.
	self assert: ( frame2 isKindOf: HumFrame4Vignette ).
	self assert: ( frame1 titleLine = frame2 titleLine ).
	self assert: ( frame1 titleLine sameAs: frame2 titleLine ).
	self assert: ( frame1 frameLines size ) = ( frame2 frameLines size ).
	self assert: ( frame1 frameLines at: 1) = ( frame2 frameLines at: 1 ).
	self assert: (( frame1 frameLines at: 1) sameAs: ( frame2 frameLines at: 1 )).
	
	
	
	
	

	
]

{ #category : #'pa610 Store In Ontology' }
HumProgrammersAssistantTests >> test620storeFrame4Plan [
	"Store plan frame.
	"
	| frameUpdater ontology |
	ontology := HumOntology new.
	
	"Initialize for a Plan Frame."
	frameUpdater := HumFrameUpdater ontology: ontology goal: 'Cake is baked according to recipe..'.
	"Append precondition lines."
	frameUpdater appendPrecondition: 'Oven is preheated to the temperature given in the recipe.'.
	frameUpdater appendPrecondition: 'The recipe`s batter is in a prepared cake pan.'.
	"Finish with action statement."
	frameUpdater appendRole: 'Oven' action: 'Bake the pan in the oven for the time given in the recipe.' .
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Plan ).
	
	self assert: (frameUpdater frame frameLines size = 3 ).
	
	"Run store and fetch test routine"
	self storeInOntology: ontology fromFrameUpdater: frameUpdater.
	

]

{ #category : #'pa610 Store In Ontology' }
HumProgrammersAssistantTests >> test630storeFrame4Action [
	"Store an action frame.
	"
	| frameUpdater ontology |
	ontology := HumOntology new.
	
	"Initialize for an Action Frame."
	frameUpdater := HumFrameUpdater ontology: ontology  
	                                               role: 'Role' action: 'Bake the pan in the oven for the time given in the recipe.'.
	"Append instruction lines."
	frameUpdater appendInstructionStatement: 'Open the oven door.'.
	frameUpdater appendInstructionStatement: 'Place the pan in the oven.'.
	frameUpdater appendInstructionStatement: 'Close the oven door.'.
	"Append an instruction that is delegated"
	frameUpdater appendInstructionRole: 'Oven' statement: 'Bake for the time given.'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Action ).
		
	self assert: ( frameUpdater frame frameLines size = 4 ).
	
	"Run store and fetch test routine"
	self storeInOntology: ontology fromFrameUpdater: frameUpdater.


	
	

]

{ #category : #'pa610 Store In Ontology' }
HumProgrammersAssistantTests >> test640storeFrame4View [
	"Store a view frame.
	"
	| frameUpdater ontology |
	ontology := HumOntology new.
	
	"A view frame must reference a known entity."
	ontology addEntity: 'recipe' attributes: #('name' 'description' 'ingredients' 'steps').

	"Initialize for a View Frame."
	frameUpdater := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	"Add markup lines."
	frameUpdater addMarkUp: '!! Recipe'.
	frameUpdater addMarkUp: ' recipe-name: [name]'.
	frameUpdater addMarkUp: '   description: [description 5]'.
	frameUpdater addMarkUp: '   ingredients: [ingredients]'.
	frameUpdater addMarkUp: '            steps: [steps]'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4View ).
		
	"Run store and fetch test routine"
	self storeInOntology: ontology fromFrameUpdater: frameUpdater.


	

]

{ #category : #'pa610 Store In Ontology' }
HumProgrammersAssistantTests >> test650storeFrame4Dictionary [
	"Store a dictionary frame.
	"
	| frameUpdater ontology |
	ontology := HumOntology new.
		
	"Initialize for a Dictionary Frame."
	frameUpdater := HumFrameUpdater ontology: ontology dictionaryTitle: 'Recipe vocabulary.'.
	"Add dictionary lines."
	"attributes"
	frameUpdater addDictionaryLine: 'Recipe attributes include recipe-name, description, ingrediants steps.'.
	"set collection"
	frameUpdater addDictionaryLine: 'Recipe includes a set of ingrediants.'.
	"Attribute used in  set above is an entity with its own attributes. Entities are members of set."
	frameUpdater addDictionaryLine: 'Ingredient attributes include ingredient-name, quantity, ingredient-type, alternate-ingredient.'.
	"categories"
	frameUpdater addDictionaryLine: 'Ingredient-type categories include wet, dry.'.
	"list collection"
	frameUpdater addDictionaryLine: 'Recipe includes a list of steps.'.
	"Attribute used in list above is an entity. Entity instances are in a list. (OrderedCollection)"
	frameUpdater addDictionaryLine: 'Step attributes include step-number, step-description'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Dictionary ).
			
	"Run store and fetch test routine"
	self storeInOntology: ontology fromFrameUpdater: frameUpdater.


	
]

{ #category : #'pa610 Store In Ontology' }
HumProgrammersAssistantTests >> test660storeFrame4Vignette [
	"Store a dictionary frame.
	"
	| frameUpdater ontology |
	ontology := HumOntology new.
		
		ontology := HumOntology new.
		
	"Initialize for a Dialog Frame."
	frameUpdater := HumFrameUpdater ontology: ontology vignetteContext: 'Expecting Hello.' pattern: 'Knock, knock.'.
	
	self assert: ( frameUpdater notNil ).
	self assert: ( frameUpdater frame isMemberOf: HumFrame4Vignette ).
	
	"Add response lines."
	"There are two kinds of resonse, verbal responses and actions."
	frameUpdater addVignetteResponse: 'Who is there?'.
	frameUpdater addVignetteInstruction: 'Next context "Expecting who.".'.

	"Run store and fetch test routine"
	self storeInOntology: ontology fromFrameUpdater: frameUpdater.


	
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test700parseSourceLineReadMe [
	"An instruction looks like: <role> : <statement> . (comment) [annotation]"
	"The role prefix is optional - It only appears when one role is delegating to another."
	"Comments and annotation are optional."
	self skip.
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test701parseInstructionLine [
	"An instruction looks like: <role> : <statement> . (comment) [annotation]"
	"The role prefix is optional - It only appears when one role is delegating to another."
	"Comments and annotation are optional."
	| pa ontology sourceLine tokenPairs |
	sourceLine := 'Cook: Place cake in pre-heated oven.'. 
	ontology := HumOntology new.
	ontology addNoun: 'cake'.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseInstructionSource: sourceLine keywords: #().
	self expect: {
			'Cook'->#role. 
			':'->#punctuation. 
			'Place'->#word. 
			'cake'->#noun.
			 'in'->#word. 
			'pre-heated'->#word. 
			'oven'->#word. 
			'.'->#punctuation.
			} 
		actual: tokenPairs asArray.
	
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test702parseInstructionLineWithComment [
	"An instruction looks like: <role> : <statement> . (comment) [annotation]"
	"The role prefix is optional - It only appears when one role is delegating to another."
	"Comments and annotation are optional."
	| pa ontology sourceLine tokenPairs |
	sourceLine := 'Cook: Place cake in pre-heated oven. (Note: pre-heat)'. 
	ontology := HumOntology new.
	ontology addNoun: 'cake'.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseInstructionSource: sourceLine keywords: #().
	self expect: {
			'Cook'->#role. 
			':'->#punctuation. 
			'Place'->#word. 
			'cake'->#noun.
			 'in'->#word. 
			'pre-heated'->#word. 
			'oven'->#word. 
			'.'->#punctuation.
			'(Note: pre-heat)' -> #comment.
			} 
		actual: tokenPairs asArray.
	
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test703parseInstructionLineWithString [
	"An instruction looks like: <role> : <statement> . (comment) [annotation]"
	"The role prefix is optional - It only appears when one role is delegating to another."
	"Comments and annotation are optional."
	| pa ontology sourceLine tokenPairs |
	sourceLine := 'Avatar: Sing "Tally Ho!"'. 
	ontology := HumOntology new.
	ontology addNoun: 'cake'.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseInstructionSource: sourceLine keywords: #().
	self expect: {'Avatar'->#role. ':'->#punctuation. 'Sing'->#word. '"Tally Ho!"'->#string}
		actual: tokenPairs asArray.
	
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test704parseInstructionLineWithTwoComments [
	"An instruction looks like: <role> : <statement> . (comment) [annotation]"
	"The role prefix is optional - It only appears when one role is delegating to another."
	"Comments and annotation are optional."
	| pa ontology sourceLine tokenPairs |
	sourceLine := 'Cook: Place cake (pan) in pre-heated oven. (Note: pre-heat)'. 
	ontology := HumOntology new.
	ontology addNoun: 'cake'.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseInstructionSource: sourceLine keywords: #().
	self expect: {
			'Cook'->#role. 
			':'->#punctuation. 
			'Place'->#word. 
			'cake'->#noun. 
			'(pan)'->#comment. 
			'in'->#word. 
			'pre-heated'->#word. 
			'oven'->#word. 
			'.'->#punctuation. 
			'(Note: pre-heat)'->#comment.
			}
		actual: tokenPairs asArray.
	
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test705parseActionLine [
	"An instruction looks like: <role> : <statement> . (comment) [annotation]"
	"The role prefix is optional - It only appears when one role is delegating to another."
	"Comments and annotation are optional."
	| pa ontology sourceLine tokenPairs |
	sourceLine := 'Action: Place cake in pre-heated oven.'. 
	ontology := HumOntology new.
	ontology addNoun: 'cake'.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseActionLine: sourceLine.
	self expect: {
			'Action'->#keyword. 
			':'->#punctuation. 
			'Place'->#word. 
			'cake'->#noun.
			 'in'->#word. 
			'pre-heated'->#word. 
			'oven'->#word. 
			'.'->#punctuation.
			} 
		actual: tokenPairs asArray.
	
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test706parseActionLineWithComment [
	"An instruction looks like: <role> : <statement> . (comment) [annotation]"
	"The role prefix is optional - It only appears when one role is delegating to another."
	"Comments and annotation are optional."
	| pa ontology sourceLine tokenPairs |
	sourceLine := 'Action: Place cake in pre-heated oven. (Note: pre-heat)'. 
	ontology := HumOntology new.
	ontology addNoun: 'cake'.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseActionLine: sourceLine.
	self expect: {
			'Action'->#keyword. 
			':'->#punctuation. 
			'Place'->#word. 
			'cake'->#noun.
			 'in'->#word. 
			'pre-heated'->#word. 
			'oven'->#word. 
			'.'->#punctuation.
			'(Note: pre-heat)'->#comment.
			} 
		actual: tokenPairs asArray.
	
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test707parseActionLineWithAnnotation [
	"An instruction looks like: <role> : <statement> . (comment) [annotation]"
	"The role prefix is optional - It only appears when one role is delegating to another."
	"Comments and annotation are optional."
	| pa ontology sourceLine tokenPairs |
	sourceLine := 'Action: Pre-heat to temperature. [native]'. 
	ontology := HumOntology new.
	ontology addNoun: 'temperature'.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseActionLine: sourceLine.
	self expect: {
			'Action'->#keyword. 
			':'->#punctuation. 
			'Pre-heat'->#word. 
			'to'->#word. 
			'temperature'->#noun. 
			'.'->#punctuation. 			
			'[native]'->#annotation.					
			} 
		actual: tokenPairs asArray.
	
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test708parseActionLineWithCommentAndAnnotation [
	"An instruction looks like: <role> : <statement> . (comment) [annotation]"
	"The role prefix is optional - It only appears when one role is delegating to another."
	"Comments and annotation are optional."
	| pa ontology sourceLine tokenPairs |
	sourceLine := 'Action: Pre-heat to temperature (in degrees Fahrenheit). [native]'. 
	ontology := HumOntology new.
	ontology addNoun: 'temperature'.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseActionLine: sourceLine.
	self expect: {
			'Action'->#keyword. 
			':'->#punctuation. 
			'Pre-heat'->#word. 
			'to'->#word. 
			'temperature'->#noun. 
			'(in degrees Fahrenheit)'->#comment. 
			'.'->#punctuation. 
			'[native]'->#annotation
			}
		actual: tokenPairs asArray.
	
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test710getLabel [
	"Some framelines have labels. Some don't."
	| pa source label remainder |
	pa := HumProgrammersAssistant new.
	source := 'Action: Bake a cake per recipe.'.
	label := pa getLabelFromSource: source.
	self assert: 'Action' equals: label.
	remainder := pa removeLabelFromSource: source.
	self assert: 'Bake a cake per recipe.' equals: remainder.
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test711parseDictionaryLine [
	"An instruction looks like: <role> : <statement> . (comment) [annotation]"
	"The role prefix is optional - It only appears when one role is delegating to another."
	"Comments and annotation are optional."
	| pa ontology sourceLine tokenPairs |
	sourceLine := 'Role attributes include role-name, actions, assigned-actors.'. 
	ontology := HumOntology new.
	ontology addNouns: #( 'role' 'role-name' 'action' 'assigned-actor' ).
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseInstructionSource: sourceLine keywords: #('attributes' 'include' 'is' 'a' 'an').
	self expect: {
		'Role'->#noun. 
		'attributes'->#keyword. 
		'include'->#keyword. 
		'role-name'->#noun. 
		','->#punctuation. 
		'actions'->#noun. 
		','->#punctuation. 
		'assigned-actors'->#noun. 
		'.'->#punctuation.
		}
			
		actual: tokenPairs asArray.
	
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test712parseDictionaryLineWithComment [
	"An instruction looks like: <role> : <statement> . (comment) [annotation]"
	"The role prefix is optional - It only appears when one role is delegating to another."
	"Comments and annotation are optional."
	| pa ontology sourceLine tokenPairs |
	sourceLine := 'Role attributes include role-name, actions, assigned-actors. (assigned-actors is a run-time attribute)'. 
	ontology := HumOntology new.
	ontology addNouns: #( 'role' 'role-name' 'action' 'assigned-actor' ).
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseInstructionSource: sourceLine keywords: #('attributes' 'include' 'is' 'a' 'an').
	self expect: {
		'Role'->#noun. 
		'attributes'->#keyword. 
		'include'->#keyword. 
		'role-name'->#noun. 
		','->#punctuation. 
		'actions'->#noun. 
		','->#punctuation. 
		'assigned-actors'->#noun. 
		'.'->#punctuation.
		'(assigned-actors is a run-time attribute)'->#comment
		}
			
		actual: tokenPairs asArray.
	
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test713parseDictionaryCategoriesLine [
	"An instruction looks like: <role> : <statement> . (comment) [annotation]"
	"The role prefix is optional - It only appears when one role is delegating to another."
	"Comments and annotation are optional."
	| pa ontology sourceLine tokenPairs |
	sourceLine := 'Frame-type categories include goal-frame, role-frame, context-frame, view-frame.'. 
	ontology := HumOntology new.
	ontology addNouns: #( 'frame-type' 'goal-frame' 'role-frame' 'context-frame' 'view-frame'  ).
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseInstructionSource: sourceLine keywords: #('attributes'  'categories' 'include' 'is' 'a' 'an' ).
	self expect: {
		'Frame-type'->#noun. 
		'categories'->#keyword. 
		'include'->#keyword. 
		'goal-frame'->#noun. 
		','->#punctuation. 
		'role-frame'->#noun. 
		','->#punctuation. 
		'context-frame'->#noun. 
		','->#punctuation. 
		'view-frame'->#noun. 
		'.'->#punctuation.
		}
		actual: tokenPairs asArray.
	
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test720getComment [
	"Some framelines have comments. Some don't."
	| pa source comment remainder |
	pa := HumProgrammersAssistant new.
	source := 'Action: Bake a cake per recipe. (Recipe is a noun.)'.
	"Note: Following assumes there is just one comment in the source.
	If there is more than one comment, only the first one is returned."
	comment := pa getCommentFromSource: source.
	self assert: '(Recipe is a noun.)' equals: comment.
	remainder := pa removeCommentFromSource: source.
	self assert: 'Action: Bake a cake per recipe.' equals: remainder.
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test725noComment [
	"Some framelines have comments. Some don't."
	| pa source comment remainder |
	pa := HumProgrammersAssistant new.
	source := 'Action: Bake a cake per recipe. '.
	comment := pa getCommentFromSource: source.
	self expect: nil actual: comment.
	remainder := pa removeCommentFromSource: source.
	self expect: source trimBoth actual: remainder.
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test730getAnnotation [
	"Some framelines have annotations. Some don't."
	| pa source annotation remainder |
	pa := HumProgrammersAssistant new.
	source := 'Equipment is washed and ready. [Assumed.]'.
	annotation := pa getAnnotationFromSource: source.
	self expect: '[Assumed.]' actual: annotation.
	remainder := pa removeAnnotationFromSource: source.
	self expect: 'Equipment is washed and ready.' actual: remainder.
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test735noAnnotation [
	"Some framelines have annotations. Some don't."
	| pa source annotation remainder |
	pa := HumProgrammersAssistant new.
	source := 'Equipment is washed and ready. (There is no annotation here.)'.
	annotation := pa getAnnotationFromSource: source.
	self expect: nil actual: annotation.
	remainder := pa removeAnnotationFromSource: source.
	self expect: source actual: remainder.
]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test741getOneWidget [
	"Markup-line class includes own parser.  
	TODO: Maybe there should be just one parser."
	|  markupLine widgets |
	markupLine :=  HumMarkupLine source: 'This string contains a widget between brackets: [widget-content]'.
	widgets := markupLine widgets.
	
	self assert: ( widgets includes: '[widget-content]')
	




	

]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test742getTwoWidgets [
	"Markup-line includes a parser."
	| markupLine widgets |
	markupLine :=  HumMarkupLine 
						source: 'This string contains two widgets: [widget-content-1] and also [widget-content-2]'.
	widgets := markupLine widgets.
	
	self assert: ( widgets includes: '[widget-content-1]').
	self assert: ( widgets includes: '[widget-content-2]').




	

]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test743getTwoWidgetsAndButton [
	"Markup-line includes a parser."
	| markupLine widgets |
	markupLine :=  HumMarkupLine 
						source: 'This string contains two widgets: [widget-content-1] and also [widget-content-2] and [[button]]'.
	widgets := markupLine widgets.
	
	self assert: ( widgets includes: '[widget-content-1]').
	self assert: ( widgets includes: '[widget-content-2]').
	self assert: ( widgets includes: '[[button]]').




	

]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test751parseOneWidget [
	"Parse a markup-line containing a widget."
	|   ontology pa sourceLine tokenPairs |
	sourceLine :=  'This string contains a widget between brackets:  [widget-content]'.
	ontology := HumOntology new.
	ontology addNoun: 'cake'.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseMarkupSource: sourceLine.
	self expect:{
			'This'->#word. 
			' '->#whitespace. 
			'string'->#word. 
			' '->#whitespace. 
			'contains'->#word. 
			' '->#whitespace. 
			'a'->#word. 
			' '->#whitespace. 
			'widget'->#word. 
			' '->#whitespace. 
			'between'->#word. 
			' '->#whitespace. 
			'brackets'->#word. 
			':'->#punctuation. 
			' '->#whitespace. 
			' '->#whitespace. 
			'[widget-content]'->#widget
			}
		actual: tokenPairs asArray.

	
	




	

]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test752parseMultipleWidgets [
	"Parse a markup line containing multiple widgets."
	|   ontology pa sourceLine tokenPairs |
	sourceLine :=  '[city], [state] [postal-code]'.
	ontology := HumOntology new.
	ontology addNouns: #('city' 'state' 'postal-code').
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseMarkupSource: sourceLine.
	self expect: {
				'[city]'->#widget. 
				','->#punctuation. 
				' '->#whitespace. 
				'[state]'->#widget. 
				' '->#whitespace. 
				'[postal-code]'->#widget
				}
		actual: tokenPairs asArray.

	
	




	

]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test753parseRadioButtons [
	"Parse a line containing radio button widgets."
	|   ontology pa sourceLine tokenPairs |
	sourceLine :=  '(y) Yes  (n) No'.
	ontology := HumOntology new.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseMarkupSource: sourceLine.
	self expect: {
				'(y)'->#widget. 
				' '->#whitespace. 
				'Yes'->#word. 
				' '->#whitespace. 
				' '->#whitespace. 
				'(n)'->#widget. 
				' '->#whitespace. 
				'No'->#word.
				}
		actual: tokenPairs asArray.

	
	




	

]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test754parseActionButton [
	"Parse a line containing an action button."
	|   ontology pa sourceLine tokenPairs |
	sourceLine :=  '[[submit]]'.
	ontology := HumOntology new.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseMarkupSource: sourceLine.
	self expect: { '[[submit]]'->#widget. } 
	        actual: tokenPairs asArray.

	
	




	

]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test755parseLinkWidget [
	"Parse a mark-up line with a link widget."
	|   ontology pa sourceLine tokenPairs |
	sourceLine :=  'More info [link: here | http:xxx.org ]'.
	ontology := HumOntology new.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseMarkupSource: sourceLine.
	self expect: {
			'More'->#word. 
			' '->#whitespace. 
			'info'->#word. 
			' '->#whitespace. 
			'[link: here | http:xxx.org ]'->#widget.
			}
		actual: tokenPairs asArray.

	
	




	

]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test760parseEmphasisMarkup [
	"Parse a mark-up line with emphasis markup."
	|   ontology pa sourceLine tokenPairs |
	sourceLine :=  'Emphasis *bold* ~italic~ _underline_ ^superscript^.'.
	ontology := HumOntology new.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseMarkupSource: sourceLine.
	self expect: {
			'Emphasis'->#word. 
			' '->#whitespace. 
			'*'->#markup. 
			'bold'->#word. 
			'*'->#markup. 
			' '->#whitespace. 
			'~'->#markup. 
			'italic'->#word. 
			'~'->#markup. 
			' '->#whitespace. 
			'_'->#markup. 
			'underline'->#word. 
			'_'->#markup. 
			' '->#whitespace. 
			'^'->#markup. 
			'superscript'->#word. 
			'^'->#markup. 
			'.'->#punctuation
			}
		actual: tokenPairs asArray.

	
	




	

]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test770parseHeadingMarkup [
	"Parse a mark-up line with emphasis markup."
	|   ontology pa sourceLine tokenPairs |
	sourceLine :=  '!!!This is a level 3 heading.'.
	ontology := HumOntology new.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseMarkupSource: sourceLine.
	self expect: {
			'!!!'->#markup. 
			'This'->#word. 
			' '->#whitespace. 
			'is'->#word. 
			' '->#whitespace. 
			'a'->#word. 
			' '->#whitespace. 
			'level'->#word. 
			' '->#whitespace. 
			'3'->#word. 
			' '->#whitespace. 
			'heading'->#word. 
			'.'->#punctuation.
			}
		actual: tokenPairs asArray.

	
	




	

]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test772parseBulletListMarkup [
	"Parse a mark-up line with bullet list markup."
	|   ontology pa sourceLine tokenPairs |
	sourceLine :=  '---This is a level 3 list outline.'.
	ontology := HumOntology new.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseMarkupSource: sourceLine.
	self expect: {
			'---'->#markup. 
			'This'->#word. 
			' '->#whitespace. 
			'is'->#word. 
			' '->#whitespace. 
			'a'->#word. 
			' '->#whitespace. 
			'level'->#word. 
			' '->#whitespace. 
			'3'->#word. 
			' '->#whitespace. 
			'list'->#word. 
			' '->#whitespace. 
			'outline'->#word. 
			'.'->#punctuation.
			}
		actual: tokenPairs asArray.

	
	




	

]

{ #category : #pa710parseFrameLineSource }
HumProgrammersAssistantTests >> test773parseNumberListMarkup [
	"Parse a mark-up line with emphasis markup."
	|   ontology pa sourceLine tokenPairs |
	sourceLine :=  '###This is a level 3 number list outline.'.
	ontology := HumOntology new.
	pa := HumProgrammersAssistant new.
	pa ontology: ontology.
	tokenPairs := pa parseMarkupSource: sourceLine.
	self expect: {
			'###'->#markup. 
			'This'->#word. 
			' '->#whitespace. 
			'is'->#word. 
			' '->#whitespace. 
			'a'->#word. 
			' '->#whitespace. 
			'level'->#word. 
			' '->#whitespace. 
			'3'->#word. 
			' '->#whitespace. 
			'number'->#word. 
			' '->#whitespace. 
			'list'->#word. 
			' '->#whitespace. 
			'outline'->#word. 
			'.'->#punctuation
			}
		actual: tokenPairs asArray.

	
	




	

]

{ #category : #pa800LoadFromTextStream }
HumProgrammersAssistantTests >> test800LoadFileReadMe [
	"The Programmers Assistant may load and parse a text file.
	1. The framing-convention is that frames are separated by ===.
	The older versions of Hum/Simple English used --- as a frame-delimiter.
	But this version also uses lines beginning with '---' in the mark-up notation.
	2. All frames should begin with a title line 
	   so that the type of frame can be quickly recognized by humans and the PA-Loader.
	3. For convenience, empty frames should be tolerated (but not stored).
	4. For convenience, the file may begin with a frame-delimiter (===).
	5. For convenience, the file may end with an end-of-file (missing frame-delimiter).
	"
	
	"Frames are separated by lines beginning with ===.
	Comment: Additional content may follow a leading === - but that content will be ignored.
	Authors may delimit frames by =============================== if they like.
	Authors may delimit groups of frames with banners.
	==================================
	===== Views Collected Below ======
	==================================
	"

]

{ #category : #pa800LoadFromTextStream }
HumProgrammersAssistantTests >> test810FramesAreSeparatedByFrameDelimiter [
	"Frames are separated by lines beginning with ===.
	Comment: Additional content may follow a leading === - but that content will be ignored.
	Authors may delimit frames by =============================== if they like.
	Authors may delimit groups of frames with banners.
	==================================
	===== Views Collected Below ======
	==================================
	"
	| stream pa |
	stream := ReadWriteStream on: ''.
	stream basicNextPutAll: 
'Comment: Copyright.
	Copyright 2014 RichardAlexanderGreen.
==='.
	stream position: 0.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextStream: stream.
	self expect: 1 actual: ( pa ontology frames size ).
	self expect: 1 actual: ( pa ontology frames count: [:frame | frame isKindOf: HumFrame4Comment  ]).
	
]

{ #category : #pa800LoadFromTextStream }
HumProgrammersAssistantTests >> test811StreamStartsWithFrameDelimiter [
	"Test where file starts with a frame-delimiter."
	| stream pa frames |
	stream := ReadWriteStream on: ''.
	"Test where file starts with a frame-delimiter."
	stream basicNextPutAll: 
'========= First Line ============
Comment: Copyright.
	Copyright 2014 RichardAlexanderGreen.
==='.
	stream position: 0.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextStream: stream.
	frames := pa ontology frames.
	self expect: 1 actual: (  frames size ).
	self expect: 1 actual: (  frames count: [:frame | frame isKindOf: HumFrame4Comment ]).

	
]

{ #category : #pa800LoadFromTextStream }
HumProgrammersAssistantTests >> test812StreamEndsWithEndOfFile [
	"Test where frame ends on end-of-file"
	| stream pa |
	stream := ReadWriteStream on: ''.
	"Test where frame ends on end-of-file"
	stream basicNextPutAll: 
'Comment: Copyright.
	Copyright 2014 RichardAlexanderGreen.'.
	stream position: 0.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextStream: stream.
	pa ontology compileAllFrames. 
	self expect: 1 actual: ( pa ontology frames size ).
	self expect: 1 actual: ( pa ontology frames count: [:frame | frame isKindOf: HumFrame4Comment ]).
	
]

{ #category : #pa800LoadFromTextStream }
HumProgrammersAssistantTests >> test813StreamStartsWithFrameDelimiterEndsWithEOF [
	"Test where file starts with a frame-delimiter and ends on end-of-file."
	| stream pa |
	stream := ReadWriteStream on: ''.
	"Test where file starts with a frame-delimiter and ends on end-of-file."
	stream basicNextPutAll: 
'========= First Line ============
Comment: Copyright.
	Copyright 2014 RichardAlexanderGreen.'.
	stream position: 0.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextStream: stream.
	self expect: 1 actual: ( pa ontology frames size ).
	self expect: 1 actual: ( pa ontology frames count: [:frame | frame isKindOf: HumFrame4Comment ]).
	
]

{ #category : #pa800LoadFromTextStream }
HumProgrammersAssistantTests >> test814StreamHasViewAndDictionaryFrames [
	"Load two frames: a view frame and a dictionary frame."
	| stream pa |
	stream := ReadWriteStream on: ''.
	"Load two frames."
	stream basicNextPutAll: 
'
========= First Line ============
Comment: Copyright.
	Copyright 2014 RichardAlexanderGreen.
===
Dictionary: User/Client Attributes.
	User attributes include name, email, passwordHash.
===
'.
	stream position: 0.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextStream: stream.
	self expect: 2 actual: ( pa ontology frames size ).
	self expect: 1 actual: ( pa ontology frames count: [:frame | frame isKindOf: HumFrame4Dictionary ] ).

	
]

{ #category : #pa800LoadFromTextStream }
HumProgrammersAssistantTests >> test815StreamHasViewDictionaryAndPlanFrame [
	"Load three frames: a view, a dictionary, and a plan frame."
	| stream pa frames planFrames planLines |
	stream := ReadWriteStream on: ''.
	"Load three frames."
	stream basicNextPutAll: 
'========= This is only a test ============
===
Dictionary: User/Client Attributes.
	User attributes include name, email, password-hash.
===
View: User.
  name: [ name ]
  email: [ email ]
===
Goal: Bake a cake per recipe.
Preconditions:
	Oven is preheated per recipe`s oven-temperature.
	Batter is prepared per recipe.
	Batter is in cake-pan prepared per recipe.
Action:
	Arm: Place cake-pan in oven.
	Timer: Wait for recipe`s bake-time.
===
'.
	stream position: 0.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextStream: stream.
	frames := pa ontology frames.
	self expect: 3 actual: (frames size).
	self expect: 1 actual: ( frames count: [:frame | frame isKindOf: HumFrame4Plan ] ).
	self expect: 1 actual: ( frames count: [:frame | frame isKindOf: HumFrame4View ] ).
	self expect: 1 actual: ( frames count: [:frame | frame isKindOf: HumFrame4Dictionary ] ).
	
	"Test for correct number of plan lines. (Remove defect where block labels are of wrong type.)"
	planFrames := ( frames select: [:frame | frame isKindOf: HumFrame4Plan ] ) asOrderedCollection.
	planLines := ( planFrames at: 1 ) frameLines.
	self expect: 3 actual: ( planLines count: [:frameLine | frameLine isKindOf: HumConditionLine ] ).
	self expect: 2 actual: ( planLines count: [:frameLine | frameLine isKindOf: HumInstructionLine ] ).

	
]

{ #category : #pa800LoadFromTextStream }
HumProgrammersAssistantTests >> test816StreamHasViewDictionaryPlanAndCommentFrames [
	"Load four frames: a view, a dictionary, a plan, and a comment frame."
	| stream pa |
	stream := ReadWriteStream on: ''.
	"Load four frames."
	stream basicNextPutAll: 
'========= This is only a test ============
===
Dictionary: User/Client Attributes.
	User attributes include name, email, password-hash.
===
View: User.
  name: [ name ]
  email: [ email ]
===
Goal: Bake a cake per recipe.
Preconditions:
	Oven is preheated per recipe`s oven-temperature.
	Batter is prepared per recipe.
	Batter is in cake-pan prepared per recipe.
Action:
	Arm: Place cake-pan in oven.
	Timer: Wait for recipe`s bake-time.
===
Comment: Some nouns may not need to be identified.
	It may or may not be necessary to identify some nouns in the domain.
	Nouns like oven and cake-pan (above) might not have variable values at run-time.
===
'.
	stream position: 0.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextStream: stream.
	self expect: 4 actual: ( pa ontology frames size ).
	self expect: 1 actual: ( pa ontology frames count: [:frame | frame isKindOf: HumFrame4Comment ] ).

	
]

{ #category : #pa800LoadFromTextStream }
HumProgrammersAssistantTests >> test817StreamHasViewDictionaryPlanAndActionFrames [
	"Load four frames: a view, a dictionary, a plan, and an action frame."
	| stream pa frames |
	stream := ReadWriteStream on: ''.
	"Load four frames."
	stream basicNextPutAll: 
'========= This is only a test ============
===
Comment: Copyright.
	Copyright 2014 RichardAlexanderGreen.
===
Dictionary: User/Client Attributes.
	User attributes include name, email, password-hash.
===
View: User.
  name: [ name ]
  email: [ email ]
===
Goal: Bake a cake per recipe.
Preconditions:
	Oven is preheated per recipe`s oven-temperature.
	Batter is prepared per recipe.
	Batter is in cake-pan prepared per recipe.
Action:
	Arm: Place cake-pan in oven.
	Timer: Wait for recipe`s bake-time.
===
Role: Arm.
Action: Place cake-pan in oven.
	Open oven door.
	Pick-up cake-pan.
	Place cake-pan inside oven.
To: Open oven door.
	Position carriage in front of oven.
	Grab door handle.
	Pull door handle to open position.
===
'.
	stream position: 0.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextStream: stream.
	frames := pa ontology frames.
	self expect: 6 actual: frames size.
	self expect: 2 actual: ( frames count: [:frame | frame isKindOf: HumFrame4Action ] ).
	self expect: 1 actual: ( frames count: [:frame | frame isKindOf: HumFrame4Plan ] ).
	self expect: 1 actual: ( frames count: [:frame | frame isKindOf: HumFrame4Dictionary ] ).
	self expect: 1 actual: ( frames count: [:frame | frame isKindOf: HumFrame4View ] ).
	self expect: 1 actual: ( frames count: [:frame | frame isKindOf: HumFrame4Comment ] ).

	
]

{ #category : #pa800LoadFromTextStream }
HumProgrammersAssistantTests >> test820StreamHasVignettes [
	"Test that vignettes are properly parsed, loaded, and indexed."
	| stream pa frames maps |
		stream := ReadWriteStream on: ''.
	"Load these frames."
	stream basicNextPutAll:
'===
Context: Start.

U: Enter.
S: Club Mech is a test bed for Hum dialogs.

U: My name is [user-name].
U: Authenticated as [user-name].
S: Hello [user-name].
   Please select an activity.
. Push context "Select an activity.".

U: I am a member.
S: What is your name?

U: *.
S: Welcome to Club Mech.
   Are you a member? 
===
Context: Select an activity.

U: Propose a topic.
U: Suggest a topic.
U: Recommend a topic.
U: Introduce a topic.
U: Enter a topic.
S: Please enter a description of the talk you are offering.
. Ask topic.

U: Vote *.
S: Here is the current ballot.
. Ask voter-ballot.
. (Assumes a ballot is available / usable.)

U: * scoreboard.
S: Here is the scoreboard for the current ballot.
. Show scoreboard.
. (Also assumes a ballot is available / usable.)
===
'.
	stream position: 0.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextStream: stream.
	frames := pa ontology frames.
	self expect: 7 actual: frames size description: 'Expecting one frame per vignette.'.
	self expect: 7 actual: ( frames count: [:frame | frame isKindOf: HumFrame4Vignette ] ) description: 'Expecting 7 vignettes.'.
	maps := pa ontology contextVignettes.
	self expect: 4 actual: (maps count: [ :assoc | assoc key = 'Start' ] ) description: 'Expect 4 vignettes under "Start" context.'.
	self expect: 3 actual: (maps count: [ :assoc | assoc key = 'SelectActivity' ] ) description: 'Expect 3 vignettes under "Select an activity" context'.

	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test830LoadActionFrame [
	"Load, parse, and render a slightly tricky action frame."
	| stream pa frames html ideal |
	stream := ReadWriteStream on: ''.
	stream basicNextPutAll:'
Role: Order-Checker. 
Action: Give carriers to the customer. 
. Match carrier to order. 
. Move matched carrier to scale. 
. (This catches most errors with carrier sequencing.) 
. If scale weight matches order`s expected weight: 
. . Release carriers to customer.[ native] 
. Else : 
. . (Most likely error is that carrier is out of sequence.)  
. . Check for carrier-sequence-error. 
. . (Now what?)
'.
	stream position: 0.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextStream: stream.
	frames := pa ontology frames asOrderedCollection.
	self expect: 1 actual: (frames size).
	self expect: 1 actual: (frames count: [:frame | frame isKindOf: HumFrame4Action ]).
	"actionFrame := frames at: 1."
	html := pa ontology view renderAsHTMLonFileNamed: './html/test830LoadActionFrame.html'.
	self assert: ('*Role:*' match: html).
	self assert: ('*Action:*' match: html).
	self assert: ('*class="indent2"*class="indent1"*class="indent2"*' match: html) 
			description: 'Should see indent pattern.'.
	self assert: ('*<k>*</k>*<k>*</k>*' match: html) description: 'Should see 2 keyword markers.'.
	 "
	HumCalculator writeString: ideal toFileNamed: 'test930LoadActionFrameIdeal.html'.
    HumCalculator writeString: html toFileNamed: 'test930LoadActionFrameActual.html'.
	"
	ideal := self text930expected.	
	HumCalculator diffCandidate: html againstIdeal: ideal showing: 3.
	
	
	
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test910LoadFromTextFile [
	"Load from pizza-ontology.txt"
	|  pa fileName |
	fileName := './ontology/Pizza-Ontology.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	self assert: ( pa ontology frames anySatisfy: [:frame | frame isKindOf: HumFrame4Vignette ]).
	self expect: 49 actual: ( pa ontology frames size ).
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test912LoadDonutShop [
	"Load from pizza-ontology.txt"
	|  pa fileName frames |
	fileName := './ontology/DonutShopV06.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	frames := pa ontology frames.
	self expect: 107 actual: ( frames size ). "Includes base-ontology."
	self assert: ( frames anySatisfy: [:frame | frame isKindOf: HumFrame4Vignette ]).
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test913LoadBarista [
	"Load from pizza-ontology.txt"
	|  pa fileName frames |
	fileName := './ontology/Barista.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	frames := pa ontology frames.
	self expect: 38 actual: ( frames size ) description: 'Was text file changed?'.
	"We want at least one of each type of frame."
	self assert: ( frames anySatisfy: [:frame | frame isKindOf: HumFrame4Dictionary ]).
	self assert: ( frames anySatisfy: [:frame | frame isKindOf: HumFrame4Vignette ]).
	self assert: ( frames anySatisfy: [:frame | frame isKindOf: HumFrame4Comment ]).
	self assert: ( frames anySatisfy: [:frame | frame isKindOf: HumFrame4Action ]).
	self assert: ( frames anySatisfy: [:frame | frame isKindOf: HumFrame4View ]).
	self assert: ( frames anySatisfy: [:frame | frame isKindOf: HumFrame4Plan ]).
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test914LoadClubMech [
	"Load from pizza-ontology.txt"
	|  pa fileName frames |
	"Transcript cr; show: 'test914LoadClubMech begins'."
	fileName := './ontology/ClubMechV02.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	frames := pa ontology frames.
	self assert: (pa ontology contextVignettes size > 0).
	"Transcript cr; show: 'test914LoadClubMech ends'."
	self expect: 47 actual: ( frames size ).
	self assert: ( frames anySatisfy: [:frame | frame isKindOf: HumFrame4Vignette ]).
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test917CreateNounTreeGraph [
	"Create a graph of the base ontology noun tree."
	|  pa  problems diagram ontology dictionaryFrame nodes connections  |
	pa := HumProgrammersAssistant new.
	dictionaryFrame := ReadWriteStream on: ''.
	dictionaryFrame nextPutAll: '===
Dictionary: Party vocabulary.
. Party attributes include name, postal-address, contact-channels, representative.
. Person is a party.
. Person attributes include first-name, last-name, family-name.
. Worker is a person.
. Employee is a worker.
. Organization is a party.
. Representative is a person.
==='.
	dictionaryFrame position: 0.
	pa loadOntologyFromTextStream: (dictionaryFrame).
	"pa loadOntologyFromTextFileNamed: fileName."
	problems := (pa ontology compileAllFrames) asSet. 
	self expect: 0 actual: (problems size) description: 'Test data should have no problems here'.
	"Assign creation of the noun tree to Ontology (HumOntology). 
	 Assign rendering to Ontology-Viewer (HumOntologyViewer)."
	diagram := HumDiagram new.
	ontology := pa ontology.
	ontology view buildDiagramForNoun: 'employee' onDiagram: diagram. 
	nodes := diagram nodes.
	self expect: 11 actual: nodes size.
	connections := diagram connections.
	self expect: 13 actual: connections size.
	
	diagram layoutDiagramWithNodeExtent: 20@20 nodeSpacing: 11@11.
	"diagram inspect."
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test920LoadBaseOntologyAndRenderAsHTMLwithCritique [
	"Load from some-ontology.txt"
	| fileName pa html problems |
	fileName := './ontology/BaseOntology.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	problems := pa ontology compileAllFrames. "HumOntology"

	self assert: ( pa ontology frames anySatisfy: [:frame | frame title beginsWith: 'Comment:']).

	html := pa ontology view renderAsHTMLwithCritique: true withBase: true onFileNamed: './html/test927LoadBaseOntologyAndRenderAsHTMLwithCritique.html'.
	self assert: ('*Base Ontology*' match: html).
	self deny: ('*not been defined*' match: html ) description: 'Some actions have not been defined.'.
	self assert: (problems isEmpty) description: 'There should be no problems in Base Ontology.'.
	self log: 'Think about how Bookkeeper actions get associated with business events.'.
	"Assumption: Business Events are associated with top-level goals.
	When a goal is invoked from a dialog, that is a business event - It should have a job-ticket."
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test921LoadFromTextFileAndRenderAsHTML [
	"Load from pizza-ontology.txt"
	| fileName pa |
	fileName := './ontology/Pizza-Ontology.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	pa ontology compileAllFrames.
	pa ontology view renderAsHTMLonFileNamed: './html/Pizza-Ontology.html'.
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test922LoadDonutShopAndRenderAsHTML [
	"Load from some-ontology.txt"
	| fileName pa |
	fileName := './ontology/DonutShopV06.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	pa ontology compileAllFrames.
	pa ontology view renderAsHTMLonFileNamed: './html/DonutShopV06.html'.
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test923LoadBaristaAndRenderAsHTML [
	"Load from some-ontology.txt"
	| fileName pa |
	fileName := './ontology/Barista.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	pa ontology compileAllFrames.
	pa ontology view renderAsHTMLonFileNamed: './html/Barista.html'.
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test924LoadClubMechAndRenderAsHTML [
	"Load from some-ontology.txt"
	| fileName pa html |
	fileName := './ontology/ClubMechV02.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	pa ontology compileAllFrames.

	self assert: ( pa ontology frames anySatisfy: [:frame | frame title beginsWith: 'Context:']).

	html := pa ontology view renderAsHTMLonFileNamed: './html/test924LoadClubMechAndRenderAsHTML.html'.
	self assert: ('*Context:*' match: html).
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test925LoadClubMechAndRenderAsHTMLwithCritique [
	"Load from some-ontology.txt"
	| fileName pa html problems n |
	fileName := './ontology/ClubMechV02.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	problems := pa ontology compileAllFrames.

	self assert: ( pa ontology frames anySatisfy: [:frame | frame title beginsWith: 'Context:']).

	html := pa ontology view renderAsHTMLwithCritiqueOnFileNamed: './html/test925LoadClubMechAndRenderAsHTMLwithCritique.html'.
	self assert: ('*Context:*' match: html).
	n := problems size.
	self expect: 0 actual: n description: ('There are', ( n asString ),' problems in {', fileName, '}').
	self deny: ('*not been defined*' match: html ) description: 'Some actions have not been defined.'.
	self log: 'Needs work connecting Dialog-Agent *Show* and *Push* and *Ask* with internal frames/sub-frames.'.

	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test926LoadDonutShopAndRenderAsHTMLwithCritique [
	"Load from some-ontology.txt"
	| fileName pa html problems n |
	"TODO: Donut Shop is the original acceptance test. Some aspects look obsolete. Need to review it's assumptions."
	"The acceptance test included these goals:
	- The Donut Shop includes retail and light-manufacturing functions. (to fully test Hum as a business platform)
	- The user interface should be rich enough to support order-entry dialogs and views.
	- The user interface should be rich enough to support billing dialogs and views.
	- The bookkeeping subsystem should track cost-of-goods-sold as a by-product of inventory tracking.
	"
	fileName := './ontology/DonutShopV06.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	problems := pa ontology compileAllFrames.

	self assert: ( pa ontology frames anySatisfy: [:frame | frame title beginsWith: 'Context:']).

	html := pa ontology view renderAsHTMLwithCritiqueOnFileNamed: './html/test926LoadDonutShopAndRenderAsHTMLwithCritique.html'.
	self assert: ('*Context:*' match: html).
	n := problems count: [ :problem | '*Action:*not*defined*' match: problem ].
	self expect: 0 actual: n description: 'Some ', n asString, ' actions are not defined.'.
	n := problems size.
	self expect: 0 actual: n description: 'We do expect problems in this Ontology.'.
	self log: 'This ontology uses a number of advanced features that are not implemented yet.'.

	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test928LoadVROntologyAndRenderAsHTMLwithCritique [
	"Load from some-ontology.txt"
	| fileName pa html problems n |
	fileName := './ontology/VR-Ontology.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	problems := pa ontology compileAllFrames. "HumOntology"
	
	self assert: ( pa ontology frames anySatisfy: [:frame | frame title beginsWith: 'Comment:']).
	
	html := pa ontology view renderAsHTMLwithCritiqueOnFileNamed: './html/test928LoadVROntologyAndRenderAsHTMLwithCritique.html'.
	self assert: ('*VR-Ontology*' match: html).
	n := problems size.
	self expect: 0 actual: n description: 'VR Ontology has ', (n asString),' problems.'.
	self deny: ('*not been defined*' match: html ) description: 'Some actions have not been defined.'.
	"TODO: Think about how Bookkeeper actions get associated with business events."
	"Assume business-event (and job-ticket) starts when a top-level goal is invoked from a dialog vignette. "
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test929LoadMarkupViewAndRenderAsHTMLwithCritique [
	"Load from some-ontology.txt"
	| fileName pa html problems |
	fileName := './ontology/DemoTestMarkup.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	problems := pa ontology compileAllFrames. "HumOntology"

	self assert: ( pa ontology frames anySatisfy: [:frame | frame title beginsWith: 'Comment:']).

	html := pa ontology view renderAsHTMLwithCritiqueOnFileNamed: './html/test929LoadMarkupViewAndRenderAsHTMLwithCritique.html'.
	self assert: ('*Header 1*' match: html).
	self assert: ('*<ol>*' match: html) description: 'Some list lines should be numbered.'.
	self assert: ('*<ol>*</ol>*<hr>*' match: html) description: 'Ordered list should be closed.'.
	self assert: (problems size = 0) description: 'There should be no problems in Markup Test.'.
	"TODO: RESULTING RENDERING HAS ERRORS. THIS TEST NEEDS MORE ASSERTIONS."
	self deny: ('*not been defined*' match: html ) description: 'Some actions have not been defined.'.
self fail.
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test930LoadToDoListAndRenderAsHTMLwithCritique [
	"Load from some-ontology.txt"
	| fileName pa html problems |
	fileName := './ontology/ToDoList-Ontology.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName. "Note: Base ontology will be included first."
	problems := pa ontology compileAllFrames. "HumOntology"
	
	self assert: ( pa ontology frames anySatisfy: [:frame | frame title beginsWith: 'Comment:']).

	html := pa ontology view renderAsHTMLwithCritiqueOnFileNamed: './html/test930LoadToDoListAndRenderAsHTMLwithCritique.html'.
	
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test931LoadBootStrapOntologyAndRenderAsHTMLwithCritique [
	"Load from some-ontology.txt"
	| fileName pa html problems |
	fileName := './ontology/BootStrap-Ontology.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName. "Note: Base ontology will be included first."
	problems := pa ontology compileAllFrames. "HumOntology"

	self assert: ( pa ontology frames anySatisfy: [:frame | frame title beginsWith: 'Comment:']).

	html := pa ontology view renderAsHTMLwithCritiqueOnFileNamed: './html/test931LoadBootStrapOntologyAndRenderAsHTMLwithCritique.html'.
	self assert: ( '*frame-line*attributes*' match: html ).
	
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test944LoadClubMechSaveReload [
	"Load from some-ontology.txt, save it, reload it."
	|  pa fileName frames saveFileName |
	"Transcript cr; show: 'test914LoadClubMech begins'."
	fileName := './ontology/ClubMechV02.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	frames := pa ontology frames.
	self expect: 47 actual: ( frames size ) description: 'Base or Club Mech frame-count changed'.
	self expect: 11 actual: ( pa ontology contextVignettes size ) description: 'Base or Club Mech vignettes changed'..
	self expect: 11 actual: ( frames count: [:frame | frame isKindOf: HumFrame4Vignette ]).
	
	"Save it to another file and reload it from the saved file."
	saveFileName := './data/test944LoadClubMechSaveReload.txt'.
	pa writeOntologyOnTextFileNamed: saveFileName.
	"Load it back - should get same result as before."
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromSaveFileNamed: saveFileName.
	frames := pa ontology frames.
	self expect: 47 actual: ( frames size ) description: 'Reloaded file should match original.'.
	self assert: (pa ontology contextVignettes size > 0).
	self expect: 11 actual: ( frames count: [:frame | frame isKindOf: HumFrame4Vignette ]).
	
	
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test945LoadDonutShopSaveReload [
	"Load from some-ontology.txt, save it, reload it."
	|  pa fileName zFrames saveFileName ontologyA ontologyB |
	fileName := './ontology/DonutShopV06.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	ontologyA := pa ontology. 
	zFrames := pa ontology frames select: [ :frame | frame origin = './ontology/DonutShopV06.txt' ].
	self expect: 83 actual: ( zFrames size ) description: 'Watch for changes'.
	self expect: 52 actual: ( zFrames count: [:frame | frame isKindOf: HumFrame4Action ]).
	self expect: 0 actual: ( zFrames count: [:frame | frame isKindOf: HumFrame4Comment ]).
	self expect: 0 actual: ( zFrames count: [:frame | frame isKindOf: HumFrame4Data ]).
	self expect: 14 actual: ( zFrames count: [:frame | frame isKindOf: HumFrame4Dictionary ]).
	self expect: 3 actual: ( zFrames count: [:frame | frame isKindOf: HumFrame4Plan ]).
	self expect: 5 actual: ( zFrames count: [:frame | frame isKindOf: HumFrame4View ]).
	self expect: 9 actual: ( zFrames count: [:frame | frame isKindOf: HumFrame4Vignette ]).
	
	"Save it to another file and reload it from the saved file."
	saveFileName := './data/test945LoadDonutShopSaveReload.txt'.
	pa writeOntologyOnTextFileNamed: saveFileName.
	"Load it back - should get same result as before."
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromSaveFileNamed: saveFileName.
	ontologyB := pa ontology.
	zFrames := pa ontology frames select: [ :frame | frame origin = './data/test945LoadDonutShopSaveReload.txt' ].
	"Counts should be same as above."
	self expect: 107 actual: ( pa ontology frames size ) description: 'Watch for BaseOntology loaded twice.'.
	"TODO: We lost the origin of the frames when we wrote them out."
	self expect: 107 actual: ( zFrames size ) description: 'Watch for changes'.
	
	
	
	
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> test954LoadClubMechSaveReload [
	"Load from some-ontology.txt, save it, reload it."
	|  pa fileName frames saveFileName |
	"Transcript cr; show: 'test914LoadClubMech begins'."
	fileName := './ontology/ClubMechV02.txt'.
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromTextFileNamed: fileName.
	frames := pa ontology frames.
	self assert: (pa ontology contextVignettes size > 0).
	self expect: 47 actual: ( frames size ) description: 'Watch for changes in test data.'.
	self expect: 11 actual: ( frames count: [:frame | frame isKindOf: HumFrame4Vignette ]).
	
	"Save it to another file and reload it from the saved file."
	saveFileName := './data/test954LoadClubMechSaveReload.txt'.
	pa writeOntologyOnTextFileNamed: saveFileName.
	"Load it back - should get same result as before."
	pa := HumProgrammersAssistant new.
	pa loadOntologyFromSaveFileNamed: saveFileName.
	frames := pa ontology frames.
	self assert: (pa ontology contextVignettes size > 0).
	self expect: 47 actual: ( frames size ) description: 'Number of frames should be preserved.'.
	self expect: 11 actual: ( frames count: [:frame | frame isKindOf: HumFrame4Vignette ]).
	
	
	
]

{ #category : #ui100userEvents }
HumProgrammersAssistantTests >> testU000UserInitiatedEvents [
"Plan for user-initiated events."
"KeyboardEvents:
calc switch: keyCharacter;
	on: { space. period. return.  } do: [ self parseCurrentLine; analyzeCurrentLine; highlightCurrentLine ];
	on: { up. } do: [ self highlightCurrentLine; bumpCursor: (0@-1). ];
	on: { down. } do: [ self highlightCurrentLine; bumpCursor: (0@+1). ];
	on: { $( } do: [ self insert: $); bumpCursor: (-1@0). ];
	on: { $[ } do: [ self insert: $]; bumpCursor: (-1@0). ];
	on: { quote.  } do: [ self insert: quote; bumpCursor: (-1@0). ];
	on: { doubleQuote.  } do: [ self insert: doubleQuote; bumpCursor: (-1@0). ];
	onOtherValuesDo: [ self insert: keyCharacter ].
"
"OntologyUpdateEvents:
- In addition to updating the ontology, update theses diagrams ==> (triggering view updates where view is active).

calc switch: ontologyEvent;
	on: { #newEntityType. #newEntityAttributeSet. #newCategorySet }
											do: [ self updateNounGraph. ];
	on: { #newPrecondition }	do: [ self updatePlanGraph ];
	on: { #newDelegation }		do: [ self updateRoleDependencyGraph ];
	on: { #newPushContext }	do: [ self updateContextFlowGraph ];	
"
"RenameEvents:
When an ontology noun or statement definition is replaced in editor, we need to ask: Should it be replaced everywhere?
- Entity replaced in dictionary statement. (entity renamed)
- Attribute replaced in dictionary statement. (attribute renamed)
- Category replaced in dictionary statement. (category renamed)
- Statement replaced in 'Action: . . .' (action renamed)
- Statement replaced in 'Goal: . . .' (goal renamed)
- View-frame renamed. (view renamed)
- Context-frame renamed. (context renamed)
"
]

{ #category : #ui100userEvents }
HumProgrammersAssistantTests >> testU100KeyBoardEvents [
"KeyboardEvents:
Given: EditFrame is active.
When: User presses key.
Then: Editor notified.
Then: Editor responds . . .

calc switch: keyCharacter;
	on: { space. period. return.  } do: [ self parseCurrentLine; analyzeCurrentLine; highlightCurrentLine ];
	on: { up. } do: [ self highlightCurrentLine; bumpCursor: (0@-1). ];
	on: { down. } do: [ self highlightCurrentLine; bumpCursor: (0@+1). ];
	on: { $( } do: [ self insert: $); bumpCursor: (-1@0). ];
	on: { $[ } do: [ self insert: $]; bumpCursor: (-1@0). ];
	on: { quote.  } do: [ self insert: quote; bumpCursor: (-1@0). ];
	on: { doubleQuote.  } do: [ self insert: doubleQuote; bumpCursor: (-1@0). ];
	onOtherValuesDo: [ self insert: keyCharacter ].
"
"
===
Context: Edit-Frame Active.

U: space.
U: period.
U: return.
. Edit-Frame: Parse current line.
. Edit-Frame: Analyze current line.
. Edit-Frame: Highlight current line.

U: up.
. Edit-Frame: Highlight current line.
. Cursor: Move up one line.

U: down.
. Edit-Frame: Highlight current line.
. Cursor: Move down one line.

U: subtext-start.
. Edit-Frame: Insert subtext-end. (Start key is passed how?)
. Cursor: Move back one column.
===
"

]

{ #category : #ui100userEvents }
HumProgrammersAssistantTests >> testU200NewRelationEvents [
"NewRelationEvents:
- In addition to updating the ontology, update theses diagrams ==> (triggering view updates where view is active).

calc switch: ontologyEvent;
	on: { #newEntityType. #newEntityAttributeSet. #newCategorySet }
											do: [ self updateNounGraph. ];
	on: { #newPrecondition }	do: [ self updatePlanGraph ];
	on: { #newDelegation }		do: [ self updateRoleDependencyGraph ];
	on: { #newPushContext }	do: [ self updateContextFlowGraph ];	
"

]

{ #category : #ui100userEvents }
HumProgrammersAssistantTests >> testU300RenameEvents [
"RenameEvents:
When an ontology noun or statement definition is replaced in editor, we need to ask: Should it be replaced everywhere?
- Entity replaced in dictionary statement. (entity renamed)
- Attribute replaced in dictionary statement. (attribute renamed)
- Category replaced in dictionary statement. (category renamed)
- Statement replaced in 'Action: . . .' (action renamed)
- Statement replaced in 'Goal: . . .' (goal renamed)
- View-frame renamed. (view renamed)
- Context-frame renamed. (context renamed)
"
]

{ #category : #pa900LoadParseCompileView }
HumProgrammersAssistantTests >> text930expected [
	^'<html>
	<head>
		<title>
			(untitled) -- No title yet.
		</title>
		<style>
	 
				body {font-family: MONOSPACE;}
				heading {font-size: X-LARGE; }			
				title1, title2, title3, title4, title5 {font-weight: BOLD;}
				title1 {font-size: 200%;}
				title2 {font-size: 150%;}
				title3 {font-size: 125%;}
				title4 {font-size: 100%;}

				frameTitle {color: BLUE; font-size: LARGER; font-weight: BOLD;}
				
				n, noun {color: PURPLE;}
				k, keyword {font-weight: BOLD;}
				r, role {font-style: ITALIC;font-weight: BOLD;}
				
				statement {color: BLUE;}
				c, comment {color: GREEN;}
				annotation {}
				
				pattern {}
				markup {font-family: MONOSPACE;}
				widget {color: RED;}		
						
				HumFrame {}
				frameLine, CommentLine, DictionaryLine, PreconditionLine  {margin-left: 1em;}
				InstructionLine {margin-left: 1em; color: BLUE;}	
				InstructionLine.indent1 {margin-left: 1em;}		
				InstructionLine.indent2 {margin-left: 2em;}		
				InstructionLine.indent3 {margin-left: 3em;}		
				InstructionLine.indent4 {margin-left: 4em;}		
					
				textarea {vertical-align: top;}	
				form {border-style: outset; padding: 1em;}
				table {}
				th {background: CYAN;}
				td {background: LIGHTGREY;}
				errorNote { color: DARKRED; }
				critiqueLine { color: DARKRED; margin-left: 1em; }
				commentLine { color: DARKGREEN; margin-left: 1em; }
		</style>
	</head>
	<body>
		<heading>
			Ontology: (untitled) -- No title yet.
		</heading>
		<hr/>
		<HumFrame>
			<ActionFrame>
			<frameTitle>
				Role: Order-Checker -- Give carriers to the customer.
			</frameTitle>
			<br/><b>Role: </b>
			<role>
				Order-Checker.
			</role>
			<br/><b>Action: </b>
			<action>
				Give carriers to the customer.
			</action>
			<br/>
			<InstructionLine class="indent1" >
				<statement>
					Match carrier to order.
				</statement>
			</InstructionLine>
			<br/>
			<InstructionLine class="indent1" >
				<statement>
					Move matched carrier to scale.
				</statement>
			</InstructionLine>
			<br/>
			<InstructionLine class="indent1" >
				<comment>
					(This catches most errors with carrier sequencing.)
				</comment>
			</InstructionLine>
			<br/>
			<InstructionLine class="indent1" >
				<statement>
					<k>If</k> scale weight
					matches order` s expected weight:
				</statement>
			</InstructionLine>
			<br/>
			<InstructionLine class="indent2" >
				<statement>
					Release carriers to customer.[ native]
				</statement>
			</InstructionLine>
			<br/>
			<InstructionLine class="indent1" >
				<statement>
					<k>Else</k>:
				</statement>
			</InstructionLine>
			<br/>
			<InstructionLine class="indent2" >
				<comment>
					(Most likely error is that carrier is out of sequence.)
				</comment>
			</InstructionLine>
			<br/>
			<InstructionLine class="indent2" >
				<statement>
					Check for carrier-sequence-error.
				</statement>
			</InstructionLine>
			<br/>
			<InstructionLine class="indent2" >
				<comment>
					(Now what?)
				</comment>
			</InstructionLine>
			</ActionFrame>
		</HumFrame>
		<hr/>
	</body>
</html>
'.
]
