"
After a bit of experimentation with these tests, I have decided that the HumVM is not a worthwhile feature.
Basically, the code and effort required to load the slots will overwhelm any savings in code space by compressing to byte code.

I had also thought that byte code would simplify translation to multiple languages, but I don't see that working out either.'
"
Class {
	#name : #HumByteCodeTests,
	#superclass : #HumTestCase,
	#instVars : [
		'humVM'
	],
	#category : #'Hum-Tests'
}

{ #category : #'as yet unclassified' }
HumByteCodeTests >> setUp [
	"For convenience, create a Hum VM instance for all of the tests to use."
	
	humVM := HumVM new.
]

{ #category : #'as yet unclassified' }
HumByteCodeTests >> test110EachInstructionHasTwoBytes [
	"A Hum byte code instruction has two bytes -- one for operation and one for operand."
	| instruction |
	instruction := HumVMInstruction new.
	instruction operation: 255.
	instruction operand: 254.

	self assert: 255 equals: ( instruction operation).
	self assert: 254 equals: ( instruction operand).
	
]

{ #category : #'as yet unclassified' }
HumByteCodeTests >> test120OpCode000IsHalt [
	"An opCode of 000 is a halt instruction. (operand is ignored)"
	| instruction |
	instruction := HumVMInstruction opCode: 000 value: 000.
	self assert: 'Halt' equals: ( instruction opCodeName ).
]

{ #category : #'as yet unclassified' }
HumByteCodeTests >> test130Operand000IsNone [
	"An operand index of zero is treated as None.
	(For some operators, this will be nonsence and should not compile.)"
	| instruction |
	instruction := HumVMInstruction opCode: 000 value: 000.
	self assert: 'None' equals: instruction slotName. 
]

{ #category : #'as yet unclassified' }
HumByteCodeTests >> test210MeasureLoad [
	"Load measure into measure-arithmetic register."
	| instruction measure |
	measure := (HumMeasure quantity: 210 units: 'meter').
	humVM setSlot: 001 to: measure.
	instruction := HumVMInstruction opCode: 001 value: 001.
	humVM runInstruction: instruction.
	self assert: ( humVM measureRegister ) equals: measure.
]

{ #category : #'as yet unclassified' }
HumByteCodeTests >> test220MeasureAdd [
	"Add measure into measure-arithmetic register."
	| instruction measureA measureB measureC |
	
	"First load a measure into the register."
	measureA := HumMeasure quantity: 220 units: 'meter'.
	humVM setSlot: 001 to: measureA.
	instruction := HumVMInstruction opCode: 001 value: 001.
	humVM runInstruction: instruction.
	self assert: ( humVM measureRegister ) equals: measureA.
	
	"Add another measure into the register."
	measureB := HumMeasure quantity: 330 units: 'meter'.
	humVM setSlot: 002 to: measureB.
	instruction := HumVMInstruction opCode: 002 value: 002.
	humVM runInstruction: instruction.
	
	measureC := HumMeasure quantity: 550 units: 'meter'.
	self assert: ( humVM measureRegister ) equals: measureC.
	
]

{ #category : #'as yet unclassified' }
HumByteCodeTests >> test230MeasureMinus [
	"Add measure into measure-arithmetic register."
	| instructionA instructionB measureA measureB measureC |
	
	"First load a measure into the register."
	measureA := HumMeasure quantity: 330 units: 'meter'.
	humVM setSlot: 001 to: measureA.
	instructionA := HumVMInstruction opCode: 001 value: 001.
	humVM runInstruction: instructionA.
	self assert: ( humVM measureRegister ) equals: measureA.
	
	"Subtract another measure from the register."
	measureB := HumMeasure quantity: 220 units: 'meter'.
	humVM setSlot: 002 to: measureB.
	instructionB := HumVMInstruction opCode: 003 value: 002.
	humVM runInstruction: instructionB.
	
	measureC := HumMeasure quantity: 110 units: 'meter'.
	self assert: ( humVM measureRegister ) equals: measureC.
	
]
