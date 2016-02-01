[![Build Status](https://travis-ci.org/ltackmann/harvest.svg)](https://travis-ci.org/ltackmann/harvest)
[![Coverage Status](https://coveralls.io/repos/ltackmann/harvest/badge.svg?branch=master&service=github)](https://coveralls.io/github/ltackmann/harvest?branch=master)

# Harvest
Harvest is a messagebus, CQRS framework and eventstore for Dart with multiple backends. Features include

### Message bus features
 * Synchronous and asynchronous delivery
 * Support for both "fire-and-forget" as well as delivery notication
 * Custom message callsbacks allowing subscribers to notify publishers of message status
 * Simple message bus API including standard Dart Stream/Sink interface
 * Extensive error handling support
 * Intercept dead messages (i.e. messages with no listeners)
 * Listen to all published events regardless of type
 * Enrich messages prior to their delivery

### Event store features
 * Create, persist and manipulate streams of events independently of the event storage type
 * Simple API for supporting differnt storage backends for events
 * Supports file, IndexedDB and memory backends

### CQRS support
 * Support for creating event sourced entities and aggregate roots
 * Support SAGA patterns for long running business process including compensating actions


## MessageBus
You can use the message bus standalone or in conjuction with the event store. Message delivery can be synchronous or asynchronous

```dart
// Synchronous messagebus
var syncMessageBus = new MessageBus()

// Asynchronous messagebus
var asyncmessageBus = new MessageBus.async()
```

the message bus support  both "fire-and-forget" as well as delivery notications
```dart
// subscribe to MyMessage
messageBus.subscribe(MyMessage, (MyMessage msg) => print(msg));

// Publish message and continue immediately
messageBus.publish(myMessage);

// Publish message and await until it has been handled by all subscribers  
int deliveredTo = await messageBus.publish(myMessage);
```

Messages can be programmatically completed by subscribers by using the **CallbackCompleted** message mixin
```dart
// Message that is completed by custom callback
class CallbackMessage extends Message with CallbackCompleted {
}
// CallbackCompleted messages provide their own success callback
messageBus.subscribe(CallbackMessage, (CallbackMessage msg) {
  print("handled $msg");
  // complete callback successfully
  msg.completed(true, "callback data");
});

// Publish message the result will contain "callback data"
var result = await messageBus.publish(myMessage);

// CallbackCompleted messages provide their own error callback
messageBus.subscribe(CallbackMessage, (CallbackMessage msg) {
  print("handled $msg");
  // complete message with an error
  msg.completed(false, "some error occured");
});

try {
  messageBus.publish(new CallbackMessage();
} catch(e} {
  // e = "some error occured";
}
```

If you prefer the Dart Stream/Sink interface HArvest supports this as well
```dart
// Get a stream for MyMessage
var stream = messageBus.stream(MyMessage);
// Listen to stream
stream.listen((MyMessage myMessage) => print("recieved message $myMessage"));

// Get sink for MyMessage
var sink = messageBus.sink(MyMessage);
// Use sink to dispatch event
sink.add(new MyMessage("a message"));
```

Error handling can be done both through streams and message bus interface
```dart
// Using stream interface: **onError** function invoked when listener fails
messageBus.stream(MyMessage).listen((m) {
  // handled m
}, onError:(e) => print("error $e"));

// Using messagebus interface: **onError** function invoked when listener fails
messageBus.subscribe(MyMessage, (m) {
  // handled m
}, onError:(e) => print("error $e"));


```

Harvest exposes a hook for intercepting messages that has no listeners
```dart
// Handler invoked when a message with no subscribers is published
messageBus.deadMessageHandler = (Message msg) => print("no handler for ${msg.runtimeType}");
```

You can also listen to all events regardless of types
```dart
messageBus.everyMessage.listen((Message msg) => print("message ${msg.runtimeType} published");
```

If you want to intercept all messages prior to delivery you can use Harvest message enricher API
```dart
// Enricher that stores the current user id in the messages header
messageBus.enricher = (Message m) {
  m.headers["userId"] = StaticSessionData.userId;    
};  
```        

## Event store
Harvest event store can be used for simply storing events which can later be retrieved
```dart
	import 'package:harvest/harvest.dart';

	main() async {
		var streamId = new Guid();
		var eventStore = new MemoryEventStore();
		// get a event stream for streamId
		eventStream = await eventStore.openStream(streamId);
		// create some events
		var event1 = ...
		var event2 = ...

		// store them
		eventStream.addAll([event1, event2]);
		eventStream.commitChanges();
	}
```

Various backends are included in the standard Harvest distribution
```dart
  // Harvest FileEventStore that stores events in JSON files
  import 'package:harvest/harvest_file.dart';
  var eventStore = new FileEventStore("path/to/file.txt");

  // Harvest IdbEventStore that stores events in IndexdDB databases
  import 'package:harvest/harvest_idb.dart';
  var eventStore = new IdbEventStore("idb_database");
```

new EventStores can be created by implementing the **EventStore** and **EventStream** APIs

### Event sourcing
Fully fletched event sourced applications are also supported. Event sourcing is the concept of saving and retriving objects by the events
that occured on them rather than by their state. Consider the following bank account use case:

1. User creates account
1. User deposits 10$
1. User withdraws 2$

In a CRUD application you would now have a **BankAccount** object with an amount property with the value **8**. In a event sourced application you
have a **BankAccount** object and 3 events for it

1. AccountCreated
1. AmountDeposited
1. AmountWithdrawn

Where is this useful?

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

Links
-----
 * https://github.com/NEventStore/NEventStore

 TODO
-----
 * Rewrite example GUI app in Polymer
 * Create serialization interface that allows switching between mirror, transformation and manual serializations 
 * Document usage of SAGAs (process manager)
 * Ensure message headers are not serialized
 * Enable CQRS event reloading test
 * Create serialization interface that allows switching between mirror, transformation and manual serializations
