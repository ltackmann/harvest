// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_example;

class CreateItem extends Command {
  CreateItem(this.itemId, this.name); 
  
  final Guid itemId;
  final String name;
}

class DecreaseInventory extends Command {
  DecreaseInventory(this.itemId, this.count, this.originalVersion); 
  
  final Guid itemId;
  final int count, originalVersion;
}
	
class IncreaseInventory extends Command {
  IncreaseInventory(this.itemId, this.count, this.originalVersion); 

	final Guid itemId;
	final int count, originalVersion;
}
	
class RenameItem extends Command {
  RenameItem(this.itemId, this.newName, this.originalVersion); 
  
  final Guid itemId;
  final String newName;
  final int originalVersion;
}

class RemoveItem extends Command {
  RemoveItem(this.itemId, this.originalVersion); 
  
  final Guid itemId;
  final int originalVersion;
}