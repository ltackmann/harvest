// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of harvest;

/**
 * Repository that stores and retrieves domain objects (aggregates) by their events
 */
class DomainRepository<T extends AggregateRoot>  {
  DomainRepository(this._builder, this._store) {
    _typeName = genericTypeNameOf(this);
  }
  
  /**
   * Save aggregate, return [true] when the aggregate had unsaved data otherwise [false].
   */ 
  Future<bool> save(AggregateRoot aggregate, [int expectedVersion = -1]) {
    var completer = new Completer<bool>();
    if(aggregate.hasUncommittedChanges) {
      _logger.debug("saving aggregate ${aggregate.id} with ${aggregate.uncommittedChanges.length} new events");
      _store.saveEvents(aggregate.id, aggregate.uncommittedChanges, expectedVersion).then((r) {
        aggregate.markChangesAsCommitted();
        completer.complete(true);
      });
    } else {
      completer.complete(false);
    }
    return completer.future;
  }

  /**
   * Load aggregate by its id
   */ 
  Future<T> load(Guid id) {
    var completer = new Completer<T>();
    _store.getEventsForAggregate(id).then((Iterable<DomainEvent> events) {
      var obj = _builder(id);
      _logger.debug("loading aggregate ${id} from ${events.length} total events");
      obj.loadFromHistory(events);
      completer.complete(obj);
    });
    return completer.future;
  }
  
  Logger get _logger => LoggerFactory.getLoggerFor(DomainRepository);
  
  String _typeName;
  final AggregateBuilder _builder;
  final EventStore _store;
}
