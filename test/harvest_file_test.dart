// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

import 'package:harvest/harvest_file.dart';
import 'package:test/test.dart';

import 'src/harvest_test_helpers.dart';

/** Test file system backed stores and repositories in Harvest */
main() {
  group('FileEventStore test', () {
    var eventStore = new FileEventStore("/tmp/eventlog");
    new EventStoreTester(eventStore);
  });

  group('MemoryEventStore CQRS test', () {
    var eventStore = new FileEventStore("/tmp/eventlog2");
    new CqrsTester(new MessageBus(), eventStore);
  });
}
