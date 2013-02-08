// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store_example;

class InventoryItemDeactivated extends DomainEvent {
  static final TYPE = "InventoryItemDeactivated";

  InventoryItemDeactivated.init(): super(TYPE);
  
  InventoryItemDeactivated(this.id): super(TYPE);
  
  Uuid id;
}

class InventoryItemCreated extends DomainEvent {
  static final TYPE = "InventoryItemCreated";
  
  InventoryItemCreated.init(): super(TYPE);
  
  InventoryItemCreated(this.id, this.name): super(TYPE); 
  
  Uuid id;
  String name;
}

class InventoryItemRenamed extends DomainEvent {
  static final TYPE = "InventoryItemRenamed";
 
  InventoryItemRenamed.init(): super(TYPE);
  
  InventoryItemRenamed(this.id, this.newName): super(TYPE);
  
  Uuid id;
  String newName;
}

class ItemsCheckedInToInventory extends DomainEvent {
  static final TYPE = "ItemsCheckedInToInventory";

  ItemsCheckedInToInventory.init(): super(TYPE); 
  
  ItemsCheckedInToInventory(this.id, this.count): super(TYPE);
  
  Uuid id;
  int count;
}

class ItemsRemovedFromInventory extends DomainEvent {
  static final TYPE = "ItemsRemovedFromInventory";
  
  ItemsRemovedFromInventory.init(): super(TYPE); 
  
  ItemsRemovedFromInventory(this.id, this.count): super(TYPE);  
  
  Uuid id;
  int count;
}
