"
A translation line may occur between triple-brace lines in a role-action frame.
It specifies how an action statement (generally an internal ""To:"" statement) may be implemented in some target language.
Generally the implementation will be a method declaration where the role is assumed to be implemented as a class.

Here is an example:
____
Role: Invoicing.

To: Extend the order's unit prices.
. As Smalltalk:
{{{
extendOrderLinePricesFor: anOrder
	""Multiply the unit price times the quantity to fill in the extended price. 
	Then apply any quantity discounts.""
	( anOrder orderLines )
		do: [ :orderLine |
			orderLine extendedPrice: (orderLine quantity) * (orderLine price).
			orderLine applyQuantityDiscountIfAny.
			""The quantity discount rule depends on the the catalogNumber and quantity""
			 ].
}}}
___

In this case, the translator will assemble the given translation lines with other translation lines to produce a Smalltalk class definition.

Similar results might be obtained for translation to Java or Python or Javascript or Objective-C.

Note: The code above could have been written entirely in Hum without the need to use an external framework.
  This example was used because it does not require explanation of the context.

The general form is:
___
To: <action statement>.
. As <language>:
{{{
   <several lines in the target procedural language>
}}}
___

Note: ""To: . . . "" could also be ""Action: . . . "". (That is allowed but is probably bad form.)

"
Class {
	#name : #HumTranslationLine,
	#superclass : #HumFrameLine,
	#category : #'Hum-Language'
}
