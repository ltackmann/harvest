// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class InventoryEventHandler {
  InventoryEventHandler(this._messageBus, this._itemListRepository, this._itemDetailsRepository) {
    _messageBus.on[InventoryItemCreated.TYPE].add(_onInventoryItemCreated);
    _messageBus.on[InventoryItemRenamed.TYPE].add(_onInventoryItemRenamed);
    _messageBus.on[ItemsRemovedFromInventory.TYPE].add(_onItemsRemovedFromInventory);
    _messageBus.on[ItemsCheckedInToInventory.TYPE].add(_onItemsCheckedInToInventory);
    _messageBus.on[InventoryItemDeactivated.TYPE].add(_onInventoryItemDeactivated);
  }
  
  _onInventoryItemCreated(InventoryItemCreated message) {
    _itemDetailsRepository.save(new InventoryItemDetails(message.id, message.name, 0, 0));
    _itemListRepository.save(new InventoryItemListEntry(message.id, message.name));
  }

  _onInventoryItemRenamed(InventoryItemRenamed message) {
    InventoryItemDetails details = _itemDetailsRepository.getById(message.id);
    details.name = message.newName;
    details.version = message.version;
    _itemDetailsRepository.save(details);
  
    InventoryItemListEntry entry = _itemListRepository.getById(message.id);
    entry.name = message.newName;
    _itemListRepository.save(entry);
  }

  _onItemsRemovedFromInventory(ItemsRemovedFromInventory message) {
    InventoryItemDetails details = _itemDetailsRepository.getById(message.id);
    details.currentCount -= message.count;
    details.version = message.version;
    _itemDetailsRepository.save(details);
  }

  _onItemsCheckedInToInventory(ItemsCheckedInToInventory message) {
    InventoryItemDetails details = _itemDetailsRepository.getById(message.id);
    details.currentCount += message.count;
    details.version = message.version;
    _itemDetailsRepository.save(details);
  }

  _onInventoryItemDeactivated(InventoryItemDeactivated message) {
    _itemDetailsRepository.removeById(message.id);
    _itemListRepository.removeById(message.id);
  }
  
  final MessageBus _messageBus;
  final ModelRepository<InventoryItemListEntry> _itemListRepository;
  final ModelRepository<InventoryItemDetails> _itemDetailsRepository;
}
