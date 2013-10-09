// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

/** Eventstore API augmented for implementing CQRS applications  */ 
library harvest_cqrs;

import 'dart:async';

import 'package:log4dart/log4dart.dart';
import 'package:meta/meta.dart';

import 'harvest.dart';
export 'harvest.dart';

part 'src/cqrs/commands.dart';
part 'src/cqrs/aggregate_root.dart';
part 'src/cqrs/domain_repository.dart';
part 'src/cqrs/events.dart';
part 'src/cqrs/model_repository.dart';
part 'src/cqrs/repositories/memory/memory_model_repository.dart';


