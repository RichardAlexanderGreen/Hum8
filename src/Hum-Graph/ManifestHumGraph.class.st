"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestHumGraph,
	#superclass : #PackageManifest,
	#category : #'Hum-Graph'
}

{ #category : #'code-critics' }
ManifestHumGraph class >> ruleGRTemporaryNotReadNorWrittenRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#HumGraph #nodesDownStreamFrom:butNotIn: #false)) #'2016-12-20T07:33:41.66789-05:00') )
]
