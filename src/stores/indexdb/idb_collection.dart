// Copyright (c) 2012 Solvr, Inc. all rights reserved.  
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

interface IDBCollection {
  Future addItem(var key, var item); 
  
  forEach(f);
}

class _IDBCollection implements IDBCollection {
  final IDBDatabase _db;
  final String _collection;
  _IDBCollection(this._db, this._collection);
  
  Future<Dynamic> addItem(var key, var item) {
    Completer<Dynamic> completer = new Completer<Dynamic>();
    
    IDBRequest request = _open(IDBTransaction.READ_WRITE).put(item, key);
    request.on.success.add((e) => completer.complete(e));
    request.on.success.add((e) => completer.completeException(e));
  
    return completer.future;
  }
  
  forEach(f) {
    IDBRequest request = _open(IDBTransaction.READ_ONLY).openCursor();
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
    IDBTransaction txn = _db.transaction(_collection, mode);
    return txn.objectStore(_collection);
  }
}
