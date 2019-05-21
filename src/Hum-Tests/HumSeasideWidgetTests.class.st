"
Test the HumWidget subclasses as Seaside components.
"
Class {
	#name : #HumSeasideWidgetTests,
	#superclass : #HumSeasideTests,
	#category : #'Hum-Tests'
}

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> setUpViewFrameInOntology: aHumOntology [
	"Generate a view frame and dictionary entries for several tests.
	---
	!! Recipe
	recipe-name: [name]
	  description: [description]
	  ingredients: [ingredients]
	        steps: [steps]
	---
	Dictionary: Recipe attributes.
	. Recipe attributes include recipe-line, description, ingredients, steps.
	. Description is a text.
	. Recipe has a set of ingredients.
	. Recipe has a list of steps.
	---
	"
	| frameEditor errors |
	"Create a view frame."
	frameEditor := HumFrameUpdater ontology: aHumOntology viewEntity: 'recipe'.
	"Add markup lines."
	frameEditor addMarkUp: '!! Recipe'.
	frameEditor addMarkUp: ' recipe-name: [name]'.
	frameEditor addMarkUp: '   description: [description]'.
	frameEditor addMarkUp: '   ingredients: [ingredients]'.
	frameEditor addMarkUp: '         steps: [steps]'.
	aHumOntology addNouns: #( 'recipe' 'name' 'description' 'ingredients' 'steps' ).
	errors := frameEditor compileToOntology: aHumOntology.
	self assert: ( errors isEmpty  ).
	
	"TODO: Make this smarter. 
	- At the very least, description, ingredients, and steps could be of type text.
	- (and rendered using textarea tag).
	"
	
	"Create a dictionary frame."
	frameEditor := HumFrameUpdater ontology: aHumOntology dictionaryTitle: 'Recipe attributes.'.
	frameEditor addDictionaryLine: 'Recipe attributes include recipe-line, description, ingredients, steps.'.
	frameEditor addDictionaryLine: 'Description is a text.'.
	"TODO: Should render description as a text area."
	frameEditor addDictionaryLine: 'Recipe has a set of ingredients.'.
	"TODO: Should render ingredients as an unordered list."
	frameEditor addDictionaryLine: 'Recipe has a list of steps.'.
	"TODO: Should render steps as an ordered list."
	errors := frameEditor compileToOntology: aHumOntology.
	self assert: ( errors isEmpty  ).

	 
	
	
	
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test010GivenWhenThen [
	"Test the test frame"
	self given: '' code: [].
	self when: '' code: [].
	self then: '' code: [ self assert: true.]
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test011GivenWhenThenFail [
	"Dry test the test frame"
	self given: '' code: [].
	self when: '' code: [].
	self then: '' code: [ self assert: true "false".].
	
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test100BasicWiring [
	"A Hum view frame is rendered as a Seaside Form."
	| ontology    humView |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
   self setUpViewFrameInOntology: ontology.

	"Create HumView as interface between Ontology and Seaside"
	humView := HumView new.
	humView
		ontology: ontology;
		view: 'recipe';
		blackboard: (HumBlackBoard new).
		
	"Generate Seaside code for the view frame."	
	
	self assert: humView gives: 'a HumView'.
		
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test102BasicWiring2 [
	"A Hum view frame is rendered as a Seaside Form."
	| ontology    humView frameEditor errors |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	"Add markup lines."
	frameEditor addMarkUp: '!! Recipe'.
	errors := frameEditor compileToOntology: ontology.
	self assert: ( errors isEmpty  ).

	"Create HumView as interface between Ontology and Seaside"
	humView := HumView new.
	humView
		ontology: ontology;
		view: 'recipe';
		blackboard: (HumBlackBoard new).
		
	"Generate Seaside code for the view frame."	
	
	self assert: (humView asWidget) matches: '<view id="recipe">*</view>'.
		
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test105BindWidgetToBlackboard [
	"A widget may be bound to blackboard"
	|  widget blackboard value entityName attributeName |
	"wire it up -- No worldbase for this test."
	blackboard := HumBlackBoard worldbase: 'none'.
	blackboard businessEvent: 'test105BindWidgetToBlackboard'.
	entityName := 'test105'.
	attributeName := 'some-attribute'.
	widget := HumWidget onEntity: entityName attribute: attributeName blackboard: blackboard.
	"Test flow: widget ==> blackboard ==> world base"
	value := 'aValue'. 
	widget store: value.
	self expect: value  actual: widget attributeValue.
	self expect: value  actual: (blackboard getEntityName: entityName attribute: attributeName).
	
	
	
	


		
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test107BindWidgetToCategory [
	"A widget may be bound to blackboard"
	|  widget blackboard value entityName attributeName |
	"wire it up"
	blackboard := HumBlackBoard worldbase: 'none'.
	blackboard businessEvent: 'test107BindWidgetToCategory'.
	entityName := 'test107'.
	attributeName := 'some-attribute'.
	widget := HumCategoryWidget onEntity: entityName attribute: attributeName blackboard: blackboard.
	widget categories: #( 'red' 'green' 'blue' 'yellow' 'orange' 'purple' ).
	"Test flow: widget ==> blackboard ==> world base"
	value := 'red'. 
	widget store: value.
	self expect: value actual: widget attributeValue.
	self expect: value actual: (blackboard getEntityName: entityName attribute: attributeName).
	
	
	
	


		
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test110ViewHasViewTag [
	"A Hum view frame is rendered as a Seaside Form.	"
	| ontology    humView frameEditor errors |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	"Add markup lines."
	frameEditor addMarkUp: '!! Recipe'.
	errors := frameEditor compileToOntology: ontology.
	self assert: ( errors isEmpty  ).
	
	"Create HumView as interface between Ontology and Seaside"
	humView := HumView new.
	humView
		ontology: ontology;
		view: 'recipe';
		blackboard: (HumBlackBoard new).
		
	"Generate Seaside code for the view frame."	
	
	self assert: [ :html | humView asWidget renderOn: html ] matches: '<view id="recipe">*</view>'.
		
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test120ViewHasFormTag [
	"A Hum view frame is rendered as a Seaside Form.	"
	| ontology    humView frameEditor errors |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	"Add markup lines."
	frameEditor addMarkUp: '!! Recipe'.
	errors := frameEditor compileToOntology: ontology.
	self assert: ( errors isEmpty  ).

	"Create HumView as interface between Ontology and Seaside"
	humView := HumView new.
	humView
		ontology: ontology;
		view: 'recipe';
		blackboard: (HumBlackBoard new).
		
	"Generate Seaside code for the view frame."	
	
	self assert: [ :html | humView asWidget renderOn: html ] matches: '*<form *id="recipe"*>*</form>*'.
		
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test130ViewHasMarkupLines [
	"A Hum view frame is rendered as a Seaside Form ...
	Expect multiple lines within the form
	"
	| ontology    humView frameEditor errors |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	"Add markup lines."
	frameEditor addMarkUp: '!! Recipe'.
	"
	frameEditor addMarkUp: ' recipe-name: [name]'.
	frameEditor addMarkUp: '   description: [description]'.
	frameEditor addMarkUp: '   ingredients: [ingredients]'.
	frameEditor addMarkUp: '         steps: [steps]'.
	"
	ontology addNouns: #( 'recipe' 'name' 'description' 'ingredients' 'steps' ).
	errors := frameEditor compileToOntology: ontology.
	self assert: ( errors isEmpty  ).

	"Create HumView as interface between Ontology and Seaside"
	humView := HumView new.
	humView
		ontology: ontology;
		view: 'recipe';
		blackboard: (HumBlackBoard new).
		
	"Generate Seaside code for the view frame."	
	"Expect break within the form."
	self assert: [ :html | humView asWidget renderOn: html ] matches: '*<form*<br/>*</form>*'.
	
		
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test132ViewHasHeadingLine [
	"A Hum view frame is rendered as a Seaside Form ...
	Render Hum Heading Markup as HTML heading.
	"
	| ontology frameEditor errors  humView |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	"Add markup lines."
	frameEditor addMarkUp: '!! Recipe'.
	errors := frameEditor compileToOntology: ontology.
	self assert: ( errors isEmpty  ).

	"Create HumView as interface between Ontology and Seaside"
	humView := HumView new.
	humView
		ontology: ontology;
		view: 'recipe';
		blackboard: (HumBlackBoard new).
		
	"Generate Seaside code for the view frame."	
	"Expect heading within the form."
	self assert: [ :html | humView asWidget renderOn: html ] matches: '*<h2>*</h2>*'.
	self assert: [ :html | humView asWidget renderOn: html ] matches: '*<form*<br/>*<h2>*</h2>*</form>*'.
	
		
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test134ViewHasStringWidget [
	"A Hum view frame is rendered as a Seaside Form ...
	Render '[attribute name]' ...
	"
	| ontology frameEditor errors  humView |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	"Add markup lines."
	"frameEditor addMarkUp: '!! Recipe'."
	frameEditor addMarkUp: ' recipe-name: [name]'.
	"
	frameEditor addMarkUp: '   description: [description 5]'.
	frameEditor addMarkUp: '   ingredients: [ingredients]'.
	frameEditor addMarkUp: '         steps: [steps]'.
	"
	ontology addNouns: #( 'recipe' 'name' 'description' 'ingredients' 'steps' ).
	errors := frameEditor compileToOntology: ontology.
	self assert: ( errors isEmpty  ).

	"Create HumView as interface between Ontology and Seaside"
	humView := HumView new.
	humView
		ontology: ontology;
		view: 'recipe';
		blackboard: (HumBlackBoard new).
	humView blackboard businessEvent: 'test134ViewHasStringWidget'.
	"Generate Seaside code for the view frame."	
	"Expect input within the form."
	self assert: [ :html | humView asWidget renderOn: html ] matches: '*<input*'.
	
		
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test135ViewUptoWidget [
	"A Hum view frame is rendered as a Seaside Form ...
	Render '[attribute name]' ...
	"
	| ontology frameEditor errors  humView |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	"Add markup lines."
	"frameEditor addMarkUp: '!! Recipe'."
	frameEditor addMarkUp: ' recipe-name: [name]'.
	"
	frameEditor addMarkUp: '   description: [description 5]'.
	frameEditor addMarkUp: '   ingredients: [ingredients]'.
	frameEditor addMarkUp: '         steps: [steps]'.
	"
	ontology addNouns: #( 'recipe' 'name' 'description' 'ingredients' 'steps' ).
	errors := frameEditor compileToOntology: ontology.
	self assert: ( errors isEmpty  ).

	"Create HumView as interface between Ontology and Seaside"
	humView := HumView new.
	humView
		ontology: ontology;
		view: 'recipe';
		blackboard: (HumBlackBoard new).
	humView blackboard businessEvent: 'test135'.	
	"Generate Seaside code for the view frame."	
	"Expect input within the form."
	self assert: [ :html | humView asWidget renderOn: html ] matches: '*recipe-name*<input*'.
	
		
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test136ViewHasTextWidget [
	"A Hum view frame is rendered as a Seaside Form ...
	Render '[attribute name]' ...
	"
	| ontology frameEditor errors  humView |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'recipe'.
	"Add markup lines."
	"frameEditor addMarkUp: '!! Recipe'.
	frameEditor addMarkUp: ' recipe-name: [name]'.
	"
	frameEditor addMarkUp: '   description: [description 5]'.
	"
	frameEditor addMarkUp: '   ingredients: [ingredients]'.
	frameEditor addMarkUp: '         steps: [steps]'.
	"
	ontology addNouns: #( 'recipe' 'name' 'description' 'ingredients' 'steps' ).
	errors := frameEditor compileToOntology: ontology.
	self assert: ( errors isEmpty  ).

	"Create HumView as interface between Ontology and Seaside"
	humView := HumView new.
	humView
		ontology: ontology;
		view: 'recipe';
		blackboard: (HumBlackBoard new).
	humView blackboard businessEvent: 'test136'.	
	"Generate Seaside code for the view frame."	
	"Expect test area within the form."
	self assert: [ :html | humView asWidget renderOn: html ] matches: '*<textarea*'.
	self assert: [ :html | humView asWidget renderOn: html ] matches: '*rows="5"*'.
	
		
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test138ViewHasDateWidget [
	"A Hum view frame is rendered as a Seaside Form ...
	Render '[attribute name]' ...
	"
	| ontology frameEditor errors  humView |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'reservation'.
	"Add markup lines."
	frameEditor addMarkUp: '   arrival date: [arrival-date]'.
	ontology addNoun: 'arrival-date' isA: 'date'.
	errors := frameEditor compileToOntology: ontology.
	self assert: ( errors isEmpty  ).

	"Create HumView as interface between Ontology and Seaside"
	humView := HumView new.
	humView
		ontology: ontology;
		view: 'reservation';
		blackboard: (HumBlackBoard new).
	humView blackboard businessEvent: 'test138'.	
	"Generate Seaside code for the view frame."	
	"Expect date input within the form."
	self assert: [ :html | humView asWidget renderOn: html ] matches: '*<input*type="date"*'.
	
		
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test139ViewHasCategoryWidget [
	"A Hum view frame is rendered as a Seaside Form ...
	Render '[category-name]' ...
	"
	| ontology frameEditor errors  humView |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'reservation'.
	"Add markup lines."
	frameEditor addMarkUp: '   class of room: [room-class]'.
	ontology categoriesOf: 'room-class' include: #( 'King' 'Double Queen' 'Suite' ) .
	errors := frameEditor compileToOntology: ontology.
	self assert: ( errors isEmpty  ).

	"Create HumView as interface between Ontology and Seaside"
	humView := HumView new.
	humView
		ontology: ontology;
		view: 'reservation';
		blackboard: (HumBlackBoard new).
	humView blackboard businessEvent: 'test139'.	
	"Generate Seaside code for the view frame."	
	"Expect date input within the form."
	self assert: [ :html | humView asWidget renderOn: html ] matches: '*<select*<option*Suite*'.
	
		
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test140ViewHasMeasureWidget [
	"A Hum view frame is rendered as a Seaside Form ...
	Render '[category-name]' ...
	"
	| ontology frameEditor errors  humView |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'reservation'.
	"Add markup lines."
	frameEditor addMarkUp: '   number of adults: [adult-count]'.
	ontology addNoun: 'adult-count' isA: 'Measure'.
	errors := frameEditor compileToOntology: ontology.
	self assert: ( errors isEmpty  ).

	"Create HumView as interface between Ontology and Seaside"
	humView := HumView new.
	humView
		ontology: ontology;
		view: 'reservation';
		blackboard: (HumBlackBoard new).
	humView blackboard businessEvent: 'test140'.	
	"Generate Seaside code for the view frame."	
	"Expect date input within the form."
	self assert: [ :html | humView asWidget renderOn: html ] matches: '*<input*type="number"*'.
	
		
]

{ #category : #'as yet unclassified' }
HumSeasideWidgetTests >> test150ViewLineHasSeveralWidgets [
	"A Hum view frame is rendered as a Seaside Form ...
	Render '[category-name]' ...
	"
	| ontology frameEditor errors  humView |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
	frameEditor := HumFrameUpdater ontology: ontology viewEntity: 'who'.
	"Add markup lines."
	frameEditor addMarkUp: '   prefix: [prefix] first: [first-name] middle: [middle-name] last: [last-name] suffix: [suffix]'.
	ontology addNouns: #( 'prefix' 'first-name' 'middle-name' 'last-name' 'suffix' ).
	errors := frameEditor compileToOntology: ontology.
	self assert: ( errors isEmpty  ).

	"Create HumView as interface between Ontology and Seaside"
	humView := HumView new.
	humView
		ontology: ontology;
		view: 'who';
		blackboard: (HumBlackBoard new).
	humView blackboard businessEvent: 'test150'.	
	"Generate Seaside code for the view frame."	
	"Expect date input within the form."
	self assert: [ :html | humView asWidget renderOn: html ] matches: '*prefix:*id="prefix"*'.
	self assert: [ :html | humView asWidget renderOn: html ] matches: '*suffix:*id="suffix"*'.
	
		
]
