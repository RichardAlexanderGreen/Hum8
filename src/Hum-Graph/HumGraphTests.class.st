Class {
	#name : #HumGraphTests,
	#superclass : #Object,
	#category : #'Hum-Graph'
}

{ #category : #'access tests' }
HumGraphTests >> test110GraphHasNodes [
	"A graph has a collection (set) of nodes"
	| graph |
	graph := HumGraph new.
	self assert: ( graph nodes isEmpty ).
]

{ #category : #'access tests' }
HumGraphTests >> test120GraphHasConnections [
	"A graph has a collection (set) of connections."
	| graph |
	graph := HumGraph new.
	self assert: ( graph connections isEmpty ).
]

{ #category : #'access tests' }
HumGraphTests >> test130PutGetNode [
	"A graph has a collection (set) of nodes"
	| graph node node2 |
	graph := HumGraph new.
	self assert: ( graph nodes isEmpty ).
	
	node := 'My content just happens to be a string but I could be any kind of object'.
	graph addNode: node.
	self assert: ( graph nodes size = 1 ).
	
	graph nodes do: [ :entry | self assert: (entry == node )].
]

{ #category : #'access tests' }
HumGraphTests >> test140PutGetConnector [
	"A graph has a collection (set) of connections."
	| graph node node2 |
	graph := HumGraph new.
	self assert: ( graph nodes isEmpty ).
	
	node := 'My content just happens to be a string but I could be any kind of object'.
	graph addNode: node.
	self assert: ( graph nodes size = 1 ).
	
	node2 := 'My content also just happens to be a string but I could be any kind of object'.
	graph addNode: node2.
	self assert: ( graph nodes size = 2 ).
	
	graph addConnection: ( node -> node2 ) label: 'A connection represents some kind of relationship.'.
	self assert: ( graph connections size = 1 ).
]

{ #category : #'access tests' }
HumGraphTests >> test150PutGetLabeledConnections [
	"A graph has a collection (set) of connections"
	| graph nodeA nodeB |
	graph := HumGraph new.
	self assert: ( graph nodes isEmpty ).
	
	nodeA := 'My content just happens to be a string but I could be any kind of object'.
	graph addNode: nodeA.
	self assert: ( graph nodes size = 1 ).
	
	nodeB := 'My content also just happens to be a string but I could be any kind of object'.
	graph addNode: nodeB.
	self assert: ( graph nodes size = 2 ).
	
	graph addConnection: ( nodeA -> nodeB ) label: 'A to B'.
	self assert: ( graph connections size = 1 ).
	
	graph addConnection: ( nodeB -> nodeA ) label: 'B to A'. "Creates a cycle."
	self assert: ( graph connections size = 2 ).
	
	graph addConnection: ( nodeA -> nodeB ) label: 'A to B again'.
	self assert: ( graph connections size = 3 ).

]

{ #category : #'access tests' }
HumGraphTests >> test152PutGetParallelConnections [
	"A graph has a collection (set) of nodes"
	| graph nodeA nodeB nodeC nDownStream downStreamNodes connectionsFromA nConnections |
	graph := HumGraph new.
	self assert: ( graph nodes isEmpty ).
	
	nodeA := 'A'.
	graph addNode: nodeA.
	self assert: ( graph nodes size = 1 ).
	
	nodeB := 'B'.
	graph addNode: nodeB.
	self assert: ( graph nodes size = 2 ).
	
	nodeC := 'C'.
	graph addNode: nodeC.
	self assert: ( graph nodes size = 3 ).

	graph addConnection: ( nodeA -> nodeB ) label: 'A to B'.
	self assert: ( graph connections size = 1 ).
	
	graph addConnection: ( nodeB -> nodeA ) label: 'B to A'. "creates a CYCLE"
	self assert: ( graph connections size = 2 ).
	
	graph addConnection: ( nodeA -> nodeB ) label: 'A to B again'.
	self assert: ( graph connections size = 3 ).
	
	graph addConnection: ( nodeA -> nodeC ) label: 'A to C'.
	self assert: ( graph connections size = 4 ).
	
	connectionsFromA := graph connectionsFrom: nodeA.
	nConnections := connectionsFromA size.
	self expect: 3 actual: nConnections description: 'Node A has 3 outbound connections.'.
	
	downStreamNodes := graph nodesDownStreamFrom: nodeA.
	nDownStream := downStreamNodes size.
	self expect: 2 actual: nDownStream description: 'Expect two nodes down-stream from nodeA.'.
	self assert: (downStreamNodes includes: nodeB). "But it includes it just once."
	self assert: (downStreamNodes includes: nodeC).
	

]

{ #category : #'access tests' }
HumGraphTests >> test160DetectCycle [
	"A graph has a collection (set) of nodes"
	| graph nodeA nodeB nodeC |
	false ifFalse: [ Transcript cr; show: 'test160DetectCycle is turned off.'. ^self.].
	graph := HumGraph new.
	self assert: ( graph nodes isEmpty ).
	
	nodeA := 'A'.
	graph addNode: nodeA label: 'nodeA'.
	nodeB := 'B'.
	graph addNode: nodeB label: 'nodeB'.
	nodeC := 'C'.
	graph addNode: nodeC label: 'nodeC'.
	graph addConnection: ( nodeA -> nodeB ) label: 'A to B'.
	graph addConnection: ( nodeB -> nodeC ) label: 'B to C'.
	self assert: (graph hasCycle) not.
	graph addConnection: ( nodeC -> nodeA ) label: 'C to A creates cycle'.
	self assert: (graph hasCycle).
	
	

]
