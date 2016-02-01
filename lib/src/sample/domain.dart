// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest_sample;

class Item extends AggregateRoot {
  bool _activated;
  String _name;

  factory Item.create(String name, Guid id) {
    var item = new Item(id);
    item.applyChange(new ItemCreated(item.id, name));
    return item;
  }

  Item(Guid itemId): super(itemId);

  apply(var event) {
    if(event is ItemCreated) {
      _name = event.name;
      _activated = true;
    } else if(event is ItemRemoved) {
      _activated = false;
    }
  }

  set name(String newName) {
    assert(newName != null && newName.isEmpty == false);
    if(newName != _name) {
      applyChange(new ItemRenamed(id, newName));
    }
  }

  decreaseInventory(int count) {
    assert(count > 0);
    applyChange(new InventoryDecreased(id, count));
  }

  increaseInventory(int count) {
    applyChange(new InventoryIncreased(id, count));
  }

  remove() {
    assert(_activated);
    applyChange(new ItemRemoved(id));
  }
}
