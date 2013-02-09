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
    group("executing events -", () {
      // record all events
      var events = new List<DomainEvent>();
      _messageBus.onAny.add((Message message) {
        if(message is DomainEvent) {
          events.add(message);
        }
      }); 
      
      String name1;
      Guid id1;
      
      test("create item 1", () {
        name1 = "Book 1";
        _presenter.createItem(name1);
        expect(_view.displayedItems.length, equals(1));
        id1 = _view.displayedItems[0].id;
      });
      
      /*
      test("show details for item 1", () {
        _presenter.showDetails(id1);
        expect(id1, equals(_view.displayedDetails.id));
        expect(name1, equals(_view.displayedDetails.name));
        assertEvents(["InventoryItemCreated"], events);   
      });
      */
      
      // 1: check items in
      
      // 1: check items out
      
      // 1: rename item
      //_presenter.renameItem()
      
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

