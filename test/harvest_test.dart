// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

library harvest_test;

import "package:unittest/unittest.dart";

import "../example/app/lib.dart";

part "lib/helpers.dart";
part "lib/eventstore_tester.dart";

main() {
  // test memory backed event store
  var memoryEventStore = new MemoryEventStore();
  new EventStoreTester(memoryEventStore);
  
  // test file backed event store
  /* TODO re-enable
  var domainEventFactory = new DomainEventFactory();
  domainEventFactory.builder["InventoryItemDeactivated"] = () => new InventoryItemDeactivated.init();
  domainEventFactory.builder["InventoryItemCreated"] = () => new InventoryItemCreated.init();
  domainEventFactory.builder["InventoryItemRenamed"] = () => new  InventoryItemRenamed.init();
  domainEventFactory.builder["ItemsCheckedInToInventory"] = () => new   ItemsCheckedInToInventory.init();
  domainEventFactory.builder["ItemsRemovedFromInventory"] = () => new  ItemsRemovedFromInventory.init();
  
  var fileInventoryItemRepository = new FileDomainRepository.reset("InventoryItem", (Guid id) => new InventoryItem.fromId(id), domainEventFactory, "/tmp/eventstore");
  new EventStoreTester(fileInventoryItemRepository);
  */
}
