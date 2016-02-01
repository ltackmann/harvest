// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest_sample;

class InventoryIncreased extends DomainEvent {
  InventoryIncreased(this.id, this.count);

  Guid id;
  int count;
}

class InventoryDecreased extends DomainEvent {
  InventoryDecreased(this.id, this.count);

  Guid id;
  int count;
}

class ItemCreated extends DomainEvent {
  ItemCreated(this.id, this.name);

  Guid id;
  String name;
}

class ItemRemoved extends DomainEvent {
  ItemRemoved(this.id);

  Guid id;
}

class ItemRenamed extends DomainEvent {
  ItemRenamed(this.id, this.newName);

  Guid id;
  String newName;
}
