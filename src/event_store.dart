// Copyright (c) 2012 Solvr, Inc. all rights reserved.  
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Interface implemented by event stores
 */ 
interface EventStore {
  void saveEvents(Guid aggregateId, List<DomainEvent> events, int expectedVersion);
  
  List<DomainEvent> getEventsForAggregate(Guid aggregateId);
}