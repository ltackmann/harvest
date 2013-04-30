// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

/** Event store API */ 
library harvest;

import 'dart:async';
import 'dart:math';

import 'package:log4dart/log4dart.dart';
import 'package:meta/meta.dart';

import 'src/harvest_api.dart';
export 'src/harvest_api.dart';

part 'src/stores/memory/memory_event_store.dart';

// Global Helper functions 
String typeNameOf(Object obj) => obj.runtimeType.toString();

String genericTypeNameOf(Object obj) {
  // TODO change when typeArguments is implemented in dart:mirrors
  var typeName = typeNameOf(obj);
  var regex = new RegExp(r'(.*)<(.*)>');
  if(!regex.hasMatch(typeName)) {
    throw new ArgumentError('Non generic type $typeName passed');
  }
  return regex.firstMatch(typeName).group(2);
}
