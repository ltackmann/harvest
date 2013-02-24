// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of harvest_example;

class InventoryItem extends AggregateRoot {
  InventoryItem(Guid itemId, String name) {
    applyChange(new InventoryItemCreated(itemId, name));
  }
  
  InventoryItem.fromId(Guid itemId) {
   id = itemId;
  }

  apply(var event) {
    if(event is InventoryItemCreated) {
      id = event.id;
      _name = event.name;
      _activated = true;
    } else if(event is InventoryItemDeactivated) {
      _activated = false;
    }
  }

  set name(String newName) {
    assert(newName != null && newName.isEmpty == false);
    applyChange(new InventoryItemRenamed(id, newName));
  }

  remove(int count) {
    assert(count > 0);
    applyChange(new ItemsRemovedFromInventory(id, count));
  }

  checkIn(int count) {
    assert(count > 0);
    applyChange(new ItemsCheckedInToInventory(id, count));
  }

  deactivate() {
    assert(_activated);
    applyChange(new InventoryItemDeactivated(id));
  }
  
  bool _activated;
  String _name;
}
