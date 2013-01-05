// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Test class used for asserting the robustness of eventstore implementations
 */ 
class EventStoreTester {
  EventStoreTester(this._inventoryItemRepository)
      : _events = new List<DomainEvent>(),
        _messageBus = new MessageBus()
  {
    _messageBus.onAny.add((Message message) {
      if(message is DomainEvent) {
        _events.add(message);
      }
    });    
        
    _setupEventStore();
    _testEventStore();
  }
  
  _setupEventStore() {
    _events.clear();
    // create repository for domain models and set up command handler 
    var commandHandler = new InventoryCommandHandler(_messageBus, _inventoryItemRepository);
    
    // create respositories for view models and set up event handler
    var itemListRepository = new MemoryModelRepository<InventoryItemListEntry>("InventoryItemListEntry");
    var itemDetailsRepository = new MemoryModelRepository<InventoryItemDetails>("InventoryItemDetails");
    var eventHandler = new InventoryEventHandler(_messageBus, itemListRepository, itemDetailsRepository);
    
    // wire up frontend
    _view = new InventoryViewMock();
    var viewModelFacade = new ViewModelFacade(itemListRepository, itemDetailsRepository);
    _presenter = new InventoryPresenter(_messageBus, _view, viewModelFacade);
  }
  
  _testEventStore() {
    _testEvents();
    var origState = _saveState();
    // stop recording events and reset application
    _messageBus.onAny.clear();
    _setupEventStore();
    var replayedState = _saveState();
    _testEqualState(origState, replayedState);
    print("EVENTSTORE TEST SUCCEDED");
  }
  
  _testEvents() {
    // 1: create item
    var name1 = "Book 1";
    _presenter.createItem(name1);
    Expect.equals(_view.displayedItems.length, 1);
    var id1 = _view.displayedItems[0].id;
    
    // 1: show details
    _presenter.showDetails(id1);
    Expect.equals(id1, _view.displayedDetails.id);
    Expect.equals(name1, _view.displayedDetails.name);
    var version1 = _view.displayedDetails.version;
    _assertEvents(["InventoryItemCreated"]);    
    
    // 1: check items in
    
    // 1: check items out
    
    // 1: rename item
    //_presenter.renameItem()
    
    // 2: create item
    
    // 2: check items in
    
    // 2: deactivate item 
  }
  
  _assertEvents(List<String> eventNames) {
    Expect.equals(eventNames.length, _events.length);
    for(int i=0; i<eventNames.length; i++) {
      Expect.equals(eventNames[i], _events[i].type);
    }
  }
  
  EventStoreState _saveState() {
    // display items
    _presenter.showItems();
    var itemList = _view.displayedItems;
    
    // save details for each item
    var itemDetailsList = new List<InventoryItemDetails>();
    itemList.forEach((var item) {
      _presenter.showDetails(item.id);
      itemDetailsList.add(_view.displayedDetails);
    });
    
    return new EventStoreState(itemList, itemDetailsList);
  }
  
  _testEqualState(EventStoreState origState, EventStoreState replayedState) {
    Expect.equals(origState.itemList.length, replayedState.itemList.length);
    for(int i=0; i<origState.itemList.length; i++) {
      var origItem = origState.itemList[i];
      var replayedItem = replayedState.itemList[i];
      Expect.equals(origItem.id, replayedItem.id);
      Expect.equals(origItem.name, replayedItem.name);
    }
    
    Expect.equals(origState.itemDetailsList.length, replayedState.itemDetailsList.length);
    for(int j=0; j<origState.itemDetailsList.length; j++) {
      var origDetails = origState.itemDetailsList[j];
      var replayedDetails = replayedState.itemDetailsList[j];
      Expect.equals(origDetails.id, replayedDetails.id);
      Expect.equals(origDetails.name, replayedDetails.name);
      Expect.equals(origDetails.currentCount, replayedDetails.currentCount);
      Expect.equals(origDetails.version, replayedDetails.version);
    }
  }
  
  DomainRepository _inventoryItemRepository;
  InventoryPresenter _presenter;
  InventoryViewMock _view;
  final List<DomainEvent> _events;
  final MessageBus _messageBus;
}

