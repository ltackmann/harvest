// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store_tests;

class EventStoreState {
  EventStoreState(this.itemList, this.itemDetailsList);
  
  final List<InventoryItemListEntry> itemList;
  final List<InventoryItemDetails> itemDetailsList;
}
