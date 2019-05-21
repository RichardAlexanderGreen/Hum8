"
A comment line is a line in a single-line or multi-line comment.
The lines in the multi-line comment are signaled by a line that begins with a '(' -- a right parend.
The lines end with a line that ends with a ')' -- a left parend.

Note: In some ontology text files, 
an additional convention allows a frame or subframe that begins with a 'Comment:' label 
and ends when the next label (of any kind) is encountered. 
"
Class {
	#name : #HumCommentLine,
	#superclass : #HumFrameLine,
	#category : #'Hum-Language'
}

{ #category : #'as yet unclassified' }
HumCommentLine >> source: aString [
	"override supertype parsing"
	source := aString.
]
