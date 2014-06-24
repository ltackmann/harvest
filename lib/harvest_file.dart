// Copyright (c) 2013-2014, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

/** Eventstore backed by a file system */ 
library harvest_file;

import 'dart:async';
import 'dart:io';
import 'dart:convert' show JSON;

import 'package:log4dart/log4dart.dart';
import 'package:serialization/serialization.dart';

import 'harvest.dart';

part 'src/stores/file_event_store.dart';
