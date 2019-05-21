"
the Client simulates client requests.
(Primarily in test/simulation context.)
"
Class {
	#name : #HClient,
	#superclass : #Object,
	#category : #'Hum-X'
}

{ #category : #'message handling' }
HClient class >> get: aURI [
	"Send URI as a HTTP GET - return ZnResponse."
	| response |
	response := ZnClient get: aURI.
	^response.
]

{ #category : #'as yet unclassified' }
HClient >> clientSettings [
	self assert: (super settings isKindOf: ZnUserAgentSettings).
	^ super settings settings.
]
