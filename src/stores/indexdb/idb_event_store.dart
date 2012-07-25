// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * IndexDB backed event store
 */
class IDBEventStore implements EventStore {
  final IDBConnection _connection;
  final Logger _logger;
  
  // Chrome only for now, see bug http://code.google.com/p/chromium/issues/detail?id=108223
  // [String version = "1", String storeName = "event-store"]
  IDBEventStore(this._connection): _logger = LoggerFactory.getLogger("cqrs4dart.IDBEventStore") {
    
  }
  
  void saveEvents(Guid aggregateId, List<DomainEvent> events, int expectedVersion) {
    throw "TODO";
  }
  
  List<DomainEvent> getEventsForAggregate(Guid aggregateId) {
    throw "TODO";
  }
}



