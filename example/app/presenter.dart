// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class InventoryPresenter {
  InventoryPresenter(this._messageBus, this._view, this._viewModelFacade)
    : _logger = LoggerFactory.getLogger("InventoryPresenter") 
  {
    _view.presenter = this;
    // show the events fired
    _messageBus.onAny.add((Message message) {
      var messageType = (message is Command) ? "Command" : "Event";
      var messageName = message.type;
      _view.recordMessage(messageType, messageName, new Date.now());
    });
  }
  
  go() => showItems();

  createItem(String name) {
    var cmd = new CreateInventoryItem(new Guid(), name);
    cmd.onSuccess(showItems());
    _messageBus.fire(cmd);
  }
  
  checkInItems(Guid id, int number, int version) {
    var cmd = new CheckInItemsToInventory(id, number, version);
    cmd.onSuccess(showDetails(id));
    _messageBus.fire(cmd);
  }
  
  deactivateItem(Guid id, int version) {
    var cmd = new DeactivateInventoryItem(id, version);
    cmd.onSuccess(showItems());
    _messageBus.fire(cmd);
  }

  renameItem(Guid id, String name, int version) {
    var cmd = new RenameInventoryItem(id, name, version);
    cmd.onSuccess(showDetails(id));
    _messageBus.fire(cmd);
  }

  removeItems(Guid id, int number, int version) {
    var cmd = new RemoveItemsFromInventory(id, number, version);
    cmd.onSuccess(showDetails(id));
    _messageBus.fire(cmd);
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
