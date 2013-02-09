// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store_example;

class DeactivateInventoryItem extends Command {
  DeactivateInventoryItem(this.inventoryItemId, this.originalVersion); 
  
  final Guid inventoryItemId;
  final int originalVersion;
}

class CreateInventoryItem extends Command {
  CreateInventoryItem(this.inventoryItemId, this.name); 
  
  final Guid inventoryItemId;
  final String name;
}
	
class RenameInventoryItem extends Command {
  RenameInventoryItem(this.inventoryItemId, this.newName, this.originalVersion); 
  
  final Guid inventoryItemId;
  final String newName;
  final int originalVersion;
}

class CheckInItemsToInventory extends Command {
	CheckInItemsToInventory(this.inventoryItemId, this.count, this.originalVersion); 

	final Guid inventoryItemId;
	final int count;
	final int originalVersion;
}
	
class RemoveItemsFromInventory extends Command {
  RemoveItemsFromInventory(this.inventoryItemId, this.count, this.originalVersion); 
  
  final Guid inventoryItemId;
  final int count;
  final int originalVersion;
}
