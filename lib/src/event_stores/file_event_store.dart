// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest_file;

/**
 * File backed event store.
 *
 * Serializes events as JSON files on disk.
 */
class FileEventStore implements EventStore {
  final Directory _directory;
  static final _store = new Map<Guid, EventStream>();

  /// create [EventStore] in  [directory] (directory is created if it does not exists)
  FileEventStore(String directory): this.path(new Directory(directory));

  /// create [EventStore] in  [_directory] (directory is created if it does not exists)
  FileEventStore.path(this._directory) {
    if(!_directory.existsSync()) {
      _logger.debug('creating file event store directory ${_directory.path}');
      _directory.createSync();
    }
  }

  @override
  Future<EventStream> openStream(Guid id, [int expectedStreamVersion = -1]) async {
    EventStream eventStream;
    if(_store.containsKey(id)) {
      eventStream = _store[id];
    } else {
      eventStream = await _getEventStream(id, _directory);
      _store[id] = eventStream;
    }
    _checkStreamVersion(eventStream, expectedStreamVersion);
    return eventStream;
  }

  @override
  bool containsStream(Guid id) => _store.containsKey(id);

  _checkStreamVersion(EventStream stream, int expectedStreamVersion) {
    if(stream.streamVersion != expectedStreamVersion) {
      new ConcurrencyError("unexpected version $expectedStreamVersion");
    }
  }
}

/**
 * File backed [EventStream]
 */
class _FileEventStream implements EventStream {
  final JsonEventStreamDescriptor _descriptor;
  final File _eventLog;
  final _uncommittedEvents = new List<DomainEvent>();

  _FileEventStream(this._eventLog, this._descriptor);

  @override
  add(DomainEvent event) => _uncommittedEvents.add(event);

  @override
  addAll(Iterable<DomainEvent> events) => events.forEach(add);

  @override
  clearChanges() => _uncommittedEvents.clear();

  @override
  Future<int> commitChanges() async {
    var numberOfEvents = _uncommittedEvents.length;

    _uncommittedEvents.forEach((DomainEvent event) {
      _descriptor.version++;
      event.version = streamVersion;
      _descriptor.events.add(event);
      _logger.debug("saving event ${event.runtimeType} for id ${id} in ${_eventLog}");
    });
    // write events to disk
    await _saveEventStream(_descriptor, _eventLog);
    clearChanges();

    return numberOfEvents;
  }

  @override
  Iterable<DomainEvent> get committedEvents => _descriptor.events;

  @override
  bool get hasUncommittedEvents => _uncommittedEvents.length > 0;

  @override
  Guid get id => _descriptor.id;

  @override
  int get streamVersion => _descriptor.version;

  @override
  Iterable<DomainEvent> get uncommittedEvents => _uncommittedEvents;
}

/**
 * Get or create [EventStream] for [id] in [directory]
 */
Future<EventStream> _getEventStream(Guid id, Directory directory) async {
  var descriptor = new JsonEventStreamDescriptor.createNew(id);

  var eventLog = new File('${directory.path}/${id}.log');
  bool exists = await eventLog.exists();
  if(!exists) {
    // create new event stream
    _logger.debug('creating new event stream in file ${eventLog.path}');
    await eventLog.create();
    await _saveEventStream(descriptor, eventLog);
  } else {
    // load existing event stream
    _logger.debug('loading existing event stream from file ${eventLog.path}');
    var jsonString = await eventLog.readAsString();
    descriptor.fromJsonString(jsonString);
  }

  return new _FileEventStream(eventLog, descriptor);
}

Future<File> _saveEventStream(JsonEventStreamDescriptor descriptor, File eventLog) async {
  var json = descriptor.toJsonString();
  await eventLog.writeAsString(json, mode:FileMode.APPEND);
  return eventLog;
}

Logger _logger = LoggerFactory.getLoggerFor(FileEventStore);
