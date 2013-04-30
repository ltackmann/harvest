// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_example;

/** The details of a [Item] */
class ItemDetails implements IdModel {
  ItemDetails(this.id, this.name, this.currentCount, this.version);
  
  Guid id;
  String name;
  int currentCount, version;
}

/** [Item] list entry */
class ItemEntry implements IdModel {
  ItemEntry(this.id, this.name);
  
  Guid id;
  String name;
}

