// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store;

/**
 * Represents an attempt to retrieve a nonexistent aggregate 
 */
class AggregateNotFoundError implements Error {
  const AggregateNotFoundError(this.aggregateId);
  
  String toString() => "No aggregate for id: $aggregateId";
  
  final Uuid aggregateId;
}

/**
 * Represents an optimistic concurrency conflict between multiple writers.
 */
class ConcurrencyError implements Exception {
}