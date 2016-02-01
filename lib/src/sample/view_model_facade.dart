// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest_sample;

/**
 * Read-only access to the view model
 */
class ViewModelFacade {
  final ModelRepository<ItemEntry> _itemEntryRepository;
  final ModelRepository<ItemDetails> _itemDetailsRepository;

  ViewModelFacade(this._itemEntryRepository, this._itemDetailsRepository);

  List<ItemEntry> getItems() => _itemEntryRepository.all;

  ItemDetails getItemDetails(Guid id) => _itemDetailsRepository.getById(id);
}
