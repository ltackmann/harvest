// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

library dart_store_example_app;

import "dart:html";
import "dart:math";

import "package:log4dart/log4dart.dart";
import "../lib/dart_store.dart";
import "../lib/dart_store_cqrs.dart";

import "app/lib.dart";

// we load the view here so "app/lib.dart" does not need to reference dart:html
part "app/view.dart";

main() {
  var messageBus = new MessageBus();
  var eventStore = new MemoryEventStore();
  
  // create repository for domain models and set up command handler 
  var inventoryItemRepo = new DomainRepository<InventoryItem>((Guid id) => new InventoryItem.fromId(id), eventStore);
  var commandHandler = new InventoryCommandHandler(messageBus, inventoryItemRepo);
  
  // create respositories for view models and set up event handler
  var itemListRepo = new MemoryModelRepository<InventoryItemListEntry>();
  var itemDetailsRepo = new MemoryModelRepository<InventoryItemDetails>();
  var eventHandler = new InventoryEventHandler(messageBus, itemListRepo, itemDetailsRepo);
  
  // wire up frontend
  var view = new _InventoryView(document.body);
  var viewModelFacade = new ViewModelFacade(itemListRepo, itemDetailsRepo);
  var presenter = new InventoryPresenter(messageBus, view, viewModelFacade);
  
  // start application
  presenter.go();
}

