// Copyright (c) 2013-2015, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_example;

class CreateItem extends DomainCommand {
  CreateItem(this.itemId, this.name); 
  
  final Guid itemId;
  final String name;
}

class DecreaseInventory extends DomainCommand {
  DecreaseInventory(this.itemId, this.count, this.originalVersion); 
  
  final Guid itemId;
  final int count, originalVersion;
}
	
class IncreaseInventory extends DomainCommand {
  IncreaseInventory(this.itemId, this.count, this.originalVersion); 

	final Guid itemId;
	final int count, originalVersion;
}
	
class RenameItem extends DomainCommand {
  RenameItem(this.itemId, this.newName, this.originalVersion); 
  
  final Guid itemId;
  final String newName;
  final int originalVersion;
}

class RemoveItem extends DomainCommand {
  RemoveItem(this.itemId, this.originalVersion); 
  
  final Guid itemId;
  final int originalVersion;
}