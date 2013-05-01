// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

/** Eventstore backed by a file system */ 
library harvest_file;

import 'dart:async';
import 'dart:io';
import 'dart:json' as JSON;

import 'package:log4dart/log4dart.dart';
import 'package:meta/meta.dart';
import 'package:serialization/serialization.dart';

import 'harvest.dart';
export 'harvest.dart';

part 'src/stores/file_event_store.dart';
