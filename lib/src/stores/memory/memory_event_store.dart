// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/**
 * Memory backed event store
 */
class MemoryEventStore implements EventStore {
  MemoryEventStore():
    _logger = LoggerFactory.getLoggerFor(MemoryEventStore),
    _store = new Map<Guid, List<DomainEventDescriptor>>(), 
    _messageBus = new MessageBus();
  
  Future<int> saveEvents(Guid aggregateId, List<DomainEvent> events, int expectedVersion) {
    var completer = new Completer<int>();
    
    if(!_store.containsKey(aggregateId)) {
      _store[aggregateId] = new List<DomainEventDescriptor>();
    } 
    List<DomainEventDescriptor> eventDescriptors = _store[aggregateId];
    
    if(expectedVersion != -1 && eventDescriptors.last.version != expectedVersion) {
      completer.completeError(new ConcurrencyError("unexpected version $expectedVersion"));
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
  
  Future<Iterable<DomainEvent>> getEventsForAggregate(Guid aggregateId) {
    var completer = new Completer<Iterable<DomainEvent>>();
    
    if(!_store.containsKey(aggregateId)) {
      completer.completeError(new AggregateNotFoundError(aggregateId));
    } 
    var eventDescriptors = _store[aggregateId];
    assert(eventDescriptors.length > 0);
    var events = eventDescriptors.map((DomainEventDescriptor desc) => desc.eventData);
    completer.complete(events);
    
    return completer.future; 
  }
  
  final Map<Guid, List<DomainEventDescriptor>> _store;
  final MessageBus _messageBus;
  final Logger _logger;
}

