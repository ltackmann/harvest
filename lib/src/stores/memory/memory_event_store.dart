// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store;

/**
 * Memory backed event store
 */
class MemoryEventStore implements EventStore {
  MemoryEventStore():
    _logger = LoggerFactory.getLogger("dartstore.MemoryEventStore"),
    _store = new Map<Uuid, List<DomainEventDescriptor>>(), 
    _messageBus = new MessageBus();
  
  Future<int> saveEvents(Uuid aggregateId, List<DomainEvent> events, int expectedVersion) {
    var completer = new Completer<int>();
    
    if(!_store.containsKey(aggregateId)) {
      _store[aggregateId] = new List<DomainEventDescriptor>();
    } 
    List<DomainEventDescriptor> eventDescriptors = _store[aggregateId];
    
    if(expectedVersion != -1 && eventDescriptors.last.version != expectedVersion) {
      completer.completeError(new ConcurrencyError());
    }
    for(DomainEvent event in events) {
      expectedVersion++;
      event.version = expectedVersion;
      eventDescriptors.add(new DomainEventDescriptor(aggregateId, event));
      _logger.debug("saving event ${event.runtimeType} for aggregate ${aggregateId}");
    }
    _store[aggregateId] = eventDescriptors;
        
    for(DomainEvent event in events) {
      _messageBus.fire(event);
    }
    completer.complete(events.length);
    
    return completer.future; 
  }
  
  Future<List<DomainEvent>> getEventsForAggregate(Uuid aggregateId) {
    var completer = new Completer<List<DomainEvent>>();
    
    if(!_store.containsKey(aggregateId)) {
      completer.completeError(new AggregateNotFoundError(aggregateId));
    } 
    var eventDescriptors = _store[aggregateId];
    Expect.isTrue(eventDescriptors.length > 0);
    List<DomainEvent> events = eventDescriptors.map((DomainEventDescriptor desc) => desc.eventData);
    completer.complete(events);
    
    return completer.future; 
  }
  
  final Map<Uuid, List<DomainEventDescriptor>> _store;
  final MessageBus _messageBus;
  final Logger _logger;
}

