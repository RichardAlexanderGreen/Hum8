"
Data frames provide a notation and means for transferring data between actors.
See #documentation method on the class side.

The format is similar to JSON but without the curly brackets.
The nesting is indicated by indentation.
The notation accomodates tables that populate collection attributes.
It also accomdates text (multi-line strings but without formatting) delimited by triple quotes.

Comment: The Hum data frame notation was invented before JSON became prevalent.
Hum contains a data frame notation for the sake of internal consistency
and because other programming frameworks (ForTran, Basic, . . .) include a data transfer notation.

The Hum data frame notation syntax is consistent with other Hum notations. 
Like Smalltalk and COBOL, statements are terminated with a  period.
Like Python, block scope is indicated by indentation.
===
Data: frame title.
Entity: identifier.
. attribute: attribute-value.
. attribute:
""""""
A text value
may go on 
and on 
for many lines.
""""""
===
"
Class {
	#name : #HumFrame4Data,
	#superclass : #HumFrame,
	#instVars : [
		'priorEntityName'
	],
	#category : #'Hum-Language'
}

{ #category : #'as yet unclassified' }
HumFrame4Data class >> documentation [
	| indentedForm tableForm |
	indentedForm := '
===
Data: (data set name)    << Indicate a data frame. Give the frame a name/title.

Worker                   << The following data is for a worker (entity). 
. ID: (string)           		<< The system knows an ID should be unique.
. name: (string)         << provides the data value for worker`s "name" attribute.
. Home Address       << "Home Address" is an embedded entity.
. . line1: (string)
. . line2: (string)
. . postal-code: (string)	<< "Reader" and "Smart Editor" validate values.
. age: (string)          		<< This value should be a measure.

Site                     		<< The following data is for a Site (entity)
. name: (string)         	<< name of site

. description:           << The description of the site is in text format.
"""                      		<< Arbitrary text delimited by triples as shown here.
(text)                   		<< The text data starts on the line after the triple.
"""                      		<< A triple DOUBLE-QUOTE or SINGLE-QUOTE starts and ends the text.

. Site Address           << Indentation indicates "Site Address" is an embedded entity.
. . line1: (string)
. . postal code: (string)
===
	'.
	tableForm := '
===
Data: Worker`s Scheduled Hours

Worker
. ID: 12345
. name: Robin Good
. weekly hours:
"""
table of weekly-hours delimited by |
| Day       		| Begin 	| End  |  						<<< First line of table names the attributes associated with the table columns.
| Monday    	| 06:00 	| 14:00 |					<<< Values between column delimiters are treated as strings, but trimmed.
| Tuesday   	| 06:00 	| 14:00 |						<< See Time class>>readFrom: for an example of how such data might be converted.
| Wednesday	| 06:00 	| 14:00 |
| Thursday  	| 06:00 	| 14:00 |
| Friday    		| 06:00 	| 14:00 |
"""
===
	'.
	^ ( indentedForm, tableForm  ).
]

{ #category : #associating }
HumFrame4Data >> appendEntity: aEntityName attrribute: anAttributeName value: aValueString [ 
	|  colon indent |
	indent := '. '.
	colon := ': '.
	( ( priorEntityName isNil ) or: [(aEntityName sameAs: priorEntityName) not]  )
		ifTrue: [ self appendFrameLine: (aEntityName, colon ).
				priorEntityName := aEntityName ].
	self appendFrameLine:  ( indent, anAttributeName, colon, aValueString ).
]

{ #category : #rendering }
HumFrame4Data >> asString [
	| s cr |
	cr := String cr.
	s := 'Data Frame', cr.
	s := s, '---', cr.
	( self frameLines )
		do: [ :line | s := s, line asString, cr. ].
	s := s, '---', cr.
		
	^s.
]
