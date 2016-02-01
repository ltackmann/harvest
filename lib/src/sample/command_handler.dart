// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest_sample;

class InventoryCommandHandler {
  final DomainRepository<Item> _domainRepository;
  final MessageBus _messageBus;
  // index used to ensure that items have unique names accross aggregates, in real life this would be a DB index
  final Map<String, Guid> _itemNameIndex = new Map<String, Guid>();

  InventoryCommandHandler(this._messageBus, this._domainRepository) {
    _messageBus.stream(CreateItem).listen(_onCreateItem, cancelOnError: true);
    _messageBus.stream(DecreaseInventory).listen(_onDecreaseInventory, cancelOnError: true);
    _messageBus.stream(IncreaseInventory).listen(_onIncreaseInventory, cancelOnError: true);
    _messageBus.stream(RemoveItem).listen(_onRemoveItem, cancelOnError: true);
    _messageBus.stream(RenameItem).listen(_onRenameItem, cancelOnError: true);
  }

  _onCreateItem(CreateItem command) async {
    try {
      _assertUniqueName(command.name, command.itemId);
      var item = new Item.create(command.name, command.itemId);
      _domainRepository.save(item).then((_) {
        // update index before callback has completed
        _itemNameIndex[command.name] = command.itemId;
        command.succeeded();
      }, onError: (e) => command.failed(e));
    } catch(e) {
      command.failed(e);
    }
  }

  _onDecreaseInventory(DecreaseInventory command) async {
    var item = await _domainRepository.load(command.itemId);
    item.decreaseInventory(command.count);
    await _domainRepository.saveAndCallback(item, command, command.originalVersion);
  }

  _onIncreaseInventory(IncreaseInventory command) async {
    var item = await _domainRepository.load(command.itemId);
    item.increaseInventory(command.count);
    await _domainRepository.saveAndCallback(item, command, command.originalVersion);
  }

  _onRemoveItem(RemoveItem command) async {
    var item = await _domainRepository.load(command.itemId);
    item.remove();
    await _domainRepository.saveAndCallback(item, command, command.originalVersion);
  }

  _onRenameItem(RenameItem command) async {
    try {
      // assert item is already in index before rename
      String orignalName;
      _itemNameIndex.forEach((k,v) {
        if(v == command.itemId) {
          orignalName = k;
          return;
        }
      });
      assert(orignalName != null);
      _assertUniqueName(command.newName, command.itemId);
      var item = await _domainRepository.load(command.itemId);
      item.name = command.newName;
      _domainRepository.save(item, command.originalVersion).then((_) {
        // update index before callback has completed
        _itemNameIndex[command.newName] = command.itemId;
        _itemNameIndex.remove(orignalName);
        command.succeeded();
      }, onError: (e) => command.failed(e));
    } catch(e) {
      command.failed(e);
    }
  }

  _assertUniqueName(String name, Guid id) {
    if(_itemNameIndex.containsKey(name) && _itemNameIndex[name] != id) {
      throw new ArgumentError("item with name ${name} already exists for item ${_itemNameIndex[name]}");
    }
  }
}
