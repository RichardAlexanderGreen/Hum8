"
The Data Frame class standardizes the way we structure and format data.

Data Frame versus Message:

A HumMessage specializes a HumDataFrame.
A Message Entity requires sender, reciever, sent-when, statement, and noun-values.
The Message class provides serialization and deserialization services.

A DataFrame may hold any entity structure and may be used for purposes other than actor-to-actor communication.
For example, we may represent configuration, layout, landscape, or actor suspence data in Data Frames. 

Data Frame includes methods to serialize and de-serialize data. (TODO)

"
Class {
	#name : #HumDataFrame,
	#superclass : #Object,
	#instVars : [
		'title'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'instance creation' }
HumDataFrame class >> title: aString [ 
	| instance |
	instance := self basicNew.
	instance title: aString.
	^instance.
]

{ #category : #access }
HumDataFrame >> title: aString [ 
	title := aString.
]
