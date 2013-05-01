// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_file;

/** File backed event store */
class FileEventStore implements EventStore {
  /// create [EventStore] in  [directory] (directory is created if it does not exists)
  FileEventStore(String directory): this.path(new Path(directory));
  
  /// create [EventStore] in  [_directory] (directory is created if it does not exists)
  FileEventStore.path(this._directory) {
    var dir = new Directory.fromPath(_directory);
    if(!dir.existsSync()) {
      _logger.debug('creating file event store directory ${dir}');
      dir.createSync();
    }
  }
  
  @override
  EventStream openStream(Guid id, [int expectedVersion = -1]) {
    if(!_store.containsKey(id)) {
      var filePath = _directory.append('${id}.log');
      var file = new File.fromPath(filePath);
      if(!file.existsSync()) {
        _logger.debug('creating file event stream ${file}');
        file.createSync();
        _store[id] = new _FileEventStream.init(id, file);
      } else {
        _store[id] = new _FileEventStream.load(file);
      }
    } 
    var stream = _store[id];
    if(stream.streamVersion != expectedVersion) {
      new ConcurrencyError("unexpected version $expectedVersion");
    }
    return stream;
  }
  
  // TODO implement async
  @override
  Future<EventStream> openStreamAsync(Guid id, [int expectedVersion = -1]) => new Future.value(openStream(id, expectedVersion));
  
  final Path _directory;
  static final _store = new Map<Guid, EventStream>();
  static final _logger = LoggerFactory.getLoggerFor(FileEventStore);
}

class _FileEventStream implements EventStream {
  factory _FileEventStream.init(Guid id, File eventLog) {
    var version = -1;
    var descriptor = new _FileEventStreamDescriptor.createNew(id, version, <DomainEvent>[]);
    descriptor.writeAsJsonSync(eventLog);
    return new _FileEventStream._internal(eventLog, descriptor);
  }

  factory _FileEventStream.load(File eventLog) {
    var descriptor = new _FileEventStreamDescriptor();
    descriptor.loadFromJsonSync(eventLog);
    return new _FileEventStream._internal(eventLog, descriptor);
  }
  
  _FileEventStream._internal(this._eventLog, this._descriptor);

  @override
  Iterable<DomainEvent> get committedEvents => _descriptor.events;

  @override
  Iterable<DomainEvent> get uncommittedEvents => _uncommittedEvents;

  @override
  commitChanges({commitListener(DomainEvent):null}) {
    _uncommittedEvents.forEach((DomainEvent event) {
      _descriptor.version++;
      event.version = streamVersion;
      _descriptor.events.add(event);
      _logger.debug("saving event ${event.runtimeType} for id ${id} in ${_eventLog}");
    });
    _descriptor.writeAsJsonSync(_eventLog);
    if(?commitListener) {
      _uncommittedEvents.forEach(commitListener);
    }
    clearChanges();
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
  Guid get id => _descriptor.id; 
  
  @override
  int get streamVersion => _descriptor.version;
  
  final _FileEventStreamDescriptor _descriptor;
  final File _eventLog;
  final _uncommittedEvents = new List<DomainEvent>();
  static final _logger = LoggerFactory.getLoggerFor(FileEventStore);
}

class _FileEventStreamDescriptor {
  _FileEventStreamDescriptor();
  
  _FileEventStreamDescriptor.createNew(this.id, this.version, this.events);
  
  // write this descriptor to a file as JSON
  writeAsJsonSync(File jsonFile) {
    var serialization = new Serialization()..addRuleFor(this);
    var jsonData = serialization.write(this);
    var jsonString = JSON.stringify(jsonData);
    jsonFile.writeAsStringSync(jsonString, mode:FileMode.APPEND);
  }
  
  // load this descriptor from JSON
  loadFromJsonSync(File jsonFile) {
    var jsonString = jsonFile.readAsStringSync();
    var jsonData = JSON.parse(jsonString);
    var serialization = new Serialization()..addRuleFor(new _FileEventStreamDescriptor());
    _FileEventStreamDescriptor descriptor = serialization.read(jsonData);
    
    this.id = descriptor.id;
    this.version = descriptor.version;
    this.events = descriptor.events;
  }
  
  Guid id;
  int version;
  List<DomainEvent> events;
}



