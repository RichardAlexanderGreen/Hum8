"
The blackboard holds the values for nouns in memory that are currently being referenced by an agent.
In addition, the blackboard operates the persistence mechanism so that new noun values are recorded on the world-base (database). 

TODO: Deal with attributes that are collections (bag, set, list).
- The items in a collection are entities. (They are identifiable and countable.)
- That implies that they have identifiers.
- The collection itself has an identifier.
- Let a collection attribute be a Hum datatype. 
. . Then it supports the Hum equivlalent of add: item, remove: item, do: [:item| ...], asStream. 
. . A Hum list also supports append: item, prepend: item, first, last.
. . Updating a collection is handled the same as updating other datatypes.
. . The difference will be that the entities in the collection must also be on the blackboard.
. . And, the collections only contain identifiers.
"
Class {
	#name : #HumBlackBoard,
	#superclass : #Object,
	#instVars : [
		'quads',
		'worldbase',
		'worldbaseID',
		'defaultEntity',
		'entityIdentifiers',
		'businessEvent'
	],
	#category : #'Hum-RunTime'
}

{ #category : #'instance creation' }
HumBlackBoard class >> worldbase: aString [ 
	| instance |
	instance := self basicNew.
	instance worldbase: aString.
	^instance.
]

{ #category : #accessing }
HumBlackBoard >> appendEntity: childEntityID toEntity: parentEntityID list: anAttributeName [ 
	"Append the given child entity to the named list attribute"
	| list attribute |
	self assert: ( childEntityID isKindOf: HumIdentifier ).	
	self assert: ( parentEntityID isKindOf: HumIdentifier ).
	self assert: ( anAttributeName isKindOf: String ).
	attribute := self cleanAttribute: anAttributeName.
	list := self getEntityID: parentEntityID attribute: attribute.
	( list isKindOf: OrderedCollection )
		ifFalse: [ list := OrderedCollection new].
	list addLast: childEntityID.
	self setEntityID: parentEntityID attribute: attribute toValue: list.
]

{ #category : #accessing }
HumBlackBoard >> businessEvent [
	"What business event is in progress?"
	^businessEvent ifNil: [Error signal: 'event not set']
]

{ #category : #accessing }
HumBlackBoard >> businessEvent: aString [
	"What business event is in progress?"
	"TODO: We need a stronger (W5) business-event representation."
	"TODO: Create a Business Event class with W5 (who, what, when, where, why) attributes."
	^businessEvent := aString
]

{ #category : #accessing }
HumBlackBoard >> cleanAttribute: anAttributeNameString [ 
	| result |
	result := ((anAttributeNameString isKindOf: String ) 
	                              ifTrue: [ anAttributeNameString ] 
	                             ifFalse: [ Error signal: 'Sent blackboard non-string value?'.
		                                      anAttributeNameString asString. ]) trimBoth asLowercase.
	^result.
]

{ #category : #accessing }
HumBlackBoard >> cleanEntity: anEntityTypeString [ 
	"Assure that the type-name is properly-trimmed, lowercase string"
	| result |
	anEntityTypeString ifNil: [ Error signal: 'Why was entity-type nil?']. 
	result := anEntityTypeString trimBoth asLowercase.
	[result endsWith: '.'] whileTrue: [ result := result copyFrom: 1 to: (result size - 1)].
	self assert: (result isKindOf: String).
	^result.
]

{ #category : #'events-triggering' }
HumBlackBoard >> clearEntity: anEntityType [ 
	"Clear all data for the given entity-name / entity-type."
	| quadsToBe cleanName |
	"REFACTOR/RETHINK: The BlackBoard seems to be built for single instances of an entity-type."
	"TODO: Think about the interaction between business roles, views, and persistence."
	"Hum`s general rule is 'Persist everthing, then add purge rules.'"
	"REFACTOR/RETHINK: The WorldBase should check for valid ID (defensive code). "
	
	Error signal: 'Why are we doing this?'.  "TODO: Why would we do this? -- Original test case (ClubMechV02.txt) was for a NEW entity."
	"Why? - Because an long-running dialog may have already created an entity of this type,
	        but a new vignette is creating another entity of this type."
	
	cleanName := self cleanEntity: anEntityType.
	"(cleanName = 'topic') ifTrue: [self halt.]."
	
	(self entityIdentifiers) removeKey: cleanName ifAbsent: ["Okay."]. 

	quadsToBe := Dictionary new.
	quads
		keysAndValuesDo: [ :key :value |
			| association entityLabel |
			association := key.
			entityLabel := HumCalculator given: (association key asString) extractUpto: ':'.
			(entityLabel sameAs: cleanName)
				ifFalse: [ quadsToBe at: key put: value ].
			].
	"At this point, quadsToBe has no data associated with the entity-type."
	quads := quadsToBe.
	
]

{ #category : #accessing }
HumBlackBoard >> entityIdentifiers [
	"What identifier is associated with a entity type noun (entity name)?"
	^ entityIdentifiers ifNil: [entityIdentifiers := Dictionary new].
]

{ #category : #accessing }
HumBlackBoard >> generateNewIdentifierForEntityName: anEntityName [
	"Create a unique identifier for an instance of the given entity-name noun."
	| id entity |
	entity := self cleanEntity: anEntityName.
	id := HumIdentifier createUniqueIdentifierForEntityName: entity inContext: (self businessEvent).
	^id.
]

{ #category : #accessing }
HumBlackBoard >> getEntityID: entityID attribute: anAttributeName [ 
	" Get requested value (if any) from the blackboard instance "
	| valueAndTau value tau attribute |
	self assert: (entityID isKindOf: HumIdentifier ).
	attribute := self cleanAttribute: anAttributeName.
	
	valueAndTau := ( self quads ) at: ( entityID -> attribute ) ifAbsent: [ ^nil ].
	"ToDo: If I don't have it, maybe WorldBase does. "
	"TODO: If the entity-attribute-value is updated in the worldbase, are the Blackboards notified?  If so, how?"
	value := valueAndTau at: 1.
	tau := valueAndTau at: 2.
	self assert: (tau notNil).
	^ value.
]

{ #category : #accessing }
HumBlackBoard >> getEntityName: anEntityName attribute: anAttributeName [ 
	"Get the entityID for that entity-name and fetch the requested attribute."
	| value entityName entityID attributeName  |
	entityName := self cleanEntity: anEntityName.
	attributeName := self cleanAttribute: anAttributeName.
	
	entityID := self identifierForEntityName: entityName.
	value := self getEntityID: entityID attribute: attributeName.
	^value.
]

{ #category : #accessing }
HumBlackBoard >> identifierForEntityName: anEntityName [ 
	"Do I already have an entity of that name? 
	 If so, assign the same ID. Otherwise, get a new identifier."
	| id entity | 
	entity := self cleanEntity: anEntityName.
	id := (self entityIdentifiers) at: entity 
	     ifAbsent: [ entityIdentifiers at: entity put: (self generateNewIdentifierForEntityName: entity). ].
	^id.
]

{ #category : #'as yet unclassified' }
HumBlackBoard >> makeEntityOfType: anEntityType [ 
	"Add a new entity ID for the given entity type. (entity name)."
	| entityIdentifier entity |
	"Generally invoked via 'New entityType.' in a dialog vignette. "
	entity := self cleanEntity: anEntityType.
	entityIdentifier := self generateNewIdentifierForEntityName: entity.
	"NOTE: If dialog blackboard already contains an entity of this type, it is no longer accessable."
	(self entityIdentifiers) at: entity put: entityIdentifier.
	
]

{ #category : #private }
HumBlackBoard >> quads [
	"a dictionary of { aValue. tau. } keyed by ( entityID -> attribute )"
	^ quads ifNil: [ quads := Dictionary new. ].
]

{ #category : #accessing }
HumBlackBoard >> setEntityID: entityID attribute: anAttributeName toValue: aValue [
	"Store given value in the blackboard with a time-stamp. 
	 *** Side Effect: Notify the World Base. ***"
	| tau  attributeName |
	self assert: ( entityID isKindOf: HumIdentifier ).
	attributeName := self cleanAttribute: anAttributeName.
		
	"Put value of entity attribute and the timestamp."
	tau := (self businessEvent hash). "TODO: Relate this to a business event."
	( self quads ) at: ( entityID -> attributeName ) put: { aValue. tau. }.
	
	"Update the world base also."
	( self worldbase isKindOf: String ) 
				ifTrue: [ "Replace string with a worldbase instance."
						(worldbase = 'none') ifTrue: ["This blackboard does not persist data immediately." ^self].
						self worldbase: (HumWorldBase openWorldBase: worldbase).
						].					 
	self assert: (self worldbase isKindOf: HumWorldBase ).
	( self worldbase ) setEntityID: entityID attribute: attributeName toValue: aValue.
	
	"NOTE: Mutation in the world-base is treated via versioning."
	"TODO: Blackboard detects mutations ? -- And then what?"
	"TODO: Code critic flags mutation as Error?"
	"COMMENT: Mutation in a business-entity is mainly a danger when a natural-key is mutated."

]

{ #category : #accessing }
HumBlackBoard >> setEntityName: anEntityName attribute: anAttributeName toValue: aValue [
	"for now -- same as:"
	| entityID entityName attributeName |
  entityName := self cleanEntity: anEntityName.
  attributeName := self cleanAttribute: anAttributeName.

	"Do I already have an entity of that name? 
	 If so, assign the same ID. Otherwise, get a new identifier."
	entityID := self identifierForEntityName: entityName.
	
	( anAttributeName sameAs: aValue asString   )
		ifTrue: ["When the value matches the attribute name, the value references an entity."
			| referencedEntityID |
			referencedEntityID := self identifierForEntityName: anAttributeName.
			self setEntityID: entityID attribute: attributeName toValue: referencedEntityID.
			^self.
			].
	
	self setEntityID: entityID attribute: attributeName toValue: aValue.
	
	
]

{ #category : #accessing }
HumBlackBoard >> updateBlackBoardFromBlackBoard: aHumBlackBoard [ 
	"Update myself from entries in the other blackboard."
	| otherQuads |
	Error signal: 'I don`t expect this to be used in current coding environment.'.
	"Assume that caller is not sharing this blackboard."
	self assert: (aHumBlackBoard == self ) not.
	"Interpret caller quads"
	otherQuads := aHumBlackBoard quads.
	self assert: ( otherQuads isKindOf: Dictionary ).
	otherQuads 
			keysAndValuesDo: [ :key :value |
				| entityID entityName attributeType newValue  |
				"Parse dictionary key - it is a map of the form: (entitID -> attributeType)"
				entityID := key key.
				attributeType := key value.
				self assert: ( entityID isKindOf: HumIdentifier ).
				entityName := entityID entityName.
				"Parse dictionary value - It is a tuple of the form: { value. tau. }"
				newValue := value at: 1.
				"tau := value at: 2."
				"Update myself -- Note: I will generate my own tau."
				self entityIdentifiers at: entityName put: entityID.
				self setEntityID: entityID attribute: attributeType toValue: newValue.
				]
	
]

{ #category : #private }
HumBlackBoard >> worldbase [
	^ worldbase ifNil: [Error signal: 'Blackboard configured without a world base.']
]

{ #category : #accessing }
HumBlackBoard >> worldbase: aHumWorldBase [ 
	self assert: ((aHumWorldBase isKindOf: HumWorldBase) or: [aHumWorldBase = 'none']).
	worldbase := aHumWorldBase
]
