// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

#import("dart:html");
#import("package:log4dart/lib.dart");

#import("app/lib.dart");
#import("../lib.dart");
#import("../src/stores/memory/lib.dart");

// we load the view here so "app/lib.dart" does not need to reference dart:html
#source("app/view.dart");

main() {
  var messageBus = new MessageBus();
  
  // command handling and domain models
  var inventoryItemRepository = new MemoryDomainRepository("InventoryItem", (Guid id) => new InventoryItem.fromId(id));
  var commandHandler = new InventoryCommandHandler(messageBus, inventoryItemRepository);
  
  // event handling and view models 
  var itemListRepository = new MemoryModelRepository<InventoryItemListEntry>("InventoryItemListEntry");
  var itemDetailsRepository = new MemoryModelRepository<InventoryItemDetails>("InventoryItemDetails");
  var eventHandler = new InventoryEventHandler(messageBus, itemListRepository, itemDetailsRepository);
  
  // wire up frontend
  var view = new _InventoryView(document.body);
  var viewModelFacade = new ViewModelFacade(itemListRepository, itemDetailsRepository);
  var presenter = new InventoryPresenter(messageBus, view, viewModelFacade);
  
  // start application
  presenter.go();
}

