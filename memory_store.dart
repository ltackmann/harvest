// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Eventstore implementation backed by memory (HashMap)
 */ 
#library("dartstore:memory-store");

#import("package:log4dart/log4dart.dart");

#import("dartstore.dart");

#source("lib/stores/memory/memory_event_store.dart");
#source("lib/stores/memory/memory_domain_repository.dart");
#source("lib/stores/memory/memory_model_repository.dart");