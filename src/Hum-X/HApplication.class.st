"
An application instance handles HTTP requests.
"
Class {
	#name : #HApplication,
	#superclass : #Object,
	#instVars : [
		'myHandler'
	],
	#category : #'Hum-X'
}

{ #category : #'instance creation' }
HApplication class >> echo [
	"Return an instance of myself handles request by echoing it."
	| instance |
	
	instance := self basicNew.
	instance handler: [:request |  
			| entity  response stream string |
			stream := ReadWriteStream on: ''.
			stream 
				nextPutAll: ( request requestLine method  );
			  nextPutAll: '...';
			  nextPutAll: ( request requestLine uri pathPrintString).
			(request requestLine method sameAs: 'POST') 
				ifTrue: [ "Show POST and query"
					stream nextPutAll: (String cr); nextPutAll: 'POST: '.
					(request requestLine uri query isNil) 
						ifTrue: [stream << ' No query arguments seen.']
						ifFalse:[request requestLine uri queryDo: [:k :v | stream nextPutAll: (k, '=', v, '  ') ].
							]
					].
			
			string := stream contents.
			(string trimBoth size > 0) ifFalse: [string:= 'Method and URI not seen in echo.'].
			(request headers) keysAndValuesDo: [:k :v | string := string, String cr, k,': ',v ].
			entity := ZnStringEntity text: string.  
		  response := ZnResponse ok: entity.
		  response.
		  ].
	^instance.
]

{ #category : #'message handling' }
HApplication >> handleRequest: aZnRequest [ 
	"Return a response for given request"
	| response |
	response := myHandler value: aZnRequest.
	^response.
]

{ #category : #accessing }
HApplication >> handler: aBlockClosure [ 
	"Use the block to handle request"
	myHandler := aBlockClosure.
]
