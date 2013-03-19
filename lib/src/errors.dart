// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/**
 * Represents an attempt to retrieve a nonexistent aggregate 
 */
class AggregateNotFoundError implements Error {
  const AggregateNotFoundError(this.aggregateId);
  
  String toString() => "No aggregate for id: $aggregateId";
  
  final Guid aggregateId;
}

/**
 * Represents an optimistic concurrency conflict between multiple writers.
 */
class ConcurrencyError implements Exception {
  ConcurrencyError(this.message);

  String toString() => message;
  
  final String message;
}
