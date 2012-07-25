// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

#library("cqrs4dart:indexdb-store");

#import("dart:html");
#import("package:log4dart/lib.dart");

#import("../../../lib.dart");

#source("idb_collection.dart");
#source("idb_connection.dart");
#source("idb_event_store.dart");

IDBConnection idbConnection(String name, String version) => new IDBConnection(name, version);