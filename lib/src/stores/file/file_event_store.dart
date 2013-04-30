// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_file;

/*
/** File backed event store */
class FileEventStore implements EventStore {
  /** Store events in files in the [directory] directory */ 
  FileEventStore(Directory directory): _store = new _FileStore(directory);
  
  Future<int> saveEvents(Guid aggregateId, List<DomainEvent> events, int expectedVersion) {
    var completer = new Completer<int>();
    
    if(!_stores.containsKey(aggregateId)) {
      // TODO switch to using path for windows support
      var aggregteFilePath = "${_store.path}/${aggregateId}.json";
      var aggregateFile = new File(aggregteFilePath);
      aggregateFile.exists().then((bool exists) {
        if(exists) {
          _logger.debug("using existing aggregate file $aggregteFilePath");
          _stores[aggregateId] = aggregateFile;
          _readJsonFile(aggregateFile).then((Map json) {
            _saveEventsFor(aggregateId, events, expectedVersion, completer, aggregateFile, json);
          });
        } else {
          _logger.debug("creating aggregate file $aggregteFilePath");
          aggregateFile.create().then((File file) {
            _stores[aggregateId] = file;
            _saveEventsFor(aggregateId, events, expectedVersion, completer, file, {"eventlog":[]});
          });
        }
      });
    } else {
      var aggregateFile = _stores[aggregateId];
      _readJsonFile(aggregateFile).then((Map json) {
        _saveEventsFor(aggregateId, events, expectedVersion, completer, aggregateFile, json);
      });
    }
    
    return completer.future; 
  }
  
  Future<Map> _readJsonFile(File file) {
    var completer = new Completer<Map>();
    file.readAsString().then((String text) {
      completer.complete(JSON.parse(text));
    });
    return completer.future;
  }
  
  _saveEventsFor(Guid aggregateId, List<DomainEvent> events, int expectedVersion, Completer<int> completer, File aggregateFile, Map data) {
    if(!data.containsKey("eventlog")) {
      completer.completeError(new ArgumentError("malformed data in file ${aggregateFile.fullPathSync()}"));
    } 
    var eventDescriptors = _jsonSerializer.loadJsonEventDescriptors(data["eventData"]);
    
    // TODO duplicated code begin
    if(expectedVersion != -1 && eventDescriptors.last.version != expectedVersion) {
      completer.completeError(new ConcurrencyError());
    }
    for(DomainEvent event in events) {
      expectedVersion++;
      event.version = expectedVersion;
      eventDescriptors.add(new DomainEventDescriptor(aggregateId, event));
      _logger.debug("saving event ${event.runtimeType} for aggregate ${aggregateId}");
    }
    // TODO duplicated code end
    
    var jsonEventDescriptors = _jsonSerializer.writeJsonEventDescriptors(eventDescriptors);
    _storeJsonFile(aggregateFile, jsonEventDescriptors).then((f) {
      // TODO duplicated code begin
      for(DomainEvent event in events) {
        _messageBus.fire(event);
      }
      completer.complete(events.length);
      // TODO duplicated code end
    });
  }
  
  Future<File> _storeJsonFile(File file, Map json) {
    var completer = new Completer<File>();
    var text = JSON.stringify(json);
    file.open(FileMode.WRITE).then((output) {
      output.writeString(text).then((r) {
        // TODO remove these        
        r.flushSync();
        completer.complete(file);
      });
    });
    return completer.future;
  }
  
  Future<List<DomainEvent>> getEventsForAggregate(Guid aggregateId) {
    /*
    var completer = new Completer<List<DomainEvent>>();
    
    if(!_store.containsKey(aggregateId)) {
      completer.completeException(new AggregateNotFoundException(aggregateId));
    } 
    var eventDescriptors = _store[aggregateId];
    Expect.isTrue(eventDescriptors.length > 0);
    List<DomainEvent> events = eventDescriptors.map((DomainEventDescriptor desc) => desc.eventData);
    completer.complete(events);
    
    return completer.future; 
    */
  }
  
  final Directory _storeFolder;
  final JsonSerializer _jsonSerializer;
  final _store = new _FileStore();
  
  static final _logger = LoggerFactory.getLoggerFor(FileEventStore);
}

class _FileStore {
  _File
  if(!_stores.containsKey(aggregateId)) {
    // TODO switch to using path for windows support
    var aggregteFilePath = "${_store.path}/${aggregateId}.json";
    var aggregateFile = new File(aggregteFilePath);
    aggregateFile.exists().then((bool exists) {
      if(exists) {
        _logger.debug("using existing aggregate file $aggregteFilePath");
        _stores[aggregateId] = aggregateFile;
        _readJsonFile(aggregateFile).then((Map json) {
          _saveEventsFor(aggregateId, events, expectedVersion, completer, aggregateFile, json);
        });
      } else {
        _logger.debug("creating aggregate file $aggregteFilePath");
        aggregateFile.create().then((File file) {
          _stores[aggregateId] = file;
          _saveEventsFor(aggregateId, events, expectedVersion, completer, file, {"eventlog":[]});
        });
      }
    });
  } else {
    var aggregateFile = _stores[aggregateId];
    _readJsonFile(aggregateFile).then((Map json) {
      _saveEventsFor(aggregateId, events, expectedVersion, completer, aggregateFile, json);
    });
  }
  
  
  Future<File> getFileFor(Guid aggregateId) {
    if(!_stores.containsKey(aggregateId)) {
      
    } else {
      return new Future.of(_stores[])
    }
  }
  
  final _stores = new Map<Guid, File>();
}
*/
