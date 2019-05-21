"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestHumX,
	#superclass : #PackageManifest,
	#category : #'Hum-X'
}

{ #category : #'code-critics' }
ManifestHumX class >> ruleRBCollectionProtocolRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#H3dObject #buildElipsoid #false)) #'2017-01-09T09:20:07.123068-05:00') #(#(#RGMethodDefinition #(#H3dObject #buildAndOrient #false)) #'2017-01-09T09:25:20.926278-05:00') )
]
