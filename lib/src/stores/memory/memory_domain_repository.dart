// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store;

/**
 * Memory backed domain repository 
 */
class MemoryDomainRepository<T extends AggregateRoot> extends DomainRepository<T> {
  static Map<String, DomainRepository> _repositoryCache;
  static EventStore _eventstore;
  
  /**
   * @type is the class name of T and builder is a DomainBuilder for T 
   *
   * TODO remove these arguments once you can use reflection to get the same info
   */
  factory MemoryDomainRepository(String type, AggregateBuilder builder) {
    if(_eventstore == null) {
      _eventstore = new MemoryEventStore();
    }
    if(_repositoryCache == null) {
      _repositoryCache = new Map<String, DomainRepository>();
    }
    if(!_repositoryCache.containsKey(type)) {
      _repositoryCache[type] = new MemoryDomainRepository._internal(type, builder);
    }
    return _repositoryCache[type];
  }

  MemoryDomainRepository._internal(String type, AggregateBuilder builder): super(type, builder, _eventstore);
}
