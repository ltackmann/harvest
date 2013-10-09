// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
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
    if(aggregate.uncommitedChanges.isEmpty) {
      completer.complete(false);
    } else {
      _store.openStream(aggregate.id).then((stream) {
        var changes = new List.from(aggregate.uncommitedChanges);
        _logger.debug("saving aggregate ${aggregate.id} with ${changes.length} new events");
        stream.addAll(changes);      
        stream.commitChanges().then((_) {
          // clear aggregate prior to broadcast to avoid duplicate events
          aggregate.uncommitedChanges.clear();
          changes.forEach(_messageBus.fire);
          completer.complete(true);
        });
      });
    }
    return completer.future;
  }
  
  /** Load domain object for [id] */ 
  Future<T> load(Guid id) {
    var completer = new Completer<T>();
    _store.openStream(id).then((stream) {
      var obj = _builder(id);
      _logger.debug("loading aggregate ${id} from ${stream.committedEvents.length} total events");
      obj.loadFromHistory(stream);
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
