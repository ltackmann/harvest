// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/** The root of an object tree (aggregate) */
abstract class AggregateRoot {
  AggregateRoot(this.id);

  /** Populate this aggregte root from historic events */
  loadFromHistory(EventStream eventStream) {
    if(eventStream.id != id) {
      throw new StateError('stream with id ${eventStream.id} does not match $this');
    }
    eventStream.committedEvents.forEach((DomainEvent e) {
      _logger.debug("loading historic event ${e.runtimeType} for aggregate ${id}");
      _applyChange(e, false);
    });
  }

  _applyChange(DomainEvent event, bool isNew) {
    this.apply(event);
    _entities.forEach((EventSourcedEntity entity) => entity.apply(event));
    if(isNew) {
      _logger.debug("applying change ${event.runtimeType} for ${id}");
      uncommitedChanges.add(event);
    }
  }

  /** Implemented in each concrete aggregate, responsible for extracting data from events and applying it itself */
  apply(DomainEvent event);

  /** Apply a new event to this aggregate */
  applyChange(DomainEvent event) => _applyChange(event, true);

  /**
   * Add a non-root entity to participate in the event sourcing of this aggregate.
   * This entity will recieve all the events the root recieves and will store its
   * event in the root.
   */
  addEventSourcedEntity(EventSourcedEntity entity) {
    _entities.add(entity);
    entity.applyChange = this.applyChange;
  }

  operator ==(AggregateRoot other) => (other.id == id);

  String toString() => "aggregate $id";

  /// id
  final Guid id;

  /// the events applied to this entity
  final uncommitedChanges = new List<DomainEvent>();

  final _entities = new List<EventSourcedEntity>();
  static final _logger = LoggerFactory.getLoggerFor(AggregateRoot);
}

/** Function that returns a bare aggregate root for the supplied [aggregateId] */
typedef AggregateRoot AggregateBuilder(Guid aggregateId);

/**
 * Event sourced entity that is part of a aggregate (but not the root)
 *
 * Note that when events are replayed the root will recieve them first.
 */
abstract class EventSourcedEntity {
  EventSourcedEntity(AggregateRoot root) {
    root.addEventSourcedEntity(this);
  }

  /** Extracting data from event and apply it to the entity itself */
  apply(DomainEvent event);

  ChangeHandler applyChange;
}

typedef ChangeHandler(DomainEvent event);
