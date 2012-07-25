// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class DeactivateInventoryItem extends Command {
  static final String TYPE = "DeactivateInventoryItem";
  final Guid inventoryItemId;
	final int originalVersion;

  DeactivateInventoryItem(this.inventoryItemId, this.originalVersion): super(TYPE); 
}

class CreateInventoryItem extends Command {
  static final String TYPE = "CreateInventoryItem";
	final Guid inventoryItemId;
	final String name;
	
  CreateInventoryItem(this.inventoryItemId, this.name): super(TYPE); 
}
	
class RenameInventoryItem extends Command {
  static final String TYPE = "RenameInventoryItem";
	final Guid inventoryItemId;
	final String newName;
	final int originalVersion;

  RenameInventoryItem(this.inventoryItemId, this.newName, this.originalVersion): super(TYPE); 
}

class CheckInItemsToInventory extends Command {
  static final String TYPE = "CheckInItemsToInventory";
  final Guid inventoryItemId;
	final int count;
	final int originalVersion;

	CheckInItemsToInventory(this.inventoryItemId, this.count, this.originalVersion): super(TYPE); 
}
	
class RemoveItemsFromInventory extends Command {
  static final String TYPE = "RemoveItemsFromInventory";
  final Guid inventoryItemId;
  final int count;
	final int originalVersion;

  RemoveItemsFromInventory(this.inventoryItemId, this.count, this.originalVersion): super(TYPE); 
}
