// Copyright (c) 2012 Solvr, Inc. all rights reserved.  
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class InventoryItemDeactivated extends DomainEvent {
  static final String TYPE = "InventoryItemDeactivated";
  final Guid id;

  InventoryItemDeactivated(this.id): super(TYPE);
}

class InventoryItemCreated extends DomainEvent {
  static final String TYPE = "InventoryItemCreated";
  final Guid id;
  final String name;
  
  InventoryItemCreated(this.id, this.name): super(TYPE); 
}

class InventoryItemRenamed extends DomainEvent {
  static final String TYPE = "InventoryItemRenamed";
  final Guid id;
  final String newName;
  
  InventoryItemRenamed(this.id, this.newName): super(TYPE);
}

class ItemsCheckedInToInventory extends DomainEvent {
  static final String TYPE = "ItemsCheckedInToInventory";
  final Guid id;
  final int count;

  ItemsCheckedInToInventory(this.id, this.count): super(TYPE);
}

class ItemsRemovedFromInventory extends DomainEvent {
  static final String TYPE = "ItemsRemovedFromInventory";
  final Guid id;
  final int count;

  ItemsRemovedFromInventory(this.id, this.count): super(TYPE); 
}
