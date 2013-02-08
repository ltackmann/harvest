// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store_example;

class InventoryItem extends AggregateRoot {
  InventoryItem(Uuid itemId, String name) {
    applyChange(new InventoryItemCreated(itemId, name));
  }
  
  InventoryItem.fromId(Uuid itemId) {
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
    Expect.isNotNull(newName);
    Expect.isFalse(newName.isEmpty);
    applyChange(new InventoryItemRenamed(id, newName));
  }

  remove(int count) {
    Expect.isTrue(count > 0);
    applyChange(new ItemsRemovedFromInventory(id, count));
  }

  checkIn(int count) {
    Expect.isTrue(count > 0);
    applyChange(new ItemsCheckedInToInventory(id, count));
  }

  deactivate() {
    Expect.isTrue(_activated);
    applyChange(new InventoryItemDeactivated(id));
  }
  
  bool _activated;
  String _name;
}
