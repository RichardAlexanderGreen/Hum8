"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestHumTests,
	#superclass : #PackageManifest,
	#category : #'Hum-Tests'
}

{ #category : #'code-critics' }
ManifestHumTests class >> ruleRBMethodSourceContainsLinefeedsRuleV1FalsePositive [
	^ #(#(#(#RGClassDefinition #(#HumProgrammersAssistantTests)) #'2017-03-21T08:03:30.317192-04:00') )
]
