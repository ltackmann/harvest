// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest_sample;

/** The details of a [Item] */
class ItemDetails implements Identifiable {
  int currentCount, version;
  String name;

  @override
  Guid id;

  ItemDetails(this.id, this.name, this.currentCount, this.version);
}

/** [Item] list entry */
class ItemEntry implements Identifiable {
  String name;

  @override
  Guid id;

  ItemEntry(this.id, this.name);
}
