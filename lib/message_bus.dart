// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class MessageBus {
  static MessageBus _instance;
  
  factory MessageBus() {
    // use a single instance for the entire application
    if(_instance == null) {
      _instance = new MessageBus._internal();
    }
    return _instance;
  }
  
  MessageBus._internal(): _handlerMap = new HandlerMap();
  
  HandlerMap get on {
    return _handlerMap;
  }
  
  fire(Message message) {
    if(_handlerMap.noHandlersFor(message.type) && message.type != DeadEvent.TYPE) {
      // fire dead event to notify application that no event handlers existed for the message
      message = new DeadEvent(message);
    }
    _handlerMap.forEach((String messageType, List<MessageHandler> messageHandlers){
      if(message.type == messageType) {
        messageHandlers.forEach((MessageHandler messageHandler) => messageHandler(message));
      }
    });
  }
  
  final HandlerMap _handlerMap;
}


