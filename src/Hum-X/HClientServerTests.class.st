"
NOTE: This test suite is currently disabled by making the supertype ""Object"" instead of ""TestCase"".
"
Class {
	#name : #HClientServerTests,
	#superclass : #Object,
	#category : #'Hum-X'
}

{ #category : #'as yet unclassified' }
HClientServerTests class >> hasErrorTest [
	self halt.
	^false.
]

{ #category : #'as yet unclassified' }
HClientServerTests class >> hasFailedTest [
	self halt.
	^false.
]

{ #category : #'as yet unclassified' }
HClientServerTests class >> hasPassedTest [
	self halt.
	^false.
]

{ #category : #'as yet unclassified' }
HClientServerTests class >> isAbstract [
	^false.
]

{ #category : #'as yet unclassified' }
HClientServerTests >> setUp [
	ZnSingleThreadedServer shutDown.
	ZnMultiThreadedServer shutDown.
	ZnServer shutDown.
]

{ #category : #'as yet unclassified' }
HClientServerTests >> tearDown [
	ZnSingleThreadedServer shutDown.
	ZnMultiThreadedServer shutDown.
	ZnServer shutDown.
]

{ #category : #'Client Characterization Tests' }
HClientServerTests >> test110CharacterizeZnHttpClient [
	"Characterize ZnHttpClient"
	| client settings |

	client := ZnHttpClient new.
	self expect: ZnHttpClient actual: client class.

	"At this point the client has nothing much going on." 
	self assert: client response isNil.
	self assert: client request isNil.
	self expect: ZnUserAgentSettings actual: client settings class.

	settings := client settings settings.
	self expect: 'Zinc HTTP Components 1.0 (Mac OS; N; Mac OS intel 1092; en) 0' actual: (settings at: #agent).
	self expect: true actual: (settings at: #followRedirect ).
	self expect: 7 actual: (settings at: #redirectLimit ).	
	self expect: 180 actual: (settings at: #timeout ).
	self expect: 4 actual: (settings size).
	

]

{ #category : #'Client Characterization Tests' }
HClientServerTests >> test112CharacterizeZnHttpClientNotFound [
	"Characterize ZnHttpClient"
	| client settings response responseString |

	client := ZnHttpClient new.
	self expect: ZnHttpClient actual: client class.

	"At this point the client has nothing much going on." 
	self assert: client response isNil.
	self assert: client request isNil.
	self expect: ZnUserAgentSettings actual: client settings class.

	settings := client settings settings.
	self expect: 'Zinc HTTP Components 1.0 (Mac OS; N; Mac OS intel 1092; en) 0' actual: (settings at: #agent).
	self expect: true actual: (settings at: #followRedirect ).
	self expect: 7 actual: (settings at: #redirectLimit ).	
	self expect: 180 actual: (settings at: #timeout ).
	self expect: 4 actual: (settings size).
	
	client url: 'http://localhost:8081/nonesuch'.
  responseString := client get.
	self expect: ByteString actual: (responseString class).
	self assert: ('Not Found /nonesuch*' matches: responseString ). 
  
  self expect: ZnResponse actual: (client response class).
  self expect: ZnUrl actual: (client url class).
	self expect: ZnUserAgentSession actual: (client session class).
	self expect: ZnUserAgentSettings actual: (client settings class).
	self expect: ZnRequest actual: (client request class).
	self expect: ZnLogSupport actual: (client log class).
	self expect: BlockClosure actual: (client errorHandler class).
	self expect: ZnMultiValueDictionary actual: (client params class).
	self expect: ZnMultiValueDictionary actual: (client headers class).
	self expect: 0 actual: (client headers size).
	
	response := client response.
	self expect: ZnResponse actual: (response class).
	self expect: 404 actual: (response code).
	self expect: 'Not Found' actual: (response statusLine reason).
	
	
	




	

]

{ #category : #'Client Characterization Tests' }
HClientServerTests >> test114CharacterizeZnHttpConnected [
	"Characterize ZnHttpClient"
	| client settings response responseString |

	client := ZnHttpClient new.
	self expect: ZnHttpClient actual: client class.

	"At this point the client has nothing much going on." 
	self assert: client response isNil.
	self assert: client request isNil.
	self expect: ZnUserAgentSettings actual: client settings class.

	settings := client settings settings.
	self expect: 'Zinc HTTP Components 1.0 (Mac OS; N; Mac OS intel 1092; en) 0' actual: (settings at: #agent).
	self expect: true actual: (settings at: #followRedirect ).
	self expect: 7 actual: (settings at: #redirectLimit ).	
	self expect: 180 actual: (settings at: #timeout ).
	self expect: 4 actual: (settings size).
	
	client url: 'http://localhost:8081'.
  responseString := client get.
	self expect: ByteString actual: (responseString class).
	"Happens to be there even though I try to shut it down."
	self assert: ('*<title>Zinc HTTP Components</title>*' matches: responseString ). 
  
  self expect: ZnResponse actual: (client response class).
  self expect: ZnUrl actual: (client url class).
	self expect: ZnUserAgentSession actual: (client session class).
	self expect: ZnUserAgentSettings actual: (client settings class).
	self expect: ZnRequest actual: (client request class).
	self expect: ZnLogSupport actual: (client log class).
	self expect: BlockClosure actual: (client errorHandler class).
	self expect: ZnMultiValueDictionary actual: (client params class).
	self expect: ZnMultiValueDictionary actual: (client headers class).
	self expect: 0 actual: (client headers size).
	
	response := client response.
	self expect: ZnResponse actual: (response class).
	self expect: 200 actual: (response code).
	self expect: 'OK' actual: (response statusLine reason).
	
	
	




	

]

{ #category : #'Client Characterization Tests' }
HClientServerTests >> test115CharacterizeZnHttpHead [
	"Characterize ZnHttpClient"
	| client settings response |

	client := ZnHttpClient new.
	self expect: ZnHttpClient actual: client class.

	"At this point the client has nothing much going on." 
	self assert: client response isNil.
	self assert: client request isNil.
	self expect: ZnUserAgentSettings actual: client settings class.

	settings := client settings settings.
	self expect: 'Zinc HTTP Components 1.0 (Mac OS; N; Mac OS intel 1092; en) 0' actual: (settings at: #agent).
	self expect: true actual: (settings at: #followRedirect ).
	self expect: 7 actual: (settings at: #redirectLimit ).	
	self expect: 180 actual: (settings at: #timeout ).
	self expect: 4 actual: (settings size).
	
	client url: 'http://localhost:8080'.
  response := client head. "In this case, we get ZnResponse back instead of ByteString."
	self expect: ZnResponse actual: (response class).
	 
  self expect: ZnResponse actual: (client response class).
  self expect: ZnUrl actual: (client url class).
	self expect: ZnUserAgentSession actual: (client session class).
	self expect: ZnUserAgentSettings actual: (client settings class).
	self expect: ZnRequest actual: (client request class).
	self expect: ZnLogSupport actual: (client log class).
	self expect: BlockClosure actual: (client errorHandler class).
	self expect: ZnMultiValueDictionary actual: (client params class).
	self expect: ZnMultiValueDictionary actual: (client headers class).
	self expect: 0 actual: (client headers size).
	
	response := client response.
	self expect: ZnResponse actual: (response class).
	self expect: 200 actual: (response code).
	self expect: 'OK' actual: (response statusLine reason).
	
	
	




	

]

{ #category : #'Client Characterization Tests' }
HClientServerTests >> test116CharacterizeZnHttpConnectExternal [
	"Characterize ZnHttpClient"
	| client settings response responseString |
	
	( NetNameResolver isConnected ) 
		ifFalse: [ Transcript cr; show: 'test116CharacterizeZnHttpConnectExternal - no net';cr.
			^self].

	client := ZnHttpClient new.
	self expect: ZnHttpClient actual: client class.

	"At this point the client has nothing much going on." 
	self assert: client response isNil.
	self assert: client request isNil.
	self expect: ZnUserAgentSettings actual: client settings class.

	settings := client settings settings.
	self expect: 'Zinc HTTP Components 1.0 (Mac OS; N; Mac OS intel 1092; en) 0' actual: (settings at: #agent).
	self expect: true actual: (settings at: #followRedirect ).
	self expect: 7 actual: (settings at: #redirectLimit ).	
	self expect: 180 actual: (settings at: #timeout ).
	self expect: 4 actual: (settings size).
	
	client url: 'http://www.w3.org/Help/search'.
  responseString := client get.
	self expect: ByteString actual: (responseString class).
	"Happens to be there even though I try to shut it down."
	self assert: ('*<title>W3C web site search</title>*' matches: responseString ). 
  
  self expect: ZnResponse actual: (client response class).
  self expect: ZnUrl actual: (client url class).
	self expect: ZnUserAgentSession actual: (client session class).
	self expect: ZnUserAgentSettings actual: (client settings class).
	self expect: ZnRequest actual: (client request class).
	self expect: ZnLogSupport actual: (client log class).
	self expect: BlockClosure actual: (client errorHandler class).
	self expect: ZnMultiValueDictionary actual: (client params class).
	self expect: ZnMultiValueDictionary actual: (client headers class).
	self expect: 0 actual: (client headers size).
	
	response := client response.
	self expect: ZnResponse actual: (response class).
	self expect: 200 actual: (response code).
	self expect: 'OK' actual: (response statusLine reason).
	
	
	




	

]

{ #category : #'Client Characterization Tests' }
HClientServerTests >> test120CharacterizeZnHTTPSocketFacade [
	"Characterize ZnHttpClient"
	| client |

	client := ZnHTTPSocketFacade new.
	self expect: ZnHTTPSocketFacade actual: client class.

	"ZnHTTPSocketFacade is stateless. 
	 It does one-shot calls based on the arguments we pass."	

]

{ #category : #'Client Characterization Tests' }
HClientServerTests >> test190CharacterizeHClient [
	"HClient is light wrapper on ZnHTTPSocketFacade."
	| client settings |
	false ifFalse: [ Transcript cr; show: 'test190CharacterizeHClient is turned off'; cr. ^self].
	client := HClient new.
	self expect: HClient actual: client class.

	"At this point the client has nothing much going on." 
	self assert: client response isNil.
	self assert: client request isNil.

	settings := client clientSettings.
	self expect: Dictionary actual: settings class.
	self expect: 'Zinc HTTP Components 1.0 (Mac OS; N; Mac OS intel 1092; en) 0' 
	                  actual: ( settings at: #agent ).
	self expect: true actual: ( settings at: #followRedirect ).
	self expect: 7    actual: ( settings at: #redirectLimit ).	
	self expect: 180  actual: ( settings at: #timeout ).
	"That`s all folks!"
	self expect: 4 actual: (settings size).
]

{ #category : #'Server Characterization Tests' }
HClientServerTests >> test210CharacterizeZnServer [
	| server |
	server := ZnSingleThreadedServer startOn: 8080.
	self expect: ZnSingleThreadedServer actual: server class.
	self expect: 8080 actual: server port.
	self expect: false actual: server log enabled.
	
	server logToTranscript.
	self expect: true actual: server log enabled.
	self expect: nil actual: server lastRequest.
	self expect: nil actual: server lastResponse.
	self expect: true actual: server isRunning.
	self expect: false actual: server isListening.  "???"
	
	server stop.
	self expect: false actual: server isRunning.

	

]

{ #category : #'Server Characterization Tests' }
HClientServerTests >> test211CharacterizeZnServer [
	| server |
	server := ZnMultiThreadedServer startOn: 8080.
	self expect: ZnMultiThreadedServer actual: server class.
	self expect: 8080 actual: server port.
	self expect: false actual: server log enabled.

	server logToTranscript.
	self expect: true actual: server log enabled.
	self expect: nil actual: server lastRequest.
	self expect: nil actual: server lastResponse.
	self expect: true actual: server isRunning.
	self expect: false actual: server isListening.  "???"
	
	server stop.
	self expect: false actual: server isRunning.
	

]

{ #category : #'Client Characterization Tests' }
HClientServerTests >> test212CharacterizeZnHTTPSocketFacadeNotFound [
	"Characterize ZnHttpClient"
	| client responseStream |

	client := ZnHTTPSocketFacade new.
	self expect: ZnHTTPSocketFacade actual: client class.

  responseStream := ZnHTTPSocketFacade httpGet: 'http://localhost:8081/test'.
	self expect: (ByteString) actual: (responseStream class).
	self assert: ('*Not Found*' matches: responseStream).
]

{ #category : #'Server Characterization Tests' }
HClientServerTests >> test212CharacterizeZnServer [
	| server |
	server := ZnMultiThreadedServer startOn: 8081.
	self expect: ZnMultiThreadedServer actual: server class.
	self expect: 8081 actual: server port.
	self expect: false actual: server log enabled.

	server logToTranscript.
	self expect: true actual: server log enabled.
	self expect: nil actual: server lastRequest.
	self expect: nil actual: server lastResponse.
	self expect: true actual: server isRunning.
	self expect: false actual: server isListening.  "???"
	
	server stop.
	self expect: false actual: server isRunning.
	

]

{ #category : #'Client Characterization Tests' }
HClientServerTests >> test214CharacterizeZnHTTPSocketFacadeConnected [
	"Characterize ZnHttpClient"
	| client responseStream |

	client := ZnHTTPSocketFacade new.
	self expect: ZnHTTPSocketFacade actual: client class.

  responseStream := ZnHTTPSocketFacade httpGet: 'http://localhost:8081'.
	self expect: (RWBinaryOrTextStream) actual: (responseStream class).
	self assert: ('*<title>Zinc HTTP Components</title>*' matches: responseStream contents).
]

{ #category : #'Client Characterization Tests' }
HClientServerTests >> test216CharacterizeZnHTTPSocketFacadePost [
	"Characterize ZnHttpClient"
	| client responseStream dict |

	client := ZnHTTPSocketFacade new.
	self expect: ZnHTTPSocketFacade actual: client class.
	
	dict := Dictionary newFrom: {'name'->'tester'.}.
  responseStream := ZnHTTPSocketFacade httpPost: 'http://localhost:8081' args: dict accept: ''.
	self expect: (RWBinaryOrTextStream) actual: (responseStream class).
	self assert: ('*<title>Zinc HTTP Components</title>*' matches: responseStream contents).
]

{ #category : #'Response Characterization Tests' }
HClientServerTests >> test220CharacterizeZnServerGetResponse [
	| server request response |
	server := ZnSingleThreadedServer startOn: 80220.
	
	server logToTranscript.
	
	"client := ZnHttpClient new."
	request := ZnRequest get: 'http://localhost:80220/test220'.
	
	response := server handleRequest: request.
	self expect: ZnResponse actual: ( response class ).
	self expect: 404 actual: ( response statusLine code ).
	self expect: 'Not Found' actual: ( response statusLine reason ).
	
	server delegate: (HApplication echo).
	response := server handleRequest: request.
	self expect: ZnResponse actual: ( response class ).
	self expect: 200 actual: ( response statusLine code ).
	self expect: 'OK' actual: ( response statusLine reason ).
	self expect: 'GET.../test220
Accept: */*
User-Agent: Zinc HTTP Components 1.0
Host: localhost:80220'
       actual: ( response contents ).

	server delegate: nil.
  server stop.
	
	
	

]

{ #category : #'Response Characterization Tests' }
HClientServerTests >> test221CharacterizeZnServerPutResponse [
	| server request response |
	server := ZnSingleThreadedServer startOn: 80221.
	
	server logToTranscript.
	
	"client := ZnHttpClient new."
	request := ZnRequest put: 'http://localhost:80221/test221'.
	
	response := server handleRequest: request.
	self expect: ZnResponse actual: ( response class ).
	self expect: 404 actual: ( response statusLine code ).
	self expect: 'Not Found' actual: ( response statusLine reason ).
	
	server delegate: (HApplication echo).
	response := server handleRequest: request.
	self expect: ZnResponse actual: ( response class ).
	self expect: 200 actual: ( response statusLine code ).
	self expect: 'OK' actual: ( response statusLine reason ).
	self expect: 'PUT.../test221
Accept: */*
User-Agent: Zinc HTTP Components 1.0
Host: localhost:80221'
       actual: ( response contents ).

	server delegate: nil.
  server stop.
	
	
	

]

{ #category : #'Response Characterization Tests' }
HClientServerTests >> test222CharacterizeZnServerPostResponse [
	| server request response |
	server := ZnSingleThreadedServer startOn: 80222.
	server logToTranscript.
	
	"client := ZnHttpClient new."
	request := ZnRequest post: 'http://localhost:80222/test222'.
	
	response := server handleRequest: request.
	self expect: ZnResponse actual: ( response class ).
	self expect: 404 actual: ( response statusLine code ).
	self expect: 'Not Found' actual: ( response statusLine reason ).
	
	server delegate: (HApplication echo).
	response := server handleRequest: request.
	self expect: ZnResponse actual: ( response class ).
	self expect: 200 actual: ( response statusLine code ).
	self expect: 'OK' actual: ( response statusLine reason ).
	self expect: 'POST.../test222
POST:  No query arguments seen.
Accept: */*
User-Agent: Zinc HTTP Components 1.0
Host: localhost:80222'
       actual: ( response contents ).

	server delegate: nil.
  server stop.
	
	
	

]

{ #category : #'Response Characterization Tests' }
HClientServerTests >> test223CharacterizeZnServerDeleteResponse [
	| server request response |
	server := ZnSingleThreadedServer startOn: 80223.
	
	server logToTranscript.
	
	"client := ZnHttpClient new."
	request := ZnRequest delete: 'http://localhost:80223/test223'.
	
	response := server handleRequest: request.
	self expect: ZnResponse actual: ( response class ).
	self expect: 404 actual: ( response statusLine code ).
	self expect: 'Not Found' actual: ( response statusLine reason ).
	
	server delegate: (HApplication echo).
	response := server handleRequest: request.
	self expect: ZnResponse actual: ( response class ).
	self expect: 200 actual: ( response statusLine code ).
	self expect: 'OK' actual: ( response statusLine reason ).
	self expect: 'DELETE.../test223
Accept: */*
User-Agent: Zinc HTTP Components 1.0
Host: localhost:80223'
        actual: ( response contents ).

	server delegate: nil.
  server stop.
	
	
	

]

{ #category : #'Response Characterization Tests' }
HClientServerTests >> test224CharacterizeZnServerHeadResponse [
	| server request response |
	server := ZnSingleThreadedServer startOn: 80224.
	
	server logToTranscript.
	request := ZnRequest head: 'http://localhost:80224/test224'.
	
	response := server handleRequest: request.
	self expect: ZnResponse actual: ( response class ).
	self expect: 404 actual: ( response statusLine code ).
	self expect: 'Not Found' actual: ( response statusLine reason ).
	
	server delegate: (HApplication echo).
	response := server handleRequest: request.
	self expect: ZnResponse actual: ( response class ).
	self expect: 200 actual: ( response statusLine code ).
	self expect: 'OK' actual: ( response statusLine reason ).
	self expect: 'HEAD.../test224
Accept: */*
User-Agent: Zinc HTTP Components 1.0
Host: localhost:80224'   actual: ( response contents ).

	server delegate: nil.
  server stop.
	
	
	

]

{ #category : #'Client Characterization Tests' }
HClientServerTests >> test226CharacterizeZnHTTPSocketFacadePost [
	"Characterize ZnHttpClient"
	| client responseStream dict server |
	
	server := ZnMultiThreadedServer startOn: 80226.
	server logToTranscript.
	server delegate: (HApplication echo).
	self ensureBlock: [server stop].

	client := ZnHTTPSocketFacade new.
	self expect: ZnHTTPSocketFacade actual: client class.
	
	dict := ZnMultiValueDictionary new.
	dict at: 'MYNAMEIS' add: 'tester'.
	
  responseStream := ZnHTTPSocketFacade httpPost: 'http://localhost:80226/test226' args: dict accept: 'application/octet-stream'.
	server delegate: nil.
	server stop.
	self expect: (RWBinaryOrTextStream) actual: (responseStream class).
	self expect: 'POST.../test226
POST: MYNAMEIS=tester
X-Zinc-Remote-Address: 127.0.0.1
Content-Length: 15
User-Agent: Zinc HTTP Components 1.0
Connection: close
Host: localhost:80226
Content-Type: application/x-www-form-urlencoded
Accept: */*'
			actual: responseStream contents.
			

]

{ #category : #'Request Characterization Tests' }
HClientServerTests >> test310CharacterizeZnRequest [
	""
	| request headers uri |
	request := ZnRequest get: 'http://localhost:8080/test'.
	self expect: ZnRequest actual: ( request class ).
	self expect: ZnRequestLine actual: ( request requestLine class).
	self expect: #GET actual: ( request requestLine method ).
	
	uri := request requestLine uri.
	self expect: ZnUrl  actual: ( uri class).
	self expect: 'http' actual: ( uri scheme).
	self expect: 'localhost' actual: ( uri host).
	self expect: 8080   actual: ( uri port).
	self expect: nil    actual: ( uri query ).
	self expect: #('test') actual: ( uri segments asArray ).
		
	headers := request headers.
	self expect: ZnHeaders actual: ( headers class ).
	self expect: 'localhost:8080' actual: ( headers at: #host ).
	self expect: '*/*' actual: ( headers at: #accept ).
	self expect: 'Zinc HTTP Components 1.0' actual: ( headers at: 'User-Agent' ).
  self expect: 3 actual: (headers headers size).
]

{ #category : #'Response Characterization Tests' }
HClientServerTests >> test324CharacterizeZnServerGetResponse [
	"Use Case: (Single Threaded) Server with HApplication responds to client GET request."
	| server response |
	server := ZnSingleThreadedServer startOn: 80324.
	self ensureBlock: [server stop].
	
	server delegate: (HApplication echo).

	response := ZnClient get: 'http://localhost:80324/test324'.

	self expect: ZnResponse actual: ( response class ).
	self expect: 200 actual: ( response statusLine code ).
	self expect: 'OK' actual: ( response statusLine reason ).
	self expect: 'GET /test324
X-Zinc-Remote-Address: 127.0.0.1
User-Agent: Zinc HTTP Components 1.0
Connection: close
Host: localhost:80324
Accept: */*'
       actual: ( response contents ).

  server delegate: nil.
	self expect: ZnDefaultServerDelegate actual: (server delegate class).
  server stop.


	
	

	
	
	

]

{ #category : #'Response Characterization Tests' }
HClientServerTests >> test325CharacterizeZnServerGetResponse [
	"Use Case: (Multi-Threaded) Server with HApplication responds to client GET request."
	| server response |
	server := ZnMultiThreadedServer startOn: 80325.
	self ensureBlock: [server stop].
	
	server delegate: (HApplication echo).

	response := ZnClient get: 'http://localhost:80325/test325'.

	self expect: ZnResponse actual: ( response class ).
	self expect: 200 actual: ( response statusLine code ).
	self expect: 'OK' actual: ( response statusLine reason ).
	self expect: 'GET /test325
X-Zinc-Remote-Address: 127.0.0.1
User-Agent: Zinc HTTP Components 1.0
Connection: close
Host: localhost:80325
Accept: */*'
       actual: ( response contents ).

  server delegate: nil.
	self expect: ZnDefaultServerDelegate actual: (server delegate class).
  server stop.


	
	

	
	
	

]

{ #category : #'Response Characterization Tests' }
HClientServerTests >> test326CharacterizeZnServerGetResponse [
	"Use Case: (Multi-Threaded) Server with HApplication responds to HClient GET request."
	| server response |
	server := ZnMultiThreadedServer startOn: 80326.
	self ensureBlock: [server stop].
	
	server delegate: (HApplication echo).

	response := HClient get: 'http://localhost:80326/test326'. "HClient is a wrapper on ZnClient."

	self expect: ZnResponse actual: ( response class ).
	self expect: 200 actual: ( response statusLine code ).
	self expect: 'OK' actual: ( response statusLine reason ).
	self expect: 'GET /test326
X-Zinc-Remote-Address: 127.0.0.1
User-Agent: Zinc HTTP Components 1.0
Connection: close
Host: localhost:80326
Accept: */*'
       actual: ( response contents ).

  server delegate: nil.
	self expect: ZnDefaultServerDelegate actual: (server delegate class).
  server stop.


	
	

	
	
	

]
