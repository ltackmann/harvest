// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

library harvest_json;

import 'dart:convert' show JSON;
import 'package:serialization/serialization_mirrors.dart';

import '../harvest.dart';


/**
 * JSON representation of the data around an [EventStream] such as the actual events and
 * the id of used to retrieve/manipulate it. Implements methods for loading/unloading
 * itself from JSON data
 */
class JsonEventStreamDescriptor {
  List<DomainEvent> events;
  int version;
  Guid id;

  JsonEventStreamDescriptor();

  JsonEventStreamDescriptor.createNew(Guid id) {
    this.id = id;
    this.version = -1;
    this.events = [];
  }

  /**
   * Serialize this descriptor into a JSON string
   */
  String toJsonString() {
    var serialization = new Serialization()..addRuleFor(this);
    var jsonData = serialization.write(this);
    var jsonString = JSON.encode(jsonData);
    return jsonString;
  }

  /**
   * Load this descriptor from JSON string
   */
  fromJsonString(String jsonString) async {
    var jsonData = JSON.decode(jsonString);
    var serialization = new Serialization()..addRuleFor(this);
    var descriptor = serialization.read(jsonData);
    this.id = descriptor.id;
    this.version = descriptor.version;
    this.events = descriptor.events;
  }
}
