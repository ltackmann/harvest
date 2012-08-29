// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

#library("dartstore:tests");

#import("package:unittest/unittest.dart");

#import("../dartstore.dart");
#import("../memory_store.dart");
#import("../example/app/lib.dart");

#source("lib/eventstore_state.dart");
#source("lib/eventstore_tester.dart");
#source("lib/view_mock.dart");

main() {
  // test memory backed event store
  var memoryItemListRepository = new MemoryModelRepository<InventoryItemListEntry>("InventoryItemListEntry");
  var memoryItemDetailsRepository = new MemoryModelRepository<InventoryItemDetails>("InventoryItemDetails");
  new EventStoreTester(memoryItemListRepository, memoryItemDetailsRepository);
  
  // test file backed event store
  
}