// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open #source software is governed by the license terms 
// specified in the LICENSE file

library dart_store;

import "dart:async";
export "dart:async";
import "dart:math";
import "dart:mirrors";

import "package:uuid/uuid.dart";
export "package:uuid/uuid.dart";
import "package:log4dart/log4dart.dart";

/**
 * DartStore API
 */ 
part "src/aggregate_builder.dart";
part "src/aggregate_root.dart";
part "src/domain_event_builder.dart";
part "src/domain_event_factory.dart";
part "src/domain_event_descriptor.dart";
part "src/domain_repository.dart";
part "src/errors.dart";
part "src/event_sourced_entity.dart";
part "src/event_store.dart";
part "src/handler_map.dart";
part "src/messages.dart";
part "src/message_bus.dart";
part "src/model_repository.dart";

/**
 * Eventstore implementation backed by memory (HashMap)
 */ 
part "src/stores/memory/memory_event_store.dart";
part "src/stores/memory/memory_domain_repository.dart";
part "src/stores/memory/memory_model_repository.dart";

/*
 * Internal helper functions 
 */
String _typeName(Object obj) => obj.runtimeType.toString();

String _genericTypeName(Object obj) {
  // TODO change when typeArguments is implemented in dart:mirrors
  var typeName = _typeName(obj);
  var regex = new RegExp(r"(.*)<(.*)>");
  if(!regex.hasMatch(typeName)) {
    throw new ArgumentError("Non generic type $typeName passed");
  }
  return regex.firstMatch(typeName).group(2);
}
