// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class InventoryPresenter {
  InventoryPresenter(this._messageBus, this._view, this._viewModelFacade)
    : _logger = LoggerFactory.getLogger("InventoryPresenter") 
  {
    _view.presenter = this;
    // show the events fired
    _messageBus.onAll.add((Message message) {
      var messageType = (message is Command) ? "Command" : "Event";
      var messageName = message.type;
      _view.recordMessage(messageType, messageName, new Date.now());
    });
  }
  
  go() => showItems();

  createItem(String name) {
    _messageBus.fire(new CreateInventoryItem(new Guid(), name));
    showItems();
  }
  
  checkInItems(Guid id, int number, int version) {
    _messageBus.fire(new CheckInItemsToInventory(id, number, version));
    showDetails(id);
  }
  
  deactivateItem(Guid id, int version) {
    _messageBus.fire(new DeactivateInventoryItem(id, version));
    showItems();
  }

  renameItem(Guid id, String name, int version) {
    _messageBus.fire(new RenameInventoryItem(id, name, version));
    showDetails(id);
  }

  removeItems(Guid id, int number, int version) {
    _messageBus.fire(new RemoveItemsFromInventory(id, number, version));
    showDetails(id);
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

interface InventoryView {
  set presenter(InventoryPresenter p);
  
  showItems(List<InventoryItemListEntry> items);
  
  showDetails(InventoryItemDetails details);
  
  recordMessage(String messageType, String messageName, Date time);
}
