// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store_tests;

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
