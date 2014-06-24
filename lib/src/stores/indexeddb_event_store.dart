// Copyright (c) 2013-2014, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_indexeddb;

/** indexed db backed event store */
class IndexeddbEventStore implements EventStore {
  /// create [EventStore] as Indexed DB name [_databaseName]
  IndexeddbEventStore(this._databaseName);
  
  @override
  Future<EventStream> openStream(Guid id, [int expectedVersion = -1]) {
    var completer = new Completer<EventStream>();
    
    if(_store.containsKey(id)) {
      var stream = _store[id];
      _checkStreamVersion(stream, expectedVersion);
      completer.complete(stream);
    } else {
      _getEventStream(id, _databaseName, expectedVersion).then((EventStream stream) {
        _store[id] = stream;
        _checkStreamVersion(stream, expectedVersion);
        completer.complete(stream);
      });
    }
    
    return completer.future;
  }
  
  _checkStreamVersion(EventStream stream, int expectedVersion) {
    if(stream.streamVersion != expectedVersion) {
      new ConcurrencyError("unexpected version $expectedVersion");
    }
  }
  
  final String _databaseName;
  static final _store = new Map<Guid, EventStream>();
}

class _IndexeddbEventStream implements EventStream {
  _IndexeddbEventStream(this.id): _streamVersion = -1;

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

Future<EventStream> _getEventStream(Guid id, String databaseName, int databaseVersion) {
  var completer = new Completer<EventStream>();  
  
  void _onUpgradeNeeded(VersionChangeEvent event) {
    throw "unsupported"; 
  }
  
  Future<Database> open() {
    return window.indexedDB.open(databaseName, version: databaseVersion, onUpgradeNeeded: _onUpgradeNeeded).then(_loadFromDB);
  }
  
  var filePath = '${directory.path}/${id}.log';
  var file = new File(filePath);
  file.exists().then((bool exists) {
    if(!exists) {
      _logger.debug('creating new event stream in file ${file}');
      file.create().then((File eventLog) {
        var descriptor = new _FileEventStreamDescriptor.createNew(id);
        descriptor.writeAsJson(eventLog).then((_) {
          var stream = new _FileEventStream(eventLog, descriptor);
          completer.complete(stream);
        });
      });
    } else {
      _logger.debug('loading existing event stream from file ${file}');
      var descriptor = new _FileEventStreamDescriptor();
      descriptor.loadFromJson(file).then((File eventLog) {
        return new _FileEventStream(eventLog, descriptor);
      });
    }
  });
  
  return completer.future;
}

Logger _logger = LoggerFactory.getLoggerFor(IndexeddbEventStore);


