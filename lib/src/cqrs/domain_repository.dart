// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/** Repository that stores and retrieves domain objects (aggregates) by their events. */
class DomainRepository<T extends AggregateRoot>  {
  static final Logger _logger = LoggerFactory.getLoggerFor(DomainRepository);
  final AggregateBuilder _builder;
  final EventStore _store;
  final MessageBus _messageBus;
  
  DomainRepository(this._builder, this._store, this._messageBus);
  
  /** Save aggregate, return [true] when the aggregate had unsaved data otherwise [false]. */ 
  Future<bool> save(AggregateRoot aggregate, [int expectedVersion = -1]) async {
    if(aggregate.uncommitedChanges.isEmpty) {
      return false;
    } else {
      var stream = await _store.openStream(aggregate.id);
      var changes = new List.from(aggregate.uncommitedChanges);
      _logger.debug("saving aggregate ${aggregate.id} with ${changes.length} new events");
      stream.addAll(changes);      
      var res = await stream.commitChanges();
      if(res != changes.length) {
        throw new ConcurrencyError("attempted to commit ${changes.length} but only $res was saved" );
      }
      // clear aggregate prior to broadcast to avoid duplicate events
      aggregate.uncommitedChanges.clear();
      changes.forEach(_messageBus.publish);
      return true;
    }
  }
  
  /**
   * Load domain object for [id], returns null if no object exists
   */
  Future<T> load(Guid id) async {
    if(!_store.containsStream(id)) {
      return new Future.value(null);  
    }
    var stream = await _store.openStream(id);
    var obj = _builder(id);
    _logger.debug("loading aggregate ${id} from ${stream.committedEvents.length} total events");
    obj.loadFromHistory(stream);
    return obj;
  }
}
