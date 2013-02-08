// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store_example;

/**
 * View/read model describing the details of a inventory item
 */
class InventoryItemDetails implements IdModel {
  InventoryItemDetails(this.id, this.name, this.currentCount, this.version);
  
  Uuid id;
  String name;
  int currentCount;
  int version;
}

/**
 * View/read model for listing inventory item's
 */
class InventoryItemListEntry implements IdModel {
  InventoryItemListEntry(this.id, this.name);
  
  Uuid id;
  String name;
}

