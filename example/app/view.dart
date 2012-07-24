// Copyright (c) 2012 Solvr, Inc. all rights reserved.  
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
      <h2>Details:</h2>
      Id: ${details.id}<br/>
      Name: ${details.name}<br/>
      Count: ${details.currentCount}<br/><br/>
      
      <a href="#" id='rename'>Rename</a> <br/>
      <a href="#" id='deactivate'>Deactivate</a> <br/>
      <a href="#" id='check_in'>CheckIn</a> <br/>
      <a href="#" id='remove'>Remove</a> <br/>
      <a href="#" id='back'>Back</a> <br/>
     </section>
     """);
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