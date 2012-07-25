// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class _InventoryView implements InventoryView {
  _InventoryView(this._container);
  
  // bind model.id/model.version in onSubmit
  showChangeNameView(onSubmit(String name)) {
    Element elm = new Element.html(""" 
      <p>Name: <input type="text"/> </p>
      <button name="submit">Submit</button>
    """);
    elm.query("button").on.click.add((MouseEvent event) {
      InputElement input = elm.query("input");
      onSubmit(input.value);
    });
    _show(elm);
  }
  
  // bind model.id/model.version in onSubmit
  showCheckIn(onSubmit(int number)) {
    Element elm = new Element.html(""" 
      <p>Number: <input type="number"/> </p>
      <button name="submit">Submit</button>
    """);
    elm.query("button").on.click.add((MouseEvent event) {
      InputElement input = elm.query("input");
      onSubmit(Math.parseInt(input.value));
    });
    _show(elm);
  }
  
  showItems(List<InventoryItemListEntry> items){
    Element elm = new Element.html("""
    <section> 
      <h2>All items:</h2>
      <ul></ul>
      <input type='text'></input>
      <a href="#">Add</a>
    </section>
    """);
    
    elm.query("a").on.click.add((Event e) {
      InputElement nameInput = elm.query('input');
      presenter.addItem(nameInput.value);
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
  
  showRemove(onSubmit(Guid id, int count)) {
    Element elm = new Element.html(""" 
      <p>Number: <input type="number"/> </p>
      <button name="submit">Submit</button>
    """);
    elm.query("button").on.click.add((MouseEvent event) {
      InputElement input = elm.query("input");
      onSubmit(Math.parseInt(input.value));
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
      
      <a href="#" id='rename'>Rename</a> <br/>
      <a href="#" id='check_in'>Check out</a> <br/>
      <a href="#" id='check_out'>Check out</a> <br/>
      <a href="#" id='remove'>Remove</a> <br/>
      <a href="#" id='back'>Back</a> <br/>
     </section>
     """);
    // rename handler
    elm.query("#rename").on.click.add((Event e) {
    });
    
    elm.query("#deactivate").on.click.add((Event e) => presenter.showItems());
    
    elm.query("#check_in").on.click.add((Event e) => presenter.showItems());
    
    elm.query("#remove").on.click.add((Event e) => presenter.removeItem(details.id));
    
    elm.query("#back").on.click.add((Event e) => presenter.showItems());
    
    _show(elm);
  }
  
  _show(Element elm) {
    _container.nodes.clear();
    _container.nodes.add(elm);
  }
  
  InventoryPresenter presenter;
  final Element _container;
}