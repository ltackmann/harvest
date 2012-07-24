// Copyright (c) 2012 Solvr, Inc. all rights reserved.  
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class AggregateNotFoundException implements Exception {
  final Guid aggregateId;
  
  const AggregateNotFoundException(this.aggregateId);
  
  String toString() => "No aggregate for id: $aggregateId";
}