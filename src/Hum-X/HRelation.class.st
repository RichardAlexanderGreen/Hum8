"
A Relation is an ""associative entity"". It is identifiable and real-world.
An ""associative entity"" differs from a ""kernal entity"" 
  in that two or more of its required-attributes are ""role-type"".
The attribute-name of a role-type attribute names the relationship role.
The attribute-value of a role-type attribute is an entity-identifier.

. TODO: Give some thought about relationship (associative entity) instantiation.
. Business-Relationships are typically caused by business actions.
. . But: Where is the observer?
. Most such business actions are transactions (buy-sell, bid, subscribe/register, assign).
. . We record and track such transactional events because they represent contracts and opportunities.
. Subtypes of Party and Person are often roles in such contracts.
. . e.g. Customer, Worker, Supplier, Subscriber, User.
. Subtypes of Order represent work-in-progress or fulfilled contracts.
. . e.g. Sales-Order Purchase-Order Work-Order Requisition Option



"
Class {
	#name : #HRelation,
	#superclass : #HEntity,
	#category : #'Hum-X'
}
