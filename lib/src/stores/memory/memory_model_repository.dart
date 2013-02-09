// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store;

/**
 * Memory backed model repository
 */
class MemoryModelRepository<T extends IdModel> implements ModelRepository<T> {
  static Map<String, MemoryModelRepository> _cache;
  
  factory MemoryModelRepository() {
    if(_cache == null) {
      _cache = new Map<String, MemoryModelRepository>();
    }
    // TODO this is suboptimal as we will create objects only to throw them away
    //
    // we need to create an instance of the object before we can look it up by
    // runtime type as we do not have access to the type info in a factory 
    // constructor.
    var obj = new MemoryModelRepository._internal();
    if(!_cache.containsKey(obj._typeName)) {
      _cache[obj._typeName] = obj;
    } 
    return _cache[obj._typeName];
  }
  
  MemoryModelRepository._internal(): _store = new Map<Uuid, T>() {
    _typeName = genericTypeNameOf(this); 
  }
  
  List<T> get all => new List.from(_store.values);    
  
  T getById(Uuid id) => _store[id];

  T getOrNew(T builder()) {
    List list = all;
    if(list.isEmpty) {
      var instance = builder();
      save(instance);
      return instance;
    } else if(list.length == 1) {
      return list[0];
    } else {
      throw new StateError("more than one existing instance of ${_typeName} exists");
    }
  }
      
  remove(T instance) => _store.remove(instance.id);
  
  removeById(Uuid id) => _store.remove(id);
  
  save(T instance) => _store[instance.id] = instance;
  
  String _typeName;
  Logger get _logger => LoggerFactory.getLogger(_typeName);
  final Map<Uuid,T> _store;
}


