// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_example;

class InventoryCommandHandler {
  InventoryCommandHandler(this._messageBus, this._domainRepository) {
    _messageBus.stream(CreateItem).listen(_onCreateItem);
    _messageBus.stream(DecreaseInventory).listen(_onDecreaseInventory);
    _messageBus.stream(IncreaseInventory).listen(_onIncreaseInventory);
    _messageBus.stream(RemoveItem).listen(_onRemoveItem);
    _messageBus.stream(RenameItem).listen(_onRenameItem);
  }
 
  _onCreateItem(CreateItem command) {
    var item = new Item.create(command.name);
    _domainRepository.save(item).then((_) => command.completeSuccess());
  }
  
  _onDecreaseInventory(DecreaseInventory command) {
    _domainRepository.load(command.itemId).then((Item item) {
      item.decreaseInventory(command.count);
      _domainRepository.save(item, command.originalVersion).then((_) => command.completeSuccess());
    });
  }
  
  _onIncreaseInventory(IncreaseInventory command) {
    _domainRepository.load(command.itemId).then((Item item) {
      item.increaseInventory(command.count);
      _domainRepository.save(item, command.originalVersion).then((_) => command.completeSuccess());
    });
  }
  
  _onRemoveItem(RemoveItem command) {
    _domainRepository.load(command.itemId).then((Item item) {
      item.remove();
      _domainRepository.save(item, command.originalVersion).then((_) => command.completeSuccess());
    });
  }
  
  _onRenameItem(RenameItem command) {
    _domainRepository.load(command.itemId).then((Item item) {
      item.name = command.newName;
      _domainRepository.save(item, command.originalVersion).then((_) => command.completeSuccess());
    });
  }
  
  final DomainRepository<Item> _domainRepository;
  final MessageBus _messageBus;
}
