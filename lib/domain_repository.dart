// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Repository that stores and retrieves domain objects by their events
 */
abstract class DomainRepository<T extends AggregateRoot>  {
  DomainRepository(String type, this._builder, this._store)
    : _logger = LoggerFactory.getLogger("dartstore.${type}DomainRepository");
  
  /**
   * Save aggregate, return [true] when the aggregate had events that could be store
   * otherwise [false].
   */ 
  Future<bool> save(AggregateRoot aggregate, [int expectedVersion = -1]) {
    var completer = new Completer<bool>();
    if(aggregate.hasUncommittedChanges) {
      _logger.debug("saving aggregate ${aggregate.id} with ${aggregate.uncommittedChanges.length} new events");
      _store.saveEvents(aggregate.id, aggregate.uncommittedChanges, expectedVersion);
      aggregate.markChangesAsCommitted();
      completer.complete(true);
    } else {
      completer.complete(false);
    }
    return completer.future;
  }

  Future<T> load(Guid id) {
    var completer = new Completer<T>();
    _store.getEventsForAggregate(id).then((List<DomainEvent> events) {
      var obj = _builder(id);
      _logger.debug("loading aggregate ${id} from ${events.length} total events");
      obj.loadFromHistory(events);
      completer.complete(obj);
    });
    return completer.future;
  }
  
  final Logger _logger;
  final DomainBuilder _builder;
  final EventStore _store;
}


/**
 * A domain builder is a function that returns a bare aggregate root for the supplied id 
 */ 
typedef AggregateRoot DomainBuilder(Guid aggregateId);