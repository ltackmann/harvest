// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_sample;

class InventoryPresenter {
  final MessageBus _messageBus;
  final ViewModelFacade _viewModelFacade;
  final InventoryView _view;
  
  InventoryPresenter(this._messageBus, this._view, this._viewModelFacade) {
    _view.presenter = this;
    // show every event fired
    _messageBus.everyMessage.listen((Message message) {
      var messageType = (message is DomainCommand) ? "Command" : "Event";
      var messageName = message.runtimeType.toString();
      _view.recordMessage(messageType, messageName, new DateTime.now());
    });
  }
  
  go() => showItems();

  Future createItem(String name) {
    var cmd = new CreateItem(new Guid(), name);
    return _messageBus.publish(cmd).whenComplete(showItems);
  }
  
  Future decreaseInventory(Guid itemId, int numberOfItems, int version) {
    var cmd = new DecreaseInventory(itemId, numberOfItems, version);
    return _messageBus.publish(cmd).whenComplete(() => showItemDetails(itemId));
  }
  
  Future increaseInventory(Guid itemId, int numberOfItems, int version) {
    var cmd = new IncreaseInventory(itemId, numberOfItems, version);
    return _messageBus.publish(cmd).whenComplete(() => showItemDetails(itemId));
  }
  
  Future removeItem(Guid itemId, int version) {
    var cmd = new RemoveItem(itemId, version);
    return _messageBus.publish(cmd).whenComplete(showItems);
  }

  Future renameItem(Guid itemId, String name, int version) {
    var cmd = new RenameItem(itemId, name, version);
    return _messageBus.publish(cmd).whenComplete(() => showItemDetails(itemId));
  }
  
  showItems() {
    var inventoryItems = _viewModelFacade.getItems();
    _view.showItems(inventoryItems);
  }

  showItemDetails(Guid itemId) {
    var details = _viewModelFacade.getItemDetails(itemId);
    _view.showDetails(details);
  }
}

abstract class InventoryView {
  set presenter(InventoryPresenter p);
  
  showItems(List<ItemEntry> itemEntries);
  
  showDetails(ItemDetails details);
  
  recordMessage(String messageType, String messageName, DateTime time);
}
