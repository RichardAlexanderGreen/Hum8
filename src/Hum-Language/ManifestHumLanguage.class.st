"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestHumLanguage,
	#superclass : #PackageManifest,
	#category : #'Hum-Language'
}

{ #category : #'code-critics' }
ManifestHumLanguage class >> ruleRBBadMessageRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#HumOntology #storeFrame: #false)) #'2017-06-07T19:00:35.671244-04:00') )
]

{ #category : #'code-critics' }
ManifestHumLanguage class >> ruleRBLongMethodsRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#HumDictionaryLine #compileLineToOntology: #false)) #'2017-02-23T12:26:58.152567-05:00') )
]

{ #category : #'code-critics' }
ManifestHumLanguage class >> ruleRBMethodSourceContainsLinefeedsRuleV1FalsePositive [
	^ #(#(#(#RGClassDefinition #(#HumOntologyViewer)) #'2017-08-15T07:24:16.626107-04:00') )
]

{ #category : #'code-critics' }
ManifestHumLanguage class >> ruleRBStringConcatenationRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#HumDictionaryLine #compileLineToOntology: #false)) #'2017-02-23T12:27:13.736902-05:00') )
]
