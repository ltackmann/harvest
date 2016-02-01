// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest_sample;

class CreateItem extends DomainCommand with CallbackCompleted {
  final Guid itemId;
  final String name;

  CreateItem(this.itemId, this.name);
}

class DecreaseInventory extends DomainCommand with CallbackCompleted {
  final Guid itemId;
  final int count, originalVersion;

  DecreaseInventory(this.itemId, this.count, this.originalVersion);
}

class IncreaseInventory extends DomainCommand with CallbackCompleted {
  final Guid itemId;
  final int count, originalVersion;

  IncreaseInventory(this.itemId, this.count, this.originalVersion);
}

class RenameItem extends DomainCommand with CallbackCompleted {
  final Guid itemId;
  final String newName;
  final int originalVersion;

  RenameItem(this.itemId, this.newName, this.originalVersion);
}

class RemoveItem extends DomainCommand with CallbackCompleted{
  final Guid itemId;
  final int originalVersion;

  RemoveItem(this.itemId, this.originalVersion);
}
