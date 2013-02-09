// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store_example;

class InventoryItemDeactivated extends DomainEvent {
  static final TYPE = "InventoryItemDeactivated";

  InventoryItemDeactivated.init();
  
  InventoryItemDeactivated(this.id);
  
  Uuid id;
}

class InventoryItemCreated extends DomainEvent {
  static final TYPE = "InventoryItemCreated";
  
  InventoryItemCreated.init();
  
  InventoryItemCreated(this.id, this.name); 
  
  Uuid id;
  String name;
}

class InventoryItemRenamed extends DomainEvent {
  static final TYPE = "InventoryItemRenamed";
 
  InventoryItemRenamed.init();
  
  InventoryItemRenamed(this.id, this.newName);
  
  Uuid id;
  String newName;
}

class ItemsCheckedInToInventory extends DomainEvent {
  static final TYPE = "ItemsCheckedInToInventory";

  ItemsCheckedInToInventory.init(); 
  
  ItemsCheckedInToInventory(this.id, this.count);
  
  Uuid id;
  int count;
}

class ItemsRemovedFromInventory extends DomainEvent {
  static final TYPE = "ItemsRemovedFromInventory";
  
  ItemsRemovedFromInventory.init(); 
  
  ItemsRemovedFromInventory(this.id, this.count);  
  
  Uuid id;
  int count;
}
