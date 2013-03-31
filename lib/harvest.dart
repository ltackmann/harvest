// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

/**
 * Event store 
 */ 
library harvest;

import "dart:async";
export "dart:async";
import "dart:math";

import "package:uuid/uuid.dart";
import "package:log4dart/log4dart.dart";

/**
 * API
 */ 
part "src/aggregate_root.dart";
part "src/events.dart";
part "src/domain_repository.dart";
part "src/errors.dart";
part "src/event_store.dart";
part "src/guid.dart";
part "src/message_bus.dart";
part "src/model_repository.dart";

/**
 * Eventstore implementation backed by memory (HashMap)
 */ 
part "src/stores/memory/memory_event_store.dart";
part "src/stores/memory/memory_model_repository.dart";

/**
 * Global Helper functions 
 */
String typeNameOf(Object obj) => obj.runtimeType.toString();

String genericTypeNameOf(Object obj) {
  // TODO change when typeArguments is implemented in dart:mirrors
  var typeName = typeNameOf(obj);
  var regex = new RegExp(r"(.*)<(.*)>");
  if(!regex.hasMatch(typeName)) {
    throw new ArgumentError("Non generic type $typeName passed");
  }
  return regex.firstMatch(typeName).group(2);
}
