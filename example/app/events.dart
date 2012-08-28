// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class InventoryItemDeactivated extends DomainEvent {
  static final TYPE = "InventoryItemDeactivated";

  InventoryItemDeactivated(this.id): super(TYPE);
  
  final Guid id;
}

class InventoryItemCreated extends DomainEvent {
  static final TYPE = "InventoryItemCreated";
  
  InventoryItemCreated(this.id, this.name): super(TYPE); 
  
  final Guid id;
  final String name;
}

class InventoryItemRenamed extends DomainEvent {
  static final TYPE = "InventoryItemRenamed";
 
  InventoryItemRenamed(this.id, this.newName): super(TYPE);
  
  final Guid id;
  final String newName;
}

class ItemsCheckedInToInventory extends DomainEvent {
  static final TYPE = "ItemsCheckedInToInventory";

  ItemsCheckedInToInventory(this.id, this.count): super(TYPE);
  
  final Guid id;
  final int count;
}

class ItemsRemovedFromInventory extends DomainEvent {
  static final TYPE = "ItemsRemovedFromInventory";
  
  ItemsRemovedFromInventory(this.id, this.count): super(TYPE); 
  
  final Guid id;
  final int count;
}
