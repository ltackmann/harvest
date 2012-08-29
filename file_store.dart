// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Eventstore implementation backed by a file system
 */ 
#library("dartstore:file");

#import("dart:io");
#import("dart:json");
#import("dart:math");
#import("dart:mirrors");

#import("package:log4dart/log4dart.dart");

#import("dartstore.dart");

#source("lib/stores/file/file_domain_repository.dart");
#source("lib/stores/file/file_event_store.dart");
