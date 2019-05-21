Class {
	#name : #HumCompiler,
	#superclass : #Object,
	#category : #'Hum-RunTime'
}

{ #category : #'as yet unclassified' }
HumCompiler class >> evaluate: aString for: aHumDispatcher logged: aFalse [
	"Delegate to the Smaltalk compiler"

	| realCompiler |
	realCompiler := SmalltalkImage compiler.
	realCompiler
		source: aString;
		logged: aFalse;
		receiver: aHumDispatcher;
		evaluate
]
