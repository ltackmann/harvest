// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

library harvest_example_app;

import "dart:html";
import "dart:math";

import "package:log4dart/log4dart.dart";

import "app/lib.dart";

// we load the view here so "app/lib.dart" does not need to reference dart:html
part "app/view.dart";

main() {
  var messageBus = new MessageBus();
  var eventStore = new MemoryEventStore();
  
  // create repository for domain models and set up command handler 
  var itemRepo = new DomainRepository<Item>((Guid id) => new Item.fromId(id), eventStore);
  var commandHandler = new InventoryCommandHandler(messageBus, itemRepo);
  
  // create respositories for view models and set up event handler
  var itemEntryRepo = new MemoryModelRepository<ItemEntry>();
  var itemDetailsRepo = new MemoryModelRepository<ItemDetails>();
  var eventHandler = new InventoryEventHandler(messageBus, itemEntryRepo, itemDetailsRepo);
  
  // wire up frontend
  var view = new _InventoryView(document.body);
  var viewModelFacade = new ViewModelFacade(itemEntryRepo, itemDetailsRepo);
  var presenter = new InventoryPresenter(messageBus, view, viewModelFacade);
  
  // start application
  presenter.go();
}

