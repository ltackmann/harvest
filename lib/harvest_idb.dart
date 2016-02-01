// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

/** Eventstore backed by IndexedDB */
library harvest_idb;

import 'dart:async';
import 'dart:html';
import 'dart:indexed_db';

import 'package:log4dart/log4dart.dart';

import 'harvest.dart';
import 'src/harvest_json.dart';

export 'harvest.dart';

part 'src/event_stores/idb_event_store.dart';
part 'src/model_repositories/idb_model_repository.dart';
