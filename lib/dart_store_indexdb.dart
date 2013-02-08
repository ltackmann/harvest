// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Eventstore implementation backed by IndexDB (HTML5)
 */ 
library dart_store_indexdb;

import "dart:indexed_db";

import "package:log4dart/log4dart.dart";

import "dart_store.dart";

part "src/stores/indexdb/idb_collection.dart";
part "src/stores/indexdb/idb_connection.dart";
part "src/stores/indexdb/idb_event_store.dart";

IDBConnection idbConnection(String name, String version) => new IDBConnection(name, version);
