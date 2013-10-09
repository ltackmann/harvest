// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

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
    var itemDetailsList = new List<ItemDetails>();
    itemList.forEach((var item) {
      presenter.showItemDetails(item.id);
      itemDetailsList.add(view.displayedDetails);
    });
    return new ViewModelState._internal(itemList, itemDetailsList);
  }
  
  ViewModelState._internal(this.itemEntryList, this.itemDetailsList);
  
  final List<ItemEntry> itemEntryList;
  final List<ItemDetails> itemDetailsList;
}

/** Mock implementation of [InventoryView] that does not depend on dart:html */
class InventoryViewMock implements InventoryView {
  set presenter(InventoryPresenter p) {
  }
  
  showItems(List<ItemEntry> items) {
    displayedItems = items;
  }
  
  showDetails(ItemDetails details) {
    displayedDetails = details;
  }
  
  recordMessage(String messageType, String messageName, DateTime time) {
  }
  
  // testing data
  List<ItemEntry> displayedItems;
  ItemDetails displayedDetails;
}

/** Assert that event are in correct order */
assertEvents(List<String> eventNames, List<DomainEvent> events) {
  expect(eventNames.length, equals(events.length));
  for(int i=0; i<eventNames.length; i++) {
    expect(eventNames[i], equals(typeNameOf(events[i])));
  }
}

/** Assert that two [ViewModelState]'s are identical */
assertEqualState(ViewModelState origState, ViewModelState replayedState) {
  expect(origState.itemEntryList.length, equals(replayedState.itemEntryList.length));
  for(int i=0; i<origState.itemEntryList.length; i++) {
    var origItem = origState.itemEntryList[i];
    var replayedItem = replayedState.itemEntryList[i];
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