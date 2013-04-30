[![Build Status](https://drone.io/github.com/ltackmann/harvest/status.png)](https://drone.io/github.com/ltackmann/harvest/latest)

Harvest
=======
Event store for Dart with multiple backends for easly creating event sourced 
applications on both the browser and VM.


How does it work
----------------

Harvest stores and load events based on identifers

```dart
main() {
	// wire up event store
	var messageBus = new MessageBus();
	var eventStore = new MemoryEventStore();
	eventStore.stream
	
	// create some events
	var event1 = ...
	var event2 = ...
	
	// store them
	eventStore.saveEvents(id, [event1, event2], expectedVersion:0);
}	
```


Introduction
------------
Event sourcing is the concept of saving and retriving domain objects by
the events that occured on them rather than by their current state (as 
is done in CRUD style persistence layers). To understand this concept 
consider the following bank use case

1. User creates account
1. User deposits 10$
1. User withdraws 2$

In a CRUD application you would now have a **BankAccount** object with an 
amount property with the value **8**. In a event sourced application you 
have a **BankAccount** object and 3 events for it

1. AccountCreated
1. AmountDeposited
1. AmountWithdrawn

Why is this a trick ?. 

For certain applications the eventlog can be useful in itself such as a audit 
trail in a financial system. It can also be a valuable for complex applications 
since it makes each use case explicit by forcing programmers to make event types 
for every action that can occur.

Further it also makes debugging easy since you can replay the event log to recreate 
any former system state where an error occurred  Finally it also makes implementing 
online/offline synchronization managable, since the offline application can just queue 
up events and replay them on the backend once it comes online. 

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
