// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_cqrs;

/** The root of an object tree (aggregate) */
abstract class AggregateRoot { 
  int get version => _version;
  
  Guid id;
  
  /**
   * Populate this aggregte root from historic events
   */
  loadFromHistory(Iterable<DomainEvent> history) {
    history.forEach((DomainEvent e) {
      _logger.debug("loading historic event ${e.runtimeType} for aggregate ${id}");
      _applyChange(e, false);
    });
  }
  
  _applyChange(DomainEvent event, bool isNew) {
    this.apply(event);
    _entities.forEach((EventSourcedEntity entity) => entity.apply(event)); 
    if(isNew) {
      _logger.debug("applying change ${event.runtimeType} for ${id}");
      _changes.add(event);
    }
  }
  
  /** Implemented in each concrete aggregate, responsible for extracting data from events and applying it itself */
  apply(DomainEvent event);

  /** Apply a new event to this aggregate */
  applyChange(DomainEvent event) => _applyChange(event, true);
  
  /** List of events applied to this aggregate that are not persisted in the event store */
  List<DomainEvent> get uncommittedChanges => _changes;
 
  bool get hasUncommittedChanges => _changes.length > 0;

    /**
   * Mark all events as persisted, usually called by event stores when events are saved
   */
  markChangesAsCommitted() => _changes.clear();
  
  /**
   * Add a non-root entity to participate in the event sourcing of this aggregate.
   * This entity will recieve all the events the root recieves and will store its
   * event in the root.
   */
  addEventSourcedEntity(EventSourcedEntity entity) {
    _entities.add(entity);
    entity.applyChange = this.applyChange;
  }
  
  operator ==(AggregateRoot other) => other.id == id; 
  
  String toString() => "aggregate $id";
  
  int _version;
  final _entities = new List<EventSourcedEntity>();
  final _changes = new List<DomainEvent>();
  static final _logger = LoggerFactory.getLoggerFor(AggregateRoot);
}

/** Function that returns a bare aggregate root for the supplied id */ 
typedef AggregateRoot AggregateBuilder(Guid aggregateId);

/** Represents an attempt to retrieve a nonexistent aggregate */
class AggregateNotFoundError implements Error {
  const AggregateNotFoundError(this.aggregateId);
  
  String toString() => "No aggregate for id: $aggregateId";
  
  final Guid aggregateId;
}

/**
 * Event sourced entity that is part of a aggregate (but not the root)
 * 
 * Note that when events are replayed the root will recieve them first.
 */
abstract class EventSourcedEntity {
  EventSourcedEntity(AggregateRoot root) {
    root.addEventSourcedEntity(this);
  }
  
  /**
   * Extracting data from event and apply it to the entity itself
   */
  apply(DomainEvent event);
  
  ChangeHandler applyChange;
}

typedef ChangeHandler(PersistentEvent event); 
