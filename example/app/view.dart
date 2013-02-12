// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store_example_app;

class _InventoryView implements InventoryView {
  _InventoryView(this._container);
  
  showItems(List<InventoryItemListEntry> items){
    Element elm = new Element.html("""
    <section> 
      <h2>Item list</h2>
      <ul></ul>
      <input type='text'></input>
      <a href="#">Add item</a>
    </section>
    """);
    
    elm.query("a").onClick.listen((Event e) {
      InputElement nameInput = elm.query('input');
      presenter.createItem(nameInput.value);
      nameInput.value = '';
    });
    
    items.forEach((var item) {
      var entry = new Element.html(""" 
        <li>
          <a href="#">Name: ${item.name}</a>
        </li>
      """);
      entry.query("a").onClick.listen((MouseEvent e) => presenter.showDetails(item.id));
      elm.query("ul").nodes.add(entry);
    });
    
    _show(elm);
  }
  
  showDetails(InventoryItemDetails details) {
    Element elm = new Element.html(""" 
    <section>
      <h2>Item Details:</h2>
      Id: ${details.id}<br/>
      Name: ${details.name}<br/>
      Count: ${details.currentCount}<br/><br/>
      
      <a href="#" id='rename'>Rename item</a> <br/>
      <a href="#" id='check_items_in'>Check items in</a> <br/>
      <a href="#" id='remove_items'>Check items out</a> <br/>
      <a href="#" id='deactivate'>Remove item</a> <br/>
      <a href="#" id='back'>Back</a> <br/>
     </section>
     """);
    // rename handler
    elm.query("#rename").onClick.listen((Event e) {
      _changeItemName((String newName) {
        presenter.renameItem(details.id, newName, details.version);
      });
    });
    
    elm.query("#check_items_in").onClick.listen((Event e) {
      _checkInItems((int count) {
        presenter.checkInItems(details.id, count, details.version);
      });
    });
    
    elm.query("#deactivate").onClick.listen((Event e) => presenter.deactivateItem(details.id, details.version));
    
    elm.query("#remove_items").onClick.listen((Event e) {
      _removeItems((int count) {
        presenter.removeItems(details.id, count, details.version);
      });
    });
    
    elm.query("#back").onClick.listen((Event e) => presenter.showItems());
    
    _show(elm);
  }
  
  recordMessage(String messageType, String messageName, DateTime time) {
    var elm = new Element.html("<li>$messageType $messageName date: ${time.toString()}");
    var widget = _container.query("#message_log ul");
    widget.nodes.add(elm);
  }
  
  _changeItemName(onSubmit(String name)) {
    Element elm = new Element.html("""
    <section> 
      <p>Name: <input type="text"/> </p>
      <button name="submit">Submit</button>
    </section>
    """);
    elm.query("button").onClick.listen((MouseEvent event) {
      InputElement input = elm.query("input");
      onSubmit(input.value);
    });
    _show(elm);
  }
  
  _checkInItems(onSubmit(int number)) {
    Element elm = new Element.html(""" 
    <section> 
      <p>Number: <input type="number"/> </p>
      <button name="submit">Submit</button>
    </section>
    """);
    elm.query("button").onClick.listen((MouseEvent event) {
      InputElement input = elm.query("input");
      onSubmit(int.parse(input.value));
    });
    _show(elm);
  }
  
  _removeItems(onSubmit(int count)) {
    Element elm = new Element.html("""
    <section> 
      <p>Number: <input type="number"/> </p>
      <button name="submit">Submit</button>
    </section>
    """);
    elm.query("button").onClick.listen((MouseEvent event) {
      InputElement input = elm.query("input");
      onSubmit(int.parse(input.value));
    });
    _show(elm);
  }
  
  _show(Element elm) {
    var app = _container.query("#app");
    app.nodes.clear();
    app.nodes.add(elm);
  }
  
  InventoryPresenter presenter;
  final Element _container;
}
