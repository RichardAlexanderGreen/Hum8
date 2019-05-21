"
This class contains tests.
"
Class {
	#name : #HumStoreTest,
	#superclass : #HumTestCase,
	#category : #'Hum-Tests'
}

{ #category : #tests }
HumStoreTest >> test120CharacterizeFileSystem [
	"Characterize the needed file-system API: FileSystem File FileReference FileStream."
	| disk rootRef workingRef |
	disk := FileSystem disk. "a FileSystem"
	self assert: disk class equals: FileSystem.
	rootRef := disk root. "File @ /"
	self assert: rootRef class equals: FileReference.
	self assert: rootRef pathString equals: '/'.
	workingRef := disk workingDirectory. 
	self assert: workingRef class equals: FileReference.
	self assert: workingRef pathString equals: '/'. "WARNING: This may depend on how image is started."
	

]

{ #category : #tests }
HumStoreTest >> test130CharacterizeFile [
	"Characterize the needed file-system API:  File FileStream."
	| file stream testString resultString |
	
	file := File named: './Developer/Smalltalk/Hum8/data/test.txt'.
	file delete. "Clean-up prior file if needed."
	stream := file writeStream.
	self assert: stream class equals: BinaryFileStream. 
	
	testString := 'This is only a test.'.
	stream nextPutAll: testString.
	stream close. "BinaryFileStream: '~/Developer/data/test.dat'"
	
	stream := file readStream.
	resultString := stream contents asString.
	self assert: resultString equals: testString.
	stream close.
	

]

{ #category : #tests }
HumStoreTest >> test210createHumStoreInstance [
	"HumStore  hides File but presents a stream."
			
	| store |
	store := HumStore onDirectoryNamed: './Developer/Smalltalk/Hum8/data'.
	self assert: store class equals: HumStore.
]

{ #category : #tests }
HumStoreTest >> test220createWriteStreamOnFile [
	"Create a writeStream associated with a file name."
	| fileName store writeStream |
	fileName := 'HumStoreTest.txt'.
	store := HumStore onDirectoryNamed:  './Developer/Smalltalk/Hum8/data'.
	writeStream := store writeStreamOnFileNamed: fileName.
	self assert: (writeStream isStream) description: 'expect some kind of stream'.
	writeStream close.
]

{ #category : #tests }
HumStoreTest >> test230putStringOnFile [
	"Create a writeStream associated with a file name."
	| fileName store writeStream |
	fileName := 'HumStoreTest.txt'.
	store := HumStore onDirectoryNamed:  './Developer/Smalltalk/Hum8/data'.
	writeStream := store writeStreamOnFileNamed: fileName.
	self assert: (writeStream isStream) description: 'expect some kind of stream'.
	writeStream nextPutAll: 'This is a test of the HumStore API.'.
	writeStream close.
]

{ #category : #tests }
HumStoreTest >> test240readStringFromFile [
	"Create a writeStream associated with a file name."
	| fileName store writeStream readStream inputString resultString |
	"Write something out so we can read it back in."
	fileName := 'HumStoreTest.txt'.
	store := HumStore onDirectoryNamed:  './Developer/Smalltalk/Hum8/data'.
	writeStream := store writeStreamOnFileNamed: fileName.
	self assert: (writeStream isStream) description: 'expect some kind of stream'.
	inputString := 'This is a test of the HumStore API.'.
	writeStream nextPutAll: inputString.
	writeStream close.
	"Read it back in - and check."
	readStream := store readStreamFromFileNamed: fileName.
	self assert: (readStream isStream) description: 'expect some kind of stream'.
	resultString := readStream contents.
	self assert: resultString equals: inputString .
	readStream close.
]

{ #category : #tests }
HumStoreTest >> test310setDefaultDirectory [
	"Store a default directory in a class-side variable to save typing and typos."
			
	| defaultDirectory pathString |
	defaultDirectory := './Developer/Smalltalk/Hum8/default'.
	HumStore defaultDirectory: defaultDirectory.
	pathString := HumStore defaultDirectory.
	self assert: pathString equals: defaultDirectory.
]

{ #category : #tests }
HumStoreTest >> test320createWriteStreamOnFileDefault [
	"Create a writeStream associated with a file name."
	| fileName store writeStream |
	fileName := 'HumStoreTest.txt'.
	store := HumStore defaultStore.
	writeStream := store writeStreamOnFileNamed: fileName.
	self assert: (writeStream isStream) description: 'expect some kind of stream'.
	writeStream close.
]

{ #category : #tests }
HumStoreTest >> test330putStringOnFileDefault [
	"Create a writeStream associated with a file name."
	| fileName store writeStream |
	fileName := 'HumStoreTest.txt'.
	store := HumStore defaultStore.
	writeStream := store writeStreamOnFileNamed: fileName.
	self assert: (writeStream isStream) description: 'expect some kind of stream'.
	writeStream nextPutAll: 'This is a test of the HumStore API.'.
	writeStream close.
]

{ #category : #tests }
HumStoreTest >> test340readStringFromFileDefault [
	"Create a writeStream associated with a file name."
	| fileName store writeStream readStream inputString resultString |
	"Write something out so we can read it back in."
	fileName := 'HumStoreTest.txt'.
	store := HumStore defaultStore.
	writeStream := store writeStreamOnFileNamed: fileName.
	self assert: (writeStream isStream) description: 'expect some kind of stream'.
	inputString := 'This is a test of the HumStore API.'.
	writeStream nextPutAll: inputString.
	writeStream close.
	"Read it back in - and check."
	readStream := store readStreamFromFileNamed: fileName.
	self assert: (readStream isStream) description: 'expect some kind of stream'.
	resultString := readStream contents.
	self assert: resultString equals: inputString .
	readStream close.
]
