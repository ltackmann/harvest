// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store_example;

class DeactivateInventoryItem extends Command {
  static final TYPE = "DeactivateInventoryItem";
  
  DeactivateInventoryItem(this.inventoryItemId, this.originalVersion): super(TYPE); 
  
  final Uuid inventoryItemId;
  final int originalVersion;
}

class CreateInventoryItem extends Command {
  static final TYPE = "CreateInventoryItem";
  
  CreateInventoryItem(this.inventoryItemId, this.name): super(TYPE); 
  
  final Uuid inventoryItemId;
  final String name;
}
	
class RenameInventoryItem extends Command {
  static final TYPE = "RenameInventoryItem";
  
  RenameInventoryItem(this.inventoryItemId, this.newName, this.originalVersion): super(TYPE); 
  
  final Uuid inventoryItemId;
  final String newName;
  final int originalVersion;
}

class CheckInItemsToInventory extends Command {
  static final TYPE = "CheckInItemsToInventory";
  
	CheckInItemsToInventory(this.inventoryItemId, this.count, this.originalVersion): super(TYPE); 

	final Uuid inventoryItemId;
	final int count;
	final int originalVersion;
}
	
class RemoveItemsFromInventory extends Command {
  static final TYPE = "RemoveItemsFromInventory";

  RemoveItemsFromInventory(this.inventoryItemId, this.count, this.originalVersion): super(TYPE); 
  
  final Uuid inventoryItemId;
  final int count;
  final int originalVersion;
}
