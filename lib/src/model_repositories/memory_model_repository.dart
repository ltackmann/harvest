// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/** Memory backed model repository */
class MemoryModelRepository<T extends Identifiable> implements ModelRepository<T> {
  final Map<Guid, T> _store = <Guid, T>{};
  
  @override
  List<T> get all => new List.from(_store.values);    
  
  @override
  T getById(Guid id) => _store[id];

  @override
  T getOrNew(Guid id, T builder()) {
    if(!_store.containsKey(id)) {
      var instance = builder();
      save(instance);
    }
    return getById(id);
  }
    
  @override
  remove(T instance) => _store.remove(instance.id);
  
  @override
  removeById(Guid id) => _store.remove(id);
  
  @override
  save(T instance) => _store[instance.id] = instance;
}


