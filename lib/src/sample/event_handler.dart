// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest_sample;

class InventoryEventHandler {
  final MessageBus _messageBus;
  final ModelRepository<ItemEntry> _itemEntryRepository;
  final ModelRepository<ItemDetails> _itemDetailsRepository;

  InventoryEventHandler(this._messageBus, this._itemEntryRepository, this._itemDetailsRepository) {
    _messageBus.subscribe(ItemCreated, _onItemCreated);
    _messageBus.stream(ItemRenamed).listen(_onItemRenamed);
    _messageBus.stream(InventoryDecreased).listen(_onInventoryDecreased);
    _messageBus.stream(InventoryIncreased).listen(_onInventoryIncreased);
    _messageBus.stream(ItemRemoved).listen(_onItemRemoved);
  }

  _onItemCreated(ItemCreated message) {
    _itemDetailsRepository.save(new ItemDetails(message.id, message.name, 0, 0));
    _itemEntryRepository.save(new ItemEntry(message.id, message.name));
  }

  _onItemRenamed(ItemRenamed message) {
    ItemDetails details = _itemDetailsRepository.getById(message.id);
    details.name = message.newName;
    details.version = message.version;
    _itemDetailsRepository.save(details);

    ItemEntry entry = _itemEntryRepository.getById(message.id);
    entry.name = message.newName;
    _itemEntryRepository.save(entry);
  }

  _onInventoryDecreased(InventoryDecreased message) {
    ItemDetails details = _itemDetailsRepository.getById(message.id);
    int newItemCount = details.currentCount - message.count;
    _assertItemCount(newItemCount);
    details.currentCount = newItemCount;
    details.version = message.version;
    _itemDetailsRepository.save(details);
  }

  _onInventoryIncreased(InventoryIncreased message) {
    ItemDetails details = _itemDetailsRepository.getById(message.id);
    int newItemCount = details.currentCount + message.count;
    _assertItemCount(newItemCount);
    details.currentCount = newItemCount;
    details.version = message.version;
    _itemDetailsRepository.save(details);
  }

  _onItemRemoved(ItemRemoved message) {
    _itemDetailsRepository.removeById(message.id);
    _itemEntryRepository.removeById(message.id);
  }

  _assertItemCount(int itemCount) {
    if(itemCount < 0) {
      throw new ArgumentError("item count cannot be nagative");
    }
  }
}
