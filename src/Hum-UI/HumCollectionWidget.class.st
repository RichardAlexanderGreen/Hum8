"
Collection widget is a contain providing a view of an attribute that is a collection.

Examples:
. An order has a list of order-items.
. A recipe has a set of ingredients.
. A recipe has a list of instructions.
. A bill-of-material has a set of part-counts.
. An inventory has a set of part-counts.

The view is typically a table where each row is a view of an item in the collection.

In a Hum View, the table is typically specified like this:

. Table of Order-Items:
| Item | Catalog-Number | Description | Quantity |  

"
Class {
	#name : #HumCollectionWidget,
	#superclass : #HumWidget,
	#category : #'Hum-UI'
}
