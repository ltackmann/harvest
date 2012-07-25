// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class InventoryCommandHandler {
  InventoryCommandHandler(this._messageBus, this._domainRepository) {
    _messageBus.on[CreateInventoryItem.TYPE].add(_onCreateInventoryItem);
  }
 
  _onCreateInventoryItem(CreateInventoryItem message) {
    var item = new InventoryItem(message.inventoryItemId, message.name);
    _domainRepository.save(item);
  }

  /*
  private readonly IRepository<InventoryItem> _repository;

  public void Handle(DeactivateInventoryItem message)
  {
      var item = _repository.GetById(message.InventoryItemId);
      item.Deactivate();
      _repository.Save(item, message.OriginalVersion);
  }
  public void Handle(RemoveItemsFromInventory message)
  {
      var item = _repository.GetById(message.InventoryItemId);
      item.Remove(message.Count);
      _repository.Save(item, message.OriginalVersion);
  }
  public void Handle(CheckInItemsToInventory message)
  {
      var item = _repository.GetById(message.InventoryItemId);
      item.CheckIn(message.Count);
      _repository.Save(item, message.OriginalVersion);
  }
  public void Handle(RenameInventoryItem message)
  {
      var item = _repository.GetById(message.InventoryItemId);
      item.ChangeName(message.NewName);
      _repository.Save(item, message.OriginalVersion);
  }
  */
  
  final DomainRepository<InventoryItem> _domainRepository;
  final MessageBus _messageBus;
}
