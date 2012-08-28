// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Eventstore implementation backed by IndexDB (HTML5)
 */ 
#library("dartstore:indexdb-store");

#import("dart:html");

#import("package:log4dart/log4dart.dart");

#import("dartstore.dart");

#source("lib/stores/indexdb/idb_collection.dart");
#source("lib/stores/indexdb/idb_connection.dart");
#source("lib/stores/indexdb/idb_event_store.dart");

IDBConnection idbConnection(String name, String version) => new IDBConnection(name, version);