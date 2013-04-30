// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

library harvest_test;

import 'package:unittest/unittest.dart';

import '../example/web/app/lib.dart';

part 'src/eventstore_test.dart';
part 'src/helpers.dart';
part 'src/stores_test.dart';

main() {
  new EventStoreTest();
  new StoresTest();
}
