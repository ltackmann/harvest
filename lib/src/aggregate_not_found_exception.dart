// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class AggregateNotFoundException implements Exception {
  const AggregateNotFoundException(this.aggregateId);
  
  String toString() => "No aggregate for id: $aggregateId";
  
  final Guid aggregateId;
}
