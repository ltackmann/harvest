// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_example_app;

class _InventoryView implements InventoryView {
  _InventoryView(this._container);
  
  clearErrors() {
    var errorContainer = _container.query("#errors");
    errorContainer.style.visibility = "hidden"; 
    errorContainer.text = "";
  }
  
  showErrors(Object errors) {
    var errorContainer = _container.query("#errors");
    errorContainer.style.visibility = "visible"; 
    errorContainer.text = errors.toString();
  }
  
  showItems(List<ItemEntry> itemEntries){
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
    
    itemEntries.forEach((var item) {
      var entry = new Element.html(""" 
        <li>
          <a href="#">Name: ${item.name}</a>
        </li>
      """);
      entry.query("a").onClick.listen((MouseEvent e) => presenter.showItemDetails(item.id));
      elm.query("ul").nodes.add(entry);
    });
    
    _show(elm);
  }
  
  showDetails(ItemDetails details) {
    Element elm = new Element.html(""" 
    <section>
      <h2>Item Details:</h2>
      Id: ${details.id}<br/>
      Name: ${details.name}<br/>
      Inventory: ${details.currentCount}<br/><br/>
      
      <a href="#" id='rename_item'>Rename item</a> <br/>
      <a href="#" id='increase_inventory'>Increase inventory</a> <br/>
      <a href="#" id='decrease_inventory'>Decrease inventory</a> <br/>
      <a href="#" id='remove_item'>Remove item</a> <br/>
      <a href="#" id='back'>Back</a> <br/>
     </section>
     """);
    // rename handler
    elm.query("#rename_item").onClick.listen((Event e) {
      _renameItem((String newName) {
        presenter.renameItem(details.id, newName, details.version);
      });
    });
    
    elm.query("#increase_inventory").onClick.listen((Event e) {
      _increaseInventory((int count) {
        presenter.increaseInventory(details.id, count, details.version);
      });
    });
    
    elm.query("#remove_item").onClick.listen((Event e) => presenter.removeItem(details.id, details.version));
    
    elm.query("#decrease_inventory").onClick.listen((Event e) {
      _decreaseInventory((int count) {
        presenter.decreaseInventory(details.id, count, details.version);
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
  
  _renameItem(onSubmit(String name)) {
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
  
  _increaseInventory(onSubmit(int number)) {
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
  
  _decreaseInventory(onSubmit(int count)) {
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
