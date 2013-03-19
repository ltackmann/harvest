// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

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

