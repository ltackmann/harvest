// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of harvest_example;

class InventoryCommandHandler {
  InventoryCommandHandler(this._messageBus, this._domainRepository) {
    _messageBus.on[CreateInventoryItem].add(_onCreateInventoryItem);
    _messageBus.on[DeactivateInventoryItem].add(_onDeactivateInventoryItem);
    _messageBus.on[RemoveItemsFromInventory].add(_onRemoveItemsFromInventory);
    _messageBus.on[CheckInItemsToInventory].add(_onCheckInItemsToInventory);
    _messageBus.on[RenameInventoryItem].add(_onRenameInventoryItem);
  }
 
  _onCreateInventoryItem(CreateInventoryItem command) {
    var item = new InventoryItem(command.inventoryItemId, command.name);
    _domainRepository.save(item).then((v) => command.completeSuccess());
  }

  _onDeactivateInventoryItem(DeactivateInventoryItem command) {
    _domainRepository.load(command.inventoryItemId).then((InventoryItem item) {
      item.deactivate();
      _domainRepository.save(item, command.originalVersion).then((v) => command.completeSuccess());
    });
  }
  
  _onRemoveItemsFromInventory(RemoveItemsFromInventory command) {
    _domainRepository.load(command.inventoryItemId).then((InventoryItem item) {
      item.remove(command.count);
      _domainRepository.save(item, command.originalVersion).then((v) => command.completeSuccess());
    });
  }
  
  _onCheckInItemsToInventory(CheckInItemsToInventory command) {
    _domainRepository.load(command.inventoryItemId).then((InventoryItem item) {
      item.checkIn(command.count);
      _domainRepository.save(item, command.originalVersion).then((v) => command.completeSuccess());
    });
  }
  
  _onRenameInventoryItem(RenameInventoryItem command) {
    _domainRepository.load(command.inventoryItemId).then((InventoryItem item) {
      item.name = command.newName;
      _domainRepository.save(item, command.originalVersion).then((v) => command.completeSuccess());
    });
  }
  
  final DomainRepository<InventoryItem> _domainRepository;
  final MessageBus _messageBus;
}
