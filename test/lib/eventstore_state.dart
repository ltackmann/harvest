// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class EventStoreState {
  EventStoreState(this.itemList, this.itemDetailsList);
  
  final List<InventoryItemListEntry> itemList;
  final List<InventoryItemDetails> itemDetailsList;
}
