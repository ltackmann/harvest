// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class DomainEventDescriptor {
  DomainEvent eventData;
  Guid id;
  int version;

  DomainEventDescriptor(this.id, this.eventData, this.version);
}
