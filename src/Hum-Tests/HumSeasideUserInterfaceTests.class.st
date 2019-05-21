"
This class holds tests of a Seaside implementation of Hum User Interface concepts.
"
Class {
	#name : #HumSeasideUserInterfaceTests,
	#superclass : #HumSeasideTests,
	#category : #'Hum-Tests'
}

{ #category : #'PA300 View Code Generator' }
HumSeasideUserInterfaceTests >> checkGeneratedCode [
	"This is a place to see if generated code will compile."


]

{ #category : #'PA300 View Code Generator' }
HumSeasideUserInterfaceTests >> setUpViewFrameInOntology: aHumOntology [
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

{ #category : #'PA300 View Code Generator' }
HumSeasideUserInterfaceTests >> test310ViewBecomesForm [
	"A Hum view frame is rendered as a Seaside Form.
	TODO: Figure out how to handle read-only form later.
	"
	| ontology  viewFrame frameCode |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
     self setUpViewFrameInOntology: ontology.

	"There is only one frame in this ontology."
	viewFrame :=  ontology fetchFrameByName: 'View: recipe.'.
	self assert: viewFrame notNil. 

	"Generate Seaside code for the view frame."
	frameCode := ontology codeGenerator generateSeasideForView: viewFrame.
	
	self assert: ( frameCode isKindOf: String ).
	self assert: ( frameCode findString: 'html form')  > 1.

]

{ #category : #'PA300 View Code Generator' }
HumSeasideUserInterfaceTests >> test311ViewHasMultipleLines [
	"A Hum view frame is rendered as a Seaside Form.
	TODO: Figure out how to handle read-only form later.
	"
	| ontology  viewFrame frameCode |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
     self setUpViewFrameInOntology: ontology.
	"There is only one frame in this ontology."
	viewFrame :=  ontology fetchFrameByName: 'View: recipe.'.
	self assert: viewFrame notNil. 

	"Generate Seaside code for the view frame."
	frameCode := ontology codeGenerator generateSeasideForView: viewFrame.
	self assert: ( frameCode includesSubString: 'html form' ).
	self assert: ( frameCode includesSubString: 'html break' ).

]

{ #category : #'PA300 View Code Generator' }
HumSeasideUserInterfaceTests >> test312ViewHeader [
	"A Hum view frame is rendered as a Seaside Form.
	TODO: Figure out how to handle read-only form later.
	"
	| ontology  viewFrame frameCode |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
     self setUpViewFrameInOntology: ontology.
	"There is only one frame in this ontology."
	viewFrame :=  ontology fetchFrameByName: 'View: recipe.'.
	self assert: viewFrame notNil. 

	"Generate Seaside code for the view frame."
	frameCode := ontology codeGenerator generateSeasideForView: viewFrame..
	self assert: ( frameCode isKindOf: String ).

	self assert: ( frameCode includesSubString: 'html form' ).
	self assert: ( frameCode includesSubString: 'html break' ).
	self assert: ( frameCode includesSubString: 'html heading level: 2' ).
	self assert: ( frameCode includesSubString: 'Recipe').
	

]

{ #category : #'PA300 View Code Generator' }
HumSeasideUserInterfaceTests >> test313ViewField [
	"A Hum view frame is rendered as a Seaside Form.
	TODO: Figure out how to handle read-only form later.
	"
	| ontology  viewFrame frameCode |
	ontology := HumOntology new.
	
	"Initialize the View Frame for this test."
     self setUpViewFrameInOntology: ontology.
	"There is only one frame in this ontology."
	viewFrame :=  ontology fetchFrameByName: 'View: recipe.'.
	self assert: viewFrame notNil. 

	"Generate Seaside code for the view frame."
	frameCode := ontology codeGenerator generateSeasideForView: viewFrame..
	self assert: ( frameCode isKindOf: String ).

	self assert: ( frameCode includesSubString: 'html form' ).
	self assert: ( frameCode includesSubString: 'html break' ).
	self assert: ( frameCode includesSubString: 'html heading level: 2' ).
	self assert: ( frameCode includesSubString: 'html textInput callback: [').
		
	self assert: ( frameCode includesSubString: 'setEntityID:').
	self assert: ( frameCode includesSubString: 'toValue:').
	self assert: ( frameCode includesSubString: '#name').
		
	self assert: ( frameCode includesSubString: 'ingredients' ).
	
	"See if the resulting code will compile in the context of a HumDialogAgent."
	
	(Parser new) parse: ('checkRenderOn: html', String cr, frameCode) class: HumView.
	
	"Transcript show: '*** test313ViewField frameCode: ***'; cr; show: frameCode; cr."
	
]

{ #category : #'PA300 View Code Generator' }
HumSeasideUserInterfaceTests >> test314CheckGeneratedCode [
	"This is a place to see if generated code will compile and run."
	| result anEntityID |
	
	result := self builder render: [ :html | 
	anEntityID := 'TestThisRecipe'.
	"Following is pasted from test313ViewField Transcript show: 
	TODO: Find a way to put in an actual method.
	"
	html form with: [ 
		html break. html heading level: 2; with: ' Recipe'.
		html break. html textInput callback: [:datum | self blackBoard setEntityID: anEntityID attribute: #name toValue: datum ]; name: 'name'; value: 'name'.
		html break. html textInput callback: [:datum | self blackBoard setEntityID: anEntityID attribute: #description toValue: datum ]; name: 'description'; value: 'description'.
		html break. html textInput callback: [:datum | self blackBoard setEntityID: anEntityID attribute: #ingredients toValue: datum ]; name: 'ingredients'; value: 'ingredients'.
		html break. html textInput callback: [:datum | self blackBoard setEntityID: anEntityID attribute: #steps toValue: datum ]; name: 'steps'; value: 'steps'.
		].
	].
	"Expect the HTML output to look like this."
	"Compare strings ignoring differences in white space."
	self assert: ( HumCalculator string: result isLike: '
	<form accept-charset="utf-8" method="post" action="/">
	  <br/>
	  <h2>Recipe</h2>
	  <br/><input name="name" value="name" type="text" class="text"/>
	  <br/><input name="description" value="description" type="text" class="text"/>
	  <br/><input name="ingredients" value="ingredients" type="text" class="text"/>
	  <br/><input name="steps" value="steps" type="text" class="text"/>
	</form>' ).
	"	
	TODO: THIS IS JUST A CRUDE FIRST APPROXIMATION. 
	It does not take data-types into account when selecting the rendering mode.
	LONGER TERM: 
	- Description should be a textarea with rows and columns.
	- Ingredients and steps could be a table/list with some way to edit the entries.
	- Ingredients (set) could be rendered as an unordered list.
	- Steps (list) could be rendered as an ordered list.
	 "	

]
