// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Eventstore implementation backed by a file system
 */ 
library harvest_file;

import "dart:io";
import "dart:json" as JSON;

import "package:log4dart/log4dart.dart";

import "harvest.dart";
export "harvest.dart";

part "src/stores/file/file_event_store.dart";
