// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/** Memory backed model repository */
class MemoryModelRepository<T extends IdModel> implements ModelRepository<T> {
  MemoryModelRepository()  {
    _typeName = genericTypeNameOf(this); 
  }
  
  @override
  List<T> get all => new List.from(_store.values);    
  
  @override
  T getById(Guid id) => _store[id];

  @override
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
    
  @override
  remove(T instance) => _store.remove(instance.id);
  
  @override
  removeById(Guid id) => _store.remove(id);
  
  @override
  save(T instance) => _store[instance.id] = instance;
  
  String _typeName;
  final _store = new Map<Guid, T>();
}


