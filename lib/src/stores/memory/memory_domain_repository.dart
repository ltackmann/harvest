// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Memory backed domain repository 
 */
class MemoryDomainRepository<T extends AggregateRoot> extends DomainRepository<T> {
  static Map<String, DomainRepository> _cache;
  static EventStore _store;
  
  /**
   * @type is the class name of T and builder is a DomainBuilder for T 
   *
   * TODO remove these arguments once you can use reflection to get the same info
   */
  factory MemoryDomainRepository(String type, AggregateBuilder builder) {
    if(_store == null) {
      _store = new MemoryEventStore();
    }
    if(_cache == null) {
      _cache = new Map<String, DomainRepository>();
    }
    if(!_cache.containsKey(type)) {
      _cache[type] = new MemoryDomainRepository._internal(type, builder);
    }
    return _cache[type];
  }

  MemoryDomainRepository._internal(String type, AggregateBuilder builder): super(type, builder, _store);
}
