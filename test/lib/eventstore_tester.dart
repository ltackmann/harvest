// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store_test;

/**
 * Test class used for asserting the robustness of eventstore implementations
 */ 
class EventStoreTester {
  EventStoreTester(this._eventStore): _messageBus = new MessageBus() {
    _init();
    
    // test that executing events causes app to behave as expected    
    _testExecutingEvents();
    
    // test that reloading all recorded events results in expected result  
    // TODO _testReloadingEvents();
  }
  
  _init() {
    // create repository for domain models and set up command handler 
    var inventoryItemRepo = new DomainRepository<InventoryItem>((Guid id) => new InventoryItem.fromId(id), _eventStore);
    var commandHandler = new InventoryCommandHandler(_messageBus, inventoryItemRepo);
    
    // create respositories for view models and set up event handler
    var itemListRepo = new MemoryModelRepository<InventoryItemListEntry>();
    var itemDetailsRepo = new MemoryModelRepository<InventoryItemDetails>();
    var eventHandler = new InventoryEventHandler(_messageBus, itemListRepo, itemDetailsRepo);
    
    // wire up frontend
    _view = new InventoryViewMock();
    var viewModelFacade = new ViewModelFacade(itemListRepo, itemDetailsRepo);
    _presenter = new InventoryPresenter(_messageBus, _view, viewModelFacade);
  }
  
  _testExecutingEvents() {
    // record all events
    var events = new List<DomainEvent>();
    _messageBus.onAny.add((Message message) {
      if(message is DomainEvent) {
        events.add(message);
      }
    }); 
    
    group("executing events -", () {
      String item1Name = "Book 1";
      Guid item1Id;
      int item1Version;
      
      test("creating an item should display it", () {
        _presenter.createItem(item1Name).then(expectAsync1((res) {
          expect(_view.displayedItems.length, equals(1));
          
          item1Id = _view.displayedItems[0].id;
          expect(item1Id, isNotNull);
        }));
      });
      
      test("show details for item 1", () {
        _presenter.showDetails(item1Id);
        expect(item1Id, equals(_view.displayedDetails.id));
        expect(item1Name, equals(_view.displayedDetails.name));
        assertEvents(["InventoryItemCreated"], events); 
        
        item1Version = _view.displayedDetails.version;
        expect(item1Version, isNotNull);
      });
      
      // 1: check items in
      
      // 1: check items out
      
      // 1: rename item
      test("rename item 1", () {
        item1Name = item1Name.concat(" v2");
        _presenter.renameItem(item1Id, item1Name, item1Version).then(expectAsync1((res) {
          expect(item1Name, equals(_view.displayedDetails.name));
          assertEvents(["InventoryItemCreated", "InventoryItemRenamed"], events);   
        }));
      });
      
      // 2: create item
      
      // 2: check items in
      
      // 2: deactivate item 
    });
  }
  
  _testReloadingEvents() {
    group("reloading events -", () {
      // save current view state
      var origState = new ViewModelState(_presenter, _view);
      
      // reload the application (causes replay of the recorded events)
      _messageBus.onAny.clear();
      _init();
      
      // compare state after replay
      var replayedState = new ViewModelState(_presenter, _view);
      assertEqualState(origState, replayedState);
    });
  }
  
  InventoryPresenter _presenter;
  InventoryViewMock _view;
  final MessageBus _messageBus;
  final EventStore _eventStore;
}

