// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Naive, but usable, 128bit implementation of a GUID class. 
 *
 * TODO Delete once a real one is added to dart:core
 */
class Guid implements Hashable {
  final String value;
  
  factory Guid() {
    int now = new Date.now().millisecondsSinceEpoch;
    String guid = "${now}-${(Math.random() * now).toInt()}";
    return new Guid.fromValue(guid);
  }
  
  Guid.fromValue(this.value);

  operator ==(Guid other) {
    return value == other.value;
  }
  
  int hashCode() => value.hashCode();
  
  toString() => value;
}
