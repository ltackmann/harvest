// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of harvet_indexd_db;

class IDBConnection {
  static IDBDatabase _connection;
  
  IDBConnection(this.dbName, this.version): _logger = LoggerFactory.getLogger(IDBConnection);

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

