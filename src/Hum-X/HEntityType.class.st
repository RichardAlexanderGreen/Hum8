"
An Entity-Type instance holds meta-data.
	The type of an entity-type is named by a noun in the ontology.
	The attributes of an entity-type are identified in the ontology.
	The data-type of the attributes are identified in the ontology. (Default is string when there is no supertype).

Currently, the ontology does not contain user-interface (scribe) *hints* such as 
- field-width          (Calculated at 90% statistic.)
- required attributes  (We could add a base-ontology type called 'required-value'.)
- immutable attributes (We could add a base-ontology type called 'immutable-value'.)
- natural key          (We could add a base-ontology type called 'natural-key'.)       
- ranges for measure, date, or timestamp values. (Should we add annotations to dictionary notation?)
- Default ordering (natural key?) on sets and bags. 
- Help data - explaining how the entity and its attributes are to be interpreted (data entered)
- - Comment: Help probably should be provided by separate views rather than meta-data. But this can be argued.

Consider:
- Should supertype attributes be displayed above subtype attributes?

*** The functions identified above can be handled in ontology, and do not require a separate class. ***


"
Class {
	#name : #HEntityType,
	#superclass : #HEntity,
	#category : #'Hum-X'
}
