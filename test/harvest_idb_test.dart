// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

@TestOn("browser")
import 'package:test/test.dart';
import 'package:polymer/polymer.dart';

import 'package:harvest/harvest_idb.dart';

import 'src/harvest_test_helpers.dart';

/** Test IndexedDB backed stores and repositories in Harvest */
main() async {
  await initPolymer();

  group('IdbEventStore test', () {
    var eventStore = new IdbEventStore("idb_test");
    new EventStoreTester(eventStore);
  });

  group('IdbEventStore CQRS test', () {
    var eventStore = new IdbEventStore("idb_test2");
    new CqrsTester(new MessageBus(), eventStore);
  });
}
