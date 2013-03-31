// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_example;

class InventoryCommandHandler {
  InventoryCommandHandler(this._messageBus, this._domainRepository) {
    _messageBus.on[CreateItem].add(_onCreateItem);
    _messageBus.on[DecreaseInventory].add(_onDecreaseInventory);
    _messageBus.on[IncreaseInventory].add(_onIncreaseInventory);
    _messageBus.on[RemoveItem].add(_onRemoveItem);
    _messageBus.on[RenameItem].add(_onRenameItem);
  }
 
  _onCreateItem(CreateItem command) {
    var item = new Item(command.itemId, command.name);
    _domainRepository.save(item).then((v) => command.completeSuccess());
  }
  
  _onDecreaseInventory(DecreaseInventory command) {
    _domainRepository.load(command.itemId).then((Item item) {
      item.decreaseInventory(command.count);
      _domainRepository.save(item, command.originalVersion).then((v) => command.completeSuccess());
    });
  }
  
  _onIncreaseInventory(IncreaseInventory command) {
    _domainRepository.load(command.itemId).then((Item item) {
      item.increaseInventory(command.count);
      _domainRepository.save(item, command.originalVersion).then((v) => command.completeSuccess());
    });
  }
  
  _onRemoveItem(RemoveItem command) {
    _domainRepository.load(command.itemId).then((Item item) {
      item.remove();
      _domainRepository.save(item, command.originalVersion).then((v) => command.completeSuccess());
    });
  }
  
  _onRenameItem(RenameItem command) {
    _domainRepository.load(command.itemId).then((Item item) {
      item.name = command.newName;
      _domainRepository.save(item, command.originalVersion).then((v) => command.completeSuccess());
    });
  }
  
  final DomainRepository<Item> _domainRepository;
  final MessageBus _messageBus;
}
