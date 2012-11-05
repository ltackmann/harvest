// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open #source software is governed by the license terms 
// specified in the LICENSE file

library dart_store;

import "dart:json";
import "dart:math";
import "dart:mirrors";

import "package:log4dart/log4dart.dart";

/**
 * DartStore API
 */ 
part "src/serializers/json_serializer.dart";
part "src/aggregate_builder.dart";
part "src/aggregate_not_found_exception.dart";
part "src/aggregate_root.dart";
part "src/application_command.dart";
part "src/application_event.dart";
part "src/command.dart";
part "src/concurrency_exception.dart";
part "src/dead_event.dart";
part "src/domain_event.dart";
part "src/domain_event_builder.dart";
part "src/domain_event_factory.dart";
part "src/domain_event_descriptor.dart";
part "src/domain_repository.dart";
part "src/event_sourced_entity.dart";
part "src/event_store.dart";
part "src/handler_map.dart";
part "src/message.dart";
part "src/message_bus.dart";
part "src/model_repository.dart";

/**
 * Eventstore implementation backed by memory (HashMap)
 */ 
part "src/stores/memory/memory_event_store.dart";
part "src/stores/memory/memory_domain_repository.dart";
part "src/stores/memory/memory_model_repository.dart";

