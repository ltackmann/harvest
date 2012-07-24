// Copyright (c) 2012 Solvr, Inc. all rights reserved.  
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

#library("dartstore");

#import("package:log4dart/lib.dart");

#source("src/serializer/event_serializer_factory.dart");
#source("src/serializer/map_serializer.dart");
#source("src/serializer/serializer.dart");

#source("src/aggregate_not_found_exception.dart");
#source("src/aggregate_root.dart");
#source("src/application_command.dart");
#source("src/application_event.dart");
#source("src/command.dart");
#source("src/concurrency_exception.dart");
#source("src/dead_event.dart");
#source("src/domain_event.dart");
#source("src/domain_event_descriptor.dart");
#source("src/domain_repository.dart");
#source("src/event_sourced_entity.dart");
#source("src/event_store.dart");
#source("src/guid.dart");
#source("src/handler_map.dart");
#source("src/message.dart");
#source("src/message_bus.dart");
#source("src/model_repository.dart");

