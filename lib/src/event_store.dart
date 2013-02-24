// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of harvest;

/**
 * Interface implemented by event stores
 */ 
abstract class EventStore {
  /**
   * Saves events for aggregate, returns number of events saved
   */  
  Future<int> saveEvents(Guid aggregateId, List<DomainEvent> events, int expectedVersion);
  
  /**
   * Get events for aggregate
   */ 
  Future<Iterable<DomainEvent>> getEventsForAggregate(Guid aggregateId);
}
