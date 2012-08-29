// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class InventoryCommandHandler {
  InventoryCommandHandler(this._messageBus, this._domainRepository) {
    _messageBus.on[CreateInventoryItem.TYPE].add(_onCreateInventoryItem);
    _messageBus.on[DeactivateInventoryItem.TYPE].add(_onDeactivateInventoryItem);
    _messageBus.on[RemoveItemsFromInventory.TYPE].add(_onRemoveItemsFromInventory);
    _messageBus.on[CheckInItemsToInventory.TYPE].add(_onCheckInItemsToInventory);
    _messageBus.on[RenameInventoryItem.TYPE].add(_onRenameInventoryItem);
  }
 
  _onCreateInventoryItem(CreateInventoryItem message) {
    var item = new InventoryItem(message.inventoryItemId, message.name);
    _domainRepository.save(item);
  }

  _onDeactivateInventoryItem(DeactivateInventoryItem message) {
    _domainRepository.load(message.inventoryItemId).then((InventoryItem item) {
      item.deactivate();
      _domainRepository.save(item, message.originalVersion);
    });
  }
  
  _onRemoveItemsFromInventory(RemoveItemsFromInventory message) {
    _domainRepository.load(message.inventoryItemId).then((InventoryItem item) {
      item.remove(message.count);
      _domainRepository.save(item, message.originalVersion);
    });
  }
  
  _onCheckInItemsToInventory(CheckInItemsToInventory message) {
    _domainRepository.load(message.inventoryItemId).then((InventoryItem item) {
      item.checkIn(message.count);
      _domainRepository.save(item, message.originalVersion);
    });
  }
  
  _onRenameInventoryItem(RenameInventoryItem message) {
    _domainRepository.load(message.inventoryItemId).then((InventoryItem item) {
      item.name = message.newName;
      _domainRepository.save(item, message.originalVersion);
    });
  }
  
  final DomainRepository<InventoryItem> _domainRepository;
  final MessageBus _messageBus;
}
