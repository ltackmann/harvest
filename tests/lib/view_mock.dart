// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class InventoryViewMock implements InventoryView {
  set presenter(InventoryPresenter p) {
    
  }
  
  showItems(List<InventoryItemListEntry> items) {
    displayedItems = items;
  }
  
  showDetails(InventoryItemDetails details) {
    displayedDetails = details;
  }
  
  recordMessage(String messageType, String messageName, Date time) {
  }
  
  // testing data
  List<InventoryItemListEntry> displayedItems;
  InventoryItemDetails displayedDetails;
}
