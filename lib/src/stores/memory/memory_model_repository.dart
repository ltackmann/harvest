// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store;

/**
 * Memory backed model repository
 */
class MemoryModelRepository<T extends IdModel> implements ModelRepository<T> {
  MemoryModelRepository(): _store = new Map<Guid, T>() {
    _typeName = genericTypeNameOf(this); 
  }
  
  List<T> get all => new List.from(_store.values);    
  
  T getById(Guid id) => _store[id];

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
  
  removeById(Guid id) => _store.remove(id);
  
  save(T instance) => _store[instance.id] = instance;
  
  String _typeName;
  Logger get _logger => LoggerFactory.getLogger(_typeName);
  final Map<Guid,T> _store;
}


