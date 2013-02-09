// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store;

class Guid {
  static Uuid valueFactory;
  
  factory Guid() {
    if(valueFactory == null) {
      valueFactory = new Uuid();
    }
    var val = valueFactory.v1();
    return new Guid._internal(val);
  }
  
  Guid._internal(this.value); 
  
  int get hashCode => value.hashCode;
  
  String toString() => value;
  
  final String value;
}

