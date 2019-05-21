"
This is a *wrapper* on the file system API.
The purpose is to isolate Hum code from the file system implementation.
(Motivation: Pharo recently deprecated old file system classes in favor of a *cleaner* implementation.)

Since Hum only deals with character (UTF-8)  files,    (2019 May)
  the HumStore provide a minimal API for working with those.
"
Class {
	#name : #HumStore,
	#superclass : #Object,
	#instVars : [
		'directory'
	],
	#classInstVars : [
		'defaultStore'
	],
	#category : #'Hum-Store'
}

{ #category : #access }
HumStore class >> defaultDirectory [
	^self defaultStore  directory path.
]

{ #category : #access }
HumStore class >> defaultStore [
	^ defaultStore
]

{ #category : #access }
HumStore class >> defaultStore: aHumStore [ 
	"Save a store to be used as a default"
	defaultStore := aHumStore.
]

{ #category : #'intance creation' }
HumStore class >> onDirectoryNamed: aDirectoryPath [
	"Create an instance associated with the given directory."
	| instance dir |
	instance := self new.
	dir := FileReference  fileSystem: (FileSystem disk) path: aDirectoryPath.
	instance directory: dir.
	^instance
]

{ #category : #access }
HumStore >> directory [
	^ directory
]

{ #category : #access }
HumStore >> directory: aFileReference [ 
	"Store the directory reference that is associated with the store."
	| pathString |
	pathString := aFileReference path.
	self assert: (aFileReference isKindOf: FileReference) description: 'a FileReference to a file directory is expected. path =',  pathString.
	self assert: (aFileReference isDirectory) description: 'The given path is not a directory.'.
	directory := aFileReference .
]

{ #category : #'instance creation' }
HumStore >> readStreamFromFileNamed: aFileName [ 
	 "Return a read stream associated with the given file name on my directory"
	| fileReference stream |
	fileReference := FileReference fileSystem:  directory  fileSystem path: directory pathString, '/', aFileName.
	stream := fileReference readStream.
	^stream.
]

{ #category : #'instance creation' }
HumStore >> writeStreamOnFileNamed: aFileName [
	"Return a write stream associated with the given file name on my directory"
	| fileReference stream |
	fileReference := FileReference fileSystem:  directory  fileSystem path: directory pathString, '/', aFileName.
	stream := fileReference writeStream.
	^stream.
]
