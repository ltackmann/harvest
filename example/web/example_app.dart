// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

library harvest_example_app;

import 'dart:html';

import 'package:harvest/harvest_idb.dart';
import 'package:harvest/harvest_sample.dart';

// we load the view here so 'app/lib.dart' does not need to reference dart:html
part 'example_view.dart';

main() {
  var messageBus = new MessageBus();
  var eventStore = new IdbEventStore("example_db");

  // create repository for domain models and set up command handler
  var itemRepo = new DomainRepository<Item>((Guid id) => new Item(id), eventStore, messageBus);
  var commandHandler = new InventoryCommandHandler(messageBus, itemRepo);
  assert(commandHandler != null);

  // create respositories for view models and set up event handler
  var itemEntryRepo = new MemoryModelRepository<ItemEntry>();
  var itemDetailsRepo = new MemoryModelRepository<ItemDetails>();
  var eventHandler = new InventoryEventHandler(messageBus, itemEntryRepo, itemDetailsRepo);
  assert(eventHandler != null);

  // wire up frontend
  var view = new _InventoryView(document.body);
  var viewModelFacade = new ViewModelFacade(itemEntryRepo, itemDetailsRepo);
  var presenter = new InventoryPresenter(messageBus, view, viewModelFacade);

  // start application
  presenter.go();
}
