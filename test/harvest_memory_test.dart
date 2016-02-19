// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

import 'package:harvest/harvest.dart';
import 'package:test/test.dart';

import 'src/harvest_test_helpers.dart';

/** Test memory backed stores and repositories in Harvest */
main() {
  group('MemoryEventStore test', () {
    var eventStore = new MemoryEventStore();
    new EventStoreTester(eventStore);
  });

  group('MemoryEventStore CQRS test', () {
    var eventStore = new MemoryEventStore();
    new CqrsTester(new MessageBus(), eventStore);
  });
}
