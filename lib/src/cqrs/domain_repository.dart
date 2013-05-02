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
    if(!aggregate.uncommitedChanges.isEmpty) {
      _store.openStreamAsync(aggregate.id).then((stream) {
        _logger.debug("saving aggregate ${aggregate.id} with ${aggregate.uncommitedChanges.length} new events");
        stream.addAll(aggregate.uncommitedChanges);      
        stream.commitChanges(commitListener:_messageBus.fire);
        aggregate.uncommitedChanges.clear();
        completer.complete(true);
      });
    } else {
      completer.complete(false);
    }
    return completer.future;
  }
  
  /** Load domain object for [id] */ 
  Future<T> load(Guid id) {
    var completer = new Completer<T>();
    _store.openStreamAsync(id).then((stream) {
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
