// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

library harvest_test;

import "package:unittest/unittest.dart";

import "../example/web/app/lib.dart";

part "src/helpers.dart";
part "src/eventstore_tester.dart";
part "src/message_test.dart";

main() {
  // test message bus
  //new MessageTest();
  //if(true) return;
  var messageBus = new MessageBus();
  // test memory backed event store
  var memoryEventStore = new MemoryEventStore(messageBus);
  new EventStoreTester(messageBus, memoryEventStore);
  
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
