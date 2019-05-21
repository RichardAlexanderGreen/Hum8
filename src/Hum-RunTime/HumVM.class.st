"
HumVM is a thought experiment for a virtural machine and byte code.
After some consideration, I (Richard Alexander Green) decided that a byte code is not a good idea at this time.
If compiled code is necessary for efficiency, it would make more sense at this time to translate to a language that has a compiler.
 
Byte Code Advantages:
- The resulting code may be more compact than the source and therefore it would require less delivery time.
- - counter: Delivery time for an agent`s code is generally not an important factor except possibly for a dialog agent.
- A byte code might be more easily compiled to a native ISA.
- - counter: It is easier to translate to another language.

Disadvantages:
- If the normal delivery is byte code, the resulting ecology discourages transparency.
- An existing VM such as JVM or BEAM would be more acceptable to many audiences.

Instance Variables:
	slots	<Dictionary>
	transferVector	<Dictionary>
	measure	<HumMeasure>
"
Class {
	#name : #HumVM,
	#superclass : #Object,
	#instVars : [
		'slots',
		'transferVector',
		'measure'
	],
	#category : #'Hum-RunTime'
}

{ #category : #accessing }
HumVM >> measureRegister [
	^ measure ifNil: [ measure := HumMeasure new. ].
]

{ #category : #'self evaluating' }
HumVM >> runInstruction: aHumInstruction [ 
	| microCode |
	"Get the microCode. (a block)"
	microCode := ( self transferVector ) at: (aHumInstruction operation) 
	                              ifAbsent: [ Error signal: 'No such opCode: ', (aHumInstruction operation)].
	"Run the microCode. (a block)"
	microCode value: ( self slots at: (aHumInstruction operand)).
	"Assure cascade."
	^self. 
]

{ #category : #accessing }
HumVM >> setSlot: slotIndex to: aHumObject [ 
	"The slots allow objects to be referenced by byte-code indices."
	
	(self slots) at: slotIndex put: aHumObject.
	"Slots are used like registers in this VM thought-experiment. "
]

{ #category : #accessing }
HumVM >> slots [
	"slots allow objects to be referenced by byte-code indices."
	^ slots ifNil: [slots := Dictionary new. ].
]

{ #category : #accessing }
HumVM >> transferVector [
	transferVector ifNil: [ transferVector := Dictionary new.
		transferVector 
			at: 001 put: [ :x | measure := x  ];
			at: 002 put: [ :x | measure := measure + x ];
			at: 003 put: [ :x | measure := measure - x ];
			at: 000 put: [ :x | self halt ].
		].
	^transferVector.
]
