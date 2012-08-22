// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * View/read model describing the details of a inventory item
 */
class InventoryItemDetails implements IdModel {
  InventoryItemDetails(this.id, this.name, this.currentCount, this.version);
  
  Guid id;
  String name;
  int currentCount;
  int version;
}

/**
 * View/read model for listing inventory item's
 */
class InventoryItemListEntry implements IdModel {
  InventoryItemListEntry(this.id, this.name);
  
  Guid id;
  String name;
}
