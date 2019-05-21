"
A Pane is a subtype of Surface (HumSurface).
Panes may contain other panes.
It is also a container which collects other 2D shapes which are also HumSurface instances.
It has a set of layout methods.

A pane may receive ""UI events"" (speech act statements) from the Scribe.




"
Class {
	#name : #HumPane,
	#superclass : #HumSurface,
	#category : #'Hum-UI'
}

{ #category : #'as yet unclassified' }
HumPane class >> id: aString height: h width: w background: aColor [
	| instance |
	instance := self new.
	instance id: aString; height: h; width: w; backgroundColor: aColor.
	^instance.
]

{ #category : #drawing }
HumPane >> drawTextLines: textLines onCanvas: aCanvas font: aFont [ 
	|   lineHeight em depth clipRectangle extent maxLineLength |
	self assert: (aCanvas isKindOf: HumCanvas).
	self assert: (aFont isKindOf: AbstractFont).
	lineHeight := aFont height.
	em := aFont linearWidthOf: $m.
	height := ( lineHeight * (textLines size + 2) ).
	maxLineLength := (textLines values max: [ :line | line size ] ).
	width := em* (maxLineLength + 2).
	textLines keysAndValuesDo: [ :key :value |  width := width max: (em*(value size)) ].
	depth := 32.
	origin := 0@0.
	extent := width@height.
	clipRectangle := Rectangle origin: origin extent: extent. 

	canvas := HumCanvas  extent: extent depth: depth origin: origin clipRect: clipRectangle.
	canvas drawTextLines: textLines withFont: aFont.
.

]

{ #category : #event }
HumPane >> textChanged: aHumTextEditor [ 
	"Text to be displayed in this pane has changed."
	| myCanvas  lines |
	"Draw the text lines on my canvas."
	myCanvas := self canvas.
	lines := aHumTextEditor lines.
	self drawTextLines: lines onCanvas: myCanvas font: (StandardFonts defaultFont). 	
]
