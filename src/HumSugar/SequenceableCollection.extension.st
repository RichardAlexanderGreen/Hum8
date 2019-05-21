Extension { #name : #SequenceableCollection }

{ #category : #'*HumSugar' }
SequenceableCollection >> include: anObject [
	"Answer whether anObject is one of the receiver's elements."

	^ self includes: anObject.
]
