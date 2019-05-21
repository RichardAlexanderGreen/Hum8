"
HumGraph is a simple directed graph.
See also: HumDiagram 

Instance Variables:
	connectionLabels	<Set> of { from -> to. label. }
	nodeLabels	<(Set of: Associations)>
"
Class {
	#name : #HumGraph,
	#superclass : #Object,
	#instVars : [
		'connectionLabels',
		'nodeLabels'
	],
	#category : #'Hum-Graph'
}

{ #category : #accessing }
HumGraph >> addConnection: anAssociation [ 
	Error signal: 'a connection without a label is bad practice.'.
	self addConnection: anAssociation label: 'unknown'.
]

{ #category : #accessing }
HumGraph >> addConnection: anAssociation label: aString [
	"Note: A pair of nodes may have more than one relation."
	| fromNode toNode connection |
	self assert: (anAssociation isKindOf: Association).
	"Make sure the nodes are in the node set."
	fromNode := anAssociation key.
	toNode := anAssociation value.
	self addNode: fromNode.
	self addNode: toNode.
	"There can be multiple connections between two nodes. But must have distinct labels."
	( self connectionLabels ) add: { anAssociation. aString. }. "A Dictionary might produce more readable code."
	connection := Dictionary new.
	connection at: #fromNode put: fromNode.
	connection at: #toNode put: toNode.
	connection at: #label put: aString.
	self connections add: connection.
]

{ #category : #accessing }
HumGraph >> addNode: anObject [ 
	"Add the given object to the set of nodes"
	" Note that each object / node is unique"
	self addNode: anObject label: (anObject asString).
]

{ #category : #accessing }
HumGraph >> addNode: anObject label: aString [
	"Add the given object to the Set of node-labels"
	" Note that each object / node is unique"
	"TODO: Shouldn't this be an association?"
	( self nodeLabels ) add: { aString. anObject. }
]

{ #category : #accessing }
HumGraph >> connectionLabels [
	"Note: A pair of nodes may have more than one relation."
	"See: #addConnection:label:"
	"Set of { fromNode -> toNode. label. }"
	^ connectionLabels ifNil: [ connectionLabels := Set new ].
]

{ #category : #accessing }
HumGraph >> connections [
	"Return the connections (associations) in this graph."
	| bagConnections |
	"TODO: Improve code readability.
	Refactor such that connections = Dictionary 
	and each connection = Dictionary with keyes #fromNode #toNode #label. "
	bagConnections := Bag new.
	(self connectionLabels)
		do: [ :entry |
			"entry looks like {  association. label.  }"
			bagConnections add: (entry at: 1 ).
			].
	^bagConnections.
]

{ #category : #'as yet unclassified' }
HumGraph >> connectionsFrom: aNode [ 
	"Get the outbound connections from this node. "
	| outboundConnections |
	outboundConnections := Set new.
	(self connectionLabels)
		do: [ :connectionLabel |
				| association label fromNode toNode |
				association := connectionLabel at: 1.
				label := connectionLabel at: 2.
				fromNode := association key.
				toNode := association value.
				(fromNode = aNode) 
						ifTrue: [ outboundConnections add: connectionLabel ].
			 ].
	^outboundConnections.
]

{ #category : #evaluating }
HumGraph >> countNeighborsOfNode: aNode [
	"Return the number of neighbors of this node.
	 (Count nodes that are directly connected to this node)"
	| count |
	count := 0.
	( self connections ) 
		do: [ :map | (((map key) = aNode) or: [(map value) = aNode]) 
			ifTrue: [ count := count + 1 ] ].
	^ count
]

{ #category : #evaluating }
HumGraph >> hasCycle [
	"Does the graph contain at least one cycle?"
	| |

	nodeLabels
		do: [:nodeLabel |
			| label rootNode downStream |
			label := nodeLabel at: 1.
			rootNode := nodeLabel at: 2.
			"downStreamFrom: will not extend leafs that match root"
			downStream := self nodesDownStreamFrom: rootNode.
			((downStream leafNodes) include: rootNode) ifTrue: [^true].
			].
	^false.
]

{ #category : #accessing }
HumGraph >> nodeLabels [
	^nodeLabels ifNil: [ nodeLabels := Set new ].
]

{ #category : #accessing }
HumGraph >> nodes [
	"Return the nodes in this graph."
	| bagNodes |
	bagNodes := Bag new.
	(self nodeLabels)
		do: [ :entry |
			"entry looks like {  label. object. }"
			bagNodes add: (entry at: 2 ).
			].
	^bagNodes.
]

{ #category : #evaluating }
HumGraph >> nodesDownStreamFrom: aRootNode [ 
	"Collect the nodes that are down-stream from a root node."
	| upStream downStream |
	"Set up recursive loop."
	upStream := Set new.
	"Avoid cycles."
	downStream := self nodesDownStreamFrom: aRootNode butNotIn: upStream.
	^downStream.
	
]

{ #category : #evaluating }
HumGraph >> nodesDownStreamFrom: aRootNode butNotIn: upStreamNodes [ 
	"Find nodes that are down-stream from the root node but not in the upStreamNodes."
	| downStreamNodes immediateBranchNodes |
	"Note: It is possible for a pair of nodes to have more than one relationship."
	immediateBranchNodes := Set new.
	(self connectionLabels)
		do: [ :connectionLabel |
			| association label fromNode toNode | 
			"Unpack the tuple."
			association := connectionLabel at: 1.
			self assert: (association isKindOf: Association). "Might be changed to Association"
			label := connectionLabel at: 2.
			fromNode := association key.
			toNode := association value.
			(fromNode = aRootNode) ifTrue: [ immediateBranchNodes add: toNode ].
			].
	downStreamNodes := immediateBranchNodes.
	"TODO: ADD RECURSION AFTER THIS IS DEBUGGED."
	^downStreamNodes.
	
]
