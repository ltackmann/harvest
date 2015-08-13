// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_sample;

class InventoryCommandHandler {
  final DomainRepository<Item> _domainRepository;
  final MessageBus _messageBus;
  
  InventoryCommandHandler(this._messageBus, this._domainRepository) {
    _messageBus.stream(CreateItem).listen(_onCreateItem);
    _messageBus.stream(DecreaseInventory).listen(_onDecreaseInventory);
    _messageBus.stream(IncreaseInventory).listen(_onIncreaseInventory);
    _messageBus.stream(RemoveItem).listen(_onRemoveItem);
    _messageBus.stream(RenameItem).listen(_onRenameItem);
  }
 
  _onCreateItem(CreateItem command) {
    var item = new Item.create(command.name, command.itemId);
    _domainRepository.save(item).then(command.completed);
  }
  
  _onDecreaseInventory(DecreaseInventory command) async {
    var item = await _domainRepository.load(command.itemId);
    item.decreaseInventory(command.count);
    _domainRepository.save(item, command.originalVersion).then(command.completed);
  }
  
  _onIncreaseInventory(IncreaseInventory command) async {
    var item = await _domainRepository.load(command.itemId);
    item.increaseInventory(command.count);
    _domainRepository.save(item, command.originalVersion).then(command.completed);
  }
  
  _onRemoveItem(RemoveItem command) async {
    var item = await _domainRepository.load(command.itemId);
    item.remove();
    _domainRepository.save(item, command.originalVersion).then(command.completed);
  }
  
  _onRenameItem(RenameItem command) async {
    var item = await _domainRepository.load(command.itemId);
    item.name = command.newName;
    _domainRepository.save(item, command.originalVersion).then(command.completed);
  }
}
