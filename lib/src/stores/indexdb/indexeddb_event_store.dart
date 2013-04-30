// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvet_indexeddb;

/**
 * IndexDB backed event store
 */
class IDBEventStore implements EventStore {
  // Chrome only for now, see bug http://code.google.com/p/chromium/issues/detail?id=108223
  // [String version = "1", String storeName = "event-store"]
  IDBEventStore(this._connection): _logger = LoggerFactory.getLoggerFor(IDBEventStore) {
    
  }
  
  void saveEvents(Uuid aggregateId, List<DomainEvent> events, int expectedVersion) {
    throw "TODO";
  }
  
  List<DomainEvent> getEventsForAggregate(Uuid aggregateId) {
    throw "TODO";
  }
  
  final IDBConnection _connection;
  final Logger _logger;
}


class IDBConnection {
  static IDBDatabase _connection;
  
  IDBConnection(this.dbName, this.version): _logger = LoggerFactory.getLoggerFor(IDBConnection);

  Future<IDBCollection> open(String collection) {
    Completer<IDBCollection> completer = new Completer<IDBCollection>();
    
    var request = window.webkitIndexedDB.open(dbName);
    request.on.success.add((connected) {
      _logger.debug("opened DB $dbName");
      IDBDatabase db = connected.target.result;
      if (db.version != version) {
        IDBVersionChangeRequest changeRequest = db.setVersion(version);
        changeRequest.on.success.add((versionChangedEvent) {
          _logger.debug("set DB version $version");
          db.createObjectStore(collection);
          completer.complete(new _IDBCollection(db, collection));
        });
        changeRequest.on.error.add((versionError) => completer.completeError(versionError));
      } else {
        completer.complete(new _IDBCollection(db, collection));
      }
    });
    request.on.error.add((connectionError) => completer.completeError(connectionError));
    
    return completer.future;
  }
  
  final Logger _logger;
  final String dbName;
  final String version;
}

abstract class IDBCollection {
  Future addItem(var key, var item); 
  
  forEach(f);
}

class _IDBCollection implements IDBCollection {
  _IDBCollection(this._db, this._collection);
  
  Future<dynamic> addItem(var key, var item) {
    var completer = new Completer<dynamic>();
    
    var request = _open(IDBTransaction.READ_WRITE).put(item, key);
    request.on.success.add((e) => completer.complete(e));
    request.on.success.add((e) => completer.completeError(e));
  
    return completer.future;
  }
  
  forEach(f) {
    var request = _open(IDBTransaction.READ_ONLY).openCursor();
    request.on.success.add((e) {
      var cursor = e.target.result;
      if (cursor != null) {
        f(cursor.value);
        cursor.continueFunction();
      }
    });
    request.on.error.add((e) {
      throw "Could not open cursor: $e";
    });
  }
  
  IDBObjectStore _open(mode) {
    var txn = _db.transaction(_collection, mode);
    return txn.objectStore(_collection);
  }
  
  final IDBDatabase _db;
  final String _collection;
}


