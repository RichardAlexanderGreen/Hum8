"
The purpose of this test suite is to characterize the Glamour package, 
and thus, understand how it is intended to be used.

""This group of tests follows 'Deep into Pharo - chapter 10' ""


"
Class {
	#name : #HGlamourTest,
	#superclass : #Object,
	#category : #'Hum-X'
}

{ #category : #'as yet unclassified' }
HGlamourTest >> test100ReadMe [
	"This group of tests follows 'Deep into Pharo - chapter 10' "
	self skip: 'Just a ReadMe'.
]

{ #category : #'as yet unclassified' }
HGlamourTest >> test110Page192 [
	"Example at page 192"
	| browser |
	self skip: 'I am finished with this example'.
	browser := GLMFinder new.
	browser show: [ :a | a list display: #children ].
	browser openOn: FileSystem disk root.
]

{ #category : #'as yet unclassified' }
HGlamourTest >> test110Page193a [
	"Example at page 193"
	| browser |
	self skip: 'I am finished with this example'.
	browser := GLMFinder new.
	browser show: [ :a | 
		a list 
		    when: #isDirectory;
			display: #children; 
			format: #basename ].
	browser openOn: FileSystem disk root.
]

{ #category : #'as yet unclassified' }
HGlamourTest >> test110Page193b [
	"Example at page 193"
	| browser |
	self skip: 'I am finished with this example'.
	browser := GLMFinder new.
	browser show: [ :a | 
		a list 
		    when: #isDirectory;
			display: #children; 
			format: #basenameWithIndicator ].
	browser openOn: FileSystem disk root.
]

{ #category : #'as yet unclassified' }
HGlamourTest >> test110Page194 [
	"Example at page 194"
	| browser |
	self skip: 'I am finished with this example'.

	browser := GLMFinder new
						variableSizePanes;
						title: 'Navigate file structure';
						yourself.
	browser show: [ :a | 
		a list 
		    when: #isDirectory;
			display: [:fileRef | [fileRef children] on: Exception do: [ Array new ] ];
			format: #basenameWithIndicator.
		a text
			when: #isFile;
			display: [:fileRef | 
							[ fileRef readStream contents] 
									on: Exception 
									do: ['Cannot display content of file'].
									].
						].
	browser openOn: FileSystem disk root.
]
