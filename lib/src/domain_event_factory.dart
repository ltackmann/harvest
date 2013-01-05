// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Factory for building [DomainEvent]'s from type names
 * 
 * TODO remove when mirrors support emit
 */ 
class DomainEventFactory {
  DomainEventFactory(): builder = new Map<String, DomainEventBuilder>();
  
  DomainEvent build(String type) => builder[type]();

  final Map<String, DomainEventBuilder> builder;
}
