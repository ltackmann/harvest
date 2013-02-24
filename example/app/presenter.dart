// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of harvest_example;

class InventoryPresenter {
  InventoryPresenter(this._messageBus, this._view, this._viewModelFacade)
    : _logger = LoggerFactory.getLoggerFor(InventoryPresenter) 
  {
    _view.presenter = this;
    // show the events fired
    _messageBus.onAny.add((Message message) {
      var messageType = (message is Command) ? "Command" : "Event";
      var messageName = message.runtimeType.toString();
      _view.recordMessage(messageType, messageName, new DateTime.now());
    });
  }
  
  go() => showItems();

  Future createItem(String name) {
    var cmd = new CreateInventoryItem(new Guid(), name);
    return cmd.onSuccess(showItems).fireAsync(_messageBus);
  }
  
  Future checkInItems(Guid id, int number, int version) {
    var cmd = new CheckInItemsToInventory(id, number, version);
    return cmd.onSuccess(() => showDetails(id)).fireAsync(_messageBus);
  }
  
  Future deactivateItem(Guid id, int version) {
    var cmd = new DeactivateInventoryItem(id, version);
    return cmd.onSuccess(showItems).fireAsync(_messageBus);
  }

  Future renameItem(Guid id, String name, int version) {
    var cmd = new RenameInventoryItem(id, name, version);
    return cmd.onSuccess(() => showDetails(id)).fireAsync(_messageBus);
  }

  Future removeItems(Guid id, int number, int version) {
    var cmd = new RemoveItemsFromInventory(id, number, version);
    return cmd.onSuccess(() => showDetails(id)).fireAsync(_messageBus);
  }
  
  showItems() {
    var inventoryItems = _viewModelFacade.getInventoryItems();
    _view.showItems(inventoryItems);
  }

  showDetails(Guid id) {
    var details = _viewModelFacade.getInventoryItemDetails(id);
    _view.showDetails(details);
  }
  
  final Logger _logger;
  final MessageBus _messageBus;
  final ViewModelFacade _viewModelFacade;
  final InventoryView _view;
}

abstract class InventoryView {
  set presenter(InventoryPresenter p);
  
  showItems(List<InventoryItemListEntry> items);
  
  showDetails(InventoryItemDetails details);
  
  recordMessage(String messageType, String messageName, DateTime time);
}
