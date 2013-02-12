DartStore
=========

Event store for Dart with multiple backends. Includes functionality for easily 
creating event sourced applications on both the client and server side. 

Introduction
------------

Event sourcing is the concept of saving and retriving domain objects by
the events that occured on them rather than by their current state (CRUD). 
To understand this concept consider the following bank deposit list

1. Create account
1. Deposit 10$
1. Withdraw 5$

In a CRUD application you would have a **BankAccount** object with an amount 
property with the value **5**. In a event sourced application you have a 
**BankAccount** object and 3 events for it

1. AccountCreated
1. AmountDeposited
1. AmountWithdrawn

Why is this a trick ?. 

For certain types of applications this eventlog can be benificial in it self 
(like auditing in financial systems) but it can also be a valuable design for complex web 
since it makes each use case explicit and makes debugging easy (you can replay the event log 
to recreate any system state. Finally it also makes implementing online/offline syncronization 
managable, since the offline application can just queue up any events that occures and 
replay them on the backend once it comes back online. 

For more information, see the provided **example** application.

Supported Storage Engines
-------------------------
Currently DartStore implements the following event stores.

* Memory engine: suitable for testing purposes
* IndexDB: suitable for web applications (**work in progress**)
* Cordova: suitable for mobile applications (**work in progress**)

Links
-----
* https://github.com/joliver/EventStore
