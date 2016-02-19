// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

import 'harvest_file_test.dart' as harvest_file_test;
import 'harvest_memory_test.dart' as harvest_memory_test;
import 'harvest_message_test.dart' as harvest_message_test;

/** Run every Harvest test */
main() {
  harvest_message_test.main();
  harvest_memory_test.main();
  harvest_file_test.main();
}
