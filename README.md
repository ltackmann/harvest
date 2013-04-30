[![Build Status](https://drone.io/github.com/ltackmann/harvest/status.png)](https://drone.io/github.com/ltackmann/harvest/latest)

Harvest
=======
Event store for Dart with multiple backends. 

How does it work
----------------

Harvest creates and persists streams of events. Each persistent event stream is identified by 
a **Guid** for future retrival. For example

```dart
main() {
	// get a event stream for streamId 
	Guid streamId = new Guid();
	var eventStore = new MemoryEventStore();
	var eventStream = eventStore.openStream(streamId);
	
	// create some events
	var event1 = ...
	var event2 = ...
	
	// store them
	eventStream.addAll([event1, event2]);
	eventStrem.commitChanges();
}	
```

Why do this ?
-------------
Event sourcing is the concept of saving and retriving object state by
the events that occured on them rather than by their current state. 

Consider the following bank use case

1. User creates account
1. User deposits 10$
1. User withdraws 2$

In a CRUD application you would now have a **BankAccount** object with an 
amount property with the value **8**. In a event sourced application you 
have a **BankAccount** object and 3 events for it

1. AccountCreated
1. AmountDeposited
1. AmountWithdrawn

Where is this useful?
--------------------- 

 * For certain applications the eventlog can be useful in itself such as a audit 
trail in a financial system. 
 * It can help manage complexity in large applications by forcing programmers to 
make event types for every action that can occur.
 * It makes debugging easy since you can replay the event log to recreate 
any former system state where an error occurred.  
 * It makes mobile app synchronization a breeze, since the offline app can just 
queue up events and replay them on the backend once it comes online. 
 * In applications using the [CQRS architecture pattern](http://msdn.microsoft.com/en-us/library/jj554200.aspx).

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
