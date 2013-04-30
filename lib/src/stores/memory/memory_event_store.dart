// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/** Memory backed event store */
class MemoryEventStore implements EventStore {
  Future<EventStream> openStream(Guid id, [int expectedVersion = -1]) {
    if(!_store.containsKey(id)) {
      _store[id] = new MemoryEventStream(id);
    }
    var stream = _store[id];
    if(stream.streamVersion != expectedVersion) {
      new ConcurrencyError("unexpected version $expectedVersion");
    }
    return new Future.value(stream);
  }
  
  final _store = new Map<Guid, EventStream>();
}

class MemoryEventStream implements EventStream {
  MemoryEventStream(this.id): _streamVersion = -1;

  @override
  Iterable<DomainEvent> get committedEvents => _storedEvents;

  @override
  Iterable<DomainEvent> get uncommittedEvents => _changes;

  @override
  commitChanges() {
    _changes.forEach((DomainEvent event) {
      _streamVersion++;
      event.version = streamVersion;
      _storedEvents.add(event);
      _logger.debug("saving event ${event.runtimeType} for id ${id}");
    });
    clearChanges();
  }

  @override
  clearChanges() => _changes.clear();
  
  @override
  bool get hasUncommittedChanges => _changes.length > 0;

  @override
  addAll(Iterable<DomainEvent> events) => events.forEach(add);
  
  @override
  add(DomainEvent event) => _changes.add(event);
  
  @override
  final Guid id;
  
  @override
  int get streamVersion => _streamVersion;
  
  int _streamVersion;
  final _changes = new List<DomainEvent>();
  final _storedEvents = new List<DomainEvent>();
  static final _logger = LoggerFactory.getLoggerFor(MemoryEventStream);
}
