// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_cqrs;

/** Repository that stores and retrieves domain objects (aggregates) by their events. */
class DomainRepository<T extends AggregateRoot>  {
  DomainRepository(this._builder, this._store, this._messageBus) {
    _typeName = genericTypeNameOf(this);
  }
  
  /** Save aggregate, return [true] when the aggregate had unsaved data otherwise [false]. */ 
  Future<bool> save(AggregateRoot aggregate, [int expectedVersion = -1]) {
    var completer = new Completer<bool>();
    // TODO clean this mess, get event stream from aggreate
    if(aggregate.hasUncommittedChanges) {
      var events = aggregate.uncommittedChanges;
      _logger.debug("saving aggregate ${aggregate.id} with ${events.length} new events");
      _store.openStream(aggregate.id, expectedVersion).then((stream) {
        stream.addAll(events);
        stream.commitChanges();
        aggregate.markChangesAsCommitted();
        _notifyEventListeners(events);
        completer.complete(true);
      });
    } else {
      completer.complete(false);
    }
    return completer.future;
  }
  
  _notifyEventListeners(List<DomainEvent> events) => events.forEach(_messageBus.fire);

  /** Load aggregate by its id */ 
  Future<T> load(Guid id) {
    var completer = new Completer<T>();
    _store.openStream(id).then((stream) {
      var events = stream.committedEvents;
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
  final MessageBus _messageBus;
}
