// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Repository for working with domain objects
 */
interface DomainRepository<T> {
  save(AggregateRoot aggregate, [int expectedVersion]);
  
  T load(Guid id);
}

/**
 * A domain builder is a function that returns a bare aggregate root for the supplied id 
 */ 
typedef AggregateRoot DomainBuilder(Guid aggregateId);