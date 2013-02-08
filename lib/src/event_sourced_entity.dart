// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store;

/**
 * Entities that are part of a aggregate but not the root can still be event sourced by 
 * extending this class. Note that when events are replayed the root will recieve them 
 * first.
 */
abstract class EventSourcedEntity {
  EventSourcedEntity(AggregateRoot root) {
    root.addEventSourcedEntity(this);
  }
  
  /**
   * Implemented in each concrete entity, responsible for extracting data from events and applying it itself
   */
  apply(DomainEvent event);
  
  ChangeHandler applyChange;
}

typedef ChangeHandler(DomainEvent event); 
