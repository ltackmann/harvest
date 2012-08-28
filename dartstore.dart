// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

#library("dartstore");

#import("package:log4dart/log4dart.dart");

#source("lib/serializer/event_serializer_factory.dart");
#source("lib/serializer/map_serializer.dart");
#source("lib/serializer/serializer.dart");

#source("lib/aggregate_not_found_exception.dart");
#source("lib/aggregate_root.dart");
#source("lib/application_command.dart");
#source("lib/application_event.dart");
#source("lib/command.dart");
#source("lib/concurrency_exception.dart");
#source("lib/dead_event.dart");
#source("lib/domain_event.dart");
#source("lib/domain_event_descriptor.dart");
#source("lib/domain_repository.dart");
#source("lib/event_sourced_entity.dart");
#source("lib/event_store.dart");
#source("lib/guid.dart");
#source("lib/handler_map.dart");
#source("lib/message.dart");
#source("lib/message_bus.dart");
#source("lib/model_repository.dart");

