// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class HandlerMap {
  final Map<String, List<MessageHandler>> _handlers;
  
  HandlerMap(): _handlers = new Map<String, List<MessageHandler>>();
  
  operator [](String messageName) {
    return _handlers.putIfAbsent(messageName, () => new List<MessageHandler>()); 
  }
  
  forEach(Function f) {
    return _handlers.forEach(f);
  }
  
  bool noHandlersFor(String messageName) => this[messageName].length == 0;
}

typedef MessageHandler(Message message);