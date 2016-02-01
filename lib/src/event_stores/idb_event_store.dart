// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest_idb;

/**
 * Indexed DB backed event store.
 *
 * Seriazlizes events into JSON and stores them in Indexed DB.
 */
class IdbEventStore implements EventStore {
  static final Map<Guid, EventStream> _store = <Guid, EventStream>{};
  final _IdbFactory _idbFactory;

  /**
   * Create [EventStore] in a IndexedDB [Database] named [databaseName] using [objectStoreName].
   */
  IdbEventStore(String databaseName, [String objectStoreName = "harvest_store", String indexName = "harvest_index", int databaseVersion = 2])
    : _idbFactory = new _IdbFactory(databaseName, objectStoreName, indexName, databaseVersion);


  @override
  Future<EventStream> openStream(Guid id, [int expectedStreamVersion = -1]) async {
    _IdbFacade idbFacade = await _idbFactory.facade;
    EventStream eventStream;
    if(_store.containsKey(id)) {
      eventStream = _store[id];
    } else {
      eventStream = await idbFacade.getEventStream(id);
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
 * IndexedDB backed [EventStream]
 */
class _IdbEventStream implements EventStream {
  final JsonEventStreamDescriptor _descriptor;
  final _IdbFacade _idbFacade;
  final _uncommittedEvents = new List<DomainEvent>();

  _IdbEventStream(this._idbFacade, this._descriptor);

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
      _logger.debug("saving event ${event.runtimeType} for id ${id} in ${_idbFacade.objectStoreName}");
    });
    // save events
    await _idbFacade.saveDescriptor(_descriptor);
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
 * Facade for interacting with IndexedDB
 *
 * See [Dart IndexedDB guide][https://www.dartlang.org/docs/tutorials/indexeddb] for
 * resources regarding implementation detail
 */
class _IdbFacade {
  final Database database;
  final String objectStoreName;
  final String indexName;

  _IdbFacade(this.database, this.objectStoreName, this.indexName);

  /**
   * Get or create [EventStream] for [id]
   */
  Future<EventStream> getEventStream(Guid id) async {
    JsonEventStreamDescriptor descriptor = await getDescriptor(id);
    if(descriptor == null) {
       _logger.debug('creating event stream in ${objectStoreName} for key ${id.hashCode}');
       descriptor = await saveDescriptor(new JsonEventStreamDescriptor.createNew(id));
     } else {
       _logger.debug('loading event stream from ${objectStoreName} for key ${id.hashCode} ');
    }

    return new _IdbEventStream(this, descriptor);
  }

  /**
   * Save descriptor, returns Future with the saved descriptor when the operation is completed
   */
  Future<JsonEventStreamDescriptor> saveDescriptor(JsonEventStreamDescriptor descriptor) async {
    var transaction = database.transaction(objectStoreName, "readwrite");
    var objectStore = transaction.objectStore(objectStoreName);
    var jsonData = descriptor.toJsonString();
    await objectStore.put(jsonData, descriptor.id.hashCode);
    await transaction.completed;
    return descriptor;
  }

  /**
   * Get descriptor for [id] from the database, returns [null] if none found
   */
  Future<JsonEventStreamDescriptor> getDescriptor(Guid id) async {
    // load descriptor data
    var transaction = database.transaction(objectStoreName, "readonly");
    var objectStore = transaction.objectStore(objectStoreName);
    var streamData = await objectStore.getObject(id.hashCode);
    await transaction.completed;
    // build descriptor from data
    JsonEventStreamDescriptor descriptor;
    if(streamData != null) {
      descriptor = new JsonEventStreamDescriptor.createNew(id);
      descriptor.fromJsonString(streamData as String);
    }
    return descriptor;
  }
}

/**
 * Factory for connecting to IndexedDB [Database]s
 */
class _IdbFactory {
  final String databaseName;
  final int databaseVersion;
  final String objectStoreName;
  final String indexName;

  _IdbFactory(this.databaseName, this.objectStoreName, this.indexName, this.databaseVersion);

  Future<_IdbFacade> get facade async {
    var database = await openDatabase(databaseName, objectStoreName, indexName, databaseVersion);
    return new _IdbFacade(database, objectStoreName, indexName);
  }

  /**
   * Helper function for opening IndexedDB databases
   */
  Future<Database> openDatabase(String databaseName, String objectStoreName, String indexName, int databaseVersion) async {
    if(!IdbFactory.supported) {
      throw new UnsupportedError("enviroment does not contain support for IndexedDb");
    }
    var database = await window.indexedDB.open(databaseName,
          version: databaseVersion,
          onUpgradeNeeded: (VersionChangeEvent e) {
            Database db = (e.target as Request).result;
            var objectStore = db.createObjectStore(objectStoreName, autoIncrement: true);
            objectStore.createIndex(indexName, '$objectStoreName', unique: true);
          });
    return database;
  }
}

Logger _logger = LoggerFactory.getLoggerFor(IdbEventStore);
