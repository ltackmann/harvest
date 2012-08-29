// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Memory backed event store
 */
class MemoryEventStore implements EventStore {
  MemoryEventStore():
    _logger = LoggerFactory.getLogger("dartstore.MemoryEventStore"),
    _store = new Map<Guid, List<DomainEventDescriptor>>(), 
    _messageBus = new MessageBus();
  
  Future<int> saveEvents(Guid aggregateId, List<DomainEvent> events, int expectedVersion) {
    var completer = new Completer<int>();
    
    if(!_store.containsKey(aggregateId)) {
      _store[aggregateId] = new List<DomainEventDescriptor>();
    } 
    List<DomainEventDescriptor> eventDescriptors = _store[aggregateId];
    
    if(expectedVersion != -1 && eventDescriptors.last().version != expectedVersion) {
      completer.completeException(new ConcurrencyException());
    }
    var v = expectedVersion;
    for(DomainEvent event in events) {
      v++;
      event.version = v;
      eventDescriptors.add(new DomainEventDescriptor(aggregateId, event, v));
      _logger.debug("saving event ${event.type} for aggregate ${aggregateId}");
    }
    _store[aggregateId] = eventDescriptors;
        
    for(DomainEvent event in events) {
      _messageBus.fire(event);
    }
    completer.complete(events.length);
    
    return completer.future; 
  }
  
  Future<List<DomainEvent>> getEventsForAggregate(Guid aggregateId) {
    var completer = new Completer<List<DomainEvent>>();
    
    if(!_store.containsKey(aggregateId)) {
      completer.completeException(new AggregateNotFoundException(aggregateId));
    } 
    var eventDescriptors = _store[aggregateId];
    Expect.isTrue(eventDescriptors.length > 0);
    List<DomainEvent> events = eventDescriptors.map((DomainEventDescriptor desc) => desc.eventData);
    completer.complete(events);
    
    return completer.future; 
  }
  
  final Map<Guid, List<DomainEventDescriptor>> _store;
  final MessageBus _messageBus;
  final Logger _logger;
}

