// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class EventSerializerFactory {
  EventSerializerFactory(): _serializers = new Map<String, Serializer>();
  
  final Map<String, Serializer> _serializers;
}