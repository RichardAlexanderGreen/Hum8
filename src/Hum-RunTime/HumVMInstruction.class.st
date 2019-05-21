"
HumVM and HumVMInstruction are artifacts of a thought experiment for a virtural machine and byte code.

See the HumVM class comment for further information.

Instance Variables:
	operation	<Integer>
	operand	<Integer>

Class Instance Variables:
	codeNames	<Dictionary>
"
Class {
	#name : #HumVMInstruction,
	#superclass : #Object,
	#instVars : [
		'operation',
		'operand'
	],
	#classInstVars : [
		'codeNames'
	],
	#category : #'Hum-RunTime'
}

{ #category : #accessing }
HumVMInstruction class >> codeNames [
	codeNames ifNotNil: [ ^codeNames ].
	"Otherwise, initialize . . ."
	codeNames := Dictionary new.
	codeNames at: 000 put: 'Halt'.
]

{ #category : #'instance creation' }
HumVMInstruction class >> opCode: opCode value: objectIndex [ 
	| instruction |
	instruction := self basicNew.
	instruction operation: opCode.
	instruction operand: objectIndex.
	^instruction.
]

{ #category : #associating }
HumVMInstruction class >> opCodeName [
	name := (self codeNames ) at: (self operation).
	^name.
]

{ #category : #associating }
HumVMInstruction >> opCodeName [
	| name |
	name := ( HumVMInstruction codeNames ) at: (self operation) ifAbsent: ['Unknown'].
	^name.
]

{ #category : #accessing }
HumVMInstruction >> operand [
	^ operand ifNil: [ Error signal: 'operand not set in HumInstruction'.  operand := 000].
]

{ #category : #accessing }
HumVMInstruction >> operand: objectIndex [ 
	operand := objectIndex
]

{ #category : #accessing }
HumVMInstruction >> operation [
	^ operation ifNil: [ Error signal: 'op code not set in HumInstruction'.  operation := 000].
]

{ #category : #accessing }
HumVMInstruction >> operation: opCode [ 
	self assert: ( opCode < 256 ).
	self assert: ( opCode >= 0 ).
	operation := opCode.
]

{ #category : #associating }
HumVMInstruction >> slotName [
	( (self operand) = 000 ) ifTrue: [^ 'None' ].
	Error signal: 'Instruction slot name is not defined.'.
	^'Undefined.'
]
