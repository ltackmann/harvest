// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * File backed event store
 */
class FileEventStore implements EventStore {
  /**
   * Store events in files in the [_storeFolder] directory. Each aggregate gets its own file.  
   */ 
  FileEventStore(this._storeFolder, DomainEventFactory eventFactory):
    _logger = LoggerFactory.getLogger("dartstore.FileEventStore"),
    _store = new Map<Guid, File>(), 
    _messageBus = new MessageBus(),
    _jsonSerializer = new JsonSerializer(eventFactory);
  
  Future<int> saveEvents(Guid aggregateId, List<DomainEvent> events, int expectedVersion) {
    var completer = new Completer<int>();
    
    if(!_store.containsKey(aggregateId)) {
      var aggregteFilePath = "${_storeFolder.path}/${aggregateId}.json";
      var aggregateFile = new File(aggregteFilePath);
      aggregateFile.exists().then((bool exists) {
        if(exists) {
          _store[aggregateId] = aggregateFile;
          _readJsonFile(aggregateFile).then((Map json) {
            _saveEventsFor(aggregateId, events, expectedVersion, completer, aggregateFile, json);
          });
        } else {
          aggregateFile.create().then((File file) {
            _store[aggregateId] = file;
            _saveEventsFor(aggregateId, events, expectedVersion, completer, file, {"eventlog":[]});
          });
        }
      });
    } else {
      var aggregateFile = _store[aggregateId];
      _readJsonFile(aggregateFile).then((Map json) {
        _saveEventsFor(aggregateId, events, expectedVersion, completer, aggregateFile, json);
      });
    }
    
    return completer.future; 
  }
  
  Future<Map> _readJsonFile(File file) {
    var completer = new Completer<Map>();
    file.readAsText().then((String text) {
      completer.complete(JSON.parse(text));
    });
    return completer.future;
  }
  
  _saveEventsFor(Guid aggregateId, List<DomainEvent> events, int expectedVersion, Completer<int> completer, File aggregateFile, Map json) {
    if(!json.containsKey("eventlog")) {
      completer.completeException(new IllegalArgumentException("malformed json in file ${aggregateFile.fullPathSync()}"));
    } 
    var eventDescriptors = _jsonSerializer.loadJsonEventDescriptors(json["eventData"]);
    
    // TODO duplicated code begin
    if(expectedVersion != -1 && eventDescriptors.last().version != expectedVersion) {
      completer.completeException(new ConcurrencyException());
    }
    for(DomainEvent event in events) {
      expectedVersion++;
      event.version = expectedVersion;
      eventDescriptors.add(new DomainEventDescriptor(aggregateId, event));
      _logger.debug("saving event ${event.type} for aggregate ${aggregateId}");
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
  
  final Map<Guid, File> _store;
  final Directory _storeFolder;
  final MessageBus _messageBus;
  final Logger _logger;
  final JsonSerializer _jsonSerializer;
}

