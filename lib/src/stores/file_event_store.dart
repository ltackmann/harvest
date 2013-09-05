// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_file;

/** File backed event store */
class FileEventStore implements EventStore {
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
  Future<EventStream> openStream(Guid id, [int expectedVersion = -1]) {
    var completer = new Completer<EventStream>();
    
    if(_store.containsKey(id)) {
      var stream = _store[id];
      _checkStreamVersion(stream, expectedVersion);
      completer.complete(stream);
    } else {
      _getEventStream(id, _directory).then((EventStream stream) {
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
  
  final Directory _directory;
  static final _store = new Map<Guid, EventStream>();
}

class _FileEventStream implements EventStream {
  _FileEventStream(this._eventLog, this._descriptor);

  @override
  Iterable<DomainEvent> get committedEvents => _descriptor.events;

  @override
  Iterable<DomainEvent> get uncommittedEvents => _uncommittedEvents;

  @override
  Future<int> commitChanges() {
    var completer = new Completer<int>();
    var numberOfEvents = _uncommittedEvents.length;
    
    _uncommittedEvents.forEach((DomainEvent event) {
      _descriptor.version++;
      event.version = streamVersion;
      _descriptor.events.add(event);
      _logger.debug("saving event ${event.runtimeType} for id ${id} in ${_eventLog}");
    });
    _descriptor.writeAsJson(_eventLog).then((_) {
      clearChanges();
      completer.complete(numberOfEvents);
    });
    
    return completer.future;
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
}

Future<EventStream> _getEventStream(Guid id, Directory directory) {
  var completer = new Completer<EventStream>();  
  
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

class _FileEventStreamDescriptor {
  _FileEventStreamDescriptor();
  
  _FileEventStreamDescriptor.createNew(this.id)
    : version = -1,
      events = [];
  
  // write this descriptor to a file as JSON
  Future<File> writeAsJson(File jsonFile) {
    var serialization = new Serialization()..addRuleFor(this);
    var jsonData = serialization.write(this);
    var jsonString = JSON.stringify(jsonData);
    return jsonFile.writeAsString(jsonString, mode:FileMode.APPEND);
  }
  
  // load this descriptor from JSON
  Future<File> loadFromJson(File jsonFile) {
    var completer = new Completer<_FileEventStreamDescriptor>();
    
    jsonFile.readAsString().then((String jsonString) {
      var jsonData = JSON.parse(jsonString);
      var serialization = new Serialization()..addRuleFor(new _FileEventStreamDescriptor());
      _FileEventStreamDescriptor descriptor = serialization.read(jsonData);
      this.id = descriptor.id;
      this.version = descriptor.version;
      this.events = descriptor.events;
      
      completer.complete(jsonFile);
    });
    
    return completer.future;
  }
  
  Guid id;
  int version;
  List<DomainEvent> events;
}

Logger _logger = LoggerFactory.getLoggerFor(FileEventStore);



