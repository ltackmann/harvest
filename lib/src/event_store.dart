// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/** Interface implemented by event stores */ 
abstract class EventStore {
  /** Saves events for aggregate, returns number of events saved */  
  Future<int> saveEvents(Guid aggregateId, List<DomainEvent> events, int expectedVersion);
  
  /** Get events for aggregate */ 
  Future<Iterable<DomainEvent>> getEventsForAggregate(Guid aggregateId);
}
