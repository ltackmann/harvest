// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Memory backed event store, mostly suitable for test use
 */
class MemoryEventStore implements EventStore {
  MemoryEventStore():
    _logger = LoggerFactory.getLogger("cqrs4dart.MemoryEventStore"),
    _store = new LinkedHashMap<Guid, List<DomainEventDescriptor>>(), 
    _messageBus = new MessageBus();
  
  void saveEvents(Guid aggregateId, List<DomainEvent> events, int expectedVersion) {
    if(!_store.containsKey(aggregateId)) {
      _store[aggregateId] = new List<DomainEventDescriptor>();
    } 
    List<DomainEventDescriptor> eventDescriptors = _store[aggregateId];
    
    if(expectedVersion != -1 && eventDescriptors.last().version != expectedVersion) {
      throw new ConcurrencyException();
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
  }
  
  List<DomainEvent> getEventsForAggregate(Guid aggregateId) {
    if(!_store.containsKey(aggregateId)) {
      throw new AggregateNotFoundException(aggregateId);
    } 
    var eventDescriptors = _store[aggregateId];
    Expect.isTrue(eventDescriptors.length > 0);
    return eventDescriptors.map((DomainEventDescriptor desc) => desc.eventData);
  }
  
  final Map<Guid, List<DomainEventDescriptor>> _store;
  final MessageBus _messageBus;
  final Logger _logger;
}

