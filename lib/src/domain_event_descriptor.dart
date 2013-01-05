// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class DomainEventDescriptor {
  DomainEventDescriptor(this.id, this.eventData) {
    version = eventData.version;
  }
  
  DomainEvent eventData;
  Guid id;
  int version;
}
