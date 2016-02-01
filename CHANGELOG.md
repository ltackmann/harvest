#### 2.0.11
* Minor improvements to tests

#### 2.0.10
* Enable GUI tests of IndexedDB using content shell

#### 2.0.9
* Bump polymer dependencies

#### 2.0.8
* Fix changelog

#### 2.0.8
* Fix changelog

#### 2.0.7
* Correct coverage status URL

#### 2.0.6
* Publish new version as pub upload of 2.0.5 failed

#### 2.0.5
* MessageBus **publish** return type changed to **Future** to signify that error and callback handling may return different data
* MessageBus Dart Stream interface now also supports **CallbackCompleted** messages
* CQRS add **saveAggregate** and **emit** methods to the **DomainRepository** for fine-grained controll when saving aggregates as event streams.
* CQRS change error handling semantics to better allow SAGA failure compensation

#### 2.0.4
* Messagebus now correctly propagates errors in message handlers
* MessageBus supports **cancelOnError** flag and **onError** callback
* Moved **DomainCommands** support for handler callback in to **CallbackCompleted** mixin allowing all message types to provide handler callbacks
* Updated documentation

#### 2.0.0
* MessageBus now supports both synchronous and asynchronous delivery
* MessageBus **fire** method renamed to **publish** and **listen** to **subscribe**
* MessageBus **publish** method now returns correct number of message deliveries
* CQRS module now includes basic SAGA process support including compensating actions
