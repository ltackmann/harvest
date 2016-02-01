// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/** Repository that stores and retrieves domain objects (aggregates) by their events. */
class DomainRepository<T extends AggregateRoot>  {
  static final Logger _logger = LoggerFactory.getLoggerFor(DomainRepository);
  final AggregateBuilder _builder;
  final EventStore _store;
  final MessageBus _messageBus;

  /**
   * Create a [DomainRepository] that uses [_builder] to construct new aggregate roots
   * and stores the events using [_store] as [EventStore]
   */
  DomainRepository(this._builder, this._store, this._messageBus);

  /**
   * Emit [messages] on message bus, returns **true** if all messages sucessfully handled,
   * otherwise **false**
   */
  Future<bool> emitMessages(Iterable<Message> messages) async {
    var failures = [];
    for(Message message in messages) {
      await _messageBus.publish(message);
      var messageFailure = message.headers["messageFailures"] as List;
      if(messageFailure.isNotEmpty) {
        failures.addAll(messageFailure);
        _logger.error("failed publishing aggregate message $message with failure ${messageFailure}");
      }
    }
    return failures.isEmpty;
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

  /**
    * Save [aggregate] and emit saved changes. Returns **true** if aggregate messages was
    * saved and emitted to listeners successfullly otherwise **false**.
    */
   Future<bool> save(AggregateRoot aggregate, [int expectedVersion = -1]) async {
     var savedMessages = await saveAggregate(aggregate, expectedVersion);
     if(savedMessages.isNotEmpty) {
       return emitMessages(savedMessages);
     }
     // no messages saved, so complete with successful status
     return true;
   }

   /**
    * Save [aggregate], returns list of messages saved
    */
   Future<List<Message>> saveAggregate(AggregateRoot aggregate, int expectedVersion) async {
     if(aggregate.uncommitedChanges.isEmpty) {
       return [];
      } else {
       var stream = await _store.openStream(aggregate.id);
       var changes = new List.from(aggregate.uncommitedChanges);
       _logger.debug("saving aggregate ${aggregate.id} with ${changes.length} new events");
       stream.addAll(changes);
       var savedChanges = await stream.commitChanges();
       if(savedChanges != changes.length) {
         throw new ConcurrencyError("attempted to commit ${changes.length} but only $savedChanges was saved" );
       }
       // clear aggregate changes after save
       aggregate.uncommitedChanges.clear();
       return changes;
     }
   }

   /**
    * Save [aggregate] and emit saved changes. If successfullly invoke sucess handler on
    * [callback] otherwise invoke error handler on [callback]. In effect a shorthand for
    *
    * ```
    *   try {
    *     domainRepository.save(aggregate);
    *     callback.messageSucceeded();
    *   } catch(e) {
    *     callback.messageFailed(e);
    *   }
    * ```
    */
   saveAndCallback(AggregateRoot aggregate, StatusCallback callback, [int expectedVersion = -1]) async {
     var saved = true;
     var callbackData = null;
     try {
       saved = await save(aggregate);
     } catch(e) {
       saved = false;
       callbackData = e;
     }
     if(saved) {
       callback.succeeded(callbackData);
     } else {
       callback.failed(callbackData);
     }
   }
}
