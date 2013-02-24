// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of harvest_test;

/**
 * Helper class that retrieves the entire current view state. Useful for comparing 
 * view state as events are fired/replayed. 
 */
class ViewModelState {
  factory ViewModelState(InventoryPresenter presenter, InventoryViewMock view) {
    // get inventory list state
    presenter.showItems();
    var itemList = view.displayedItems;
    
    // save details for each item in the list
    var itemDetailsList = new List<InventoryItemDetails>();
    itemList.forEach((var item) {
      presenter.showDetails(item.id);
      itemDetailsList.add(view.displayedDetails);
    });
    return new ViewModelState._internal(itemList, itemDetailsList);
  }
  
  ViewModelState._internal(this.itemList, this.itemDetailsList);
  
  final List<InventoryItemListEntry> itemList;
  final List<InventoryItemDetails> itemDetailsList;
}

/**
 * Mock implementation of [InventoryView] that does not depend on dart:html
 */
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

/**
 * Assert that event are in correct order 
 */
assertEvents(List<String> eventNames, List<DomainEvent> events) {
  expect(eventNames.length, equals(events.length));
  for(int i=0; i<eventNames.length; i++) {
    expect(eventNames[i], equals(typeNameOf(events[i])));
  }
}

/**
 * Assert that two [ViewModelState]'s are identical
 */
assertEqualState(ViewModelState origState, ViewModelState replayedState) {
  expect(origState.itemList.length, equals(replayedState.itemList.length));
  for(int i=0; i<origState.itemList.length; i++) {
    var origItem = origState.itemList[i];
    var replayedItem = replayedState.itemList[i];
    expect(origItem.id, equals(replayedItem.id));
    expect(origItem.name, equals(replayedItem.name));
  }
  
  expect(origState.itemDetailsList.length, equals(replayedState.itemDetailsList.length));
  for(int j=0; j<origState.itemDetailsList.length; j++) {
    var origDetails = origState.itemDetailsList[j];
    var replayedDetails = replayedState.itemDetailsList[j];
    expect(origDetails.id, equals(replayedDetails.id));
    expect(origDetails.name, equals(replayedDetails.name));
    expect(origDetails.currentCount, equals(replayedDetails.currentCount));
    expect(origDetails.version, equals(replayedDetails.version));
  }
}