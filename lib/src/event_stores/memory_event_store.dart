// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/** Memory backed event store */
class MemoryEventStore implements EventStore {
  static final _store = new Map<Guid, EventStream>();

  @override
  Future<EventStream> openStream(Guid id, [int expectedVersion = -1]) async {
    if(!_store.containsKey(id)) {
      _store[id] = new _MemoryEventStream(id);
    }
    var stream = _store[id];
    if(stream.streamVersion != expectedVersion) {
      new ConcurrencyError("unexpected version $expectedVersion");
    }
    return stream;
  }

  @override
  bool containsStream(Guid id) => _store.containsKey(id);
}

class _MemoryEventStream implements EventStream {
  static final _logger = LoggerFactory.getLoggerFor(MemoryEventStore);
  final _uncommittedEvents = new List<DomainEvent>();
  final _committedEvents = new List<DomainEvent>();
  int _streamVersion;

  _MemoryEventStream(this.id): _streamVersion = -1;

  @override
  Iterable<DomainEvent> get committedEvents => _committedEvents;

  @override
  Iterable<DomainEvent> get uncommittedEvents => _uncommittedEvents;

  @override
  Future<int> commitChanges() async {
    var numberOfEvents = _uncommittedEvents.length;

    _uncommittedEvents.forEach((DomainEvent event) {
      _streamVersion++;
      event.version = streamVersion;
      _committedEvents.add(event);
      _logger.debug("saving event ${event.runtimeType} for id ${id}");
    });
    clearChanges();
    return numberOfEvents;
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
}
