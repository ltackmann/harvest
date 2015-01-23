// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/** Memory backed event store */
class MemoryEventStore implements EventStore {
  @override
  Future<EventStream> openStream(Guid id, [int expectedVersion = -1]) {
    if(!_store.containsKey(id)) {
      _store[id] = new _MemoryEventStream(id);
    }
    var stream = _store[id];
    if(stream.streamVersion != expectedVersion) {
      new ConcurrencyError("unexpected version $expectedVersion");
    }
    return new Future.value(stream);
  }
  
  static final _store = new Map<Guid, EventStream>();
}

class _MemoryEventStream implements EventStream {
  _MemoryEventStream(this.id): _streamVersion = -1;

  @override
  Iterable<DomainEvent> get committedEvents => _committedEvents;

  @override
  Iterable<DomainEvent> get uncommittedEvents => _uncommittedEvents;

  @override
  Future<int> commitChanges() {
    var numberOfEvents = _uncommittedEvents.length;
    
    _uncommittedEvents.forEach((DomainEvent event) {
      _streamVersion++;
      event.version = streamVersion;
      _committedEvents.add(event);
      _logger.debug("saving event ${event.runtimeType} for id ${id}");
    });
    clearChanges();
    return new Future.value(numberOfEvents);
  }

  @override
  clearChanges() => _uncommittedEvents.clear();
  
  @override
  bool get hasUncommittedEvents => _uncommittedEvents.length > 0;

  @override
  addAll(Iterable<DomainEvent> events) => events.forEach(add);
  
  @override
  add(DomainEvent event) => _uncommittedEvents.add(event);
  
  @override
  final Guid id;
  
  @override
  int get streamVersion => _streamVersion;
  
  int _streamVersion;
  final _uncommittedEvents = new List<DomainEvent>();
  final _committedEvents = new List<DomainEvent>();
  static final _logger = LoggerFactory.getLoggerFor(MemoryEventStore);
}
