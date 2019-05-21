"
An attribute describes an entity. Hence we may say entity-attribute to be more explicit.

An attribute exists in two contexts: attribute-type, attribute-instance.
However we tend to just say ""attribute"" in many contexts because the meaning is generally clear enough.

1. In an ontology, an attribute-type is named by a noun.
. . Entity-types have attributes. More than one entity-type may have the same attribute.
. . Basically this means that an attribute-type has no meaning without the context of an entity-type.
. . However, to avoid confusion, only one datatype may be associated with the noun that names an attribute-type.

2. In an ontology, an attribute-type may reference an entity-type or one of the built-in entity-types.
. . The built-in datatypes include string, date, timestamp, collection (set, list, bag), and measure.
. . . There are no abstract or machine-oriented numeric types in Hum. 
. . . A real-world number is always a measurement. (See HumMeasure).
. . . If no datatype is assigned to an attribute-type, the default datatype is a string.

3. At run-time, an attribute-instance is associated with an entity-instance in a data store (BlackBoard/WorldBase).
. . The entity-instance identifier plus the attribute-type (noun) is unique. 
. . . So the attribute-instance does not need an additional identifier.
. . The attribute may take on different values over time. 
. . . Attribute values have timestamps so we know which value was applicable at any point in time.
. . . Note: It makes no sense to assign a null value to a Hum attribute.
. . . Comment: Generally, it is a bad practice to use an empty value as a business signal.

The primative datatypes include:
- String . . an array of characters
- Text . . . an array of lines of tokens with styling
- Measure. . a quantity with a unit of measure and precision
- Date . . . a calendar date (DateAndTime)
- Category . some value within an enumerated set 
- Collection a collection of objects (entity instances)
- Identifer . . Identifies an entity instance in a World Base.

Future primative datatypes might include media types:
- Image  . . a 2D picture (very technology dependent)



"
Class {
	#name : #HumEntityAttribute,
	#superclass : #Object,
	#instVars : [
		'title',
		'id'
	],
	#category : #'Hum-RunTime'
}
