// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class _InventoryView implements InventoryView {
  _InventoryView(this._container);
  
  showItems(List<InventoryItemListEntry> items){
    Element elm = new Element.html("""
    <section> 
      <h2>All items:</h2>
      <ul></ul>
      <input type='text'></input>
      <a href="#">Add item</a>
    </section>
    """);
    
    elm.query("a").on.click.add((Event e) {
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
      entry.query("a").on.click.add((Event e) => presenter.showDetails(item.id));
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
    elm.query("#rename").on.click.add((Event e) {
      _changeItemName((String newName) {
        presenter.renameItem(details.id, newName, details.version);
      });
    });
    
    elm.query("#check_items_in").on.click.add((Event e) {
      _checkInItems((int count) {
        presenter.checkInItems(details.id, count, details.version);
      });
    });
    
    elm.query("#deactivate").on.click.add((Event e) => presenter.deactivateItem(details.id, details.version));
    
    elm.query("#remove_items").on.click.add((Event e) {
      _removeItems((int count) {
        presenter.removeItems(details.id, count, details.version);
      });
    });
    
    elm.query("#back").on.click.add((Event e) => presenter.showItems());
    
    _show(elm);
  }
  
  _changeItemName(onSubmit(String name)) {
    Element elm = new Element.html("""
    <section> 
      <p>Name: <input type="text"/> </p>
      <button name="submit">Submit</button>
    </section>
    """);
    elm.query("button").on.click.add((MouseEvent event) {
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
    elm.query("button").on.click.add((MouseEvent event) {
      InputElement input = elm.query("input");
      onSubmit(parseInt(input.value));
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
    elm.query("button").on.click.add((MouseEvent event) {
      InputElement input = elm.query("input");
      onSubmit(parseInt(input.value));
    });
    _show(elm);
  }
  
  _show(Element elm) {
    _container.nodes.clear();
    _container.nodes.add(elm);
  }
  
  InventoryPresenter presenter;
  final Element _container;
}