"
HumOntology is similar to a Smalltalk image file.
It records the frames that make up the source code.
It also tracks the relationships between syntax elements.

Instance Variables:
	fromFile	        <String>	-- The name of the file where this ontology was last stored (read).
	nouns	        	<Set>		-- The nouns known in this ontology
	nounSubtypes	  <Set>		-- The subtype relations between nouns 
												-- set of ( supertype -> suptype)  associations
	entityAttributes  <Set>		-- The attributes of those nouns that represent entity names 
													-- set of ( entity -> attribute )
	roles	          	<Set>		-- The roles defined in this ontology 
	roleActions  	  <Set>		-- The actions of the roles 
													-- set of ( role -> actionStatement )
	instructionSequences   <Dictionary>	-- The instructions that define the actions
	framesByName	          <Dictionary>	-- frames indexed by name
	framesByIdentifier	    <Dictionary>	-- frames indexed by their unique ID
			
(An ontology is held in a single file much like the code in a Smalltalk image.)
(However, an ontology does not hold run-time state.) 
An ontology has a set of frames.
Token attributes include string.
Token types include word, noun, punctuation, keyword, comment, annotation.
Frame attributes include frame-title, framelines.
Frame types include goal-frame, action-frame, dialog-frame, view-frame, dictionary-frame.
Frameline attributes include source, tokens, label, comment.
Frameline types include title-line, action-line, precondition-line, markup-line, instruction-line, vignette-line, dictionary-line.
Instruction-line attributes include role, statement, comment, annotation.
Precondition-line attributes include precondition, commment, annotation.
A precondition is a statement.
Title-line attributes include label, title, comment. (no annotation)
Statement attributes include source, nouns, tokens.
Noun attributes include word, supertypes.
Noun types include string, category, collection, date, measure, entity, name. (class types)
Collection types include set, list. (A collection is a list by default)
Measure attributes include quantity, unit-of-measure, distribution, precision.
Entity attributes include attributes.
Entity-instance attributes include name, values.
Value attributes include name, datum.
Datum types include string, category, collection, date, measure, entity, name. (instance types)
A supertype is a noun.

"
Class {
	#name : #HumOntology,
	#superclass : #Object,
	#instVars : [
		'nouns',
		'nounSubtypes',
		'entityAttributes',
		'roles',
		'roleActions',
		'fromFile',
		'framesByName',
		'framesByIdentifier',
		'nounReferences',
		'contextVignettes',
		'title',
		'frames',
		'frameRelations',
		'viewer',
		'translator',
		'attributeChain',
		'nounCategories',
		'debug',
		'contexts',
		'nounSynonyms'
	],
	#category : #'Hum-Language'
}

{ #category : #'instance creation' }
HumOntology class >> baseOntology [
	"Return a base ontology -- See also: BaseOntology.txt."
	| base  pa |
	pa := HumProgrammersAssistant new.
	base := pa loadOntologyFromSaveFileNamed: './ontology/BaseOntology.txt'.
	^base.
]

{ #category : #'instance creation' }
HumOntology class >> baseOntologyOld [
	"Return a base ontology -- See also: BaseOntology.txt."
	| base dummyAction |
	base := HumOntology new.
	"TODO: Load base-ontology from a text file."
	"TODO: Add base nouns and frames to the base ontology."
	"The base vocabulary includes: 
	  order, order item, bill-of-material, material, part, assembly, 
	  container, person, worker, employee, organization, roles, 
	  measure, metric, money, cost, price, account, 
	  resource, resource-pool, inventory, 
	  and more".
	base
		addEntity: 'order' attributes: #( 'order-items' );
		addEntity: 'party' attributes: #( 'email' 'name' 'roles' );
		addEntity: 'person' attributes: #( 'first-name' 'last-name' );
		addNoun: 'organization' isA: 'party';
		addNoun: 'organisation' isA: 'organization';		"synonym"
	  addEntity: 'organization' attributes: #( 'members');
		addNoun: 'member' isA: 'party'; "Creates a loop in the noun graph!!!!"
		addNoun: 'person' isA: 'party';
		addNoun: 'worker' isA: 'person';
		addNoun: 'employee' isA: 'worker';
		addEntity: 'measure' attributes: #('quantity' 'unit-of-measure' 'precision' 'methodology' ).
		 
	"TODO: Add action frames for HumDialogAgent ?
	- Ask viewName.
	- Show viewName.
	- New entityType."
	base addNoun: 'view' isA: 'name'. 
	dummyAction := HumFrame4Action ontology: base role: 'DialogAgent' action: 'Ask view.'.
	dummyAction appendInstructionStatement: 'Dummy statement.'.
	"TODO: Finalize syntax for translations."
	dummyAction compileToOntology: base.
	
	 ^base.
]

{ #category : #'instance creation' }
HumOntology class >> nounAsCamelCase: aString [ 
	| tokens result |
	tokens := aString substrings: '-'.
	result := ''.
	tokens do: [ :token |
		(result = '') 
			ifTrue: [ result := token] 
			ifFalse: [ result := result, (token capitalized )].
		].
	^result.
]

{ #category : #'instance creation' }
HumOntology class >> title: aString [
	"Create an instance with the given title."
	| instance |
	instance := self new.
	instance title: aString.
	^instance.
	
]

{ #category : #'instance creation' }
HumOntology class >> tokensInString: aString [
	"Return the tokens in the statement as an array of strings."
	| punctuation whiteSpace tokens quote apostrophe |

	"Punctuation does not include hyphen because nouns may be hypenated."
	quote := $' asString.
	apostrophe := $` asString.
	punctuation := '~!@#$%^&*()_+={}|[[]\:";<>?,./', quote. ", apostrophe."
	"Apostrophe (`) is treated as part of a word? (possessive contraction)"
	"WARNING: Hum has a quirk: Accent (`) is used as apostrophe. Avoid complication distinguishing uses of single-quote."

	"White space includes space, cr, tab."	
	whiteSpace := ' 	
		'.

	"Tokens are all lower-case and include punctuation."
	tokens := ( aString asLowercase ) findTokens: ( punctuation, whiteSpace ) keep: punctuation.
	^tokens.
]

{ #category : #'about Roles and Actions' }
HumOntology >> actionsOf: aRole [
	"The actions of a role define its public interface. (API).
	NOTE: Statements prefixed with: 'To: ' name private methods. 
	"
      ^self projectValuesOf: (self roleActions) from: (aRole capitalized).
]

{ #category : #'about Nouns' }
HumOntology >> addEntity: anEntity attribute: anAttribute [ 
      "Define these nouns and their relationship."
	| lcEntity lcAttribute |
	lcEntity := anEntity asLowercase.
	lcAttribute := anAttribute asLowercase.
	self addNoun: lcEntity.
	self addNoun: lcAttribute.
	"Add entity-attribute relationship."
	self entityAttributes add: ( lcEntity -> lcAttribute ).
]

{ #category : #'about Nouns' }
HumOntology >> addEntity: anEntity attributes: anAttributeCollection [ 
      "Define these nouns and their relationship."
 | entityName |
	entityName := anEntity asLowercase.
	self addNoun: entityName.
	anAttributeCollection 
		do: [ :anAttribute | 
			self addEntity: anEntity attribute: anAttribute.
			].

]

{ #category : #'about Nouns' }
HumOntology >> addNoun: aNoun [ 
	"Remember noun."
	| singularNoun |
	self assert: (aNoun isKindOf: String).
	(#('a' 'an' 'the') includes: (aNoun)) 
		ifTrue: [ "Error signal: 'Attempt to add article as noun.' "
			^self.
			].
	"Watch for parsing bug -- NOTE: category nouns are not strings."
	(aNoun at: 1) isLetter ifFalse: [ Error signal: 'noun must start with a letter.' ].
	"Watch for parsing bug where noun includes a space."
	( '* *' match: aNoun) ifTrue: [ Error signal: 'noun {', aNoun ,'} contains a space' ].
	
	singularNoun := self singularFormOfNoun: aNoun.
	self nouns add: singularNoun.
	"Check if noun has an implied supertype."
	self setAutomaticSupertypeForNoun: singularNoun.
	
]

{ #category : #'about Nouns' }
HumOntology >> addNoun: aSubType isA: aSuperType [ 
      "Add these nouns and add is-A relation."
	| theNoun theSuperType |
	theNoun := aSubType asLowercase.
	theSuperType := aSuperType asLowercase.
	"Add these nouns in case they are not already added."
	self addNoun: theNoun.
	self addNoun: theSuperType.
	"Add inverse relation -- Note: subtypes is also a Set."
	self nounSubtypes add: ( theSuperType -> theNoun).
	
]

{ #category : #'about Nouns' }
HumOntology >> addNoun: aNoun isDerivedFrom: anotherNoun [
	 self log: 'This ontology uses advanced features that have not been implemented yet.'
	
]

{ #category : #'about Nouns' }
HumOntology >> addNoun: aSynonym isSynonymFor: aStandardNoun [ 
   "Add these nouns and add is-A relation."
	| theNoun theSynonym |
	theNoun := aStandardNoun asLowercase.
	theSynonym := aSynonym asLowercase.
	"Add these nouns in case they are not already added."
	self addNoun: theNoun.
	self addNoun: theSynonym.
	"Add inverse relation -- Note: subtypes is also a Set."
	self nounSynonyms add: ( theSynonym -> theNoun).
	
]

{ #category : #'about Nouns' }
HumOntology >> addNoun: aNounString reference: aFrameLine [ 
	"Remember where nouns are referenced."
	(self nounReferences ) add: ( aNounString -> aFrameLine ).
]

{ #category : #'about Nouns' }
HumOntology >> addNouns: anArrayOfNouns [ 
	
	anArrayOfNouns do: [ :noun | self addNoun: noun ].
]

{ #category : #'about Plans and Conditions' }
HumOntology >> addPlanFrame: aPlanFrame ForGoal: aGoalString [ 
	"Store frame as a plan frame - index as needed."
	| |
	self assert: ( aPlanFrame isKindOf: HumFrame4Plan ).
	self storeFrame: aPlanFrame.
	
]

{ #category : #'about Roles and Actions' }
HumOntology >> addRole: aRole [ 
	self assert: (aRole isKindOf: String ).
	self roles add: aRole capitalized.
]

{ #category : #'about Vignettes' }
HumOntology >> addVignette: aFrame4Vignette toContext: aContext [ 
	"Add to store"
	| contextKey association  |
	contextKey := self cleanKey: aContext.
	association := ( contextKey -> aFrame4Vignette ).
	(self contextVignettes includes: association ) ifTrue: [ ^self ]. "Avoid duplicates."
	
	( self contexts ) add: contextKey.
	( self contextVignettes ) add: association.
	
	"frame defines context"
	self indexFrame: aFrame4Vignette relation: #definesContext object: contextKey.
]

{ #category : #'about Nouns' }
HumOntology >> allAttributesOfEntity: anEntity [ 
	"Get the attributes, the attributes of the attributes, and the attributes of the supertypes."
	| allAttributes localAttributes tempAttributes localSupertypes localProperties entity |
	(self attributeChain includes: anEntity) ifTrue: [ ^Set new. "Return empty set to terminate cycle." ].
	self attributeChainPush: anEntity.
	entity := anEntity asLowercase.
	self assert: (entity sameAs: anEntity).
	"Get the immediate properties of this entity."
	localAttributes := self immediateAttributesOfEntity: anEntity.
	self assert: (( localAttributes include: anEntity ) not ) description: 'An entity should not be an attribute of itself.'.
	localSupertypes := self immediateSupertypesOf: anEntity.
	self assert: (( localSupertypes include: anEntity ) not ) description: 'An entity should not be a supertype of itself.'.
	
	"Entity properties include attributes and supertypes."
	localProperties := localAttributes, localSupertypes.
	self assert: ( localProperties include: anEntity ) not.
	
	"For each local property: Look up attributes and add them to the result set."
	allAttributes := localAttributes.
	self assert: ( allAttributes include: anEntity ) not.
	localProperties 
		do: [ :eachProperty |
			"RECURSIVE CALL !!!"
			tempAttributes := self allAttributesOfEntity: eachProperty.
			allAttributes := allAttributes, tempAttributes.
			"Detect cycles in the tree."
			( allAttributes include: anEntity ) 
				ifTrue: [ Error signal: 'noun attribute-tree contains cycle at: ', anEntity ].
			 ].
	self attributeChainPop: anEntity.	
	^allAttributes
	
]

{ #category : #'about Nouns' }
HumOntology >> allSubtypesOf: aSuperType [ 
	"Get the subtypes (if any) of this noun and the subtypes of the subtypes all the way down"
	| localSubtypes tempSubtypes allSubtypes |
	localSubtypes := self immediateSubtypesOf: aSuperType asLowercase.
	allSubtypes := localSubtypes.
	localSubtypes 
		do: [ :eachSubtype | 
			"RECURSION: Get the subtypes for each of those subtypes."
			tempSubtypes := self allSubtypesOf: eachSubtype.
			"Merge the sets"
			allSubtypes := allSubtypes, tempSubtypes. 
			"Detect cycles in the tree."
			( allSubtypes includes: aSuperType ) 
				ifTrue: [ Error signal: 'noun subtype-tree contains a cycle at: ', aSuperType ].
		 	].
	"Return the merged set of all subtypes."	
	^allSubtypes.
]

{ #category : #'about Nouns' }
HumOntology >> allSupertypesOf: aSubType [ 
	"Get the Supertypes (if any) of this noun and the Supertypes of the Supertypes all the way down"
	| localSupertypes tempSupertypes allSupertypes |
	localSupertypes := self immediateSupertypesOf: aSubType asLowercase.
	allSupertypes := localSupertypes.
	localSupertypes 
		do: [ :eachSupertype | 
			"RECURSION: Get the Supertypes for each of those Supertypes."
			tempSupertypes := self allSupertypesOf: eachSupertype.
			"Merge the sets"
			allSupertypes := allSupertypes, tempSupertypes. 
			"Detect cycles in the tree."
			( allSupertypes includes: aSubType ) 
				ifTrue: [ Error signal: 'noun Supertype-tree contains a cycle at: ', aSubType ].
		 	].
	"Return the merged set of all Supertypes."	
	^allSupertypes.
]

{ #category : #'about Roles and Actions' }
HumOntology >> appendInstruction: aHumInstruction toRole: aRole action: anAction [ 
	"Append the given instruction to the action's sequence of instructions."
	| sequence instruction actionString actionFrame |	
	self assert: ( aRole isKindOf: String ).
	actionString := (anAction isKindOf: String ) ifTrue: [ anAction ] ifFalse: [ anAction asString ].
	self assert: ( actionString isKindOf: String ).	
	instruction := aHumInstruction copy.
	( instruction isKindOf: String ) ifTrue: [ instruction := HumInstructionLine statement: aHumInstruction ].	
		
	"Get the sequence of instructions belonging to this role action."
	actionFrame := self getFrameForRole: aRole capitalized action: actionString. 
	sequence := actionFrame frameLines.
	
	"Append the given instruction to the sequence."
	sequence add: instruction.
	
	"Assure that the data store is updated."
	self storeFrame: actionFrame.
]

{ #category : #'about Roles and Actions' }
HumOntology >> appendRole: aRole action: actionStatement [ 
   "Add role and action statement."
   | capRole |
	Error signal: 'Use indexRole: aRole action: actionStatement.'.
	self assert: ( aRole isKindOf: String ).
	self assert: ( actionStatement isKindOf: HumStatement ).
	"Assure role is in set."
	capRole := aRole capitalized.
	self addRole: capRole.
	
	"Assure statement is in set."
	self roleActions add: ( capRole -> actionStatement ).
]

{ #category : #accessing }
HumOntology >> asString [
	| s |
	s := (self class name), '( ', (self title), ' )'.
	^s
]

{ #category : #'about Nouns' }
HumOntology >> attributeChain [
	^attributeChain ifNil: [ attributeChain := Stack new.]
]

{ #category : #'about Nouns' }
HumOntology >> attributeChainPop: anAttribute [ 
  self assert: (self attributeChain top) = anAttribute.
	self attributeChain pop.
]

{ #category : #'about Nouns' }
HumOntology >> attributeChainPush: anAttribute [ 
	self assert: ((self attributeChain) includes: anAttribute ) not. 
	(self attributeChain) push: anAttribute.
	 
]

{ #category : #'about Plans and Conditions' }
HumOntology >> buildPlanTreeForGoal: aGoal indent: anIndentLevel [
	"Build a list of associations: ( goalStatement -> { anIndentLevel. precondition statement.} )"
	| goalStatement planTree subTree rootFrame |
	goalStatement := HumStatement from: aGoal.
	planTree := OrderedCollection new.
	rootFrame := self getPlanFrameForGoal: aGoal.
	"Stop building the plan subtree if the root frame is not defined."
	( rootFrame isNoPlan ) ifTrue: [ ^planTree ].
	
	( rootFrame preconditions )
		do: [ :precondition |
			planTree add: ( goalStatement -> { anIndentLevel. precondition statement.} ).
			subTree := self buildPlanTreeForGoal: (precondition statement) indent: (anIndentLevel + 1).
			planTree := planTree, subTree.
			"Detect a cycle in the tree."
			( planTree anySatisfy: [ :map |  (map value at: 2) = goalStatement ] ) 
				ifTrue: [ Error signal: 'cycle detected in plan tree' ].
			].		
	^planTree.
]

{ #category : #'about Nouns' }
HumOntology >> categoriesOf: anAttributeName [ 
	| categories |
	^categories := (self nounCategories) at: anAttributeName ifAbsent: [Set new].
]

{ #category : #'about Nouns' }
HumOntology >> categoriesOf: anAttributeName include: anArrayOfCategoryNames [
	"Add this noun in case it is not already added;"
	"and make it a kind of category"
	| setOfCategories attribute |
	attribute := anAttributeName trimBoth asLowercase. 
	self addNoun: attribute isA: 'category'.
	setOfCategories := self categoriesOf: attribute.
	anArrayOfCategoryNames 
		do: [:category | 
				setOfCategories add: category. 
				self addNoun: category. 
				].
	(self nounCategories) at: attribute put: setOfCategories.
	
]

{ #category : #parsing }
HumOntology >> checkNounStringSyntax: aNounString [ 
	"Check for parsing errors."
	self assert: ('* *' match: aNounString) not description: 'noun-string should not contain a space.'.
]

{ #category : #'about Plans and Conditions' }
HumOntology >> checkPlanTreeForGoal: aGoal [ 
	| goalStatement planTreeProblems subTreeProblems rootFrame planFrame |
	"Check for problems that would prevent the plan from working."
	goalStatement := HumStatement from: aGoal.
	planTreeProblems := OrderedCollection new.
	
	"Safety check -- >>buildPlanTreeForGoal: . . . will stop execution if there is a cycle in the plan-tree."
	self buildPlanTreeForGoal: aGoal indent: 0.

	rootFrame := self getPlanFrameForGoal: goalStatement.
	(rootFrame isNoPlan) 
		ifTrue: [ planTreeProblems add: 'Precondition: {', ( goalStatement asString ), '} has no plan frame.'. 
						^ planTreeProblems ].
	
	" Look for preconditions that have no corresponding plan frame in the ontology."
	( rootFrame preconditions )
		do: [ :precondition |
			planFrame := self getPlanFrameForGoal: precondition statement.
			planFrame ifNil: [ planTreeProblems add: 'Precondition: {', ( precondition statement asString ), '} has no plan frame.' ].
			subTreeProblems := self checkPlanTreeForGoal:   ( precondition statement ).
			planTreeProblems := planTreeProblems, subTreeProblems.
			].		
				
	^planTreeProblems.
]

{ #category : #'about Nouns' }
HumOntology >> cleanKey: aString [
	"Assure that the string will be a clean key -- convert to lower-case, trim blanks."
	| camelCase |
	camelCase := HumCalculator camelCase: aString.
	^camelCase.
]

{ #category : #'translate to' }
HumOntology >> codeGenerator [
	"Return a translator."
	^translator 
		ifNil: [ 
			"Precondition: Assure we are compiled."
			self compileAllFrames.
			"TODO: This 'Assure we are compiled.' strategy will fail 
			       when the ontology is updated between translations."
			"Post condition: translator is set."
			translator := HumOntologyTranslator ontology: self. 
			].
]

{ #category : #'about Plans and Conditions' }
HumOntology >> collectPlanFramesForGoal: aGoalStatement [ 
	"| goalStatement planTree subTree rootFrame |
	goalStatement := HumStatement from: aGoal.
	planTree := OrderedCollection new.
	rootFrame := self getPlanFrameForGoal: aGoal.
	( rootFrame preconditions )
		do: [ :precondition |
			planTree add: ( goalStatement -> (precondition statement) ).
			subTree := self buildPlanTreeForGoal: (precondition statement).
			planTree := planTree, subTree.
			( planTree anySatisfy: [ :map |  map value = goalStatement ] ) 
				ifTrue: [ Error signal: 'cycle detected in plan tree' ].
			].		
	^planTree."
	| problems rootFrame frameCollection subSet |
	"First check to make sure the plan frames are complete."
	problems := self checkPlanTreeForGoal:  aGoalStatement.
	problems isEmpty
		 ifFalse: [ Error signal: 'There are problems with the plan tree for goal: ', (aGoalStatement asString)
			                                , String cr, ' Problems: ', problems asString. ].
	"Collect the plan frames."
	frameCollection := Set new.
	rootFrame := self getPlanFrameForGoal: aGoalStatement.
	frameCollection add: rootFrame.
	( rootFrame preconditions )
		do: [ :precondition |
			subSet := self collectPlanFramesForGoal: (precondition statement).
			frameCollection addAll: subSet.
			].
	^frameCollection.
]

{ #category : #'about Frames' }
HumOntology >> compileAllFrames [
	"Compile the dictionary frames first, then the others." 
	| dictionaryFrames otherFrames problems frameProblems |
	"Return any problems found."
	problems := OrderedCollection new.
	"Reset the frame index"
	frameRelations := nil.
	
	"Compile the dictionary frames first."
	dictionaryFrames := (self frames) select: [:frame | frame isKindOf: HumFrame4Dictionary ].
	dictionaryFrames
		do: [ :frame | 
			frameProblems := frame compileToOntology: self. 
			problems addAllLast: frameProblems.
			].
		
	"Compile the remaining frames."
	otherFrames := (self frames) select: [:frame | (frame isKindOf: HumFrame4Dictionary) not ].
	otherFrames
		do: [ :frame | 
			frameProblems := frame compileToOntology: self. 
			problems addAllLast: frameProblems.
			].
		
	^problems.

]

{ #category : #'about Vignettes' }
HumOntology >> contextVignettes [
	"This list holds the (1:M) relation (context -> vignette)."
	contextVignettes ifNil: [ contextVignettes := OrderedCollection new. ].
	"Vignettes are evaluated in the order seen."
	"TODO: Decide if we need a priority attribute on a vignette to enable re-ordering." 
	self assert: (contextVignettes isKindOf: OrderedCollection ).
	^contextVignettes.
]

{ #category : #'about Vignettes' }
HumOntology >> contexts [
	^ contexts ifNil: [  contexts := Set new. ]
]

{ #category : #'about Roles and Actions' }
HumOntology >> critiqueRole: aRole action: anAction [
	"Critique the instructions for this role action."

	| critique actionStatement sequence actionNouns instructionNouns |
	"Return the critique as a sequence of strings."
	critique := OrderedCollection new.

	"The action should contain at least one noun."
	actionStatement := self getRole: aRole action: anAction.
	actionNouns := self nounsInStatement: actionStatement.
	actionNouns size > 0
		ifFalse: [ critique add: 'Action Statement has no known nouns.' ].

	"There should be at least one instruction for the action statement."
	sequence := self instructionsForRole: aRole action: anAction.
	sequence size > 0
		ifFalse: [ critique add: 'Action has no instructions.' ].

	"Nouns in the instructions should find antecedants in the action statement."
	sequence
		do: [ :instruction | 
			instructionNouns := self nounsInStatement: instruction statement.
			(actionNouns includesAll: instructionNouns)
				ifFalse: [ critique
						add: 'Some nouns lack antecedants in: ' , instruction statement source ] ].
	^ critique
]

{ #category : #debugging }
HumOntology >> debug [
	"Am I in debug mode?"
	^ debug ifNil: [debug := false].
]

{ #category : #'about Nouns' }
HumOntology >> entityAttributes [
	"This instance variable is a map, a set of associations ( anEntity -> anAttribute )"
	^entityAttributes ifNil: [ entityAttributes := Set new.].
]

{ #category : #'about Frames' }
HumOntology >> fetchFrameByIdentifier: aPrimaryKey [ 
	"Fetch the frame with this identifier."
	| frame |
	frame := ( self framesByIdentifier ) at: aPrimaryKey ifAbsent: [ Error signal: 'No such frame in this ontology!'].
	^frame.
]

{ #category : #'about Frames' }
HumOntology >> fetchFrameByName: aString [ 
	| frame |
	self assert: (aString isKindOf: String).
	"self assert: (aString endsWith: '.')."
	frame := (self framesByName ) at: aString ifAbsent: [ Error signal: 'No frame by this name.'].
	^frame.
]

{ #category : #accessing }
HumOntology >> file [
	^ fromFile ifNil: [ fromFile := 'HumOntologyFile.ontology' ].
]

{ #category : #accessing }
HumOntology >> file: aString [ 
	fromFile := aString.
]

{ #category : #'about Vignettes' }
HumOntology >> findBestMatchingVignetteForInput: aString inContextStack: aStack [ 
	"Search the vignette frames for the one whose pattern is the best match
	for the given input and context-stack."
	| bestMatch stackCopy bestMatchScore |
	self assert: ( aString isKindOf: String ).
	self assert: ( aStack  isKindOf: Stack ).
	self assert: ( aStack notEmpty ).
	"We want the best match with a score better than zero."
	bestMatchScore := 0.
	aStack
		do: [ :contextString |
			"See if we have any vignettes that match that context."
			| vignettesInContext |
			vignettesInContext := self vignettesForContext: contextString.
			"Get the bestMatch from that set."
			vignettesInContext
				do: [ :candidate |
					| score |
					score := candidate patternMatchScore: aString.
					( score > bestMatchScore)
							ifTrue: [ bestMatch := candidate. 
								        bestMatchScore := score. 
								     ].
					].
			].
	( bestMatchScore = 0 )
			ifTrue: [ bestMatch := self hasNoVignetteMatchFor: aString. ].
	^ bestMatch.
]

{ #category : #'about Frames' }
HumOntology >> frameRelations [
	"The cross index collection tracks relationships between frames."
	"Entries have the form: { frameA. #symbol. frameB. }
	  where the frames are identified by their titles.
	 Cases:
		- { frameA.    #invokes. actionB. }  ( frameA may be action, plan, or vignette. )
		- { vignetteA. #stacks. contextB. }
		- { goalA.     #requires.  goalB. }  ( This very like plan tree. )
	"
	^ frameRelations ifNil: [ frameRelations := Set new. ].
]

{ #category : #'about Frames' }
HumOntology >> frameRelationsWhere:  aBlock [
	"Return frame relations where aBlock evaluates as true"
	| selectedRelations |
	selectedRelations := self frameRelations 
			select:  [ :frameRelation |
				| a r b |
				a := frameRelation at: 1.
				r := frameRelation at: 2.
				b := frameRelation at: 3.
				aBlock value: a value: r value: b ].
	^selectedRelations.
]

{ #category : #'about Frames' }
HumOntology >> frames [
	^ frames ifNil: [ frames := Set new. ].
]

{ #category : #'about Frames' }
HumOntology >> framesByIdentifier [
	"Each frame is given a unique identifier. 
	This store indexes the frames their identifiers."
	^ framesByIdentifier ifNil: [ framesByIdentifier := Dictionary new. ].
]

{ #category : #'about Frames' }
HumOntology >> framesByName [
	"Enable access to frames by their name (title line string)."
	^ framesByName ifNil: [ framesByName := Dictionary new ].
]

{ #category : #'about Frames' }
HumOntology >> fromFile [
	"The file name serves as a natural identifier. "
	^ fromFile ifNil: [ ^ '(untitled)' ].
]

{ #category : #'about Nouns' }
HumOntology >> getEntityAttributePhraseFromStatement: aHumStatement [ 
	"Return collection of 'entity attribute' pairs when statement contains possessive nouns."
	| remainder  pairs |
	pairs := OrderedCollection new.
	remainder := aHumStatement source.
	['*`s *' match: remainder]
		whileTrue: [  "Get the first entity and the attribute pair"
			| entity attribute front back tokens |
			front := HumCalculator given: remainder  extractUpto: '`s '.
			back := HumCalculator given: remainder  extractAfter: '`s '.
			tokens := HumCalculator findTokensInString: front.
			entity := tokens last.
			tokens := HumCalculator findTokensInString: back.
			attribute := tokens first.
			remainder := HumCalculator given: back extractAfter: attribute.
			pairs add: (entity, ' ', attribute).
			"TODO: Perhaps we should put '`s' in the pair. Leave a clue, other than the space, for other processes."
			].
	^pairs.
]

{ #category : #'about Roles and Actions' }
HumOntology >> getFrameForRole: aRole action: anAction [ 
	"Get the frame that matches given role and action."
	| frame  |
	"TODO: Kludge some polymorphism.
	 TODO: Fix-up string arguments"	

	(self roleActions)
		do: [:map | 
			| role frameAction |
			role := map key.
			frameAction := map value.
			self assert: (role = (role capitalized)) description: 'Watch for index bug.'.
			( (role sameAs: aRole) 
			  and: [frameAction matchesCandidateStatement: anAction inOntology: self])
					ifTrue: ["Get the frame. If it does not exist, make it."
						| frameKey |
						frameKey := 'Role: ',aRole,' -- ',(frameAction source).
						frame := (self framesByName) at: frameKey 
						                  ifAbsent: [ "Make and store an action frame."
																frame := HumFrame4Action ontology: self role: role action: frameAction.
							 									self storeFrame: frame.
																frame.
																].
						^frame.
						].
			].
	"If no frame is found/generated (will happen for a new role), return an empty frame."
	frame ifNil: [frame := HumFrame4Action ontology: self role: aRole action: anAction.].
	self assert: (frame isKindOf: HumFrame4Action) .
	^frame.
]

{ #category : #'about Vignettes' }
HumOntology >> getFramesThatDefineContext: aContextName [ 
	"Get the vignette frames that define the given context."
	| resultSet |
	resultSet := Set new.
	
	resultSet := self frames select: [ :frame | (frame isKindOf: HumFrame4Vignette) and: [ frame vignetteContext sameAs: aContextName ]   ].

	^resultSet.
]

{ #category : #'about Roles and Actions' }
HumOntology >> getFramesThatInvokeAction: anActionString [ 
	"Lookup the frames where action is invoked."
	| resultSet  |
	resultSet := self getFramesWithRelation: #invokesAction object: anActionString.
	^ resultSet.
]

{ #category : #'about Frames' }
HumOntology >> getFramesThatInvokeContext: aContextName [ 
	"Get frames with 'Push context <aContextName>.'  instructions."
	| resultSet |
	resultSet := self getFramesWithRelation: #invokesContext object: aContextName.
	^resultSet.
]

{ #category : #'about Plans and Conditions' }
HumOntology >> getFramesThatInvokePrecondition: aStatementString [ 
	"Lookup the frames where precondition is invoked."
	| resultSet  |
	resultSet := self getFramesWithRelation: #precondition object: aStatementString.
	^ resultSet.
]

{ #category : #'about Views' }
HumOntology >> getFramesThatInvokeView: aViewName [
	"A view may be invoked by another view or by a vignette."
	| resultSet |
	"Compiler will scan views to index [pane: ...] pattern. " 
	
	"Compiler will scan vignettes to index instructions 'Show <viewname>.' and 'Ask <viewname>.'"

	resultSet := self getFramesWithRelation: #invokesView object: aViewName.	
	^resultSet.
	
]

{ #category : #'about Frames' }
HumOntology >> getFramesWithRelation: aSymbol object: aName [
	"Get frames that are indexed with given relation and object."
	| resultSet |
	resultSet := Set new.
	
	(self frameRelations select: [:tuple | (tuple at: 2) = aSymbol])
		do: [ :relation |		"Relation looks like { frameTitle. relationSymbol. someString. }"
			| subject verb object |
			subject := relation at: 1.
			verb := relation at: 2.
			object := relation at: 3.
			(( verb = aSymbol ) and: [ object = (aName trimBoth asLowercase) ])
					ifTrue: [ resultSet add: subject. ].
			].
	^resultSet.

]

{ #category : #'about Plans and Conditions' }
HumOntology >> getPlanFrameForGoal: aGoalString [ 
	| frame key |
	key := 'Goal: ', aGoalString asString.
	frame := (self framesByName ) 
							at: key
							ifAbsent: [ "Return an empty planFrame." 
								^ HumFrame4Plan ontology: self goal: (aGoalString asString).
								].
	self assert: ( frame isKindOf: HumFrame4Plan ).
	^frame.
	
]

{ #category : #'about Roles and Actions' }
HumOntology >> getRole: aRole action: aStringOrStatement [ 
	"Get the action if it already exists."
	| actionStatement |
	"TODO: Kludge some polymorphism.
	 TODO: Fix-up string arguments"	

	"Assure that we are dealing with a HumStatment."
	actionStatement := aStringOrStatement copy.
	( actionStatement isKindOf: HumStatement ) 
		ifFalse: [ actionStatement := HumStatement from: aStringOrStatement ].
	"If the role action set already contains the action statement,
	    return an equivalent statement.
	"	
	(self roleActions include: ( ( aRole capitalized ) -> actionStatement ) ) 
		ifFalse: [ "The role does not currently define a proper match"
			"TODO: Refactor to handle polymorphism."
			self error: 'Attempt to get a non-existent action statement.'. 
			^nil ].
	^actionStatement.
]

{ #category : #'about Views' }
HumOntology >> getViewFrame: nameString [ 
	"Get the view frame with the given name."
	| frame viewName |
	viewName := nameString.
	(viewName endsWith: '.') ifTrue: [viewName := nameString copyFrom: 1 to: ((nameString size) - 1)].
	frame := ( self framesByName ) 
						at: ('View: ', viewName trimBoth capitalized,'.')
						ifAbsent: ["If none, make one."
							Error signal: 'No such view as: ', viewName.
							frame := HumFrame4View ontology: self viewEntity: viewName.
							].
	^frame.
]

{ #category : #'about Vignettes' }
HumOntology >> hasNoVignetteMatchFor: aString [ 
	| defaultVignette |
	(self debug) ifTrue: [Error signal: 'No vignette pattern match for {',aString,'}'].
	defaultVignette := HumFrame4Vignette ontology: self vignetteContext: 'any' pattern: aString trimBoth.
	defaultVignette addVignetteResponse: ('Sorry, { ', aString, '} is not understood.').
	^ defaultVignette.
]

{ #category : #'about Nouns' }
HumOntology >> immediateAttributesOfEntity: anEntity [ 
	^ self projectValuesOf: (self entityAttributes) from: anEntity.
]

{ #category : #'about Nouns' }
HumOntology >> immediateSubtypesOf: aSuperType [ 
	"Get the subtypes (if any) of this noun."
	^ self projectValuesOf: (self nounSubtypes) from: aSuperType.
]

{ #category : #'about Nouns' }
HumOntology >> immediateSupertypesOf: aNoun [
	"Get the immedate supertypes (if any) for this noun." 
	| mapSet supertypes |
	"Initialize the result set."
	supertypes := Set new.
	"for each map ( supertype -> subtype ):"
	mapSet := self nounSubtypes.
	mapSet 
		do: [ :nounSubtype |
			( nounSubtype value = aNoun )
				ifTrue: [ supertypes add: nounSubtype key ].
			].
	^supertypes.
]

{ #category : #'about Frames' }
HumOntology >> indexFrame: aFrame [
	| calc |
	"Create index entries for the frame."
	calc := HumCalculator new.
	calc cases;
		when: [aFrame isKindOf: HumFrame4Action  ]
			then:  [ self indexRole: (aFrame role) action: aFrame actionStatement. ];
		when: [aFrame isKindOf: HumFrame4Plan  ]
			then:  [ self indexFrame: aFrame relation: #goal object: aFrame goal source  ]; "Do we know too much?"
		when: [  aFrame isKindOf: HumFrame4Vignette ]
			then: [ "Enable caller to fetch vignettes by context-name."
					self addVignette: aFrame toContext: aFrame vignetteContext ];
		when: [ aFrame isKindOf: HumFrame4View  ]
			then: [ self indexViewFrame: aFrame. ];
		when: [ aFrame isKindOf: HumFrame4Dictionary  ]
			then: [ "Index the nouns"
						aFrame compileToOntology: self ];
		when: [ aFrame isKindOf: HumFrame4Comment  ] then: [ "Do nothing" ];
		otherwise: ["Also enable caller to fetch frame collection without any keys."
						 Error signal: 'How did we get here?'].
		"TODO: Should we do this indexing in subtypes of HumFrame instead?
					Indexing is an ontology function and we get an overview by doing it onotology.
		"

]

{ #category : #'about Frames' }
HumOntology >> indexFrame: aHumFrame relation: aSymbol object: aKeyString [ 
	"Add the given frame to the index"
	| |
	self assert: ( aSymbol isKindOf: Symbol ).
	(self frameRelations) add: { aHumFrame title. aSymbol. (aKeyString trimBoth asLowercase). }.
]

{ #category : #'about Roles and Actions' }
HumOntology >> indexRole: aRole action: actionStatement [ 
   "Index role and action statement."
   | capRole |
	
	self assert: ( aRole isKindOf: String ).
	self assert: ( actionStatement isKindOf: HumStatement ).
	"Assure role is in set."
	capRole := aRole capitalized.
	self addRole: capRole.
	
	"Assure statement is in set."
	self roleActions add: ( capRole -> actionStatement ).
]

{ #category : #'about Views' }
HumOntology >> indexViewFrame: aHumFrame4View [ 
	| viewName |
	"TODO: Assertions in #viewEntity: which is called by #entity should be problems when ontology is compiled - but are currently crashing load-time process. "
	viewName := aHumFrame4View entity.
	"Preconditions - Catch bugs seen before."
	('* *' match:  viewName) 
		ifTrue: [ Error signal: 'View-name { ', viewName,' } should not contain a space.' ].
	('*.*' match:  viewName) 
		ifTrue: [ Error signal: 'View-name { ', viewName,' } should not contain a period.' ].
	self addNoun: viewName isA: 'view'.
]

{ #category : #'about Roles and Actions' }
HumOntology >> instructionsForRole: aRole action: anAction [
	| actionFrame lines actionStatement |
	self assert: (aRole > '') description: 'Role cannot be empty for frame lookup.'.
	(anAction isKindOf: HumStatement) ifTrue: [ actionStatement := anAction  ].
	(anAction isKindOf: HumInstructionLine) ifTrue: [ actionStatement := anAction statement ].
	(anAction isKindOf: String ) ifTrue: [ actionStatement := HumStatement source: anAction ].
	self assert: (actionStatement isKindOf: HumStatement ).
	actionFrame := self getFrameForRole: aRole capitalized action: actionStatement.
	lines := actionFrame frameLines.
	^lines.  
	
]

{ #category : #'about Roles and Actions' }
HumOntology >> isActionDefined: anInstructionLine inRole: aRole [
	"Has the given statement been defined as an action for the given role?"
	| instructions result verb | 
	"TODO: Kludge some polymorphism.
	 TODO: Fix-up string arguments"	
	(aRole > ' ') ifFalse:[Error signal: 'Role cannot be empty for action lookup.'].
	"Preempt Dialog-Agent verbs."
	(aRole = 'DialogAgent') 
		ifTrue: [ 
			verb := HumCalculator given: (anInstructionLine statement source) extractUpto: ' '.
			(#('Ask' 'Show' 'New') includes: verb) ifTrue: [ ^true ].
			"TODO: When the verbs 'Ask' 'Show' 'New' are defined in the base ontology we will not need this bypass. "
			].
	"Ignore If / Else / For each / Find statements.  -- For Now."
	verb := HumCalculator given: (anInstructionLine statement source) extractUpto: ' '.
	(#('If' 'Else:' 'For' 'Find') includes: verb) 
		ifTrue: [ "TODO: Parse and critique If / For / Find statements."
			^true ].
	
	instructions := self instructionsForRole: aRole action: ( anInstructionLine statement ).
	result := instructions isEmpty. 
	"(result) ifFalse: [ self halt. ]."
	^ result.
]

{ #category : #'about Nouns' }
HumOntology >> isAttribute: aNameString [
	"Does the string name an attribute? (An attribute has no attributes of its own.)"
	| result attributes |
 	
	"First: Does it name a noun?"
	result := self isNoun: aNameString.
	result ifFalse: [^false].
	
	"An attribute has no attributes. 
	 Nor is it a subtype of something that has attributes."
	attributes := self allAttributesOfEntity: aNameString.
	result := attributes size = 0.
	^result.
	
]

{ #category : #'about Nouns' }
HumOntology >> isCategory: aNameString [
	"Does the string name an attribute? (An attribute has no attributes of its own.)"
	| result  |
	
	"First: Does it name a noun?"
	result := self isNoun: aNameString.
	result ifFalse: [^false].
	
	result := self yesNoun: aNameString isAKindOf: 'category'.
	^result.
	
]

{ #category : #'about Nouns' }
HumOntology >> isEntity: aNameString [
	"Does the string name an entity?"
	| result attributes |
	
	"First: Does it name a noun?"
	result := self isNoun: aNameString.
	result ifFalse: [^false].
	
	"An entity has one or more attributes."
	attributes := self allAttributesOfEntity: (self singularFormOfNoun: aNameString).
	result := attributes size > 0.
	^result.
	
]

{ #category : #'about Nouns' }
HumOntology >> isEntity: entityName attribute: attributeName [
	"Does this combination make sense? "
	| result attributes |

	"Does the first noun name an entity?"
	result := self isEntity: entityName.
	result ifFalse: [^false].
	
	"Is the second noun an attribute of the first noun?"
	attributes := self allAttributesOfEntity: entityName.
	result := attributes includes: attributeName.
	^result.
	
	
]

{ #category : #'about Nouns' }
HumOntology >> isNoun: aNounString [ 	
	"Is the given string a noun?"
	| singular |
	self assert: [ aNounString isKindOf: String ].
	
	"TODO: Refactor to deal with possessive case. e.g. 'user`s name'. "
	('* *' match: aNounString)
		ifFalse: [ "No entity prefix" 
				singular := self singularFormOfNoun: aNounString.
				^( self nouns ) include: singular.
			]
		ifTrue: [ "Is this a ligit entity-attribute pair?" 
			"Separate the entity from the attribute."
			| entity attribute |
			entity := HumCalculator given: aNounString extractUpto: ' '.
			attribute := HumCalculator given: aNounString extractAfter: ' '.
			^( self isEntity: entity attribute: attribute ).
			
			].

]

{ #category : #'about Nouns' }
HumOntology >> isPluralNoun: aNoun [
	"Return true if the noun is plural."
	| singular isSingular |
	singular := self singularFormOfNoun: aNoun.
	isSingular := (singular sameAs: aNoun).
	^isSingular not.
	
]

{ #category : #'about Views' }
HumOntology >> isViewName: aString [ 
	"Does the string name a view frame?"
	| frame result |
	frame := (self framesByName) at: ('View: ',aString trimBoth,'.') ifAbsent: [^false].
	result := frame isKindOf: HumFrame4View.
	
	^result.
]

{ #category : #utility }
HumOntology >> nounAsCamelCase: aString [ 
	|result delimiters tokens |
	delimiters := '- '.
	tokens := aString findTokens: delimiters keep: ' '.
	result := tokens at: 1.
	(tokens copyFrom: 2 to: tokens size)
		do: [:token | result := result, (token capitalized) ].
	^result.
]

{ #category : #'about Nouns' }
HumOntology >> nounCategories [
	"(self nounCategories) at: attribute put: setOfCategories."
	^ nounCategories ifNil: [ nounCategories := Dictionary new ].
]

{ #category : #'about Nouns' }
HumOntology >> nounReferences [
	"(self nounReferences ) add: ( aNounString -> aFrameLine )."
	^ nounReferences ifNil: [ nounReferences := Set new. ].
]

{ #category : #'about Nouns' }
HumOntology >> nounSubtypes [
	"This instance variable is a map, a set of associations ( aSuperType -> aSubType )."
	"(self nounSubtypes) add: ( theSuperType -> theNoun)."
	^ nounSubtypes ifNil: [ nounSubtypes := Set new.].
]

{ #category : #'about Nouns' }
HumOntology >> nounSynonyms [
	"(self nounSynonyms) add: ( theSynonym -> theNoun)."
	^nounSynonyms ifNil: [  nounSynonyms := Set new ].
]

{ #category : #'about Nouns' }
HumOntology >> nouns [
	"This instance variable is the set of all nouns that have been defined so far."
	^nouns ifNil: [ nouns := Set new.].
	
]

{ #category : #'about Nouns' }
HumOntology >> nounsInStatement: aHumStatement [ 
	"Return the (known) nouns found in the statement."
	| tokens statement statementNouns nounSet |
	"Forgive a nil statement. (Sometimes an instruction line has no statement.)"
	aHumStatement ifNil: [ ^OrderedCollection new ].
	"Forgive a string instead of a statement."
	statement := aHumStatement.
	(statement isKindOf: String) ifTrue: [ statement := HumStatement from: aHumStatement ].
	self assert: ( statement isKindOf: HumStatement ).
	
	tokens := statement tokens.
	nounSet := self nouns copy.
	statementNouns := tokens select: [ :token | nounSet includes: token ].
	"TODO: Detect entity-attribute noun-phrase. Example: recipe`s bake-time."
	('*`s*' match: statement source) 
		ifTrue: [ | pairs | pairs := (self getEntityAttributePhraseFromStatement: statement).
			"Remove nouns in each pair from the prior set."
			pairs do: [ :pair | 
				| entity attribute |
				entity := HumCalculator given: pair extractUpto: ' '.
				attribute := HumCalculator given: pair extractAfter: ' '.
				statementNouns remove: entity ifAbsent: [].
				statementNouns remove: attribute ifAbsent: [].
				statementNouns add: pair.
				 ].
			].
	"TODO: Technical strategy for dealing with explicit constants in caller code."
	"TODO: Detect quoted strings as nouns? -- (Caller side)"
	"TODO: Detect measurements as nouns? -- (Caller side)"
	"TODO: Detect names as nouns? -- (Caller side) "
	^statementNouns.
	
]

{ #category : #'about Frames' }
HumOntology >> parseFrameLine: frameLine keywords: keywords [
	"Parse the frameLine -- Return a list of token-type pairs: ( token -> tokenType ).
	TODO: Fix this up so that it returns comment and annotation as types."
	| whitespace punctuation quote tokens tokenTypePairs tokenType i |
	whitespace := String space, String tab, String crlf.
	quote := $' asString.
	punctuation := '~!@#$%^&*()_+`={}|[]\:";<>?,./', quote.
	"Note: Preserve uppercase in tokens so that first word of a sentence is capitalized."
	tokens := frameLine source  findTokens: ( punctuation, whitespace ) keep: punctuation.
	tokenTypePairs := OrderedCollection new.
	"QUESTION: Is the role-label part of the statement? 
	(I think it is part of an instruction, but the statement is separated.)"
	i := 1.
	[ i <= tokens size ]	
		whileTrue: [ 
			| token |
			token := tokens at: i.
			tokenType := #word.
			( self isNoun: token ) ifTrue: [ tokenType := #noun ].
			( keywords include: token ) ifTrue: [ tokenType := #keyword ].
			( punctuation includes: (token at: 1) ) 
				ifTrue: [ tokenType := #punctuation. "Until proven otherwise."
					"Does the source have a comment?"
					(((token at: 1) = '(') and: ['*(*)*' match: (frameLine source) ] )
						ifTrue: [ "Advance index to closing parend"
							| commentString |
							commentString := '('.
							[ i <= (tokens size) and:[( token at: 1) =')']] 
								whileFalse: [ i := i+1. token := tokens at: i. commentString := commentString, ' ', token. ].
								token := commentString.
								tokenType := #comment.
								]. 
					"Does the source have annotation?"
					(((token at: 1) = '[') and: ['*[*]*' match: (frameLine source) ] )
						ifTrue: [ "Advance index to closing parend"
							| annotationString |
							annotationString := '['.
							[ i <= (tokens size) and: [( token at: 1) =']']] 
								whileFalse: [ i := i+1. token := tokens at: i. annotationString := annotationString, ' ', token. ].
								token := annotationString.
								tokenType := #annotation.
								]. 
					].
			tokenTypePairs add: ( token -> tokenType ).
			].
	^ tokenTypePairs.

]

{ #category : #parsing }
HumOntology >> parseStatement: aHumStatement triggerWords: triggerWords keywords: keywords [ 
	"Parse the statement -- Return a list of token-type pairs: ( token -> tokenType ).
	triggerWords are 'if else for-each' when they appear as first word. 
	TODO: Fix this up so that it returns comment and annotation as types."
	|  whitespace punctuation quote tokens tokenTypes tokenType firstToken |
	self assert: (triggerWords isKindOf: String) not.
	self assert: (keywords isKindOf: String) not.
	whitespace := Character separators.
	quote := $' asString.
	punctuation := '~!@#$%^&*()_+`={}|[]\:";<>?,./', quote.
	"TODO: Scan to detect and remove strings delimited by quote or double-quote."
	(aHumStatement source includes: '"') ifTrue: [Error signal: 'Strings as tokens is not implemented yet.'].
	"Note: Preserve uppercase in tokens so that first word of a sentence is capitalized."
	tokens := aHumStatement source  findTokens: ( punctuation, whitespace ) keep: punctuation.
	tokenTypes := OrderedCollection new.
	"QUESTION: Is the role-label part of the statement? 
	(I think it is part of an instruction, but the statement is separated.)"
	firstToken := true.
	tokens 
		do: [ :token | 
			tokenType := #word.
			( self isNoun: token ) ifTrue: [ tokenType := #noun ].
			( firstToken and: [triggerWords include: (token asLowercase)]) ifTrue: [ tokenType := #keyword ].
			( (firstToken not) and: [keywords include: (token asLowercase)]) ifTrue: [ tokenType := #keyword ].
			( punctuation includes: (token at: 1) ) ifTrue: [tokenType := #punctuation ].
			( token isAllDigits ) ifTrue: [ tokenType := #number. ].
			tokenTypes add: ( token -> tokenType ).
			firstToken := false.
			].
	"TODO: Detect measurement pattern: 'number unit-of-measure' "
	^ tokenTypes.

]

{ #category : #'about Plans and Conditions' }
HumOntology >> planFrames [
	| planFrames |
	planFrames := Set new.
	( self framesByIdentifier )
		keysAndValuesDo:  [ :key :value | 
			(value isKindOf: HumFrame4Plan)  ifTrue: [ planFrames add: value ].
			].
	^planFrames 
]

{ #category : #accessing }
HumOntology >> printOn: aStream [
	aStream nextPutAll: (self asString).
]

{ #category : #utility }
HumOntology >> projectValuesOf: aSetOfAssociations from: aKey [
	"encapsulate a bit of recurring code"

	| resultSet |
	self assert: ( aSetOfAssociations isKindOf: Collection ).
	resultSet := Set new.
	aSetOfAssociations do: [ :map | ( map key = aKey) ifTrue: [resultSet add: (map value)] ].
	^resultSet.
]

{ #category : #'about Roles and Actions' }
HumOntology >> roleActions [
	"This instance variable is a map, a set of associations  ( role -> actionStatement ) "
	^roleActions ifNil: [ roleActions := Set new.]
]

{ #category : #'about Roles and Actions' }
HumOntology >> roles [
	"This instance variable contains the set of all roles that have been defined so far."
	^roles ifNil: [ roles := Set new.].
]

{ #category : #'about Nouns' }
HumOntology >> setAutomaticSupertypeForNoun: aNoun [ 
	"If a hyphenated nouns ends with the name of another noun,
	 it is automately a subtype of the other noun."
	| tokens suffix |
	"See if there is a hyphen in the noun."
	tokens := aNoun findTokens: '-'.
	( tokens size > 1 ) ifFalse: [^self].
	
	"See if the last token is currently a noun."
	suffix := tokens last.
	(self isEntity: suffix ) ifFalse: [^self].
	
  "The last token is currently a noun, so make this noun a subtype."
	self nounSubtypes add: ( suffix -> aNoun ).
]

{ #category : #'about Nouns' }
HumOntology >> singularFormOfNoun: aNoun [ 
	"If noun ends in 's'  remove the 's'.  Crude."
	| s singular calc |
	self assert: ( aNoun isKindOf: String ).
	
	s := aNoun asLowercase.
	
	"Following is first approximation. 
	TODO: Deal with other plural forms."
	calc := HumCalculator new.
	calc cases;
		when: [ (s endsWith: 's' ) not] then: [ singular := s ];	
		"Following cases end in 's'. "
		when: [ s endsWith: 'ss' ] then: [ singular := s ];
		when: [ s endsWith: 'ies' ] then: [ singular :=  (s copyFrom: 1 to: (s size-3)),'y' ];
		when: [ s endsWith: 'sses' ] then: [ singular :=  (s copyFrom: 1 to: (s size-2)) ];
		otherwise: [  singular :=  (s copyFrom: 1 to: (s size-1)) ].
	^singular.
	
]

{ #category : #'about Frames' }
HumOntology >> storeFrame: aFrame [ 
	"Store this frame in the ontology.
	The frame may be stored even if it has errors.
	"
	| primaryKey frameName  |
	self assert: (aFrame isKindOf: HumFrame ).
	"Store the frame."
	( self frames ) add: aFrame. 
	"If the frame does not have an ID (serial-number) give it one."
	"The title of the frame can serve to index it but cannot be used to ID it 
		because the title can be changed by the user 
			while the intent of the frame remains the same."
	"TODO: Syntax errors in the frame can crash the load process. << ERROR"
	primaryKey := aFrame uniqueIdentifier.
	( self framesByIdentifier ) at: primaryKey put: aFrame.
	
	"Also enable caller to fetch a frame by its name."
	frameName := aFrame frameName.
	( self framesByName ) at: frameName put: aFrame.
	
	"Create index entries for the frame."
	"TODO: Is this side-effect a good idea?"
	self indexFrame: aFrame.
]

{ #category : #accessing }
HumOntology >> title [
	^ title ifNil: [ title :=  (self fromFile), ' -- No title yet.'. ].
]

{ #category : #accessing }
HumOntology >> title: aString [ 
	title := aString
]

{ #category : #'translate to' }
HumOntology >> view [
	^viewer ifNil: [ viewer := HumOntologyViewer ontology: self. ].
]

{ #category : #'about Vignettes' }
HumOntology >> vignettesForContext: aRequestedContext [
	| vignettes calc requestedContext |
	self assert: ( aRequestedContext isKindOf: String ).
	"DEBUG ('*activity*' match: aRequestedContext ) ifTrue: [ self halt. ]."
	requestedContext := self cleanKey: aRequestedContext.
	calc := HumCalculator new.
	vignettes := OrderedCollection new.
	(self contextVignettes )
		do: [ :contextVignette |
			| contextName contextFrame  |
			self assert: (contextVignette isKindOf: Association ).
			contextName  := contextVignette key.
			contextFrame := contextVignette value.
			( calc string: contextName isLike: requestedContext ignore: ' .' ) ifTrue: [ vignettes add: contextFrame ].
			].
	^vignettes.
]

{ #category : #parsing }
HumOntology >> xparseString: aStatementString keywords: keywords [ 
	"Coding experiment to see if I can tweak existing code to handle quoted strings."
	"Parse the statement string -- Return a list of token-type pairs: ( token -> tokenType ).
	TODO: Fix this up so that it returns comment and annotation as types."
	| whitespace punctuation quote tokens tokenTypes tokenType doubleQuote isQuoteSeen |
	whitespace := ' 	
		'.
	quote := $' asString.
	doubleQuote := $" asString.
	isQuoteSeen := false.
	"Note: Preserve uppercase in tokens so that first word of a sentence is capitalized."
	punctuation := '~!@#$%^&*()_+`={}|[]\:;<>?,./', quote, doubleQuote.
	tokens := aStatementString  findTokens: ( punctuation, whitespace ) keep: punctuation.
	tokenTypes := OrderedCollection new.
	"QUESTION: Is the role-label part of the statement? 
	(I think it is part of an instruction, but the statement is separated.)"
	tokens 
		do: [ :token | 
			tokenType := #word. "default"
			( self isNoun: token ) ifTrue: [ tokenType := #noun ].
			( keywords include: token ) ifTrue: [ tokenType := #keyword ].
			( punctuation includes: (token at: 1) ) "WARNING: A sequence of punctuation is single token."
				 ifTrue: [tokenType := #punctuation ].
			( token isAllDigits ) ifTrue: [ tokenType := #number. ].
			( token = quote or: [token = doubleQuote] ) ifTrue: [tokenType := #quote. isQuoteSeen := true. ].
			tokenTypes add: ( token -> tokenType ).
			].
	"Collapse quoted string."
	isQuoteSeen 
		ifTrue: ["Collapse the tokens in the quoted string into a single token."
			self shouldBeImplemented.
			].
	"TODO: Detect measurement pattern: 'number unit-of-measure' "
	^ tokenTypes.
]

{ #category : #'about Nouns' }
HumOntology >> yesNoun: aSubtype isAKindOf: aSuperType [ 
	"Is the noun a subtype of the given supertype? Used when matching action statements."
	| result |
	"Check for special case:
	Action statement definitions in the base ontology may include 'entity' as a noun.
	The noun 'entity' is not in the base ontology because it would cause too much clutter.
	Example: 'New entity.' action statements.
	"
	(aSuperType = 'entity')
		ifTrue: [ ^self isEntity: aSubtype ].
	"Normal case:"
	result := self nounSubtypes includes: ( aSuperType -> aSubtype  ).
	^result.
]

{ #category : #'about Roles and Actions' }
HumOntology >> yesRole: aRole hasAction: aSource [
	"Is the given action defined for the given role?"
	| actionCandidate |
	"Convert String to Statement, if needed."
	(aSource isKindOf: String)
		ifTrue: [actionCandidate := HumStatement source: aSource].
	(aSource isKindOf: HumStatement)
		ifTrue: [actionCandidate := aSource].
	self assert: (actionCandidate isKindOf: HumStatement).	 
	^(self actionsOf: (aRole capitalized ) ) anySatisfy: [ :statement | 
		 actionCandidate matchesTemplateStatement: statement inOntology: self.
		 ] .
]
