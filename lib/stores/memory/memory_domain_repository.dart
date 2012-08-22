// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Memory backed domain repository that stores and retrieves domain objects by their events
 */
class MemoryDomainRepository<T extends AggregateRoot> implements DomainRepository<T> {
  static Map<String, MemoryDomainRepository> _cache;
  static EventStore _store;
  final Logger _logger;
  DomainBuilder _builder;
  
  /**
   * @type is the class name of T and builder is a DomainBuilder for T 
   *
   * TODO remove these arguments once you can use reflection to get the same info
   */
  factory MemoryDomainRepository(String type, DomainBuilder builder) {
    if(_store == null) {
      _store = new MemoryEventStore();
    }
    if(_cache == null) {
      _cache = new Map<String, MemoryDomainRepository>();
    }
    if(!_cache.containsKey(type)) {
      _cache[type] = new MemoryDomainRepository._internal(type, builder);
    }
    return _cache[type];
  }

  MemoryDomainRepository._internal(String type, this._builder)
    : _logger = LoggerFactory.getLogger("cqrs4dart.${type}DomainRepository");
  
  save(AggregateRoot aggregate, [int expectedVersion = -1]) {
    if(aggregate.hasUncommittedChanges) {
      _logger.debug("saving aggregate ${aggregate.id} with ${aggregate.uncommittedChanges.length} new events");
      _store.saveEvents(aggregate.id, aggregate.uncommittedChanges, expectedVersion);
      aggregate.markChangesAsCommitted();
    }
  }

  T load(Guid id) {
    var obj = _builder(id);
    var events = _store.getEventsForAggregate(id);
    _logger.debug("loading aggregate ${id} from ${events.length} total events");
    obj.loadFromHistory(events);
    return obj;
  }
}





