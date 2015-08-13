// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_test_helpers;

/**
 * Test CQRS sample model against different [EventStore] implementations
 */
class CqrsTester {
  InventoryPresenter _presenter;
  InventoryViewMock _view;
  final EventStore _eventStore;
  final MessageBus _messageBus;
  
  CqrsTester(this._messageBus, this._eventStore) {
    init();
    eventsTest();
  }
  
  /**
   * Initialize classes used in test, placed in sepearate method so it can be called 
   * again when asserting that replaying events from scratch results in the same view 
   * model
   */
  init() {
    // create repository for domain models and set up command handler 
    var itemRepo = new DomainRepository<Item>((Guid id) => new Item(id), _eventStore, _messageBus);
    var commandHandler = new InventoryCommandHandler(_messageBus, itemRepo);
    
    // create respositories for view models and set up event handler
    var itemEntryRepo = new MemoryModelRepository<ItemEntry>();
    var itemDetailsRepo = new MemoryModelRepository<ItemDetails>();
    var eventHandler = new InventoryEventHandler(_messageBus, itemEntryRepo, itemDetailsRepo);
    
    // wire up mock frontend
    _view = new InventoryViewMock();
    var viewModelFacade = new ViewModelFacade(itemEntryRepo, itemDetailsRepo);
    _presenter = new InventoryPresenter(_messageBus, _view, viewModelFacade);
  }
  
  /**
   * Test executing events causes app to behave as expected  
   */
  eventsTest() {
    final expectedMessages = new List<String>();
    String item1Name = "Book";
    String item2Name = "Car";
    var item1Id, item1Version, item2Id;
    
    test("create item and assert its displayed in item list", () async {
      await _presenter.createItem(item1Name);
      expect(_view.displayedItems.length, equals(1));
      assertEventNames(_view.recordedMessages, expectedMessages..addAll(["CreateItem","ItemCreated"])); 
      
      item1Id = _view.displayedItems[0].id;
      expect(item1Id, isNotNull);
    });
    
    test("show details for item 1", () async {
      _presenter.showItemDetails(item1Id);
      expect(item1Id, equals(_view.displayedDetails.id));
      expect(item1Name, equals(_view.displayedDetails.name));
      
      item1Version = _view.displayedDetails.version;
      expect(item1Version, equals(0), reason:"initial version should be zero");
    });
    
    test("increase invetory of item 1", () async {
      await _presenter.increaseInventory(item1Id, 2, item1Version);
      expect(_view.displayedDetails.currentCount, equals(2));
      assertEventNames(_view.recordedMessages, expectedMessages..addAll(["IncreaseInventory","InventoryIncreased"]));   
      
      expect(_view.displayedDetails.version, isNot(equals(item1Version)), reason: "version should be bumped");
      item1Version = _view.displayedDetails.version;
    });
    
    test("rename item 1", () async {
      item1Name = "$item1Name v2";
      await _presenter.renameItem(item1Id, item1Name, item1Version);
      expect(item1Name, equals(_view.displayedDetails.name));
      assertEventNames(_view.recordedMessages, expectedMessages..addAll(["RenameItem","ItemRenamed"]));
      
      expect(_view.displayedDetails.version, isNot(equals(item1Version)), reason: "version should be bumped");
      item1Version = _view.displayedDetails.version;
    });
    
    test("decrease invetory of item 1", () async {
      await _presenter.decreaseInventory(item1Id, 1, item1Version);
      expect(_view.displayedDetails.currentCount, equals(1));
      assertEventNames(_view.recordedMessages, expectedMessages..addAll(["DecreaseInventory","InventoryDecreased"]));   
      
      expect(_view.displayedDetails.version, isNot(equals(item1Version)), reason: "version should be bumped");
      item1Version = _view.displayedDetails.version;
    });
    
    test("create inventory of item 2 using a process", () async {
      var processManager = new ProcessManager(_messageBus);
      var createItemWithInventory = processManager.createProcessPrototype([
        new WorkItem<CreateItemStep>(() => new CreateItemStep()),
        new WorkItem<IncreaseInventoryStep>(() => new IncreaseInventoryStep()),
      ]);
      var process = processManager.createProcess(createItemWithInventory, {"itemName":item2Name, "itemCount":2});
      await processManager.startProcess(process);  
      _presenter.showItems();
      expect(_view.displayedItems.length, equals(2));
      assertEventNames(_view.recordedMessages, expectedMessages..addAll(["CreateItem","ItemCreated","IncreaseInventory","InventoryIncreased"])); 
           
      item2Id = _view.displayedItems[1].id;
      expect(item2Id, isNotNull);
      expect(item1Id == item2Id, isFalse);
    });
    
    // TODO 2: deactivate item 1 (checks that we can corretly reload another view)
  }
  
  /**
   * Test reloading recorded events gives same result as recieving them one by one
   */
  reloadEventsTest() {
    // save current view state
    var origState = new ViewModelState(_presenter, _view);
    
    // reload the application (causes replay of the recorded events)
    init();
    
    // compare state after replay
    var replayedState = new ViewModelState(_presenter, _view);
    assertEqualState(origState, replayedState);
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
}
