// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store_example;

class InventoryItemDeactivated extends DomainEvent {
  InventoryItemDeactivated.init();
  
  InventoryItemDeactivated(this.id);
  
  Guid id;
}

class InventoryItemCreated extends DomainEvent {
  InventoryItemCreated.init();
  
  InventoryItemCreated(this.id, this.name); 
  
  Guid id;
  String name;
}

class InventoryItemRenamed extends DomainEvent {
  InventoryItemRenamed.init();
  
  InventoryItemRenamed(this.id, this.newName);
  
  Guid id;
  String newName;
}

class ItemsCheckedInToInventory extends DomainEvent {
  ItemsCheckedInToInventory.init(); 
  
  ItemsCheckedInToInventory(this.id, this.count);
  
  Guid id;
  int count;
}

class ItemsRemovedFromInventory extends DomainEvent {
  ItemsRemovedFromInventory.init(); 
  
  ItemsRemovedFromInventory(this.id, this.count);  
  
  Guid id;
  int count;
}
