// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store_example;

/**
 * Read-only access to the view model
 */ 
class ViewModelFacade {
  ViewModelFacade( this._itemListRepository, this._itemDetailsRepository);
  
  List<InventoryItemListEntry> getInventoryItems() {
    return _itemListRepository.all;
  }

  InventoryItemDetails getInventoryItemDetails(Guid id) {
    return _itemDetailsRepository.getById(id);
  }
  
  final ModelRepository<InventoryItemListEntry> _itemListRepository;
  final ModelRepository<InventoryItemDetails> _itemDetailsRepository;
}
