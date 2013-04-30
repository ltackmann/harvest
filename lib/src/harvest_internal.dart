// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

library harvest_internal;

import 'harvest_api.dart';

/* Decorate [PersistentEvent] with extra attributes so its easy to store/retrieve */
class PersistentEventDescriptor {
  PersistentEventDescriptor(this.id, this.event) {
    version = event.version;
  }
  
  PersistentEvent event;
  Guid id;
  int version;
}

