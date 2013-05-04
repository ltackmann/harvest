[![Build Status](https://drone.io/github.com/ltackmann/harvest/status.png)](https://drone.io/github.com/ltackmann/harvest/latest)

Harvest
=======
Harvest is a event store for Dart with multiple backends. Harvest creates and persists streams of events, where each persistent event stream is identified by 
a **Guid** for future retrival.

Quick Guide
-----------

**1.** Add the folowing to your pubspec.yaml and run pub install
```yaml
    dependencies:
      harvest: any
```

**2.** Add harvest to some code and run it
```dart
	import 'package:harvest/harvest.dart';
	
	main() {
		var streamId = new Guid();
		var eventStore = new MemoryEventStore();
		// get a event stream for streamId 
		eventStore.openStream(streamId).then((eventStream) {
			// create some events
			var event1 = ...
			var event2 = ...
			
			// store them
			eventStream.addAll([event1, event2]);
			eventStrem.commitChanges();
		});
	}	
```

Why do this ?
-------------
Event sourcing is the concept of saving and retriving object state by the events 
that occured on them rather than by their current state. Consider the following 
bank use case:

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
Harvest supports the following event stores.

* **FileEventStore**: Durable disk based event store
* **IndexeddbEventStore**: Durable IndexedDB based event store, suitable for web applications.
* **MemoryEventStore**: Non-durable memory based event store, suitable for testing purposes

Links
-----
* https://github.com/joliver/EventStore
