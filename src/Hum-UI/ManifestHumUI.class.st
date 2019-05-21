"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestHumUI,
	#superclass : #PackageManifest,
	#category : #'Hum-UI'
}

{ #category : #'code-critics' }
ManifestHumUI class >> ruleAssertEqualSignIntoAssertEqualsV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#HumTurtle #initialize #false)) #'2016-12-08T08:34:44.037556-05:00') )
]

{ #category : #'code-critics' }
ManifestHumUI class >> ruleRBBadMessageRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#HumTurtle #heading: #false)) #'2016-12-08T10:24:39.527239-05:00') #(#(#RGMethodDefinition #(#HumTurtle #turn: #false)) #'2016-12-08T10:35:56.10992-05:00') )
]

{ #category : #'code-critics' }
ManifestHumUI class >> ruleRBInconsistentMethodClassificationRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#HumTurtle #initialize #false)) #'2016-12-08T08:38:10.617792-05:00') )
]
