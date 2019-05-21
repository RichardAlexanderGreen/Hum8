"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestHumRunTime,
	#superclass : #PackageManifest,
	#category : #'Hum-RunTime'
}

{ #category : #'code-critics' }
ManifestHumRunTime class >> ruleRBBadMessageRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#'HumMeasure class' #solveFormula:target:guess:precision:iterate: #true)) #'2019-01-05T10:22:40.611477-05:00') )
]

{ #category : #'code-critics' }
ManifestHumRunTime class >> ruleRBExcessiveArgumentsRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#'HumMeasure class' #solveFormula:target:guess:precision:iterate: #true)) #'2019-01-05T10:22:19.252157-05:00') )
]

{ #category : #'code-critics' }
ManifestHumRunTime class >> ruleRBIfTrueReturnsRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#HumMeasure #compareAngle: #false)) #'2016-12-08T13:35:36.244944-05:00') )
]
