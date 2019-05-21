"
A HumWidget provides a view of a single Attribute.
A HumWidget is connected to a Hum Blackboard.
See: HumEntityAttribute
Note: Some Attributes are collections and some attributes are HumEntity objects.

The primative datatypes include:
- String . . an array of characters
- Text . . . an array of lines of tokens with styling
- Measure. . a quantity with a unit of measure and precision
- Date . . . a calendar date (DateAndTime)
- Category . some value within an enumerated set 
- Collection a collection of objects (entities)
- Identifer . . Identifies an entity instance in a World Base.

Future primative datatypes might include media types:
- Image  . . a 2D picture (very technology dependent)

The reference implementation renders a HumWidget as an HTML5 widget.
However, the design intent requires that a HumWidget NOT be coupled to a specific rendering technology.

A widget may also be a controller. That means:
- It may react to external events (messages or calls from the HumScribe actor).
>> highlight: aColor (Change the background or border color to indicate focus.)
>> visible: aBoolean (If the widget is invisible, it occupies space but is not rendered.)
- It may update the attribute value that is in its view.
>> store: aValue

Q: What is the relation between Sensor, Scribe, Widget, Canvas, Solid, ViewPort.
A: The Scribe interprets inputs from the Sensor and updates a Widget.
The Widget is drawn on a Canvas which is painted on a Surface.
A Surface might be painted on a Solid within a Scene.
Note: A Surface is not rendered if it is not visible to the Viewport`s Camera. 
(The implication is that form widgets are not active until ""touched"" in some way.
Some UI convention may be needed to activate forms.)

The flow is Sensor >> Scribe >> Widget >> Canvas >> Surface >> ViewPort (Camera). ???

*** Some mark-up looks like a data widget but has different semantics.***
*** [[button-label]] ***
*** [X] << a check-box ***
*** [page: page-name] is wiki-style link to an internal page ***
*** [link: URL | link-text] is wiki-style link to an external page ***
*** [pane: view-name] is mark-up to embed a pane within the current view *** 
"
Class {
	#name : #HumWidget,
	#superclass : #Object,
	#instVars : [
		'attributeName',
		'attributeValue',
		'entityName',
		'blackboard',
		'canvas'
	],
	#classInstVars : [
		'blackboard'
	],
	#category : #'Hum-UI'
}

{ #category : #'instance creation' }
HumWidget class >> onEntity: anEntityName attribute: anAttributeName blackboard: aHumBlackBoard [ 
  "Create an instance of me with given connections."
	| widget |
	widget := self basicNew.
	widget 
		blackboard: aHumBlackBoard;
		entityName: anEntityName;
		attributeName: anAttributeName;
		attributeValue: ( aHumBlackBoard getEntityName: anEntityName attribute: anAttributeName ).
	^widget.
]

{ #category : #'as yet unclassified' }
HumWidget >> about [
" The traditional idea of a widget is that it is a component in a view. (MVC concept)
But in a 3D virtual-reality context, the widget concept must be extended.
"
"
Q: What is the relation between Sensor, Scribe, Widget, Canvas, Solid, ViewPort.
A: The Scribe interprets inputs from the Sensor and updates a Widget.
The Widget is drawn on a Canvas which is painted on a Surface.
A Surface might be painted on a Solid within a Scene.
Note: A Surface is not rendered if it is not visible to the Viewport`s Camera. 

The flow is Sensor >> Scribe >> Widget >> Canvas >> Surface >> ViewPort (Camera).
"
"
Q: What is the relationship between Sensor, Scribe, Widget, Blackboard, Dialog?
A: The Scribe interprets Sensor inputs and updates both the view and the Dialog.
The update of a Dialog might wait until form data is submitted.
"
" Note: An Avatar may be a kind of widget. 
It is in the 3D view and may interact with the user.
"
" A Scene is mostly decoration, but it may also trigger interaction via proximity triggers.
That means that a proximity trigger may be a kind of widget.
The Scribe will translate the sensor into vignette pattern input.
Examples:
U: User-Avatar enters the conference room.
U: User-Avatar is facing the receptionist."
]

{ #category : #'Render As' }
HumWidget >> asGlamorBrick [
	"Render widget and data as Glamor Brick object"
	self subclassResponsibility.
]

{ #category : #'Render As' }
HumWidget >> asHTML [
	"Render widget and data as HTML code"
	self subclassResponsibility.
]

{ #category : #'Render As' }
HumWidget >> asJSF [
	"Render widget and data as Jave Server Face code"
	self subclassResponsibility.
]

{ #category : #'Render As' }
HumWidget >> asMagritteMorph [
	"Render widget and data as Magritte Morph object"
	self subclassResponsibility.
]

{ #category : #'Render As' }
HumWidget >> asMorph [
	"Render widget and data as Morph object  
	- See: MorphicModel hierarchy"
	self subclassResponsibility.
]

{ #category : #'Render As' }
HumWidget >> asXUL [
	"Render widget and data as XUL code"
	self subclassResponsibility.
]

{ #category : #accessing }
HumWidget >> attributeName [
	^attributeName
]

{ #category : #accessing }
HumWidget >> attributeName: aString [
	"name of attribute"
	attributeName := aString.
]

{ #category : #accessing }
HumWidget >> attributeValue [
	^ attributeValue ifNil: [ '' ].
]

{ #category : #accessing }
HumWidget >> attributeValue: aString [
	"Set current value of attribute -- in display/input format."
	"See >>store: -- which sets the value and also notifies the blackboard."
	attributeValue := aString.
]

{ #category : #accessing }
HumWidget >> blackboard: aHumBlackBoard [ 
	blackboard := aHumBlackBoard. 

]

{ #category : #accessing }
HumWidget >> canvas [
	"Canvas on which to draw the widget - "
	^canvas ifNil: [ canvas := HumCanvas new. ].
	
"
Q: What is the relation between Sensor, Scribe, Widget, Canvas, Solid, ViewPort.
A: The Scribe interprets inputs from the Sensor and updates a Widget.
The Widget is drawn on a Canvas which is painted on a Surface.
A Surface might be painted on a Solid within a Scene.
Note: A Surface is not rendered if it is not visible to the Viewport`s Camera. 

The flow is Sensor >> Scribe >> Widget >> Canvas >> Surface >> ViewPort (Camera)."
]

{ #category : #accessing }
HumWidget >> canvas: aHumCanvas [ 
	"Canvas on which to draw the widget - "
	self assert: (aHumCanvas isKindOf: HumCanvas).
	canvas := aHumCanvas.
]

{ #category : #accessing }
HumWidget >> entityName: aString [ 
	entityName := aString.
]

{ #category : #accessing }
HumWidget >> formCanvas [
	^self canvas formCanvas.
]

{ #category : #'events-triggering' }
HumWidget >> store: anObject [ 
	"Set my attribute value and store it on my blackboard."
	"TODO: Perhaps this should be #update: method to correspond with other UI controller conventions."
  	self attributeValue: anObject.
	"Note: The blackboard might send the value to it`s world-base, if it has a world-base."
	blackboard setEntityName: entityName attribute: attributeName toValue: anObject.
]
