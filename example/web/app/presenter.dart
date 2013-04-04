// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_example;

class InventoryPresenter {
  InventoryPresenter(this._messageBus, this._view, this._viewModelFacade) {
    _view.presenter = this;
    // show events fired
    _messageBus.everyMessage.listen((Message message) {
      var messageType = (message is Command) ? "Command" : "Event";
      var messageName = message.runtimeType.toString();
      _view.recordMessage(messageType, messageName, new DateTime.now());
    });
  }
  
  go() => showItems();

  Future createItem(String name) {
    var cmd = new CreateItem(new Guid(), name);
    return cmd.onSuccess(showItems).executeOn(_messageBus);
  }
  
  Future decreaseInventory(Guid itemId, int numberOfItems, int version) {
    var cmd = new DecreaseInventory(itemId, numberOfItems, version);
    return cmd.onSuccess(() => showItemDetails(itemId)).executeOn(_messageBus);
  }
  
  Future increaseInventory(Guid itemId, int numberOfItems, int version) {
    var cmd = new IncreaseInventory(itemId, numberOfItems, version);
    return cmd.onSuccess(() => showItemDetails(itemId)).executeOn(_messageBus);
  }
  
  Future removeItem(Guid itemId, int version) {
    assert(itemId is Guid);
    var cmd = new RemoveItem(itemId, version);
    return cmd.onSuccess(showItems).executeOn(_messageBus);
  }

  Future renameItem(Guid itemId, String name, int version) {
    var cmd = new RenameItem(itemId, name, version);
    return cmd.onSuccess(() => showItemDetails(itemId)).executeOn(_messageBus);
  }
  
  showItems() {
    var inventoryItems = _viewModelFacade.getItems();
    _view.showItems(inventoryItems);
  }

  showItemDetails(Guid itemId) {
    var details = _viewModelFacade.getItemDetails(itemId);
    _view.showDetails(details);
  }
 
  final MessageBus _messageBus;
  final ViewModelFacade _viewModelFacade;
  final InventoryView _view;
  static final _logger = LoggerFactory.getLoggerFor(InventoryPresenter);
}

abstract class InventoryView {
  set presenter(InventoryPresenter p);
  
  showItems(List<ItemEntry> itemEntries);
  
  showDetails(ItemDetails details);
  
  recordMessage(String messageType, String messageName, DateTime time);
}
