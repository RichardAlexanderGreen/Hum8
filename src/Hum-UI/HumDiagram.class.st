"
A HumDiagram is a viewbox in a HumSurface for visualizing a Graph.
HumDiagram knows how to layout the graph. 

NOTE: HumDiagram has functions that overlap HumGraph.

Instance Variables:
	graph <HumGraph>
	nodePositions	<Dictionary>
	positionNode	<Dictionary>
	nodeExtent	<PTEvent | Point | TTPoint>
	nodeSpacing	<PTEvent | Point | TTPoint>
"
Class {
	#name : #HumDiagram,
	#superclass : #HumPane,
	#instVars : [
		'nodeExtent',
		'nodeSpacing',
		'mapNodePosition',
		'mapPositionNode',
		'graph'
	],
	#category : #'Hum-UI'
}

{ #category : #accessing }
HumDiagram >> addConnection: anAssociation [ 
	"anAssociation := ( fromNode -> toNode )"
	| label  fromNode toNode |
	self assert: ( anAssociation isKindOf: Association ).
	fromNode := anAssociation key.
	toNode := anAssociation value.
	label := (fromNode title),'->',(toNode title).
	self graph addConnection: anAssociation label: label.
]

{ #category : #accessing }
HumDiagram >> addConnection: anAssociation label: aString [
	"anAssociation := ( fromNode -> toNode )"
	self assert: ( anAssociation isKindOf: Association ).
	self graph addConnection: anAssociation label: aString.
]

{ #category : #accessing }
HumDiagram >> addNode: anObject [
	"A node object should have a title. 
	(It should have something to display in a rendering or mouse-over or debug.) "
	(anObject class selectors includes: #title )
		ifTrue: [ self graph addNode: anObject label: anObject title. ]
		ifFalse: [ self graph addNode: anObject label: anObject asString ].

]

{ #category : #rendering }
HumDiagram >> asSVGonHtml: html width: aWidth height: aHeight [ 
	"TODO: REFACTOR to render as HTML string."
	|  |
	self assert: ( html isKindOf: String ).
	html div 
		class: 'diagram'; 
		id: (self title asCamelCase);
		with: ["Label and Diagram"
			html strong: self title.
			html break.
			"Eventually, we want to draw the diagram using SVG."
			( html tag: 'svg' ) 
				attributeAt: 'width' put: (aWidth asString);     
				attributeAt: 'height' put: (aHeight asString);
				attributeAt: 'viewBox' put: '0 0 1000 1000';
				attributeAt: 'style' put: 'background: CYAN';
				"FOLLOWING IS A STUB -- EVENTUALLY THIS WILL DRAW NODES AND CONNECTIONS"
				"ToDo: Finish this after we have layout working."
				with: ["SVG path element"
					( html tag: 'path' )
						attributeAt: 'd' put: 'M 100 100  q 0,100 100,100 ';
						attributeAt: 'fill' put: 'none';
						attributeAt: 'stroke' put: 'red';
						attributeAt: 'stroke-width' put: '1'.
					( html tag: 'text' ) 
						attributeAt: 'x' put: 200;
						attributeAt: 'y' put: 200;
						attributeAt: 'font-size' put: 20;
						attributeAt: 'fill' put: 'BLUE';
						with: 'This is just a test of the SVG text rendering.'
					].
			].
]

{ #category : #rendering }
HumDiagram >> asSVGonHtmlCanvas: html width: aWidth height: aHeight [ 
	"Render this diagram on the given Seaside canvas.
	Note: We use SVG.
	"
	|  |
	self assert: ( html isKindOf: WACanvas ).
	html div 
		class: 'diagram'; 
		id: (self title asCamelCase);
		with: ["Label and Diagram"
			html strong: self title.
			html break.
			"Eventually, we want to draw the diagram using SVG."
			( html tag: 'svg' ) 
				attributeAt: 'width' put: (aWidth asString);     
				attributeAt: 'height' put: (aHeight asString);
				attributeAt: 'viewBox' put: '0 0 1000 1000';
				attributeAt: 'style' put: 'background: CYAN';
				"FOLLOWING IS A STUB -- EVENTUALLY THIS WILL DRAW NODES AND CONNECTIONS"
				"ToDo: Finish this after we have layout working."
				with: ["SVG path element"
					( html tag: 'path' )
						attributeAt: 'd' put: 'M 100 100  q 0,100 100,100 ';
						attributeAt: 'fill' put: 'none';
						attributeAt: 'stroke' put: 'red';
						attributeAt: 'stroke-width' put: '1'.
					( html tag: 'text' ) 
						attributeAt: 'x' put: 200;
						attributeAt: 'y' put: 200;
						attributeAt: 'font-size' put: 20;
						attributeAt: 'fill' put: 'BLUE';
						with: 'This is just a test of the SVG text rendering.'
					].
			].
]

{ #category : #rendering }
HumDiagram >> asSVGonSeasideCanvas: html width: aWidth height: aHeight [ 
	"Render this diagram on the given Seaside canvas.
	Note: We use SVG.
	"
	|  |
	self assert: ( html isKindOf: (self seasideCanvas) ).
	html div 
		class: 'diagram'; 
		id: (self title asCamelCase);
		with: ["Label and Diagram"
			html strong: self title.
			html break.
			"Eventually, we want to draw the diagram using SVG."
			( html tag: 'svg' ) 
				attributeAt: 'width' put: (aWidth asString);     
				attributeAt: 'height' put: (aHeight asString);
				attributeAt: 'viewBox' put: '0 0 1000 1000';
				attributeAt: 'style' put: 'background: CYAN';
				"FOLLOWING IS A STUB -- EVENTUALLY THIS WILL DRAW NODES AND CONNECTIONS"
				"ToDo: Finish this after we have layout working."
				with: ["SVG path element"
					( html tag: 'path' )
						attributeAt: 'd' put: 'M 100 100  q 0,100 100,100 ';
						attributeAt: 'fill' put: 'none';
						attributeAt: 'stroke' put: 'red';
						attributeAt: 'stroke-width' put: '1'.
					( html tag: 'text' ) 
						attributeAt: 'x' put: 200;
						attributeAt: 'y' put: 200;
						attributeAt: 'font-size' put: 20;
						attributeAt: 'fill' put: 'BLUE';
						with: 'This is just a test of the SVG text rendering.'
					].
			].
]

{ #category : #accessing }
HumDiagram >> connections [
	"Model connections as a set of associations."
	^ self graph connections.
	
]

{ #category : #accessing }
HumDiagram >> countNeighborsOfNode: aNode [
	"Return the number of neighbors of this node.
	 (Count nodes that are directly connected to this node)"
	| count |
	count := 0.
	( self connections ) 
		do: [ :map | (((map key) = aNode) or: [(map value) = aNode]) 
			ifTrue: [ count := count + 1 ] ].
	^ count
]

{ #category : #accessing }
HumDiagram >> getNodesDownstreamFromNode: thisNode [ 
	"Return nodes that are connected downstream from this node."
	| result |
	result := Set new.
	( self connections )
		do: [ :connection |
			| upstreamNode downstreamNode |
			upstreamNode := connection key.
			downstreamNode := connection value.
			( upstreamNode = thisNode )
				ifTrue: [ result add: downstreamNode ].
			].
	^ result.
]

{ #category : #accessing }
HumDiagram >> getNodesUpstreamFromNode: thisNode [ 
	"Return nodes that are connected upstream from this node."
	| result |
	result := Set new.
	( self connections )
		do: [ :connection |
			| upstreamNode downstreamNode |
			upstreamNode := connection key.
			downstreamNode := connection value.
			( downstreamNode = thisNode )
				ifTrue: [ result add: upstreamNode ].
			].
	^ result.
]

{ #category : #accessing }
HumDiagram >> getPositionForNode: aNodeObject [
	^ self mapNodePosition at: aNodeObject ifAbsent: [ ^nil ].
]

{ #category : #accessing }
HumDiagram >> graph [
	^graph ifNil: [ graph := HumGraph new. ].
]

{ #category : #accessing }
HumDiagram >> initialize [
	"Set up the graph instance that backs this diagram."

	| |
	self assert: ((self graph) isKindOf: HumGraph).
]

{ #category : #layout }
HumDiagram >> layoutDiagramWithNodeExtent: extentPoint nodeSpacing: spacingPoint [
	"Layout the diagram using the given node extent and spacing between node edges."
	| xIncrement yIncrement nodePriority nodesByPriority |
	"Following must be set before calling me."
	self assert: ( extentPoint notNil ).
	self assert: ( spacingPoint notNil ).
	"Following is assumed in code below."
	self assert: ( extentPoint  isKindOf: Point).
	self assert: ( spacingPoint isKindOf: Point).
	"Reset these instance (global) variables!"
	nodeExtent := extentPoint.
	nodeSpacing := spacingPoint.
	
	"Compute increments between grid locations."
	"In this version, the placement is on a rectalinear grid.
	But other/future versions may be radial and/or decrease as the number of priorNodes increases.
	"
	xIncrement := (nodeSpacing x) + (( nodeExtent x )/2).
	yIncrement := (nodeSpacing y) + (( nodeExtent y )/2).
	
	"Strategy: Prioritize the objects that have the most connections."
	"Count the number of connections that each node has."
	nodePriority := Dictionary new.
	(self connections)
		do: [ :map | 
			| fromNode toNode fromCount toCount |
			fromNode := map key.
			toNode := map value. 
			fromCount := nodePriority at: fromNode ifAbsent: [0].
			nodePriority at: fromNode put: ( fromCount + 1).
			toCount := nodePriority at: toNode ifAbsent: [0].
			nodePriority at: toNode put: ( toCount + 1).
			].
	"Sort into a collection where nodes with most connections appear first."	
	nodesByPriority := SortedCollection new.
	nodePriority 
		keysAndValuesDo: [ :node :priority |
			nodesByPriority add: ( (priority negated) -> node ).
			]. 
	"Place the nodes with the most connections on the first pass.
	Note: This documentation uses term 'primary node' to refer to the node seen first.
	      The primary node will be placed at 0@0.
	"	
	nodesByPriority
		do: [ :map |
			| node xy |
			node := map value.
			xy := 0@0.
			self layoutRecursiveWithNode: node relativePosition: xy seenBefore: (Set new).
			xy := xy + (0@yIncrement).
			]. 

	
	
]

{ #category : #layout }
HumDiagram >> layoutDistanceFromNode: nodeA toNode: nodeB [
	"Calculate the length of the connection between the nodes."

	| xA xB yA yB xR yR r2 r|
	xA := (( self mapNodePosition ) at: nodeA ) x.
	yA := (( self mapNodePosition ) at: nodeA ) y.
	xB := (( self mapNodePosition ) at: nodeB ) x.
	yB := (( self mapNodePosition ) at: nodeB ) y.
	
	xR := xA - xB.
	yR := yA - yB.
	
	r2 := ( xR * xR ) + ( yR * yR ).
	r := r2 sqrt.
	^r
	
]

{ #category : #layout }
HumDiagram >> layoutEnergyOnNode: nodeA fromNode: nodeB [
	"Calculate a energy scalar. 
	 Rules are similar to elctrostatic energy.
	 But since the layout is in a 2-D world, 
	  the energy rules are linear. (in this version)
	 Note: This method assumes that nodeA and nodeB are directly connected.
	"
	| r qA qB attraction repulsion attractionFactor repulsionFactor |
	
	"Radius is the length of the connection between the nodes."
	r := self layoutDistanceFromNode: nodeA toNode: nodeB.
	
	"Attractive force increases when the radius increases.
	This is analog of spring rate.
	"
	attractionFactor  := 1.0.
	attraction := attractionFactor * r.
	
	"Repulsion increases when charge Q (number of direct connections) increases.
	"
	repulsionFactor := 1.0.
	qA := self countNeighborsOfNode: nodeA.
	qB := self countNeighborsOfNode: nodeB.
	
	repulsion := repulsionFactor * ( qA + qB ).
	"TODO: Consider using minimum of qA or qB.
	 TODO: Consider dividing by r.
	"
	
	^ ( attraction - repulsion ). 
	"Notes: 
	1. Return value is a scalar quantity. Not a vector.
	2. Since the connected entities require space on the diagram,
	     it may work better if we sqared the connection 'charge' quantities.
	3. Perhaps we should divide by 'radius' in the repulsion calculation.
	4. This calculation assumes the that nodeA and nodeB are directly connected.
	5. What if return was ( attraction / repulsion )?
	"
	"TODO: Refactor so that attraction and repulsion factors are instance variables and externally adjustable."
	"TODO: Set up a UI where user can tinker with the factors. (And we can verify the intended layout effects.)"
	
]

{ #category : #layout }
HumDiagram >> layoutNode: aNode from: aPosition by: anIncrement [
	"Find a place for the given node starting from the given position.
	 Increment the position until an empty position is found.
	 Return the position where we placed the node.
	Typically, aPosition is down-right from an existing node, and the increment is down - giving a tree-like structure.
	"				
	| proposedPosition nodePosition |	
	proposedPosition := aPosition.
	nodePosition := self getPositionForNode: aNode.
	"If the node has already been positioned, leave it where it is."
	[ nodePosition  isNil]
		whileTrue: [ "Is the proposed position empty?"
			((self mapPositionNode) at: proposedPosition ifAbsent: [nil])
				ifNil: [ "Yes. It is empty"
					nodePosition := proposedPosition.
					self setNode: aNode position: nodePosition.
					]
				ifNotNil: ["Compute next proposed position"	
					 proposedPosition := proposedPosition + anIncrement.
					].
			].			
	"At this point, proposedPosition should be the related node`s position"
	self assert: ( nodePosition = (self getPositionForNode: aNode) ).
		
	"Return the position where we placed the node."	
	^ nodePosition.

]

{ #category : #layout }
HumDiagram >> layoutRecursiveWithNode: node relativePosition: relativePosition seenBefore: priorNodes [
	"Assign initial position to this node, and then, using recursion, to its neighbors.
	- relativePosition is suggested first position to try. 
	If that position is already filled, try other positions below it until one is found.
	- priorNodes contains nodes that have been seen before in this recursion.
	If this node is also in priorNodes, 
	 it has already been handled and we return immediately to avoid a loop.
	In some implementations,
	  we might want to limit the depth (based on priorNodes size).
	"
	| xIncrement  xy downStreamNodes upStreamNodes yIncrement |
	"Return immediately if this node has been seen before.
	Otherwise add it to the nodes we have seen before and proceed."
	( priorNodes includes: node ) ifTrue: [ ^self ] ifFalse: [ priorNodes add: node ].
	
	"Following must be set before calling me."
	self assert: ( nodeExtent notNil ).
	self assert: ( nodeSpacing notNil ).
	"Following is assumed in code below."
	self assert: ( nodeExtent  isKindOf: Point).
	self assert: ( nodeSpacing isKindOf: Point).
	
	"Compute increments between grid locations."
	"In this version, the placement is on a rectalinear grid.
	But other/future versions may be radial and/or decrease as the number of priorNodes increases.
	"
	xIncrement := (nodeSpacing x) + (( nodeExtent x )/2).
	yIncrement := (nodeSpacing y) + (( nodeExtent y )/2).	

	xy := self layoutNode: node from: relativePosition by: (0@yIncrement).
	
	"Next: Find positions for nodes that are downstream from this node."
	downStreamNodes := self getNodesDownstreamFromNode: node.
	downStreamNodes
				do: [ :downStreamNode | "Place downstream nodes to right and below of priority node."
					self layoutRecursiveWithNode: downStreamNode 
					             relativePosition: (xy + (xIncrement@0)) 
					                  seenBefore: priorNodes.

					"ToDo: Calculate which node positions are intersected by connecting lines.
					       Assign the central node or a dummy node to those positions also.
					       The parent node might be expanded to fill or the dummy node never drawn.
					"
					].			
	"Next: Find positions for nodes that are upstream from this node."
	upStreamNodes := self getNodesUpstreamFromNode: node.
	upStreamNodes
				do: [ :upStreamNode | "Place upstream nodes to left and below priority node."
					self layoutRecursiveWithNode: upStreamNode 
					             relativePosition: (xy - (xIncrement@0))
					                  seenBefore: priorNodes.

					"ToDo: Calculate which node positions are intersected by connecting lines."
					].	
]

{ #category : #accessing }
HumDiagram >> mapNodePosition [
	^ mapNodePosition ifNil: [ mapNodePosition := Dictionary new. ].
]

{ #category : #accessing }
HumDiagram >> mapPositionNode [
	" What node is at a position"
	^ mapPositionNode ifNil: [ mapPositionNode := Dictionary new. ].
]

{ #category : #accessing }
HumDiagram >> nodeExtent: aPoint [ 
	nodeExtent := aPoint
]

{ #category : #accessing }
HumDiagram >> nodeSpacing: aPoint [ 
	nodeSpacing := aPoint
]

{ #category : #accessing }
HumDiagram >> nodes [
	"Model nodes as a set of objects."
	^ self graph nodes.
]

{ #category : #accessing }
HumDiagram >> setNode: aNodeObject position: aPosition [
	"Node should also be in nodes collection for internal consistency."
	self addNode: aNodeObject.
	self mapNodePosition at: aNodeObject  put: aPosition.
	self mapPositionNode at: aPosition put: aNodeObject.
]

{ #category : #accessing }
HumDiagram >> title [
	^ title ifNil: [ title := '** Diagram has no title! **'].
]

{ #category : #accessing }
HumDiagram >> title: aString [
	title := aString.
	
]
