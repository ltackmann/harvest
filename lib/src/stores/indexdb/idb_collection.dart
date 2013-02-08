// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store_indexdb;

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
